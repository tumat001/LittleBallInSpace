extends Node

const StoreOfVicDefAnim = preload("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/StoreOfVicDefAnim.gd")

#

signal game_result_decided(arg_game_result)


#

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
	attempt_set_current_game_result(GameResult.WIN)
	


##

func attempt_set_current_game_result(arg_result):
	if _current_game_result == GameResult.NONE:
		_current_game_result = arg_result
		
		is_game_result_decided = true
		#print("GRM: result decided: %s" % [_current_game_result])
		emit_signal("game_result_decided", _current_game_result)
		
		if is_instance_valid(SingletonsAndConsts.current_game_front_hud):
			SingletonsAndConsts.current_game_front_hud.hide_in_game_pause_control_tree()
		
		_play_game_result_showing_anim()


func _play_game_result_showing_anim():
	if _current_game_result == GameResult.WIN:
		_play_game_result_showing_anim__win()
		
	elif _current_game_result == GameResult.LOSE:
		_play_game_result_showing_anim__lose()
		


func _play_game_result_showing_anim__win():
	var anim_scene = SingletonsAndConsts.current_base_level.get_anim_instance_to_play__on_victory()
	if anim_scene != null:
		_add_anim_scene_to_game_front_hud__and_monitor_for_end(anim_scene)
	

func _play_game_result_showing_anim__lose():
	var anim_scene = SingletonsAndConsts.current_base_level.get_anim_instance_to_play__on_defeat()
	if anim_scene != null:
		_add_anim_scene_to_game_front_hud__and_monitor_for_end(anim_scene)
	

func _add_anim_scene_to_game_front_hud__and_monitor_for_end(arg_scene):
	arg_scene.win_message_type = SingletonsAndConsts.current_base_level.win_message_type
	arg_scene.lose_message_type = SingletonsAndConsts.current_base_level.lose_messege_type
	
	arg_scene.connect("end_of_anim", self, "_on_end_of_anim")
	SingletonsAndConsts.current_game_front_hud.add_vic_def_anim(arg_scene)
	


func _on_end_of_anim():
	if _current_game_result == GameResult.WIN:
		end_game__as_win()
	else:
		end_game__as_lose()


func end_game__as_win():
	SingletonsAndConsts.switch_to_level_selection_scene__from_game_elements__as_win()
	

func end_game__as_lose():
	SingletonsAndConsts.switch_to_level_selection_scene__from_game_elements__as_lose()
	



