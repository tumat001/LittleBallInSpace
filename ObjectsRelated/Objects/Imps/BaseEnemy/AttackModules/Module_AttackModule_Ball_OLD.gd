extends Node2D

const Module_AttackModule_Laser = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.gd")


const LASER_LENGTH = Module_AttackModule_Laser.LASER_LENGTH 

#

var body_to_ignore_on_ball_launch   # needs to implement specific funcs

var ball_flat_dmg : float
var ball_dmg__max_bonus_dmg_based_on_lin_vel

func fire_ball_toward_position(arg_origin : Vector2, arg_lin_vel : Vector2):
	var ball = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.BALL)
	
	ball.global_position = arg_origin
	StoreOfObjects.helper_ball__configure_as_enemy_ball_proj(ball, ball_flat_dmg, ball_dmg__max_bonus_dmg_based_on_lin_vel)
	
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

static func extend_vector_to_length(arg_origin : Vector2, arg_vec : Vector2, arg_length : float):
	return Module_AttackModule_Laser.extend_vector_to_length(arg_origin, arg_vec, arg_length)


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = false #NOTE: change this to true if needed
var is_dead_but_reserved_for_rewind : bool


 #NOTE: change "is_rewindable" to true if needed
func get_rewind_save_state():
	pass

 #NOTE: change "is_rewindable" to true if needed
func load_into_rewind_save_state(arg_state : Dictionary):
	pass

func destroy_from_rewind_save_state():
	pass

func restore_from_destroyed_from_rewind():
	pass

func started_rewind():
	pass

func ended_rewind():
	pass



