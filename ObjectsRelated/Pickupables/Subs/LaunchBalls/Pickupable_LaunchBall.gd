tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"

#

signal ball_collected_by_player()

#

const LaunchBallPickupableParticle = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Particles/LaunchBallPickupableParticle.gd")

#

enum LaunchBallType {
	AMMO_01 = 0,
	AMMO_02 = 1,
	AMMO_03 = 2,
	
	INFINITE_AMMO = 3,
}

export(LaunchBallType) var launch_ball_type : int = LaunchBallType.AMMO_01 setget set_launch_ball_type

var ammo_refill : int
var is_make_ammo_infinite : bool


export(bool) var is_replenish_type : bool = false

#

const offset_from_center__red = Vector2(0, -8)
const offset_from_center__green = Vector2(-8, 6)
const offset_from_center__blue = Vector2(8, 6)

const delay_per_ball_particle : float = 0.1

#

func set_launch_ball_type(arg_type):
	launch_ball_type = arg_type
	
	if is_inside_tree() or (Engine.editor_hint and is_inside_tree()):
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
		var has_made_changes : bool = false
		if ammo_refill != 0:
			if !is_replenish_type:
				modi.set_current_ball_count(modi.get_current_ball_count() + ammo_refill)
				has_made_changes = true
			else:
				var curr_count = modi.get_current_ball_count()
				if curr_count < ammo_refill:
					modi.set_current_ball_count(ammo_refill)
					has_made_changes = true
		
		if is_make_ammo_infinite:
			if !is_replenish_type:
				modi.is_infinite_ball_count = true
				has_made_changes = true
			else:
				var old_val = modi.is_infinite_ball_count
				modi.is_infinite_ball_count = true
				has_made_changes = old_val != true
		
		if has_made_changes:
			_attempt_play_particle_and_sound_effects()
		
		
		if has_made_changes and !is_replenish_type:
			_destroy_self__on_consume_by_player()
		
		if has_made_changes:
			emit_signal("ball_collected_by_player")

func _attempt_play_particle_and_sound_effects():
	if SingletonsAndConsts.current_game_elements.is_game_front_hud_initialized:
		_play_pickup_particles_and_sfx()

func _play_pickup_particles_and_sfx():
	if launch_ball_type == LaunchBallType.AMMO_01:
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallAmmo, global_position, 1.0, null)
		_play_pickup_particle__randomized_offset__x_times(1, Vector2(5, 0), 32)
		_play_orange_ring(5, 32, 0.4)
		
	elif launch_ball_type == LaunchBallType.AMMO_02:
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallAmmo, global_position, 1.0, null)
		_play_pickup_particle__randomized_offset__x_times(2, Vector2(5, 0), 32)
		_play_orange_ring(5, 32, 0.4)
		
	elif launch_ball_type == LaunchBallType.AMMO_03:
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallAmmo, global_position, 1.0, null)
		_play_pickup_particle__randomized_offset__x_times(3, Vector2(5, 0), 32)
		_play_orange_ring(5, 32, 0.5)
		
	elif launch_ball_type == LaunchBallType.INFINITE_AMMO:
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallAmmo, global_position, 1.0, null)
		_play_pickup_particles__as_inf_ammo()
		_play_orange_ring(offset_from_center__blue.length(), 46, 0.5)
	

func _play_pickup_particle__randomized_offset__x_times(arg_count : int, arg_initial_offset : Vector2, arg_dist_from_offset : float):
	var total_delay = 0
	for i in arg_count:
		var initial_offset = _get_randomized_rotation_of_vector(arg_initial_offset)
		SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_launch_ball_pickup_particle_effects(self, initial_offset, arg_dist_from_offset, LaunchBallPickupableParticle.anim_name__white, total_delay)
		total_delay += delay_per_ball_particle

func _get_randomized_rotation_of_vector(arg_vec : Vector2):
	return arg_vec.rotated(SingletonsAndConsts.non_essential_rng.randf_range(0, 2*PI))


func _play_pickup_particles__as_inf_ammo():
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_launch_ball_pickup_particle_effects(self, offset_from_center__red, 46, LaunchBallPickupableParticle.anim_name__red, delay_per_ball_particle * 0)
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_launch_ball_pickup_particle_effects(self, offset_from_center__green, 46, LaunchBallPickupableParticle.anim_name__green, delay_per_ball_particle * 1)
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_launch_ball_pickup_particle_effects(self, offset_from_center__blue, 46, LaunchBallPickupableParticle.anim_name__blue, delay_per_ball_particle * 2)

func _play_orange_ring(arg_initial_radius, arg_final_radius, mod_a):
	var pos = get_global_transform_with_canvas().origin
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_orange_ring__pickup_of_launch_ball(pos, arg_initial_radius, arg_final_radius, LaunchBallPickupableParticle.DURATION__TO_FIRST_DEST, mod_a)


