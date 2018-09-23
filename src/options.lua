local mpopts = require("mp.options")
local options = {
	-- Defaults to shift+w
	keybind = "W",
	-- If empty, saves on the same directory of the playing video.
	-- A starting "~" will be replaced by the home dir.
	output_directory = "",
	run_detached = false,
	-- Template string for the output file
	-- %f - Filename, with extension
	-- %F - Filename, without extension
	-- %T - Media title, if it exists, or filename, with extension (useful for some streams, such as YouTube).
	-- %s, %e - Start and end time, with milliseconds
	-- %S, %E - Start and time, without milliseconds
	-- %M - "-audio", if audio is enabled, empty otherwise
	output_template = "%F-[%s-%e]%M",
	-- Scale video to a certain height, keeping the aspect ratio. -1 disables it.
	scale_height = -1,
	-- Target filesize, in kB.
	target_filesize = 2500,
	-- If true, will use stricter flags to ensure the resulting file doesn't
	-- overshoot the target filesize. Not recommended, as constrained quality
	-- mode should work well, unless you're really having trouble hitting
	-- the target size.
	strict_filesize_constraint = false,
	strict_bitrate_multiplier = 0.95,
	-- In kilobits.
	strict_audio_bitrate = 64,
	-- Sets the output format, from a few predefined ones.
	-- Currently we have webm-vp8 (libvpx/libvorbis), webm-vp9 (libvpx-vp9/libvorbis)
	-- and raw (rawvideo/pcm_s16le).
	output_format = "webm-vp8",
	-- The encoding backend to use. Currently supports mpv and ffmpeg.
	backend = "mpv",
	-- Location to the backend executable. Leave blank to have this fall back on the backend option.
	backend_location = "",
	twopass = false,
	-- If set, applies the video filters currently used on the playback to the encode.
	apply_current_filters = true,
	-- If set, writes the video's filename to the "Title" field on the metadata.
	write_filename_on_metadata = false,
	-- Set the number of encoding threads, for codecs libvpx and libvpx-vp9
	libvpx_threads = 4,
	libx264_preset: "veryfast",
	additional_flags = "",
	-- Useful for flags that may impact output filesize, such as crf, qmin, qmax etc
	-- Won't be applied when strict_filesize_constraint is on.
	non_strict_additional_flags = "--ovcopts-add=crf=10",
	-- The font size used in the menu. Isn't used for the notifications (started encode, finished encode etc)
	font_size = 28,
	margin = 10,
	message_duration = 5
}

mpopts.read_options(options)
