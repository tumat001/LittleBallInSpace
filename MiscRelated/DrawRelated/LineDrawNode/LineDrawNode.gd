extends Node2D


class DrawParams:
	var angle : float
	var center_pos : Vector2
	var length : float
	var color : Color
	var width : float
	

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


###

func _process(delta):
	update()

func _draw():
	for param in _all_draw_params:
		var dest_pos = param.center_pos + Vector2(param.length, 0).rotated(param.angle)
		draw_line(param.center_pos, dest_pos, param.color, param.width)

