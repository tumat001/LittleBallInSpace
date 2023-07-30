extends "res://ObjectsRelated/Objects/BaseObject.gd"



var texture_to_use__fragment : AtlasTexture

var _current_delay_before_collidable_with_player : float = 2.5
var _can_collide_with_player__from_delay : bool = true  # leave it this way

func _ready():
	if texture_to_use__fragment != null:
		set_texture_in_anim_sprite__first_time(texture_to_use__fragment, true)
	
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


