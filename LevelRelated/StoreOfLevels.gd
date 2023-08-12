extends Node

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

signal hidden_levels_state_changed()

#####

enum LevelIds {
	TEST = -10,
	
	LEVEL_01 = 1
	LEVEL_02 = 2
	LEVEL_03 = 3
	LEVEL_04 = 4
	LEVEL_05 = 5
	
}
# dont change this (useless). 
# This determines which levels are hidden at the very start, before any save states. i.e. hidden by default
const level_ids_hidden : Array = [
	LevelIds.TEST,
]

var _all_non_hidden_level_ids : Array

#

var _level_id_to_level_details_map : Dictionary = {}

var _level_id_to_coin_amount_map : Dictionary
var _total_coin_count : int


var level_ids_unlocked_by_default = [
	LevelIds.LEVEL_01
]




var _level_id_to_level_ids_required_for_unlock : Dictionary

# should never happen normally...
const DEFAULT_LEVEL_ID_FOR_EMPTY = LevelIds.TEST


#################

func _init():
	_initialize__all_non_hidden_level_ids()
	


func _ready():
	_initialize_level_id_unlock_requirmenets()
	
	_initialize_for__and_check_for_game_save_manager()

#

func _initialize__all_non_hidden_level_ids():
	for id in LevelIds.values():
		if !level_ids_hidden.has(id):
			_all_non_hidden_level_ids.append(id)


func get_all_non_hidden_level_ids():
	return _all_non_hidden_level_ids


func add_level_id_as_non_hidden(arg_id):
	_add_level_id_as_non_hidden__internal(arg_id, true)
	

func add_level_ids_as_non_hidden(arg_ids : Array):
	for id in arg_ids:
		_add_level_id_as_non_hidden__internal(id, false)
	
	emit_signal("hidden_levels_state_changed")

func _add_level_id_as_non_hidden__internal(arg_id, arg_emit_signal : bool):
	if !_all_non_hidden_level_ids.has(arg_id):
		_all_non_hidden_level_ids.append(arg_id)
	
	emit_signal("hidden_levels_state_changed")



func get_total_non_hidden_level_count():
	return _all_non_hidden_level_ids.size()
	

#

func is_level_id_exists(arg_id):
	return LevelIds.values().has(arg_id)

#

