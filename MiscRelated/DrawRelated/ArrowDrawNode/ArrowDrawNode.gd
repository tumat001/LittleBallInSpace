extends Node2D


signal all_draw_params_finished()


var _all_draw_params : Array


class DrawParams:
	
	var head_wing_thickness : float
	var head_wing_length : float
	var head_wing_angle_modif_from_stalk_angle : float = PI/4
	var head_color : Color
	
	var stalk_half_width : float
	var stalk_half_length : float
	# Angle of 0 means pointing UP
	var stalk_point_angle : float = 0.0
	var stalk_color : Color
	
	var stalk_midpoint_pos : Vector2
	
	#
	
	var _current_lifetime : float = 0
	var lifetime_of_draw : float
	var has_lifetime : bool = true
	

#######

func _ready():
	set_process(false)


func add_draw_param(arg_draw_param : DrawParams):
	arg_draw_param.configure_properties()
	_all_draw_params.append(arg_draw_param)
	
	set_process(true)

func remove_draw_param(arg_draw_param : DrawParams):
	_all_draw_params.erase(arg_draw_param)
	
	if _all_draw_params.size() == 0:
		set_process(false)
		
		update()
		emit_signal("all_draw_params_finished")

func remove_all_draw_params():
	_all_draw_params.clear()
	
	set_process(false)
	update()
	emit_signal("all_draw_params_finished")


func has_draw_param():
	return _all_draw_params.size() > 0
	

func get_all_draw_params():
	return _all_draw_params

###

func _process(delta):
	for param in _all_draw_params:
		if param.has_lifetime:
			param._current_lifetime += delta
		
		if param.lifetime_of_draw <= param._current_lifetime:
			remove_draw_param(param)
	
	update()

#############

func _draw() -> void:
	for param in _all_draw_params:
		_draw_arrow_param(param)
	

func _draw_arrow_param(arg_param : DrawParams):
	_draw_arrow_param__stalk_portion(arg_param)
	_draw_arrow_param__head_portion(arg_param)


func _draw_arrow_param__stalk_portion(arg_param : DrawParams):
	var rect = Rect2(arg_param.stalk_midpoint_pos, Vector2(arg_param.stalk_half_width, arg_param.stalk_half_length))
	
	draw_set_transform(Vector2(0, 0), arg_param.stalk_point_angle, Vector2(1, 1))
	draw_rect(rect, arg_param.stalk_color, true, 0.0)


func _draw_arrow_param__head_portion(arg_param : DrawParams):
	var raw__head_point_at_stalk__left : Vector2 = Vector2(-arg_param.stalk_half_width, arg_param.stalk_half_length)
	var raw__head_point_at_stalk__right : Vector2 = Vector2(arg_param.stalk_half_width, arg_param.stalk_half_length)
	
	var wing_line__to_left := Vector2(-arg_param.head_wing_length, 0).rotated(-arg_param.head_wing_angle_modif_from_stalk_angle)
	var wing_line__to_right := Vector2(arg_param.head_wing_length, 0).rotated(arg_param.head_wing_angle_modif_from_stalk_angle)
	var raw__upper_wing_point__left := raw__head_point_at_stalk__left + wing_line__to_left
	var raw__upper_wing_point__right := raw__head_point_at_stalk__right + wing_line__to_right
	
	var wing_line_thickness_rotated := Vector2(0, -arg_param.head_wing_thickness).rotated(arg_param.stalk_point_angle)
	var raw__lower_wing_point__left := raw__upper_wing_point__left + wing_line_thickness_rotated
	var raw__lower_wing_point__right := raw__upper_wing_point__right + wing_line_thickness_rotated
	
	var raw__lower_head_point_at_stalk__left := raw__head_point_at_stalk__left - Vector2(0, arg_param.head_wing_thickness)
	var raw__lower_head_point_at_stalk__right := raw__head_point_at_stalk__right - Vector2(0, arg_param.head_wing_thickness)
	
	
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1, 1))
	
	var left_head__vec_array = [raw__head_point_at_stalk__left, raw__upper_wing_point__left, raw__lower_wing_point__left, raw__lower_head_point_at_stalk__left]
	var left_head__pool_vec_array = PoolVector2Array(left_head__vec_array)
	draw_colored_polygon(left_head__pool_vec_array, arg_param.head_color)
	
	var right_head__vec_array = [raw__head_point_at_stalk__right, raw__upper_wing_point__right, raw__lower_wing_point__right, raw__lower_head_point_at_stalk__right]
	var right_head__pool_vec_array = PoolVector2Array(right_head__vec_array)
	draw_colored_polygon(right_head__pool_vec_array, arg_param.head_color)
	
