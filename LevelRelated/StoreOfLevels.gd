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
	
	##
	
	LEVEL_01__STAGE_2 = 100
	LEVEL_02__STAGE_2 = 101
	LEVEL_03__STAGE_2 = 102
	LEVEL_04__STAGE_2 = 103
	LEVEL_05__STAGE_2 = 104
	LEVEL_06__STAGE_2 = 105
	
	LEVEL_02__STAGE_2__HARD = 151
	LEVEL_06__STAGE_2__HARD = 152
	
	##
	
	LEVEL_01__STAGE_3 = 200
	LEVEL_02__STAGE_3 = 201
	LEVEL_03__STAGE_3 = 202
	LEVEL_04__STAGE_3 = 203
	LEVEL_05__STAGE_3 = 204
	LEVEL_06__STAGE_3 = 205
	
	LEVEL_03__STAGE_3__HARD = 250
	LEVEL_04__STAGE_3__HARD = 251
	LEVEL_05__STAGE_3__HARD = 252
	
	
	##
	
	LEVEL_01__STAGE_4 = 300
	LEVEL_02__STAGE_4 = 301
	LEVEL_03__STAGE_4 = 302
	LEVEL_04__STAGE_4 = 303
	LEVEL_05__STAGE_4 = 304
	
	LEVEL_03__STAGE_4__HARD = 350
	LEVEL_05__STAGE_4__HARD = 351
	
	##
	
	LEVEL_01__STAGE_5 = 400
	
	
}
# dont change this in runtime(useless). 
# This determines which levels are not hidden at the very start, before any save states. i.e. not hidden by default
const level_ids_not_hidden : Array = [
	#LevelIds.TEST,
	
	LevelIds.LEVEL_01,
	LevelIds.LEVEL_02,
	LevelIds.LEVEL_03,
	LevelIds.LEVEL_04,
	LevelIds.LEVEL_05,
	
]

var _all_non_hidden_level_ids : Array

#

var _level_id_to_level_details_map : Dictionary = {}

var _level_id_to_coin_amount_map : Dictionary
var _total_coin_count : int
var _total_coin_count__unhidden : int


var level_ids_unlocked_by_default = [
	LevelIds.LEVEL_01
]


var _level_id_to_level_ids_required_for_unlock : Dictionary



enum AllLevelsHiddenState {
	FIRST_STAGE_ONLY = 0,
	ALL_EXCEPT_FOR_TEST = 1,
}
var current_level_hidden_state : int setget set_current_level_hidden_state, get_current_levels_hidden_state

# should never happen normally...
const DEFAULT_LEVEL_ID_FOR_EMPTY = LevelIds.TEST


#################

func _init():
	_initialize__all_non_hidden_level_ids()
	


func _ready():
	_initialize_level_id_unlock_requirmenets()
	
	_initialize_for__and_check_for_game_save_manager()
	
	connect("hidden_levels_state_changed", self, "_on_hidden_levels_state_changed")

#

func _initialize__all_non_hidden_level_ids():
	for id in LevelIds.values():
		if level_ids_not_hidden.has(id):
			_all_non_hidden_level_ids.append(id)


func get_all_non_hidden_level_ids():
	return _all_non_hidden_level_ids

#func get_all_level_id_to_is_hidden_map():
#	var map = {}
#	for level_id in LevelIds.values():
#		var is_hidden : bool = true
#		if _all_non_hidden_level_ids.has(level_id):
#			is_hidden = false
#
#		map[level_id] = is_hidden
#
#	return map


func _add_level_id_as_non_hidden(arg_id):
	_add_level_id_as_non_hidden__internal(arg_id, true)
	

func _add_level_ids_as_non_hidden(arg_ids : Array):
	var at_least_one_changed : bool = false
	
	for id in arg_ids:
		var changed = _add_level_id_as_non_hidden__internal(id, false)
		if changed:
			at_least_one_changed = true
	
	if at_least_one_changed:
		emit_signal("hidden_levels_state_changed")

