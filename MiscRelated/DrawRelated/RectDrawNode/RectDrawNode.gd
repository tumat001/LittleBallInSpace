extends Node2D


class DrawParams:
	
	var initial_rect : Rect2
	var target_rect : Rect2
	var _current_rect : Rect2
	
	var fill_color : Color
	
	var outline_color : Color
	var outline_width : float = 0
	
	var _current_lifetime : float = 0 setget set_current_lifetime
	var lifetime_of_draw : float
	var lifetime_to_start_transparency : float
	var has_lifetime : bool
	
	var remove_self_at_max_lifetime : bool = false
	
	var _current_rect_pos_per_sec : Vector2
	var _current_rect_end_per_sec : Vector2
	
	var angle_rad : float
	var pivot_point : Vector2
	
	#
	
	var _outline_transparency_per_sec : float
	var _fill_transparency_per_sec : float
	
	#
	
	func set_current_lifetime(arg_val):
		_current_lifetime = arg_val
		
		if _current_lifetime >= lifetime_of_draw:
			_current_lifetime = lifetime_of_draw
	
	
	func configure_properties():
		if lifetime_to_start_transparency != -1:
			_outline_transparency_per_sec = outline_color.a / (lifetime_of_draw - lifetime_to_start_transparency)
			_fill_transparency_per_sec = fill_color.a / (lifetime_of_draw - lifetime_to_start_transparency)
		else:
			_outline_transparency_per_sec = 0
			_fill_transparency_per_sec = 0
		
		_current_lifetime = 0
		_current_rect = initial_rect
		
		
		_current_rect_pos_per_sec = (target_rect.position - initial_rect.position) / lifetime_of_draw
		_current_rect_end_per_sec = (target_rect.end - initial_rect.end) / lifetime_of_draw
		
		#print("current rect pos: %s, current rect end: %s" % [_current_rect_pos_per_sec, _current_rect_end_per_sec])
	
	


var _all_draw_params : Array

var pause_lifetime_of_all_draws : bool = false


#####

func _ready():
	#z_index = ZIndexStore.PARTICLE_EFFECTS
	#z_as_relative = false
	
	set_process(false)


func add_draw_param(arg_draw_param : DrawParams):
	arg_draw_param.configure_properties()
	_all_draw_params.append(arg_draw_param)
	
	set_process(true)

func remove_draw_param(arg_draw_param : DrawParams):
	_all_draw_params.erase(arg_draw_param)
	
	arg_draw_param.unconfigure_self_from_all()
	
	if _all_draw_params.size() == 0:
		set_process(false)

#####


func _process(delta):
	for _u_param in _all_draw_params:
		var param : DrawParams = _u_param
		
		if !pause_lifetime_of_all_draws and param.has_lifetime:
			param._current_lifetime += delta
		
		#param._current_rect.position = param.initial_rect.position + (param._current_rect_pos_per_sec * param._current_lifetime)
		#param._current_rect.end = param.initial_rect.end + (param._current_rect_end_per_sec * param._current_lifetime)
		
		if param.lifetime_to_start_transparency <= param._current_lifetime:
			param.fill_color.a -= param._fill_transparency_per_sec * delta
			param.outline_color.a -= param._outline_transparency_per_sec * delta
		
		if param.lifetime_of_draw <= param._current_lifetime and param.remove_self_at_max_lifetime:
			remove_draw_param(param)
		
		
		#print("pos: %s, end: %s" % [param._current_rect.position.rotated(param.angle_rad), param._current_rect.end.rotated(param.angle_rad)])
	
	update()


func _draw():
	for param in _all_draw_params:
		
		draw_set_transform(param.pivot_point, param.angle_rad, Vector2(1, 1))
		
		var rect = param._current_rect
		#rect.position -= param._current_rect.get_center()
		#rect.end -= param._current_rect.get_center()
		
		draw_rect(rect, param.fill_color, true)
		if param.outline_width != 0:
			draw_rect(rect, param.outline_color, false, param.outline_width)
		




