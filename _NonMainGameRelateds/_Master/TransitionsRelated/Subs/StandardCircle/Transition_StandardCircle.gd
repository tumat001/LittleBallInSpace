extends "res://_NonMainGameRelateds/_Master/TransitionsRelated/AbstractTransitionSprite.gd"


var screen_size = Vector2(960, 540)
var circle_center : Vector2 = screen_size / 2


var initial_ratio : float
var target_ratio : float

var duration : float = 0.35

var wait_at_end : float

var wait_at_start : float = 0

#

var trans_type = Tween.TRANS_LINEAR
var ease_type = Tween.EASE_IN

####

func start_transition():
	.start_transition()
	
	_configure_properties_for_shader()
	


func _configure_properties_for_shader():
	var dist_vec = _get_distance_vec_of_screen_center_from_circle_center()
	var total_vec = screen_size + dist_vec + dist_vec
	
	var dist_vec_with_dir = _get_distance_vec_of_screen_center_from_circle_center__with_dir()
	var total_vec_with_dir = screen_size + dist_vec_with_dir + dist_vec_with_dir
	
	scale = total_vec
	position = circle_center + (total_vec / 2)
	
	material.set_shader_param("screen_width", total_vec.x)
	material.set_shader_param("screen_height", total_vec.y)
	material.set_shader_param("circle_size", initial_ratio)
	
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_method(self, "_tween_circle_size_of_shader", initial_ratio, target_ratio, duration).set_trans(trans_type).set_ease(ease_type).set_delay(wait_at_start)
	tweener.tween_callback(self, "_finished_tween").set_delay(wait_at_end)

func _get_distance_vec_of_screen_center_from_circle_center():
	var dist_vec = circle_center - (screen_size / 2)
	return Vector2(abs(dist_vec.x), abs(dist_vec.y))
	

func _get_distance_vec_of_screen_center_from_circle_center__with_dir():
	return circle_center - (screen_size / 2)



func _tween_circle_size_of_shader(arg_ratio):
	material.set_shader_param("circle_size", arg_ratio)
	

func _finished_tween():
	_on_end_of_transition()
	



