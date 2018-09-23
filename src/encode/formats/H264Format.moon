class H264Format extends Format
	new: =>
		@displayName = "H.264"
		@supportsTwopass = true
		@videoCodec = "libx264"
		@audioCodec = "aac"
		@outputExtension = "mp4"
		@acceptsBitrate = true

	getFlags: (backend) =>
		switch backend.name
			when "mpv"
				return {"--ovcopts-add=preset=#{options.libx264_preset}"}
			when "ffmpeg"
				return {"-preset", options.libx264_preset}

formats["h264"] = H264Format!
