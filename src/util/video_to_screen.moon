-- most functions were shamelessly copypasted from occivink's mpv-scripts, changed to moonscript syntax
dimensions_changed = true
_video_dimensions = {}
-- Code that uses get_video_dimensions should observe the mpv properties that could affect
-- the resulting video dimensions, and call set_dimensions_changed when one of them change.
-- See CropPage for an example.
-- TODO maybe the observe property code should be here?
get_video_dimensions = ->
	return _video_dimensions unless dimensions_changed

	-- this function is very much ripped from video/out/aspect.c in mpv's source
	video_params = mp.get_property_native("video-out-params")
	return nil if not video_params

	dimensions_changed = false
	keep_aspect = mp.get_property_bool("keepaspect")
	w = video_params["w"]
	h = video_params["h"]
	dw = video_params["dw"]
	dh = video_params["dh"]
	if mp.get_property_number("video-rotate") % 180 == 90
		w, h = h, w
		dw, dh = dh, dw
	
	_video_dimensions = {
		top_left: {},
		bottom_right: {},
		ratios: {},
	}
	window_w, window_h = mp.get_osd_size()

	if keep_aspect
		unscaled = mp.get_property_native("video-unscaled")
		panscan = mp.get_property_number("panscan")

		fwidth = window_w
		fheight = math.floor(window_w / dw * dh)
		if fheight > window_h or fheight < h
			tmpw = math.floor(window_h / dh * dw)
			if tmpw <= window_w
				fheight = window_h
				fwidth = tmpw
		vo_panscan_area = window_h - fheight
		f_w = fwidth / fheight
		f_h = 1
		if vo_panscan_area == 0
			vo_panscan_area = window_h - fwidth
			f_w = 1
			f_h = fheight / fwidth

		if unscaled or unscaled == "downscale-big"
			vo_panscan_area = 0
			if unscaled or (dw <= window_w and dh <= window_h)
				fwidth = dw
				fheight = dh

		scaled_width = fwidth + math.floor(vo_panscan_area * panscan * f_w)
		scaled_height = fheight + math.floor(vo_panscan_area * panscan * f_h)

		split_scaling = (dst_size, scaled_src_size, zoom, align, pan) ->
			scaled_src_size = math.floor(scaled_src_size * 2 ^ zoom)
			align = (align + 1) / 2
			dst_start = math.floor((dst_size - scaled_src_size) * align + pan * scaled_src_size)
			if dst_start < 0
				--account for C int cast truncating as opposed to flooring
				dst_start = dst_start + 1
			dst_end = dst_start + scaled_src_size
			if dst_start >= dst_end
				dst_start = 0
				dst_end = 1
			return dst_start, dst_end

		zoom = mp.get_property_number("video-zoom")

		align_x = mp.get_property_number("video-align-x")
		pan_x = mp.get_property_number("video-pan-x")
		_video_dimensions.top_left.x, _video_dimensions.bottom_right.x = split_scaling(window_w, scaled_width, zoom, align_x, pan_x)

		align_y = mp.get_property_number("video-align-y")
		pan_y = mp.get_property_number("video-pan-y")
		_video_dimensions.top_left.y, _video_dimensions.bottom_right.y = split_scaling(window_h,  scaled_height, zoom, align_y, pan_y)
	else
		_video_dimensions.top_left.x = 0
		_video_dimensions.bottom_right.x = window_w
		_video_dimensions.top_left.y = 0
		_video_dimensions.bottom_right.y = window_h

	_video_dimensions.ratios.w = w / (_video_dimensions.bottom_right.x - _video_dimensions.top_left.x)
	_video_dimensions.ratios.h = h / (_video_dimensions.bottom_right.y - _video_dimensions.top_left.y)
	return _video_dimensions

set_dimensions_changed = () ->
	dimensions_changed = true

monitor_dimensions = () ->
	-- Monitor these properties, as they affect the video dimensions.
	-- Set the dimensions-changed flag when they change.
	properties = {
		"keepaspect",
		"video-out-params",
		"video-unscaled",
		"panscan",
		"video-zoom",
		"video-align-x",
		"video-pan-x",
		"video-align-y",
		"video-pan-y",
		"osd-width",
		"osd-height",
	}
	for _, p in ipairs(properties)
		mp.observe_property(p, "native", set_dimensions_changed)
