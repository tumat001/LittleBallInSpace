extends "res://ObjectsRelated/Objects/BaseObject.gd"



var texture_to_use__fragment : AtlasTexture


var player
var _is_inside_player
var _entering_velocity : Vector2

var _is_from_rewind__frame_count : int


onready var player_soft_area_2d = $PlayerSoftArea2D
onready var player_soft_coll_shape = $PlayerSoftArea2D/CollisionShape2D

#var _current_delay_before_collidable_with_player : float = 2.5
#var _can_collide_with_player__from_delay : bool = true  # leave it this way

func _ready():
	if texture_to_use__fragment != null:
		var shape = set_texture_in_anim_sprite__first_time(texture_to_use__fragment, true)
		
		player_soft_coll_shape.set_deferred("shape", shape)
	
	block_can_collide_with_player_cond_clauses.attempt_insert_clause(BlockCollisionWithPlayerClauseIds.IS_TILE_FRAGMENT)
	
	#set_current_delay_before_collidable_with_player(_current_delay_before_collidable_with_player)



#func _process(delta):
#	set_current_delay_before_collidable_with_player(_current_delay_before_collidable_with_player - delta)
#
#
#func set_current_delay_before_collidable_with_player(arg_val):
#	_current_delay_before_collidable_with_player = arg_val
#
#	if _current_delay_before_collidable_with_player <= 0 and !_can_collide_with_player__from_delay:
#		_can_collide_with_player__from_delay = true
#		block_can_collide_with_player_cond_clauses.remove_clause(BlockCollisionWithPlayerClauseIds.TILE_FRAGMENT__DURATION_DELAY)
#
#	elif _current_delay_before_collidable_with_player > 0 and _can_collide_with_player__from_delay:
#		_can_collide_with_player__from_delay = false
#		block_can_collide_with_player_cond_clauses.attempt_insert_clause(BlockCollisionWithPlayerClauseIds.TILE_FRAGMENT__DURATION_DELAY)
#
#




func _on_PlayerSoftArea2D_body_entered(body):
	if body.get("is_player"):
		player = body
		_is_inside_player = true
		
		
		if _is_from_rewind__frame_count == 0:
			var pushback = 75
			var dir = global_position.angle_to_point(player.global_position)
			var force = Vector2(pushback, 0).rotated(dir)
			
			var lin_vel : Vector2= body.linear_velocity
			lin_vel.limit_length(100)
			
			apply_central_impulse(force + lin_vel)


#

func _physics_process(delta):
	if _is_inside_player:
		var dist = global_position.distance_to(player.global_position)
		#var pushback = 40000 + (80000 * (1 - _convert_result_into_ratio_using_num_range(dist, 0, player.get_player_radius())))
		var pushback = 5 #+ (5 * (1 - _convert_result_into_ratio_using_num_range(dist, 0, player.get_player_radius())))
		
		var dir = global_position.angle_to_point(player.global_position)
		var force = Vector2(pushback, 0).rotated(dir)
		add_central_force(force)
		
		#print(force)
		#print("--")
	
	if _is_from_rewind__frame_count > 0:
		_is_from_rewind__frame_count -= 1
	elif _is_from_rewind__frame_count < 0:
		_is_from_rewind__frame_count = 0



#

func _convert_ratio_using_num_range(arg_ratio, arg_min, arg_max):
	var diff = arg_max - arg_min
	
	return arg_min + (diff * arg_ratio)

func _convert_result_into_ratio_using_num_range(arg_result, arg_min, arg_max):
	return (arg_result - arg_min) / (arg_max - arg_min)


####

func _on_PlayerSoftArea2D_body_exited(body):
	if body.get("is_player"):
		_is_inside_player = false

###################### 
# REWIND RELATED
#####################

func queue_free():
	.queue_free()
	
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		player_soft_coll_shape.set_deferred("disabled", true)



func stared_rewind():
	.stared_rewind()
	
	player_soft_coll_shape.set_deferred("disabled", true)


func ended_rewind():
	.ended_rewind()
	
	if !is_dead_but_reserved_for_rewind:
		player_soft_coll_shape.set_deferred("disabled", false)
	
	_is_from_rewind__frame_count = 2




