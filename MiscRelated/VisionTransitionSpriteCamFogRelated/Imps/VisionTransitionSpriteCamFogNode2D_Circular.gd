tool
extends "res://MiscRelated/VisionTransitionSpriteCamFogRelated/AbstractVisionTransitionSpriteCamFogNode2D.gd"

#

signal progress_one_to_zero_ratio_changed(arg_ratio)

#

export(float) var circle_ratio__outside_of_outer_ring : float = 0.0
export(float) var circle_ratio__inside_of_outer_ring : float = 0.0
export(float) var circle_ratio__inside_of_inner_ring : float = 0.8


#

var _transition_sprite

var _current_circle_ratio

#

func _ready():
	if !Engine.editor_hint:
		_attempt_construct_transition_sprite()
		

func _attempt_construct_transition_sprite():
	if SingletonsAndConsts.current_game_elements.is_game_front_hud_initialized:
		_construct_transition_sprite()
	else:
		SingletonsAndConsts.current_game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized__for_sprite_constr", [], CONNECT_ONESHOT)

func _on_game_front_hud_initialized__for_sprite_constr(arg_hud):
	_construct_transition_sprite()


func _construct_transition_sprite():
	_transition_sprite = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK)
	transition_sprite__for_mod_a = _transition_sprite
	
	_transition_sprite.is_custom_controlled__avoid_auto_tweens = true
	
	_transition_sprite.initial_ratio = 0.0
	_transition_sprite.target_ratio = 0.0
	_transition_sprite.wait_at_start = 0.0
	_transition_sprite.duration = 1
	_transition_sprite.trans_type = Tween.TRANS_BOUNCE
	#SingletonsAndConsts.current_master.play_transition__alter_no_states(_transition_sprite)
	
	_transition_sprite.queue_free_on_end_of_transition = false
	#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(_transition_sprite)
	SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(_transition_sprite)
	_transition_sprite.start_transition()
	_transition_sprite.modulate.a = 0.0

#

func get_transition_sprite():
	return _transition_sprite

###

func _exit_tree():
	queue_free_transition_sprite()

func queue_free_transition_sprite():
	if is_instance_valid(_transition_sprite):
		_transition_sprite.queue_free()

#

func _player_is_outside_of_outer_ring(arg_dist):
	._player_is_outside_of_outer_ring(arg_dist)
	set_transition_sprite_circle_ratio(circle_ratio__outside_of_outer_ring)
	
	emit_signal("progress_one_to_zero_ratio_changed", 0.0)

func _player_is_inside_of_outer_ring(arg_dist):
#	_set_transition_sprite_circle_ratio__dist__inside_of_outer_ring(arg_dist)
#	var circle_ratio = _tween_for_intervalue.interpolate_value(circle_ratio__inside_of_outer_ring, (circle_ratio__inside_of_outer_ring - circle_ratio__inside_of_inner_ring), (outer_ring__radius_start_of_fog - inner_ring__radius_max_fog), (arg_dist - inner_ring__radius_max_fog), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	set_transition_sprite_circle_ratio(circle_ratio)
	._player_is_inside_of_outer_ring(arg_dist)
	
	var circle_ratio = _tween_for_intervalue.interpolate_value(circle_ratio__inside_of_outer_ring, (circle_ratio__inside_of_inner_ring - circle_ratio__inside_of_outer_ring), (arg_dist - inner_ring__radius_max_fog), (outer_ring__radius_start_of_fog - inner_ring__radius_max_fog), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	circle_ratio = (1 + circle_ratio__inside_of_inner_ring) - circle_ratio
	set_transition_sprite_circle_ratio(circle_ratio)
	
	var prog_ratio = _tween_for_intervalue.interpolate_value(1.0, -1.0, (arg_dist - inner_ring__radius_max_fog), (outer_ring__radius_start_of_fog - inner_ring__radius_max_fog), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	emit_signal("progress_one_to_zero_ratio_changed", prog_ratio)

func _player_is_inside_of_inner_ring(arg_dist):
	._player_is_inside_of_inner_ring(arg_dist)
	set_transition_sprite_circle_ratio(circle_ratio__inside_of_inner_ring)
	
	emit_signal("progress_one_to_zero_ratio_changed", 1.0)


func set_transition_sprite_circle_ratio(arg_circle_ratio):
	_transition_sprite.set_circle_ratio(arg_circle_ratio)
	_current_circle_ratio = arg_circle_ratio


##

func _lift_and_end_fog__using_tween__for_imps(arg_tween : SceneTreeTween, arg_duration_for_end, arg_tween_trans = Tween.TRANS_LINEAR, arg_ease = Tween.EASE_IN):
	arg_tween.tween_method(self, "set_transition_sprite_circle_ratio", _current_circle_ratio, 1.0, arg_duration_for_end).set_trans(arg_tween_trans).set_ease(arg_ease)
	