func _add_level_id_as_non_hidden__internal(arg_id, arg_emit_signal : bool):
	if !_all_non_hidden_level_ids.has(arg_id):
		_all_non_hidden_level_ids.append(arg_id)
		
		emit_signal("hidden_levels_state_changed")
		
		return true
	
	return false

func get_total_non_hidden_level_count():
	return _all_non_hidden_level_ids.size()
	


func is_level_id_exists(arg_id):
	return LevelIds.values().has(arg_id)


func get_all_level_ids__not_including_tests() -> Array:
	var bucket = []
	
	for level_id_key in LevelIds.keys():
		var find_index = level_id_key.findn("TEST")
		if find_index == -1:
			bucket.append(LevelIds[level_id_key])
	
	return bucket




func get_current_levels_hidden_state():
	return current_level_hidden_state

func set_current_level_hidden_state(arg_val):
	current_level_hidden_state = arg_val
	
	if current_level_hidden_state == AllLevelsHiddenState.FIRST_STAGE_ONLY:
		pass
		
	elif current_level_hidden_state == AllLevelsHiddenState.ALL_EXCEPT_FOR_TEST:
		_add_level_ids_as_non_hidden(get_all_level_ids__not_including_tests())
		
	
	



###############

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
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		
		
	elif arg_id == LevelIds.LEVEL_01:
		level_details.level_name = [
			["Beginnings", []]
		]
		level_details.level_desc = [
			["A step in a thousand mile journey... Well, you can't really make a step here but you know what I mean...", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "01"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_02:
		level_details.level_name = [
			["Labyrinth", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "02"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_03:
		level_details.level_name = [
			["Energy", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Yellow_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "03"
		level_details.level_label_text_color = Color("#444444")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_04:
		level_details.level_name = [
			["Remnants", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Yellow_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "04"
		level_details.level_label_text_color = Color("#444444")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_05:
		level_details.level_name = [
			["Escape", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Violet_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "05"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_2:
		level_details.level_full_name = [
			["2-1 Recoil", []]
		]
		level_details.level_name = [
			["Recoil", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "01"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_02__STAGE_2:
		level_details.level_full_name = [
			["2-2 Bounce", []]
		]
		level_details.level_name = [
			["Bounce", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!2"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_02__STAGE_2__HARD:
		level_details.level_full_name = [
			["2-!2 Bounce 2.0", []]
		]
		level_details.level_name = [
			["Bounce 2.0", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!2"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_2:
		level_details.level_full_name = [
			["2-3 Infinity", []]
		]
		level_details.level_name = [
			["Infinity", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "03"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_04__STAGE_2:
		level_details.level_full_name = [
			["2-4 Manuever", []]
		]
		level_details.level_name = [
			["Manuever", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "04"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_05__STAGE_2:
		level_details.level_full_name = [
			["2-5 Ricochete", []]
		]
		level_details.level_name = [
			["Ricochete", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "05"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_06__STAGE_2:
		level_details.level_full_name = [
			["2-6 Enclosed", []]
		]
		level_details.level_name = [
			["Enclosed", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Violet_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "06"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
		
	elif arg_id == LevelIds.LEVEL_06__STAGE_2__HARD:
		level_details.level_full_name = [
			["2-!6 Planned Out", []]
		]
		level_details.level_name = [
			["Planned Out", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedWithVio_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!6"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		level_details.additional_level_ids_to_mark_as_complete.append(LevelIds.LEVEL_06__STAGE_2)
		
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_3:
		level_details.level_full_name = [
			["3-1 Gates", []]
		]
		level_details.level_name = [
			["Gates", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "01"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_02__STAGE_3:
		level_details.level_full_name = [
			["3-2 Airborne", []]
		]
		level_details.level_name = [
			["Airborne", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "02"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_3:
		level_details.level_full_name = [
			["3-3 Direction", []]
		]
		level_details.level_name = [
			["Direction", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "03"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_3__HARD:
		level_details.level_full_name = [
			["3-!3 In and Out 2.0", []]
		]
		level_details.level_name = [
			["In and Out 2.0", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!3"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		
		
	elif arg_id == LevelIds.LEVEL_04__STAGE_3:
		level_details.level_full_name = [
			["3-4 Golfing", []]
		]
		level_details.level_name = [
			["Golfing", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "04"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_04__STAGE_3:
		level_details.level_full_name = [
			["3-!4 Manuever 2.0", []]
		]
		level_details.level_name = [
			["Manuever 2.0", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!4"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		
		
		
	elif arg_id == LevelIds.LEVEL_05__STAGE_3:
		level_details.level_full_name = [
			["3-5 Perpetual", []]
		]
		level_details.level_name = [
			["Perpetual", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Violet_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "05"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
		
	elif arg_id == LevelIds.LEVEL_05__STAGE_3__HARD:
		level_details.level_full_name = [
			["3-5! In the way", []]
		]
		level_details.level_name = [
			["In the way", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedWithVio_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!5"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		level_details.additional_level_ids_to_mark_as_complete.append(LevelIds.LEVEL_05__STAGE_3)
		
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_4:
		level_details.level_full_name = [
			["4-1 Breakables", []]
		]
		level_details.level_name = [
			["Breakables", []]
		]
		level_details.level_desc = [
			["If you like breaking things, then this stage of the game is for you", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "01"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_02__STAGE_4:
		level_details.level_full_name = [
			["4-2 Glass and Ball", []]
		]
		level_details.level_name = [
			["Glass and Ball", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "02"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_4:
		level_details.level_full_name = [
			["4-3 Goal", []]
		]
		level_details.level_name = [
			["Goal", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "03"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_4__HARD:
		level_details.level_full_name = [
			["4-!3 Six Pointer", []]
		]
		level_details.level_name = [
			["Six Pointer", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!3"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		
		
	elif arg_id == LevelIds.LEVEL_04__STAGE_4:
		level_details.level_full_name = [
			["4-4 Bounce 3.0", []]
		]
		level_details.level_name = [
			["Bounce 3.0", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "04"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	elif arg_id == LevelIds.LEVEL_05__STAGE_4:
		level_details.level_full_name = [
			["4-5 Slow Down", []]
		]
		level_details.level_name = [
			["Slow Down", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Violet_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "05"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
		
		
	elif arg_id == LevelIds.LEVEL_05__STAGE_4__HARD:
		level_details.level_full_name = [
			["4-!5 Trim", []]
		]
		level_details.level_name = [
			["Trim", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedWithVio_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "!5"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		level_details.level_type = level_details.LevelTypeId.CHALLENGE
		level_details.additional_level_ids_to_mark_as_complete.append(LevelIds.LEVEL_05__STAGE_4)
		
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_5:
		level_details.level_full_name = [
			["5-1 Terminal Velocity", []]
		]
		level_details.level_name = [
			["Terminal Velocity", []]
		]
		level_details.level_desc = [
			["", []]
		]
		
		
		_set_details__transitions_to_usual_circle_types(level_details)
		
		level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_SpecialBlue_32x32.png")
		level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
		level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
		
		level_details.level_label_on_tile = "01"
		level_details.level_label_text_color = Color("#dddddd")
		#level_details.level_label_outline_color = Color("#dddddd")
		level_details.has_outline_color = false
		
		
	
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
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_2:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_01__L2.gd").new()
	elif arg_id == LevelIds.LEVEL_02__STAGE_2:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_02__L2.gd").new()
	elif arg_id == LevelIds.LEVEL_03__STAGE_2:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_03__L2.gd").new()
	elif arg_id == LevelIds.LEVEL_04__STAGE_2:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_04__L2.gd").new()
	elif arg_id == LevelIds.LEVEL_05__STAGE_2:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_05__L2.gd").new()
	elif arg_id == LevelIds.LEVEL_06__STAGE_2:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_06__L2.gd").new()
		
	elif arg_id == LevelIds.LEVEL_02__STAGE_2__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_02__L2__Hard.gd").new()
	elif arg_id == LevelIds.LEVEL_06__STAGE_2__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout02/Level_06__L2__Hard.gd").new()
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_3:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_01__L3.gd").new()
	elif arg_id == LevelIds.LEVEL_02__STAGE_3:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_02__L3.gd").new()
	elif arg_id == LevelIds.LEVEL_03__STAGE_3:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_03__L3.gd").new()
	elif arg_id == LevelIds.LEVEL_04__STAGE_3:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_04__L3.gd").new()
	elif arg_id == LevelIds.LEVEL_05__STAGE_3:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_05__L3.gd").new()
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_3__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_03__L3__Hard.gd").new()
	elif arg_id == LevelIds.LEVEL_04__STAGE_3__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_04__L3__Hard.gd").new()
	elif arg_id == LevelIds.LEVEL_05__STAGE_3__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout03/Level_05__L3__Hard.gd").new()
		
		
	elif arg_id == LevelIds.LEVEL_01__STAGE_4:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_01__L4.gd").new()
	elif arg_id == LevelIds.LEVEL_02__STAGE_4:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_02__L4.gd").new()
	elif arg_id == LevelIds.LEVEL_03__STAGE_4:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_03__L4.gd").new()
	elif arg_id == LevelIds.LEVEL_04__STAGE_4:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_04__L4.gd").new()
	elif arg_id == LevelIds.LEVEL_05__STAGE_4:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_05__L4.gd").new()
		
	elif arg_id == LevelIds.LEVEL_03__STAGE_4__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_03__L4__Hard.gd").new()
	elif arg_id == LevelIds.LEVEL_05__STAGE_4__HARD:
		return load("res://LevelRelated/BaseLevelImps/Layout04/Level_05__L4__Hard.gd").new()
	
	
	

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
		LevelIds.LEVEL_05 : 3,
		
		LevelIds.LEVEL_01__STAGE_2 : 2,
		LevelIds.LEVEL_02__STAGE_2 : 1,
		LevelIds.LEVEL_03__STAGE_2 : 2,
		LevelIds.LEVEL_04__STAGE_2 : 2,
		LevelIds.LEVEL_05__STAGE_2 : 2,
		LevelIds.LEVEL_06__STAGE_2 : 0,
		
		LevelIds.LEVEL_02__STAGE_2__HARD : 1,
		LevelIds.LEVEL_02__STAGE_2__HARD : 0,
		
		
		LevelIds.LEVEL_01__STAGE_3 : 0,
		LevelIds.LEVEL_02__STAGE_3 : 2,
		LevelIds.LEVEL_03__STAGE_3 : 1,
		LevelIds.LEVEL_04__STAGE_3 : 1,
		LevelIds.LEVEL_05__STAGE_3 : 0,
		
		LevelIds.LEVEL_03__STAGE_3__HARD : 3,
		LevelIds.LEVEL_04__STAGE_3__HARD : 2,
		
		
		LevelIds.LEVEL_01__STAGE_4 : 2,
		LevelIds.LEVEL_02__STAGE_4 : 0,
		LevelIds.LEVEL_03__STAGE_4 : 1,
		LevelIds.LEVEL_04__STAGE_4 : 2,
		LevelIds.LEVEL_05__STAGE_4 : 1,
		
		LevelIds.LEVEL_03__STAGE_4__HARD : 3,
		LevelIds.LEVEL_05__STAGE_4__HARD : 0,
		
		
	}
	
	_calculate_total_coin_count()

func _calculate_total_coin_count():
	_total_coin_count = 0
	_total_coin_count__unhidden = 0
	
	for level_id in _level_id_to_coin_amount_map.keys():
		var amount = _level_id_to_coin_amount_map[level_id]
		_total_coin_count += amount
		
		if _all_non_hidden_level_ids.has(level_id):
			_total_coin_count__unhidden += amount


func get_coin_count_for_level(arg_id):
	return _level_id_to_coin_amount_map[arg_id]

func get_total_coin_count() -> int:
	return _total_coin_count



func get_total_coin_count__unhidden():
	return _total_coin_count__unhidden

#

func _on_hidden_levels_state_changed():
	_calculate_total_coin_count()

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
		
		#######
		
		LevelIds.LEVEL_01__STAGE_2 : [LevelIds.LEVEL_05],
		LevelIds.LEVEL_02__STAGE_2 : [LevelIds.LEVEL_01__STAGE_2],
		LevelIds.LEVEL_03__STAGE_2 : [LevelIds.LEVEL_02__STAGE_2],
		LevelIds.LEVEL_04__STAGE_2 : [LevelIds.LEVEL_03__STAGE_2],
		LevelIds.LEVEL_05__STAGE_2 : [LevelIds.LEVEL_04__STAGE_2],
		LevelIds.LEVEL_06__STAGE_2 : [LevelIds.LEVEL_05__STAGE_2],
		
		LevelIds.LEVEL_02__STAGE_2__HARD : [LevelIds.LEVEL_02__STAGE_2],
		LevelIds.LEVEL_06__STAGE_2__HARD : [LevelIds.LEVEL_05__STAGE_2],
		
		####
		
		LevelIds.LEVEL_01__STAGE_3 : [LevelIds.LEVEL_06__STAGE_2, LevelIds.LEVEL_06__STAGE_2__HARD],
		LevelIds.LEVEL_02__STAGE_3 : [LevelIds.LEVEL_01__STAGE_3],
		LevelIds.LEVEL_03__STAGE_3 : [LevelIds.LEVEL_02__STAGE_3],
		LevelIds.LEVEL_04__STAGE_3 : [LevelIds.LEVEL_03__STAGE_3],
		LevelIds.LEVEL_05__STAGE_3 : [LevelIds.LEVEL_04__STAGE_3],
		
		LevelIds.LEVEL_03__STAGE_3__HARD : [LevelIds.LEVEL_03__STAGE_3],
		LevelIds.LEVEL_04__STAGE_3__HARD : [LevelIds.LEVEL_04__STAGE_3],
		LevelIds.LEVEL_05__STAGE_3__HARD : [LevelIds.LEVEL_04__STAGE_3],
		
		
		######
		
		LevelIds.LEVEL_01__STAGE_4 : [LevelIds.LEVEL_05__STAGE_3, LevelIds.LEVEL_05__STAGE_3__HARD],
		LevelIds.LEVEL_02__STAGE_4 : [LevelIds.LEVEL_01__STAGE_4],
		LevelIds.LEVEL_03__STAGE_4 : [LevelIds.LEVEL_02__STAGE_4],
		LevelIds.LEVEL_04__STAGE_4 : [LevelIds.LEVEL_03__STAGE_4],
		LevelIds.LEVEL_05__STAGE_4 : [LevelIds.LEVEL_04__STAGE_4],
		
		LevelIds.LEVEL_03__STAGE_4__HARD : [LevelIds.LEVEL_03__STAGE_4],
		LevelIds.LEVEL_05__STAGE_4__HARD : [LevelIds.LEVEL_04__STAGE_4],
		
		
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
#
###########################

func unlock_stage_05__and_unhide_eles_to_layout_05():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 18, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 19, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 20, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 21, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 22, false)
		
		
	


func unlock_stage_04__and_unhide_eles_to_layout_04():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 17, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 18, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 19, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 20, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 21, false)
		


func unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03):
		GameSaveManager.last_hovered_over_level_layout_element_id = 0 # the first one
		GameSaveManager.last_opened_level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03
		
		SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
		SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel = StoreOfLevels.LevelIds.LEVEL_01__STAGE_3
		
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 20, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 21, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 22, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 23, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 24, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 25, false)
		
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)


func unlock_stage_02__and_start_at_stage_02_01_on_level_finish__if_appropriate():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02):
		GameSaveManager.last_hovered_over_level_layout_element_id = 0 # the first one
		GameSaveManager.last_opened_level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02
		
		StoreOfLevels.set_current_level_hidden_state(StoreOfLevels.AllLevelsHiddenState.ALL_EXCEPT_FOR_TEST)
		
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
		SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel = StoreOfLevels.LevelIds.LEVEL_01__STAGE_2



###########################
### HELPERS
############################

# All black
func _set_details__transitions_to_usual_circle_types(arg_details : LevelDetails):
	arg_details.transition_id__entering_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__entering_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK




