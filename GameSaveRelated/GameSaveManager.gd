extends Node

const player_data_file_path = "user://player_data.save"


const INITIAL_PLAYER_HEALTH_AT_START = 100
const INITIAL_IS_PLAYER_DEAD = false

var player_health_on_start : float = INITIAL_PLAYER_HEALTH_AT_START
var is_player_dead : bool = INITIAL_IS_PLAYER_DEAD


func set_player(arg_player):
	if !is_player_dead:
		arg_player.set_current_health(player_health_on_start, false)
	else:
		arg_player.set_current_health(0, false)
	
	
	arg_player.connect("health_reached_breakpoint", self, "_on_player_health_reached_breakpoint", [], CONNECT_PERSIST)


func _on_player_health_reached_breakpoint(arg_breakpoint_val, arg_health_val_at_breakpoint):
	pass
	

