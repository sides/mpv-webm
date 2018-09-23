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
