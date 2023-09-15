extends Node2D


var color_of_background_from_focus = Color(0, 0, 0, 0.92)


var _rects_to_draw : Array

func _ready():
	set_process(false)
	modulate.a = 0.0


func focus_draw_on_control(arg_control : Control, arg_margins_each_direction : float):
	var top_left_pos_of_focus_region = arg_control.rect_global_position - Vector2(arg_margins_each_direction, arg_margins_each_direction)
	var region_size = arg_control.rect_size + Vector2(arg_margins_each_direction * 2, arg_margins_each_direction * 2)
	
	#print("%s, %s" % [top_left_pos_of_focus_region, region_size])
	
	_calc_rects_to_draw(top_left_pos_of_focus_region, region_size)
	update()

func _calc_rects_to_draw(arg_top_left_pos : Vector2, arg_region_size : Vector2):
	var full_top_rect = Rect2(Vector2(0, 0), Vector2(960, arg_top_left_pos.y))
	
	var start_y_of_full_bot_rect = arg_top_left_pos.y + arg_region_size.y
	var full_bot_rect = Rect2(0, start_y_of_full_bot_rect, 960, 540 - start_y_of_full_bot_rect)
	
	var partial_left_rect = Rect2(Vector2(0, arg_top_left_pos.y), Vector2(arg_top_left_pos.x, arg_region_size.y))
	
	var start_x_of_partial_right_rect = arg_top_left_pos.x + arg_region_size.x
	var partial_right_rect = Rect2(Vector2(start_x_of_partial_right_rect, arg_top_left_pos.y), Vector2(960 - start_x_of_partial_right_rect, arg_region_size.y))
	
	
	_rects_to_draw.clear()
	_rects_to_draw.append(full_top_rect)
	_rects_to_draw.append(full_bot_rect)
	_rects_to_draw.append(partial_left_rect)
	_rects_to_draw.append(partial_right_rect)


func end_focus_draw():
	_rects_to_draw.clear()
	update()

##

func _draw():
	for rect in _rects_to_draw:
		draw_rect(rect, color_of_background_from_focus, true)
	

###############

func start_mod_a_tween(arg_mod_a_val, arg_duration, 
		arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params):
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", arg_mod_a_val, arg_duration)
	tween.tween_callback(arg_func_source, arg_func_name, [arg_func_params]).set_delay(arg_delay_for_func_call)




