extends Reference

const _size_to_texture_map : Dictionary = {}
const _color_pair__to_gradient_map : Dictionary = {}


##########

static func construct_or_get_rect_gradient_texture(arg_size : Vector2) -> GradientTexture2D:
	if _size_to_texture_map.has(arg_size):
		return _size_to_texture_map[arg_size]
		
	
	var texture = GradientTexture2D.new()
	
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.9, 0.9)
	
	texture.flags = GradientTexture2D.FLAG_MIPMAPS | GradientTexture2D.FLAG_FILTER
	
	texture.width = arg_size.x
	texture.height = arg_size.y
	
	
	if !_size_to_texture_map.has(arg_size):
		_size_to_texture_map[arg_size] = texture
		
	
	return texture


static func construct_or_get_gradient_two_color(arg_color_start_center, arg_color_end):
	for pair in _color_pair__to_gradient_map.keys():
		if pair[0] == arg_color_start_center and pair[1] == arg_color_end:
			return _color_pair__to_gradient_map[pair]
	
	var gradient = Gradient.new()
	# we use set_color because default starts with two colors
	gradient.set_color(0, arg_color_start_center)
	gradient.set_color(1, arg_color_end)
	
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	
	var pair = [arg_color_start_center, arg_color_end]
	_color_pair__to_gradient_map[pair] = gradient
	
	return gradient
	
