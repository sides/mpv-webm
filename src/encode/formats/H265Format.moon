class H265Format extends H264Format
	new: =>
		@displayName = "HEVC"
		@supportsTwopass = true
		@videoCodec = "libx265"
		@audioCodec = "aac"
		@outputExtension = "mp4"
		@acceptsBitrate = true

formats["h265"] = H265Format!
