formats = {}

-- A basic format class, which specifies some fields to be set by child classes.
class Format
	new: =>
		@displayName = "Basic"
		@supportsTwopass = true
		@videoCodec = ""
		@audioCodec = ""
		@outputExtension = ""
		-- A kinda weird flag, but... whatever, I don't have a better name for it.
		@acceptsBitrate = true

	-- Filters that should be applied before the transformations we do (crop, scale)
	-- Should be a array of ffmpeg filters e.g. {"colormatrix=bt709", "sub"}.
	getPreFilters: (backend) => {}

	-- Similar to getPreFilters, but after our transformations.
	getPostFilters: (backend) => {}

	-- A list of flags, to be appended to the command line.
	getFlags: (backend) => {}
