class VP8Format extends Format
	new: =>
		@displayName = "WebM"
		@supportsTwopass = true
		@videoCodec = "libvpx"
		@audioCodec = "libvorbis"
		@outputExtension = "webm"
		@acceptsBitrate = true

	getPreFilters: (backend) =>
		-- colormatrix filter
		colormatrixFilter =
			"bt.709": "bt709"
			"bt.2020": "bt2020"
			"smpte-240m": "smpte240m"
		ret = {}
		-- vp8 only supports bt.601, so add a conversion filter
		-- thanks anon
		colormatrix = mp.get_property_native("video-params/colormatrix")
		if colormatrixFilter[colormatrix]
			append(ret, {
				MpvFilter("lavfi-colormatrix",
					"@0": colormatrixFilter[colormatrix],
					"@1": "bt601")
			})
		return ret

	getFlags: (backend) =>
		switch backend.name
			when "mpv"
				return {"--ovcopts-add=threads=#{options.libvpx_threads}"}
			when "ffmpeg"
				return {"-threads", options.libvpx_threads}

formats["vp8"] = VP8Format!
