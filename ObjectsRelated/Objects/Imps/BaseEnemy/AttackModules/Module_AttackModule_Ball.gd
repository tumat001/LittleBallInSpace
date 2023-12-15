extends "res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/BaseModule_AttackModule.gd"

#const Module_AttackModule_Laser = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.gd")


#

signal attack_sequence_finished()

#

#const LASER_WIDTH__BASE = 2.0
#const LASER_DURATION__CHARGING = Module_AttackModule_Laser.LASER_DURATION__CHARGING

#const LASER_DURATION__LOOKAHEAD_PREDICT = Module_AttackModule_Laser.LASER_DURATION__LOOKAHEAD_PREDICT

#

var body_to_ignore_on_ball_launch   # needs to implement specific funcs

var ball_flat_dmg : float
var ball_dmg__max_bonus_dmg_based_on_lin_vel

var ball_lin_vel_to_use : Vector2

var ball_modulate_to_use_for_hit_damage_particle : Color

#

func _fire_ball_toward_position(arg_origin : Vector2, arg_lin_vel : Vector2):
	var ball = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.BALL)
	
	ball.global_position = arg_origin
	StoreOfObjects.helper_ball__configure_as_enemy_ball_proj(ball, ball_flat_dmg, ball_dmg__max_bonus_dmg_based_on_lin_vel, ball_modulate_to_use_for_hit_damage_particle)
	
	StoreOfObjects.helper_ball__launch_at_vec(ball, arg_lin_vel)
	
	StoreOfObjects.helper_ball__ignore_first_collision_with_body(ball, body_to_ignore_on_ball_launch)
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(ball)


#

func get_launch_strength_to_use(arg_origin : Vector2, arg_target_pos : Vector2):
	var dist = arg_origin.distance_to(arg_target_pos)
	
	if dist >= 550:
		return 250
		
	else:
		return 125

#


func _physics_process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if is_in_fire_sequence():
			#update() is called by this method
			_current_duration_of_laser_completon__to_any += delta
			
			if _fire_sequence_state == FireSequenceStateId.CHARGING:
				if _current_duration_of_laser_completon__to_any > LASER_DURATION__TO_MIN:
					_current_duration_of_laser_completon__to_any = 0
					#_rewind__current_duration_of_laser_completon__to_any__has_changes = true
					
					AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Enemy_LaunchBall, global_position, 1, null, AudioManager.MaskLevel.Minor_SoundFX)
					
					_fire_ball_toward_position(global_position, ball_lin_vel_to_use)
					
					_end_fire_sequence()
			
			var width = _calc_laser_width_to_currently_use()
			_set_current_laser_width(width)
			
			
		else:
			update()
			

#static func extend_vector_to_length(arg_origin : Vector2, arg_vec : Vector2, arg_length : float):
#	return Module_AttackModule_Laser.extend_vector_to_length(arg_origin, arg_vec, arg_length)


####################### 
## REWIND RELATED
######################
#
#export(bool) var is_rewindable : bool = false #NOTE: change this to true if needed
#var is_dead_but_reserved_for_rewind : bool
#
#
# #NOTE: change "is_rewindable" to true if needed
#func get_rewind_save_state():
#	pass
#
# #NOTE: change "is_rewindable" to true if needed
#func load_into_rewind_save_state(arg_state : Dictionary):
#	pass
#
#func destroy_from_rewind_save_state():
#	pass
#
#func restore_from_destroyed_from_rewind():
#	pass
#
#func started_rewind():
#	pass
#
#func ended_rewind():
#	pass



