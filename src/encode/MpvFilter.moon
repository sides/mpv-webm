-- Represents an mpv video/audio filter.
class MpvFilter
	@isBuiltin: (name) ->
		-- mpv --vf=help
		(name == "format" or
		name == "sub" or
		name == "convert" or
		name == "d3d11vpp" or
		-- mpv --af=help
		name == "lavcac3enc" or
		name == "lavrresample" or
		name == "rubberband" or
		name == "scaletempo")

	new: (name, params={}) =>
		@lavfiCompat = not @@.isBuiltin(name)
		if string.sub(name,1,6)=="lavfi-" then
			@name = string.sub(name,7,string.len(name))
		else
			@name = name
		@params = params
