tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"


enum LaunchBallType {
	AMMO_01 = 0,
	AMMO_02 = 1,
	AMMO_03 = 2,
	
	INFINITE_AMMO = 3,
}

export(LaunchBallType) var launch_ball_type : int = LaunchBallType.AMMO_01 setget set_launch_ball_type

var ammo_refill : int
var is_make_ammo_infinite : bool


func set_launch_ball_type(arg_type):
	launch_ball_type = arg_type
	
	if is_inside_tree() or Engine.editor_hint:
		if launch_ball_type == LaunchBallType.AMMO_01:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Assets/Pickupables_LaunchBall_Ball01.png")
			ammo_refill = 1
			is_make_ammo_infinite = false
			
		elif launch_ball_type == LaunchBallType.AMMO_02:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Assets/Pickupables_LaunchBall_Ball02.png")
			ammo_refill = 2
			is_make_ammo_infinite = false
			
		elif launch_ball_type == LaunchBallType.AMMO_03:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Assets/Pickupables_LaunchBall_Ball03.png")
			ammo_refill = 3
			is_make_ammo_infinite = false
			
		elif launch_ball_type == LaunchBallType.INFINITE_AMMO:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Assets/Pickupables_LaunchBall_BallInfinity.png")
			ammo_refill = 1
			is_make_ammo_infinite = true
			
		
		if !Engine.editor_hint:
			_update_coll_shape_based_on_texture()

func _update_coll_shape_based_on_texture():
	_set_coll_shape_to_match_sprite__rect()


#

func _ready():
	set_launch_ball_type(launch_ball_type)
	


func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	var modi = SingletonsAndConsts.current_game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	if modi != null:
		if ammo_refill != 0:
			modi.set_current_ball_count(modi.get_current_ball_count() + ammo_refill)
		
		if is_make_ammo_infinite:
			modi.is_infinite_ball_count = is_make_ammo_infinite
		
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallAmmo, global_position, 1.0, null)
		
		_destroy_self__on_consume_by_player()
