class EncodeOptionsPage extends Page
	new: (callback) =>
		@callback = callback
		@currentOption = 1
		-- TODO this shouldn't be here.
		scaleHeightOpts =
			possibleValues: {{-1, "no"}, {240}, {360}, {480}, {720}, {1080}, {1440}, {2160}}
		filesizeOpts =
			step: 250
			min: 0
			altDisplayNames:
				[0]: "disabled"

		-- I really dislike hardcoding this here, but, as said below, order in dicts isn't
		-- guaranteed, and we can't use the formats dict keys.
		formatIds = {"webm-vp8", "webm-vp9", "hevc-h264", "raw"}
		formatOpts =
			possibleValues: [{fId, formats[fId].displayName} for fId in *formatIds]

		-- This could be a dict instead of a array of pairs, but order isn't guaranteed
		-- by dicts on Lua.
		@options = {
			{"output_format", Option("list", "Output Format", options.output_format, formatOpts)}
			{"twopass", Option("bool", "Two Pass", options.twopass)},
			{"apply_current_filters", Option("bool", "Apply Current Video Filters", options.apply_current_filters)}
			{"scale_height", Option("list", "Scale Height", options.scale_height, scaleHeightOpts)},
			{"strict_filesize_constraint", Option("bool", "Strict Filesize Constraint", options.strict_filesize_constraint)},
			{"write_filename_on_metadata", Option("bool", "Write Filename on Metadata", options.write_filename_on_metadata)},
			{"target_filesize", Option("int", "Target Filesize", options.target_filesize, filesizeOpts)}
		}

		@keybinds =
			"LEFT": self\leftKey
			"RIGHT": self\rightKey
			"UP": self\prevOpt
			"DOWN": self\nextOpt
			"ENTER": self\confirmOpts
			"ESC": self\cancelOpts

	getCurrentOption: =>
		return @options[@currentOption][2]

	leftKey: =>
		(self\getCurrentOption!)\leftKey!
		self\draw!

	rightKey: =>
		(self\getCurrentOption!)\rightKey!
		self\draw!

	prevOpt: =>
		@currentOption = math.max(1, @currentOption - 1)
		self\draw!

	nextOpt: =>
		@currentOption = math.min(#@options, @currentOption + 1)
		self\draw!

	confirmOpts: =>
		for _, optPair in ipairs @options
			{optName, opt} = optPair
			-- Set the global options object.
			options[optName] = opt\getValue!
		self\hide!
		self.callback(true)

	cancelOpts: =>
		self\hide!
		self.callback(false)

	draw: =>
		window_w, window_h = mp.get_osd_size()
		ass = assdraw.ass_new()
		ass\new_event()
		self\setup_text(ass)
		ass\append("#{bold('Options:')}\\N\\N")
		for i, optPair in ipairs @options
			opt = optPair[2]
			opt\draw(ass, @currentOption == i)
		ass\append("\\N▲ / ▼: navigate\\N")
		ass\append("#{bold('ENTER:')} confirm options\\N")
		ass\append("#{bold('ESC:')} cancel\\N")
		mp.set_osd_ass(window_w, window_h, ass.text)
