tool
extends "res://ObjectsRelated/Pickupables/BasePickupables.gd"

signal collected_by_player()
signal uncollected_by_player()


const POS_UPPER = Vector2(0, -10)
const POS_LEFT = Vector2(-9, -1.5)
const POS_LOWER_LEFT = Vector2(-6, 8)
const POS_RIGHT = Vector2(9, -1.5)
const POS_LOWER_RIGHT = Vector2(6, 8)
const all_poses = [
	POS_UPPER,
	POS_LEFT,
	POS_LOWER_LEFT,
	POS_RIGHT,
	POS_LOWER_RIGHT
]

#

var coin_id : String

var is_disabled_by_assist_mode : bool = false

#

func get_all_poses():
	return all_poses

#

func _on_player_entered_self(arg_player):
	if is_disabled_by_assist_mode:
		return
	
	._on_player_entered_self(arg_player)
	
	GameSaveManager.set_tentative_coin_id_collected_in_curr_level(coin_id, true)
	
	emit_signal("collected_by_player")
	
	_destroy_self__on_consume_by_player()

func restore_from_destroyed_from_rewind():
	.restore_from_destroyed_from_rewind()
	
	emit_signal("uncollected_by_player")
	
	GameSaveManager.set_tentative_coin_id_collected_in_curr_level(coin_id, false)

#

func collect_by_player():
	_on_player_entered_self(SingletonsAndConsts.current_game_elements.get_current_player())

#

func configure_self_as_assist_mode_is_active():
	is_disabled_by_assist_mode = true
	
	modulate.a = 0.3
	sprite.material = null


