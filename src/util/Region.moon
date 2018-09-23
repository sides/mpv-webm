-- Stores a video region. Used with VideoPoint to translate between screen and source coordinates. See CropPage.
class Region
	@makeFullscreen: ->
		r = @@!
		d = get_video_dimensions!
		a = VideoPoint!
		b = VideoPoint!
		{x: xa, y: ya} = d.top_left
		a\set_from_screen(xa, ya)
		{x: xb, y: yb} = d.bottom_right
		b\set_from_screen(xb, yb)
		r\set_from_points(a, b)
		return r

	new: =>
		@x = -1
		@y = -1
		@w = -1
		@h = -1

	is_valid: =>
		@x > -1 and @y > -1 and @w > -1 and @h > -1

	set_from_points: (p1, p2) =>
		@x = math.min(p1.x, p2.x)
		@y = math.min(p1.y, p2.y)
		@w = math.abs(p1.x - p2.x)
		@h = math.abs(p1.y - p2.y)
