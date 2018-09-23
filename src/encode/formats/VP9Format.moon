class VP9Format extends Format
	new: =>
		@displayName = "WebM (VP9)"
		@supportsTwopass = true
		@videoCodec = "libvpx-vp9"
		@audioCodec = "libvorbis"
		@outputExtension = "webm"
		@acceptsBitrate = true

	getFlags: (backend) =>
		switch backend.name
			when "mpv"
				return {"--ovcopts-add=threads=#{options.libvpx_threads}"}
			when "ffmpeg"
				return {"-threads", options.libvpx_threads}

formats["vp9"] = VP9Format!