func generate_or_get_level_details_of_id(arg_id) -> LevelDetails:
	if !GameSaveManager.is_manager_initialized():
		print("StoreOfLevels: generating level details but save manager not initialized")
		return null
	
	#
	
	if _level_id_to_level_details_map.has(arg_id):
		return _level_id_to_level_details_map[arg_id]
	
	#######
	
	var level_details : LevelDetails = LevelDetails.new()
	level_details.level_id = arg_id
	
	if arg_id == LevelIds.TEST:
		level_details.level_name = [
			["TestName Desc", []]
		]
		level_details.level_desc = [
			["Testing Desc Lorem ipsum", []]
		]
		
		#level_details.texture_of_level_tile
		level_details.modulate_of_level_tile = Color(1, 1, 0, 1)
		
		#level_details.texture_of_level_tile__locked
		level_details.modulate_of_level_tile__locked = Color(1, 0, 0, 1)
		
		_set_details__to_usual_circle_types(level_details)
		
		
		
	elif arg_id == LevelIds.LEVEL_01:
		level_details.level_name = [
			["Beginnings", []]
		]
		level_details.level_desc = [
			["A step in a thousand mile journey... Well, you can't really make a step here but you know what I mean...", []]
		]
		
		
		_set_details__to_usual_circle_types(level_details)
		
	elif arg_id == LevelIds.LEVEL_02:
		level_details.level_name = [
			["Labyrinth", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__to_usual_circle_types(level_details)
		
		
	elif arg_id == LevelIds.LEVEL_03:
		level_details.level_name = [
			["Energy", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__to_usual_circle_types(level_details)
		
		
	elif arg_id == LevelIds.LEVEL_04:
		level_details.level_name = [
			["Remnants", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__to_usual_circle_types(level_details)
		
		
	elif arg_id == LevelIds.LEVEL_05:
		level_details.level_name = [
			["Escape", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__to_usual_circle_types(level_details)
		
	
	
	_level_id_to_level_details_map[arg_id] = level_details
	
	#
	
	_set_level_details_configs_and_params_based_on_GSM(level_details)
	
	#
	
	return level_details


#####

func generate_base_level_imp_new(arg_id):
	if arg_id == LevelIds.TEST:
		return load("res://LevelRelated/BaseLevelImps/Test/Level_Test01.gd").new()
	elif arg_id == LevelIds.LEVEL_01:
		return load("res://LevelRelated/BaseLevelImps/Layout01/Level_01.gd").new()
	elif arg_id == LevelIds.LEVEL_02:
		return load("res://LevelRelated/BaseLevelImps/Layout01/Level_02.gd").new()
	elif arg_id == LevelIds.LEVEL_03:
		return load("res://LevelRelated/BaseLevelImps/Layout01/Level_03.gd").new()
	elif arg_id == LevelIds.LEVEL_04:
		return load("res://LevelRelated/BaseLevelImps/Layout01/Level_04.gd").new()
	elif arg_id == LevelIds.LEVEL_05:
		return load("res://LevelRelated/BaseLevelImps/Layout01/Level_05.gd").new()
		
	

###### COINS

func _initialize_for__and_check_for_game_save_manager():
	if GameSaveManager.is_manager_initialized():
		_initialize_coin_details()
		_initialize_monitor_of_level_status_changes()
		
	else:
		GameSaveManager.connect("save_manager_initialized", self, "_on_save_manager_initialized", [], CONNECT_ONESHOT)
		
	

func _on_save_manager_initialized():
	_initialize_coin_details()
	_initialize_monitor_of_level_status_changes()
	

func _initialize_coin_details():
	_level_id_to_coin_amount_map = {
		LevelIds.TEST : 0,
		
		LevelIds.LEVEL_01 : 3,
		LevelIds.LEVEL_02 : 3,
		LevelIds.LEVEL_03 : 4,
		LevelIds.LEVEL_04 : 3,
		LevelIds.LEVEL_05 : 0,
		
	}
	
	_calculate_total_coin_count()

func _calculate_total_coin_count():
	for amount in _level_id_to_coin_amount_map.values():
		_total_coin_count += amount


func get_coin_count_for_level(arg_id):
	return _level_id_to_coin_amount_map[arg_id]

func get_total_coin_count() -> int:
	return _total_coin_count



##

func _initialize_monitor_of_level_status_changes():
	GameSaveManager.connect("level_id_completion_status_changed", self, "_on_GSM_level_id_completion_status_changed")
	

func _on_GSM_level_id_completion_status_changed(arg_id, arg_status):
	if _level_id_to_level_details_map.has(arg_id):
		var details = _level_id_to_level_details_map[arg_id]
		_set_level_details_configs_and_params_based_on_GSM(details)
	
	_attempt_unlock_levels_based_on_level_status_changed(arg_id, arg_status)

func _set_level_details_configs_and_params_based_on_GSM(arg_details : LevelDetails):
	arg_details.is_level_locked = !GameSaveManager.is_level_id_playable(arg_details.level_id)
	


###
# UNLOCK REQUIRMENETS
##

func _initialize_level_id_unlock_requirmenets():
	_level_id_to_level_ids_required_for_unlock = {
		LevelIds.LEVEL_01 : [],
		LevelIds.LEVEL_02 : [LevelIds.LEVEL_01],
		LevelIds.LEVEL_03 : [LevelIds.LEVEL_02],
		LevelIds.LEVEL_04 : [LevelIds.LEVEL_03],
		LevelIds.LEVEL_05 : [LevelIds.LEVEL_04],
		
	}

func _attempt_unlock_levels_based_on_level_status_changed(arg_level_id, arg_status):
	if arg_status == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED:
		for candi_level_id_to_unlock in _level_id_to_level_ids_required_for_unlock.keys():
			
			var unlock : bool = true
			for level_id_needed in _level_id_to_level_ids_required_for_unlock[candi_level_id_to_unlock]:
				#print("testing level id needed: %s" % level_id_needed)
				if !GameSaveManager.is_level_id_finished(level_id_needed):
					unlock = false
					
					#print("level id needed not fulfilled: %s, for %s" % [level_id_needed, candi_level_id_to_unlock])
					break
					
			
			if unlock:
				if !GameSaveManager.is_level_id_playable(candi_level_id_to_unlock):
					#print("unlocked id: %s" % candi_level_id_to_unlock)
					GameSaveManager.set_level_id_status_completion(candi_level_id_to_unlock, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)



###########################
### HELPERS
############################

# All black
func _set_details__to_usual_circle_types(arg_details : LevelDetails):
	arg_details.transition_id__entering_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__entering_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK

