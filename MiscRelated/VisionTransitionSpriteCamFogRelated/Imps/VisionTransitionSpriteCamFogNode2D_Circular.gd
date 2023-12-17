tool
extends "res://MiscRelated/VisionTransitionSpriteCamFogRelated/AbstractVisionTransitionSpriteCamFogNode2D.gd"

#

export(float) var circle_ratio__outside_of_outer_ring : float = 0.0
export(float) var circle_ratio__inside_of_outer_ring : float = 0.0
export(float) var circle_ratio__inside_of_inner_ring : float = 0.8


#

var _transition_sprite

#

func _ready():
	if !Engine.editor_hint:
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
	SingletonsAndConsts.current_master.play_transition__alter_no_states(_transition_sprite)
	_transition_sprite.modulate.a = 0.0

#

func _exit_tree():
	queue_free_transition_sprite()

func queue_free_transition_sprite():
	if is_instance_valid(_transition_sprite):
		_transition_sprite.queue_free()

#

func _set_transition_sprite_circle_ratio__dist__outside_of_outer_ring(arg_dist):
	set_transition_sprite_circle_ratio(circle_ratio__outside_of_outer_ring)
	

func _set_transition_sprite_circle_ratio__dist__inside_of_outer_ring(arg_dist):
	var circle_ratio = _tween_for_intervalue.interpolate_value(circle_ratio__inside_of_outer_ring, (circle_ratio__inside_of_outer_ring - circle_ratio__inside_of_inner_ring), (outer_ring__radius_start_of_fog - inner_ring__radius_max_fog), (arg_dist - inner_ring__radius_max_fog), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	set_transition_sprite_circle_ratio(circle_ratio)

func _set_transition_sprite_circle_ratio__dist__inside_of_inner_ring(arg_dist):
	set_transition_sprite_circle_ratio(circle_ratio__inside_of_inner_ring)
	


func set_transition_sprite_circle_ratio(arg_circle_ratio):
	_transition_sprite.set_circle_ratio(arg_circle_ratio)



