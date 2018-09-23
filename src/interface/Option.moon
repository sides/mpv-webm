class Option
	-- If optType is a "bool" or an "int", @value is the boolean/integer value of the option.
	-- Additionally, when optType is an "int":
	--     - opts.step specifies the step on which the values are changed.
	--     - opts.min specifies a minimum value for the option.
	--     - opts.max specifies a maximum value for the option.
	--     - opts.altDisplayNames is a int->string dict, which contains alternative display names
	--       for certain values.
	-- If optType is a "list", @value is the index of the current option, inside opts.possibleValues.
	-- opts.possibleValues is a array in the format
	-- {
	--		{value, displayValue}, -- Display value can be omitted.
	-- 		{value}
	-- }
	-- setValue will be called for the constructor argument.
	new: (optType, displayText, value, opts) =>
		@optType = optType
		@displayText = displayText
		@opts = opts
		@value = 1
		self\setValue(value)

	-- Whether we have a "previous" option (for left key)
	hasPrevious: =>
		switch @optType
			when "bool"
				return true
			when "int"
				if @opts.min
					return @value > @opts.min
				else
					return true
			when "list"
				return @value > 1

	-- Analogous of hasPrevious.
	hasNext: =>
		switch @optType
			when "bool"
				return true
			when "int"
				if @opts.max
					return @value < @opts.max
				else
					return true
			when "list"
				return @value < #@opts.possibleValues

	leftKey: =>
		switch @optType
			when "bool"
				@value = not @value
			when "int"
				@value -= @opts.step
				if @opts.min and @opts.min > @value
					@value = @opts.min
			when "list"
				@value -= 1 if @value > 1

	rightKey: =>
		switch @optType
			when "bool"
				@value = not @value
			when "int"
				@value += @opts.step
				if @opts.max and @opts.max < @value
					@value = @opts.max
			when "list"
				@value += 1 if @value < #@opts.possibleValues

	getValue: =>
		switch @optType
			when "bool"
				return @value
			when "int"
				return @value
			when "list"
				{value, _} = @opts.possibleValues[@value]
				return value

	setValue: (value) =>
		switch @optType
			when "bool"
				@value = value
			when "int"
				-- TODO Should we obey opts.min/max? Or just trust the script to do the right thing(tm)?
				@value = value
			when "list"
				set = false
				for i, possiblePair in ipairs @opts.possibleValues
					{possibleValue, _} = possiblePair
					if possibleValue == value
						set = true
						@value = i
						break
				if not set
					msg.warn("Tried to set invalid value #{value} to #{@displayText} option.")

	getDisplayValue: =>
		switch @optType
			when "bool"
				return @value and "yes" or "no"
			when "int"
				if @opts.altDisplayNames and @opts.altDisplayNames[@value]
					return @opts.altDisplayNames[@value]
				else
					return "#{@value}"
			when "list"
				{value, displayValue} = @opts.possibleValues[@value]
				return displayValue or value

	draw: (ass, selected) =>
		if selected
			ass\append("#{bold(@displayText)}: ")
		else
			ass\append("#{@displayText}: ")
		-- left arrow unicode
		ass\append("◀ ") if self\hasPrevious!
		ass\append(self\getDisplayValue!)
		-- right arrow unicode
		ass\append(" ▶") if self\hasNext!
		ass\append("\\N")
