tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"


enum BatteryType {
	SMALL = 0,
	MEDIUM = 1,
	BIG = 2,
}
export(BatteryType) var battery_type : int = BatteryType.SMALL setget set_battery_type

var energy_replenish_ratio : float

#

func set_battery_type(arg_type):
	battery_type = arg_type
	
	if is_inside_tree() or Engine.editor_hint:
		if battery_type == BatteryType.SMALL:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/Battery/Assets/Pickupables_Battery_Small.png")
			energy_replenish_ratio = 0.2
			
		elif battery_type == BatteryType.MEDIUM:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/Battery/Assets/Pickupables_Battery_Medium.png")
			energy_replenish_ratio = 0.5
			
		elif battery_type == BatteryType.BIG:
			sprite.texture = preload("res://ObjectsRelated/Pickupables/Subs/Battery/Assets/Pickupables_Battery_Big.png")
			energy_replenish_ratio = 1.0
			
		
		if !Engine.editor_hint:
			_update_coll_shape_based_on_texture()


func _update_coll_shape_based_on_texture():
	_set_coll_shape_to_match_sprite__rect()


#

func _ready():
	set_battery_type(battery_type)
	

#


func _on_player_entered_self(arg_player):
	._on_player_entered_self(arg_player)
	
	if arg_player.is_player_modi_energy_set:
		var player_modi__energy = arg_player.player_modi__energy
		
		var applied_increase = player_modi__energy.inc_current_energy(player_modi__energy.get_max_energy() * energy_replenish_ratio)
		var applied_inc_ratio = applied_increase / player_modi__energy.get_max_energy()
		
		_attempt_play_particle_and_sound_effects(applied_inc_ratio)
		
		_destroy_self__on_consume_by_player()
		

func _attempt_play_particle_and_sound_effects(arg_applied_inc_ratio):
	if SingletonsAndConsts.current_game_elements.is_game_front_hud_initialized:
		_play_pickup_particles_and_sfx(arg_applied_inc_ratio)


func _play_pickup_particles_and_sfx(arg_applied_inc_ratio):
	AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Pickupable_Battery_01, global_position, 1.0, null)
	
	if battery_type == BatteryType.SMALL:
		_play_yellow_ring(5, 32, 0.4)
	elif battery_type == BatteryType.MEDIUM:
		_play_yellow_ring(5, 32, 0.4)
	elif battery_type == BatteryType.BIG:
		_play_yellow_ring(5, 46, 0.5)
	
#	##
#	var particle_count : int
#	if arg_applied_inc_ratio < 0.25:
#		particle_count = 4
#	elif arg_applied_inc_ratio < 0.5:
#		particle_count = 6
#	elif arg_applied_inc_ratio < 0.8:
#		particle_count = 8
#	else:
#		particle_count = 2
#
#
#	if particle_count > 0:
#		SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_battery_pickup_particle_effects__multiple(
#				get_global_transform_with_canvas().origin,
#				2, 2,
#				5, 5,
#				28, 52,
#				particle_count, 0.15)
#
#

func _play_yellow_ring(arg_initial_radius, arg_final_radius, mod_a):
	var pos = get_global_transform_with_canvas().origin
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster.play_yellow_ring__pickup_of_battery(pos, arg_initial_radius, arg_final_radius, 0.2, mod_a)





