extends Node2D


class DrawParams:
	var angle : float
	var center_pos : Vector2
	var length : float
	var color : Color
	var width : float
	
	var remove_self_if_length_is_or_below_zero : bool = true
	

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
		if param.length > 0:
			var dest_pos = param.center_pos + Vector2(param.length, 0).rotated(param.angle)
			draw_line(param.center_pos, dest_pos, param.color, param.width)
			
		else:
			if param.remove_self_if_length_is_or_below_zero:
				remove_draw_param(param)
