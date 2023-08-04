extends Node


signal game_result_decided(arg_game_result)


enum GameResult {
	NONE = 0,
	WIN = 1,
	LOSE = 2,
}
var _current_game_result : int = GameResult.NONE

var is_game_result_decided : bool

#

var player
var game_elements


##


func _enter_tree():
	SingletonsAndConsts.current_game_result_manager = self

func _exit_tree():
	SingletonsAndConsts.current_game_result_manager = null

###

func set_player(arg_player):
	player = arg_player
	
	

func set_game_elements(arg_elements):
	game_elements = arg_elements
	
	game_elements.world_manager.connect("all_PCAs_of_all_world_slices_captured", self, "_on_all_PCAs_of_all_world_slices_captured")


#

func _on_all_PCAs_of_all_world_slices_captured():
	_attempt_set_current_game_result(GameResult.WIN)
	



func _attempt_set_current_game_result(arg_result):
	if _current_game_result == GameResult.NONE:
		_current_game_result = arg_result
		
		is_game_result_decided = true
		#print("GRM: result decided: %s" % [_current_game_result])
		emit_signal("game_result_decided", _current_game_result)



