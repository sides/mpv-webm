-- Stores a point in the video, relative to the source resolution.
class VideoPoint extends Point
	set_from_screen: (sx, sy) =>
		d = get_video_dimensions!
		point = clamp_point(d.top_left, {x: sx, y: sy}, d.bottom_right)
		@x = math.floor(d.ratios.w * (point.x - d.top_left.x) + 0.5)
		@y = math.floor(d.ratios.h * (point.y - d.top_left.y) + 0.5)

	to_screen: =>
		d = get_video_dimensions!
		return {
			x: math.floor(@x / d.ratios.w + d.top_left.x + 0.5),
			y: math.floor(@y / d.ratios.h + d.top_left.y + 0.5)
		}
