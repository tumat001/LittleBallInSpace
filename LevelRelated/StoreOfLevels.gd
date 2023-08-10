extends Node

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


#####

enum LevelIds {
	TEST = -10,
	
	LEVEL_01 = 1
	LEVEL_02 = 2
	LEVEL_03 = 3
	LEVEL_04 = 4
	LEVEL_05 = 5
	
}

var _level_id_to_level_details_map : Dictionary = {}

var _level_id_to_coin_amount_map : Dictionary
var _total_coin_count : int

# should never happen normally...
const DEFAULT_LEVEL_ID_FOR_EMPTY = LevelIds.TEST


#################

func _ready():
	_initialize_coin_details__check_for_game_save_manager()

#

func is_level_id_exists(arg_id):
	return LevelIds.values().has(arg_id)


#

func generate_or_get_level_details_of_id(arg_id) -> LevelDetails:
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

func _initialize_coin_details__check_for_game_save_manager():
	if GameSaveManager.is_manager_initialized():
		_initialize_coin_details()
	else:
		GameSaveManager.connect("save_manager_initialized", self, "_on_save_manager_initialized", [], CONNECT_ONESHOT)
		
	

func _on_save_manager_initialized():
	_initialize_coin_details()
	

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

###########################
### HELPERS
############################

# All black
func _set_details__to_usual_circle_types(arg_details : LevelDetails):
	arg_details.transition_id__entering_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__entering_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK

