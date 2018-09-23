-- Represents a video/audio/subtitle track.
class Track
	new: (track) =>
		@id = track["id"]
		-- Absolute index of the track. Using ff-index here isn't
		-- perfect but it should get the job done in most cases.
		@index = track["ff-index"] or 0
		@type = track["type"]
		@isExternal = track["external"]
		@externalFilename = @isExternal and track["external-filename"] or nil

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

class EncodingParameters
	new: =>
		-- {Format}
		-- The format to encode in.
		@format = nil

		-- {string}
		-- The path to the input stream.
		@inputPath = nil

		-- {string}
		-- The direct url to an external stream, provided
		-- e.g. by youtube-dl. `nil` if not an external
		-- stream.
		@inputStreamPath = nil

		-- {string}
		-- The output path the encoding will be written to.
		@outputPath = nil

		-- {number}
		-- The start time in milliseconds.
		@startTime = 0

		-- {number}
		-- The end time in milliseconds.
		@endTime = 0

		-- {Region}
		-- A region specifying how to crop the video. `nil`
		-- for no cropping.
		@crop = nil

		-- {Point}
		-- A point specifying how the video should be
		-- scaled. `nil` means no scaling and `-1` for
		-- either x or y means aspect ratio should be
		-- maintained.
		@scale = nil

		-- {Track}
		-- The video track to include. `nil` for no video.
		@videoTrack = nil

		-- {Track}
		-- The audio track to include. `nil` for no audio.
		@audioTrack = nil

		-- {Track}
		-- The subtitle track to include. `nil` for no
		-- subtitles.
		@subTrack = nil

		-- {number}
		-- The target bitrate in kB. `0` to disable.
		@bitrate = 0

		-- {number}
		-- The minimum allowed bitrate in kB. `0` to
		-- disable.
		@minBitrate = 0

		-- {number}
		-- The maximum allowed bitrate in kB. `0` to
		-- disable.
		@maxBitrate = 0

		-- {number}
		-- The target audio bitrate in kB. `0` to disable.
		@audioBitrate = 0

		-- {boolean}
		-- Whether or not to use two-pass encoding.
		@twopass = false

		-- {table}
		-- Key-value pairs of metadata to encode with.
		@metadata = {}

		-- {MpvFilter[]}
		-- A table of additional mpv filters that should be
		-- applied to the encoding, or attempted to.
		@mpvFilters = {}

		-- {string[]}
		-- Additional (backend-specific) flags.
		@flags = {}
