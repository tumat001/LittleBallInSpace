extends "res://_NonMainGameRelateds/_Master/TransitionsRelated/AbstractTransitionSprite.gd"


signal circle_ratio_changed(arg_ratio)


var screen_size = Vector2(960, 540)
var circle_center : Vector2 = screen_size / 2


var initial_ratio : float
var target_ratio : float

var duration : float = 0.35

var wait_at_end : float

var wait_at_start : float = 0

#

var modulate_at_end : Color

#

var _curr_tweener : SceneTreeTween

var trans_type = Tween.TRANS_LINEAR
var ease_type = Tween.EASE_IN

####

func _ready():
	material = ShaderMaterial.new()
	material.shader = preload("res://MiscRelated/ShadersRelated/Shader_CircleTransition.tres")


func start_transition():
	.start_transition()
	
	_configure_properties_for_shader()
	_configure_modulate_tweener()


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
	
	if !is_custom_controlled__avoid_auto_tweens:
		var tweener = create_tween()
		tweener.set_parallel(false)
		tweener.tween_method(self, "_tween_circle_size_of_shader", initial_ratio, target_ratio, duration).set_trans(trans_type).set_ease(ease_type).set_delay(wait_at_start)
		tweener.tween_callback(self, "_finished_tween").set_delay(wait_at_end)
		_curr_tweener = tweener

func _get_distance_vec_of_screen_center_from_circle_center():
	var dist_vec = circle_center - (screen_size / 2)
	return Vector2(abs(dist_vec.x), abs(dist_vec.y))
	

func _get_distance_vec_of_screen_center_from_circle_center__with_dir():
	return circle_center - (screen_size / 2)



func _tween_circle_size_of_shader(arg_ratio):
	#material.set_shader_param("circle_size", arg_ratio)
	set_circle_ratio(arg_ratio)

func set_circle_ratio(arg_ratio):
	material.set_shader_param("circle_size", arg_ratio)
	
	emit_signal("circle_ratio_changed", arg_ratio)

func _finished_tween():
	_on_end_of_transition()
	

#

func set_is_transition_paused(arg_val):
	.set_is_transition_paused(arg_val)
	
	if arg_val:
		_curr_tweener.pause()
	else:
		_curr_tweener.play()

##

func _configure_modulate_tweener():
	
	if modulate != modulate_at_end and !is_custom_controlled__avoid_auto_tweens:
		var tweener = create_tween()
		tweener.set_parallel(true)
		
		tweener.tween_property(self, "modulate:r", modulate_at_end.r, duration).set_delay(wait_at_start)
		tweener.tween_property(self, "modulate:g", modulate_at_end.g, duration).set_delay(wait_at_start)
		tweener.tween_property(self, "modulate:b", modulate_at_end.b, duration).set_delay(wait_at_start)
		tweener.tween_property(self, "modulate:a", modulate_at_end.a, duration).set_delay(wait_at_start)
		
		tweener.set_parallel(false)
		#tweener.tween_callback(self, "finished_with_fade_inses")



