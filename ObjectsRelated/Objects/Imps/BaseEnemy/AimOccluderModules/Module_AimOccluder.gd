extends Reference

#

const StoreOfPhysicsLayers = preload("res://SingletonsAndConsts/StoreOfPhysicsLayers.gd")

#

var target_actual_position : Vector2
var origin_position : Vector2

var direct_space_state : Physics2DDirectSpaceState


func is_aim_to_target_occluded() -> bool:
	var result = direct_space_state.intersect_ray(origin_position, target_actual_position, [], StoreOfPhysicsLayers.LAYER__TILE_FOR_OBJS)
	return result.size() != 0
	
