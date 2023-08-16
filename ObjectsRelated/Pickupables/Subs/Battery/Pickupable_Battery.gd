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
		player_modi__energy.inc_current_energy(player_modi__energy.get_max_energy() * energy_replenish_ratio)
		
		AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_Pickupable_Battery_01, global_position, 1.0, null)
		
		_destroy_self__on_consume_by_player()
		



