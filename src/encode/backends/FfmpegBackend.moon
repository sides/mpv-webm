class FfmpegBackend extends Backend
	new: =>
		@name = "ffmpeg"

	escapeQuotes: (str) =>
		return str\gsub("\"", "\\\"")

	-- Turn `MpvFilter`s into command line options.
	solveFilters: (filters) =>
		solved = {}
		for filter in *filters
			if not filter.lavfiCompat
				continue
			str = filter.name .. "="
			ordered_params = {}
			highest_n = 0
			for k, v in pairs filter.params
				-- @n keys dictate the order of keyless params. Sort them here.
				param_n = tonumber(string.match(k, "^@(%d+)$"))
				if param_n ~= nil
					ordered_params[param_n] = v
					if param_n > highest_n
						highest_n = param_n
				else
					str ..= "#{k}=#{v}:"
			for i = 0, highest_n
				if ordered_params[i] ~= nil
					str ..= "#{ordered_params[i]}:"
			solved[#solved+1] = string.sub(str, 0, string.len(str) - 1)
		return solved

	buildCommand: (params) =>
		format = params.format

		-- Build the base command.
		command = {get_backend_location!, "-y"}

		-- Based on whether this is a (youtube-dl) stream or not, inputs are handled
		-- differently.
		ss = seconds_to_time_string(params.startTime, false, true)
		if params.inputStreamPath ~= nil
			-- Assume the video track is what mpv considers to be the main track...
			-- Not sure if this is correct, but it seems consistent from using youtube-dl
			-- on multiple sites.
			adhocVideoTrack = Track({})
			adhocVideoTrack.isExternal = true
			adhocVideoTrack.externalFilename = params.inputStreamPath
			-- Append all our external inputs.
			for _,track in ipairs {adhocVideoTrack, params.audioTrack, params.subTrack}
				if track ~= nil and track.isExternal and track.externalFilename
					append(command, {"-ss", ss, "-i", track.externalFilename})
		else
			-- Append the base input.
			append(command, {"-ss", ss, "-i", params.inputPath})
			-- Append the track mappings for subtitles.
			if params.subTrack ~= nil
				-- If we have external subtitles, add them as input first.
				if params.subTrack.isExternal
					if params.subTrack.externalFilename
						append(command, {
							"-ss", ss, "-i", params.subTrack.externalFilename,
							"-map", "1:#{params.subTrack.index}"
						})
				else
					append(command, {"-map", "0:#{params.subTrack.index}"})
			-- Append the track mappings for video/audio.
			for _,track in ipairs {params.videoTrack, params.audioTrack}
				if track ~= nil
					append(command, {"-map", "0:#{track.index}"})

		-- Append the duration timing.
		append(command, {"-t", tostring(params.endTime - params.startTime)})

		-- Append our video/audio codecs.
		append(command, {
			"-c:v", "#{format.videoCodec}",
			"-c:a", "#{format.audioCodec}"
		})

		-- Append filters: Prefilters from the format, raw filters from the parameters, cropping
		-- and scaling filters, and postfilters from the format.
		-- Begin by solving them from our parameters.
		filters = {}
		append(filters, self\solveFilters(format\getPreFilters self))
		append(filters, self\solveFilters(params.mpvFilters))
		if params.crop
			filters[#filters+1] = "crop=#{params.crop.w}:#{params.crop.h}:#{params.crop.x}:#{params.crop.y}"
		if params.scale
			filters[#filters+1] = "scale=#{params.scale.x}:#{params.scale.y}"
		append(filters, self\solveFilters(format\getPostFilters self))
		-- Then append them to the command.
		append(command, {
			"-vf", table.concat(filters, ",")
		})

		for k, v in pairs params.metadata
			append(command, {
				"-metadata", "#{k}=\"#{self\escapeQuotes(v)}\""
			})

		-- Append any extra flags the format wants.
		append(command, format\getFlags self)

		-- Append bitrate options.
		if format.acceptsBitrate
			if params.audioBitrate ~= 0
				append(command, {"-b:a", "#{params.audioBitrate}K"})
			if params.bitrate ~= 0
				append(command, {"-b:v", "#{params.bitrate}K"})
			if params.minBitrate ~= 0
				append(command, {"-minrate", "#{params.minBitrate}K"})
			if params.maxBitrate ~= 0
				append(command, {"-maxrate", "#{params.maxBitrate}K"})

		-- Append user-passed flags.
		for flag in *params.flags
			command[#command+1] = flag

		-- If two-pass is go, do the first pass now with the current command. Note: This
		-- ignores the user option to run the encoding process detached (for the first pass).
		if params.twopass and format.supportsTwopass
			-- copy the commandline
			first_pass_cmdline = [arg for arg in *command]
			append(first_pass_cmdline, {
				"-pass", "1",
				get_null_path!
			})
			message("Starting first pass...")
			msg.verbose("First-pass command line: ", table.concat(first_pass_cmdline, " "))
			res = run_subprocess({args: first_pass_cmdline, cancellable: false})
			if not res
				message("First pass failed! Check the logs for details.")
				return nil
			-- set the second pass flag on the final encode command
			append(command, {
				"-pass", "2"
			})

		-- Append the output path. It's assumed elsewhere that this parameter IS the output
		-- path. Not wise to modify it here!
		append(command, {params.outputPath})

		return command

backends["ffmpeg"] = FfmpegBackend!
