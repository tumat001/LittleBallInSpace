extends Node2D


class DrawParams:
	var angle : float
	var texture_scale : Vector2 = Vector2.ONE
	var texture_offset : Vector2 = Vector2.ZERO
	
	var center_pos : Vector2
	var texture : Texture
	var texture_modulate : Color = Color(1, 1, 1, 1)
	


var _all_draw_params : Array



func _ready():
	set_process(false)


func add_draw_param(arg_draw_param : DrawParams):
	#arg_draw_param.configure_properties()
	_all_draw_params.append(arg_draw_param)
	
	set_process(true)

func remove_draw_param(arg_draw_param : DrawParams):
	_all_draw_params.erase(arg_draw_param)
	
	if _all_draw_params.size() == 0:
		set_process(false)
		
		update()

func remove_all_draw_params():
	if _all_draw_params.size() != 0:
		_all_draw_params.clear()
		set_process(false)
		update()

func get_all_draw_params():
	return _all_draw_params

###

func _process(delta):
	update()

func _draw():
	for param in _all_draw_params:
		draw_set_transform(param.center_pos - param.texture.get_size()/2, param.angle, param.texture_scale)
		draw_texture(param.texture, Vector2.ZERO, param.texture_modulate)
		
		#draw_set_transform(param.texture_offset, param.angle, param.texture_scale)
		#draw_texture(param.texture, param.center_pos - param.texture.get_size()/2, param.texture_modulate)



