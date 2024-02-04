tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"


enum WrenchType {
	REPAIR_FULL = 0,
	
}

export(WrenchType) var wrench_type : int = WrenchType.REPAIR_FULL setget set_wrench_type

export(bool) var is_replenish_type : bool = false


var health_ratio_increase

#

func set_wrench_type(arg_val):
	wrench_type = arg_val
	
	if is_inside_tree() or Engine.editor_hint:
		match wrench_type:
			WrenchType.REPAIR_FULL:
				sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/Wrench/Assets/Pickupables_Wrench_01.png")
				health_ratio_increase = 1.0
				
		
		##
		
		if !Engine.editor_hint:
			_update_coll_shape_based_on_texture()

func _update_coll_shape_based_on_texture():
	_set_coll_shape_to_match_sprite__rect()

##

func _ready():
	set_wrench_type(wrench_type)
	


func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	#
	if !is_equal_approx(arg_player.get_current_robot_health(), arg_player.get_max_robot_health()): 
		var health_flat_heal = arg_player.get_max_robot_health() * health_ratio_increase
		arg_player.heal_robot_health(health_flat_heal)
		
		_attempt_play_particle_and_sound_effects()
		
		if !is_replenish_type:
			_destroy_self__on_consume_by_player()
	

func _attempt_play_particle_and_sound_effects():
	if SingletonsAndConsts.current_game_elements.is_game_front_hud_initialized:
		_play_pickup_particles_and_sfx()
	

func _play_pickup_particles_and_sfx():
	match wrench_type:
		WrenchType.REPAIR_FULL:
			_play_pickup_particles_and_sfx__as_repair_full()
			
		

func _play_pickup_particles_and_sfx__as_repair_full():
	AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_Wrench_RepairFull, global_position, 1.0, null)
	_play_blue_ring(5, 46, 0.5)


func _play_blue_ring(arg_initial_radius, arg_final_radius, mod_a):
	var pos = get_global_transform_with_canvas().origin
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_blue_ring__pickup_of_wrench(pos, arg_initial_radius, arg_final_radius, 0.2, mod_a)


