extends Node

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

const GameBackground = preload("res://GameBackgroundRelated/GameBackground.gd")

const GUI_LevelLayout_MainMidPanel = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Subs/LevelMainMidPanel/GUI_LevelLayout_MainMidPanel.gd")

#

signal hidden_levels_state_changed()

#####


const ALL_LEVEL_ID_NAMES__STAGE_X_FOR_BEFORE_POSTGAME = [
	"STAGE_1",
	"STAGE_2",
	"STAGE_3",
	"STAGE_4",
	"STAGE_5",
	"STAGE_SPECIAL_1",
	
]

enum LevelIds {
	TEST = -10,
	
	LEVEL_01__STAGE_1 = 1
	LEVEL_02__STAGE_1 = 2
	LEVEL_03__STAGE_1 = 3
	LEVEL_04__STAGE_1 = 4
	LEVEL_05__STAGE_1 = 5
	
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
	#LEVEL_06__STAGE_3 = 205
	
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
	LEVEL_04__STAGE_4__HARD = 351
	LEVEL_05__STAGE_4__HARD = 352
	
	##
	
	LEVEL_01__STAGE_5 = 400
	LEVEL_02__STAGE_5 = 401
	
	
	##
	
	LEVEL_01__STAGE_SPECIAL_1 = 10000
	LEVEL_02__STAGE_SPECIAL_1 = 10001
	LEVEL_03__STAGE_SPECIAL_1 = 10002
	LEVEL_04__STAGE_SPECIAL_1 = 10003
	
	##
	
	LEVEL_01__STAGE_6 = 500
	LEVEL_02__STAGE_6 = 501
	LEVEL_03__STAGE_6 = 502
	LEVEL_04__STAGE_6 = 503
	LEVEL_05__STAGE_6 = 504
	LEVEL_06__STAGE_6 = 505
	LEVEL_07__STAGE_6 = 506
	
	LEVEL_04__STAGE_6__HARD = 550
	LEVEL_04__STAGE_6__HARD_V02 = 551
	LEVEL_06__STAGE_6__HARD = 552
	LEVEL_06__STAGE_6__HARD_V02 = 553
	LEVEL_07__STAGE_6__HARD = 554
	
	##
	
	LEVEL_01__STAGE_7 = 600
	
	##
	
	LEVEL_01__STAGE_SPECIAL_2 = 10100
	LEVEL_02__STAGE_SPECIAL_2 = 10101
	
}
# dont change this in runtime(useless). 
# This determines which levels are not hidden at the very start, before any save states. i.e. not hidden by default
const level_ids_not_hidden : Array = [
	#LevelIds.TEST,
	
	LevelIds.LEVEL_01__STAGE_1,
	LevelIds.LEVEL_02__STAGE_1,
	LevelIds.LEVEL_03__STAGE_1,
	LevelIds.LEVEL_04__STAGE_1,
	LevelIds.LEVEL_05__STAGE_1,
	
]

var _all_non_hidden_level_ids : Array

#

var _level_id_to_level_details_map : Dictionary = {}

var _level_id_to_coin_amount_map : Dictionary
var _total_coin_count : int
var _total_coin_count__unhidden : int


var level_ids_unlocked_by_default = [
	LevelIds.LEVEL_01__STAGE_1
]


var _level_id_to_level_ids_required_for_unlock : Dictionary



enum AllLevelsHiddenState {
	FIRST_STAGE_ONLY = 0,
	BEFORE_POSTGAME_STAGE_05 = 1,
	AFTER_POSTGAME_STAGE_05 = 2,
}
var current_level_hidden_state : int setget set_current_level_hidden_state, get_current_levels_hidden_state

# should never happen normally...
const DEFAULT_LEVEL_ID_FOR_EMPTY = LevelIds.TEST

#

var _level_layout_id_to_level_id_map : Dictionary
# see func to initialize this
var _stage_name_to_level_layout_id_map : Dictionary

#

const MODULATE_LEVEL_HOVER_LIST__NORMAL = [Color("#ADADAD")]
const MODULATE_LEVEL_HOVER_LIST__CHALLENGE = [Color("#FC0307")]
const MODULATE_LEVEL_HOVER_LIST__CHALLENGE_WITH_VIO = [Color("#FC0307"), Color("#6C02DA")]
const MODULATE_LEVEL_HOVER_LIST__VIO = [Color("#6C02DA")]

const MODULATE_LEVEL_HOVER_LIST__YELLOW = [Color("#9CB102")]
const MODULATE_LEVEL_HOVER_LIST__BLUE = [Color("#462BFD")]
const MODULATE_LEVEL_HOVER_LIST__MAGNUM_OPUS = [Color("#440297"), Color("#E3AB02")]
const MODULATE_LEVEL_HOVER_LIST__CONSTELLATION = [Color("#FEEDB9"), Color("#454545")]


#################

func _initialize_levels_in_level_layout():
	_stage_name_to_level_layout_id_map = {
		"STAGE_1" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01,
		"STAGE_2" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02,
		"STAGE_3" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03,
		"STAGE_4" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04,
		"STAGE_5" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05,
		
		"STAGE_SPECIAL_1" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01,
		
		"STAGE_6" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06,
		"STAGE_7" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_07,
		
		"STAGE_SPECIAL_2" : StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02,
		
	}
	
	##
	
	for level_id_name in LevelIds.keys():
		for stage_name in _stage_name_to_level_layout_id_map.keys():
			if stage_name in level_id_name:
				var layout_id = _stage_name_to_level_layout_id_map[stage_name]
				if !_level_layout_id_to_level_id_map.has(layout_id):
					_level_layout_id_to_level_id_map[layout_id] = []
				_level_layout_id_to_level_id_map[layout_id].append(LevelIds[level_id_name])
	

##

func _init():
	_initialize__all_non_hidden_level_ids()
	


func _ready():
	_initialize_levels_in_level_layout()
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
		
		if arg_emit_signal:
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

#

func get_level_ids__before_postgame():
	var bucket = []
	
	for level_id_key in LevelIds.keys():
		var find_index__for_test = level_id_key.findn("TEST")
		var find_index__for_before_postgame_name_str = -1
		for name_str in ALL_LEVEL_ID_NAMES__STAGE_X_FOR_BEFORE_POSTGAME:
			var find_index = level_id_key.findn(name_str)
			if find_index != -1:
				find_index__for_before_postgame_name_str = find_index
		
		
		if find_index__for_test == -1 and find_index__for_before_postgame_name_str != -1:
			
			bucket.append(LevelIds[level_id_key])
	
	return bucket

#

func get_current_levels_hidden_state():
	return current_level_hidden_state

func set_current_level_hidden_state(arg_val):
	current_level_hidden_state = arg_val
	
	if current_level_hidden_state == AllLevelsHiddenState.FIRST_STAGE_ONLY:
		pass
		
	elif current_level_hidden_state == AllLevelsHiddenState.BEFORE_POSTGAME_STAGE_05:
		_add_level_ids_as_non_hidden(get_level_ids__before_postgame())
		
	elif current_level_hidden_state == AllLevelsHiddenState.AFTER_POSTGAME_STAGE_05:
		_add_level_ids_as_non_hidden(get_all_level_ids__not_including_tests())
	

###

func is_level_layout_all_associated_levels_completed(arg_layout_id):
	for level_id in _level_layout_id_to_level_id_map[arg_layout_id]:
		if !GameSaveManager.is_level_id_finished(level_id):
			return false
	
	return true

func is_level_layout_all_associated_levels_all_coins_collected(arg_layout_id):
	for level_id in _level_layout_id_to_level_id_map[arg_layout_id]:
		if !GameSaveManager.is_all_coins_collected_in_level(level_id):
			return false
	
	return true


# coins, level compl
func get_level_layout_completion_status__for_all(arg_layout_id):
	var all_levels_completed : bool = true
	var all_coins_collected : bool = true
	for level_id in _level_layout_id_to_level_id_map[arg_layout_id]:
		if !GameSaveManager.is_all_coins_collected_in_level(level_id):
			all_coins_collected = false
		
		if !GameSaveManager.is_level_id_finished(level_id):
			all_levels_completed = false
		
		
		###
		if !all_coins_collected and !all_levels_completed:
			break
	
	return [all_coins_collected, all_levels_completed]

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
	
	match arg_id:
		LevelIds.TEST:
			level_details.level_name = [
				["TestName Desc", []]
			]
			level_details.level_desc = [
				["Testing Desc Lorem ipsum", []]
			]
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			
			
		LevelIds.LEVEL_01__STAGE_1:
			level_details.level_name = [
				["Beginnings", []]
			]
			level_details.level_desc = [
				["A step in a thousand mile journey... Well, you can't really make a step here but you know what I mean...", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.can_start_playlist_on_master = false
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "01"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
		LevelIds.LEVEL_02__STAGE_1:
			level_details.level_name = [
				["Decision", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
		LevelIds.LEVEL_03__STAGE_1:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__YELLOW
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_04__STAGE_1:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__YELLOW
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_05__STAGE_1:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.LVL_01_05
			
			
		LevelIds.LEVEL_01__STAGE_2:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_02__STAGE_2:
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
			
			level_details.level_label_on_tile = "02"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_02__STAGE_2__HARD:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
			_attach_custom_behavior_to_lvl_details__show_4_point_star_based_on_conditions(level_details)
			
		LevelIds.LEVEL_03__STAGE_2:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_04__STAGE_2:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_05__STAGE_2:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_06__STAGE_2:
			level_details.level_full_name = [
				["2-6 Path Maker", []]
			]
			level_details.level_name = [
				["Path Maker", []]
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_NORMAL
			
			
		LevelIds.LEVEL_06__STAGE_2__HARD:
			level_details.level_full_name = [
				["2-!6 Path Maker V2", []]
			]
			level_details.level_name = [
				["Path Maker V2", []]
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE_WITH_VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_CHALLENGE
			
			
		LevelIds.LEVEL_01__STAGE_3:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_02__STAGE_3:
			level_details.level_full_name = [
				["3-2 Direction", []]
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
			
			level_details.level_label_on_tile = "02"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_03__STAGE_3:
			level_details.level_full_name = [
				["3-3 Parity", []]
			]
			level_details.level_name = [
				["Parity", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_03__STAGE_3__HARD:
			level_details.level_full_name = [
				["3-!3 Parity V2", []]
			]
			level_details.level_name = [
				["Parity V2", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_04__STAGE_3:
			level_details.level_full_name = [
				["3-4 Holes", []]
			]
			level_details.level_name = [
				["Holes", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_04__STAGE_3__HARD:
			level_details.level_full_name = [
				["3-!4 Trickshot", []]
			]
			level_details.level_name = [
				["Trickshot", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_05__STAGE_3:
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_NORMAL
			
			
		LevelIds.LEVEL_05__STAGE_3__HARD:
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE_WITH_VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_CHALLENGE
			
			
		LevelIds.LEVEL_01__STAGE_4:
			level_details.level_full_name = [
				["4-1 Breakables", []]
			]
			level_details.level_name = [
				["Breakables", []]
			]
			level_details.level_desc = [
				["Breakables", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_02__STAGE_4:
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_03__STAGE_4:
			level_details.level_full_name = [
				["4-3 Speed Limit", []]
			]
			level_details.level_name = [
				["Speed Limit", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_03__STAGE_4__HARD:
			level_details.level_full_name = [
				["4-!3 Speed Control", []]
			]
			level_details.level_name = [
				["Speed Control", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_04__STAGE_4:
			level_details.level_full_name = [
				["4-4 Speed", []]
			]
			level_details.level_name = [
				["Speed", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_04__STAGE_4__HARD:
			level_details.level_full_name = [
				["4-!4 Speed 2.0", []]
			]
			level_details.level_name = [
				["Speed 2.0", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_05__STAGE_4:
			level_details.level_full_name = [
				["4-5 One Way", []]
			]
			level_details.level_name = [
				["One Way", []]
			]
			level_details.level_desc = [
				["Commitment to one way.", []]
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_NORMAL
			
			
		LevelIds.LEVEL_05__STAGE_4__HARD:
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE_WITH_VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_CHALLENGE
			
			
		LevelIds.LEVEL_01__STAGE_5:
			level_details.level_full_name = [
				["5-0 Limitless", []]
			]
			level_details.level_name = [
				["Limitless", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_SpecialBlue_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "00"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__BLUE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.STAGE_05
			
			
		LevelIds.LEVEL_02__STAGE_5:
			level_details.level_full_name = [
				["5-1 True Escape", []]
			]
			level_details.level_name = [
				["True Escape", []]
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
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__BLUE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.STAGE_05
			
			
		LevelIds.LEVEL_01__STAGE_6:
			level_details.level_full_name = [
				["6-1 Prelude", []]
			]
			level_details.level_name = [
				["Prelude", []]
			]
			level_details.level_desc = [
				["The adventure's ain't over, yet", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_02__STAGE_6:
			level_details.level_full_name = [
				["6-2 First Contact", []]
			]
			level_details.level_name = [
				["First Contact", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_03__STAGE_6:
			level_details.level_full_name = [
				["6-3 Colony", []]
			]
			level_details.level_name = [
				["Colony", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_04__STAGE_6:
			level_details.level_full_name = [
				["6-4 Painful Aid", []]
			]
			level_details.level_name = [
				["Painful Aid", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_04__STAGE_6__HARD:
			level_details.level_full_name = [
				["6-!4 Reveal", []]
			]
			level_details.level_name = [
				["Reveal", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_04__STAGE_6__HARD_V02:
			level_details.level_full_name = [
				["6-?4 Reveal v2", []]
			]
			level_details.level_name = [
				["Reveal v2", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "?4"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_05__STAGE_6:
			level_details.level_full_name = [
				["6-5 Intercept", []]
			]
			level_details.level_name = [
				["Intercept", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_06__STAGE_6:
			level_details.level_full_name = [
				["6-6 Happy Feet", []]
			]
			level_details.level_name = [
				["Happy Feet", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Gray_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "06"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_06__STAGE_6__HARD:
			level_details.level_full_name = [
				["6-!6 Moving Capture", []]
			]
			level_details.level_name = [
				["Moving Capture", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "!6"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
		LevelIds.LEVEL_06__STAGE_6__HARD_V02:
			level_details.level_full_name = [
				["6-?6 Unrewindable", []]
			]
			level_details.level_name = [
				["Unrewindable", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "?6"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CHALLENGE
			
			
			
		LevelIds.LEVEL_07__STAGE_6:
			level_details.level_full_name = [
				["6-7 Range", []]
			]
			level_details.level_name = [
				["Range", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_Violet_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "07"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_NORMAL
			
			
			
		LevelIds.LEVEL_07__STAGE_6__HARD:
			level_details.level_full_name = [
				["6-!7 Slider", []]
			]
			level_details.level_name = [
				["Slider", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedWithVio_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "!7"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			level_details.additional_level_ids_to_mark_as_complete.append(LevelIds.LEVEL_07__STAGE_6)
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.RISING_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE_WITH_VIO
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.BRANCHING_CHALLENGE
			
			
		LevelIds.LEVEL_01__STAGE_7:
			level_details.level_full_name = [
				["7-1 New Tool", []]
			]
			level_details.level_name = [
				["New Tool", []]
			]
			level_details.level_desc = [
				["Future content", []]
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
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__NORMAL
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.NORMAL
			
			
		LevelIds.LEVEL_01__STAGE_SPECIAL_1:
			level_details.level_full_name = [
				["S-!1 Darkness", []]
			]
			level_details.level_name = [
				["Darkness", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Stage01_RedChallenge_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = "!1"
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			level_details.ignore_assist_mode_modifications = true
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.background_type = GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.SUSPENSE_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.SPEC_CHALLENGE
			
			
		LevelIds.LEVEL_02__STAGE_SPECIAL_1:
			level_details.level_full_name = [
				["S-!2 Too Late", []]
			]
			level_details.level_name = [
				["Too Late", []]
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
			
			level_details.ignore_assist_mode_modifications = true
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.background_type = GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.SUSPENSE_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.SPEC_CHALLENGE
			
			
		LevelIds.LEVEL_03__STAGE_SPECIAL_1:
			#NOTE: assist mode in enabled for this specific special level.
			level_details.level_full_name = [
				["S-!3 Zero", []]
			]
			level_details.level_name = [
				["Zero", []]
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
			
			#an exception to the rule
			#level_details.ignore_assist_mode_modifications = true
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.background_type = GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.SUSPENSE_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.SPEC_CHALLENGE
			
			
		LevelIds.LEVEL_04__STAGE_SPECIAL_1:
			level_details.level_full_name = [
				["S-!4 Losing Control", []]
			]
			level_details.level_name = [
				["Losing Control", []]
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
			
			
			level_details.ignore_assist_mode_modifications = true
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			level_details.background_type = GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.SUSPENSE_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CHALLENGE
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.SPEC_CHALLENGE
			
			
		LevelIds.LEVEL_01__STAGE_SPECIAL_2:
			level_details.level_full_name = [
				["Magnum Opus", []]
			]
			level_details.level_name = [
				["Magnum Opus", []]
			]
			level_details.level_desc = [
				["", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_StageSpec02_Opus_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = ""
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			
			level_details.ignore_assist_mode_modifications = true
			
			level_details.level_type = level_details.LevelTypeId.CHALLENGE
			
			
			level_details.background_type = GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01
			
			level_details.BGM_playlist_id_to_use__on_level_start = StoreOfAudio.BGMPlaylistId.SUSPENSE_01
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__MAGNUM_OPUS
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.MAGNUM_OPUS
			
			
		LevelIds.LEVEL_02__STAGE_SPECIAL_2:
			level_details.level_full_name = [
				["Constellation", []]
			]
			level_details.level_name = [
				["Constellation", []]
			]
			level_details.level_desc = [
				["If I could be a", []]
			]
			
			
			_set_details__transitions_to_usual_circle_types(level_details)
			#level_details.transition_id__exiting_level__in = StoreOfTransitionSprites.TransitionSpriteIds.NONE
			#level_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.NONE
			
			level_details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_StageSpec02_CurCall_32x32.png")
			level_details.modulate_of_level_tile = Color(1, 1, 1, 1)
			
			level_details.texture_of_level_tile__locked = level_details.texture_of_level_tile
			level_details.modulate_of_level_tile__locked = LevelDetails.DEFAULT_LEVEL_TILE_LOCKED_MODULATE
			
			level_details.level_label_on_tile = ""
			level_details.level_label_text_color = Color("#dddddd")
			#level_details.level_label_outline_color = Color("#dddddd")
			level_details.has_outline_color = false
			
			
			level_details.ignore_assist_mode_modifications = true
			
			level_details.level_type = level_details.LevelTypeId.FOR_FUN
			
			
			level_details.background_type = GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01
			
			#note: only for this!
			level_details.queue_free_gui_level_selection_panel = false
			level_details.immediately_start_stats_record_on_GE_ready = false
			
			level_details.modulates_for_level_hover_list = MODULATE_LEVEL_HOVER_LIST__CONSTELLATION
			
			level_details.rect_particle_type_id_for_level_layout_main_mid_panel = GUI_LevelLayout_MainMidPanel.MainMidPanelColorTemplateType.CONSTELLATION
			
	
	##
	
	_level_id_to_level_details_map[arg_id] = level_details
	
	#
	
	_set_level_details_configs_and_params_based_on_GSM(level_details)
	
	#
	
	return level_details

##

func _attach_custom_behavior_to_lvl_details__show_4_point_star_based_on_conditions(arg_lvl_details : LevelDetails):
	_update_lvl_details__volatile__is_show_four_pointed_star_vfx__based_on_conditions(arg_lvl_details)
	
	GameSaveManager.connect("level_id_completion_status_changed", self, "_on_level_id_completion_status_changed__for_4_pointed_star_for_02_02_hard", [arg_lvl_details])
	GameSaveManager.connect("level_layout_id_completion_status_changed", self, "_on_level_layout_id_completion_status_changed__for_4_pointed_star_for_02_02_hard", [arg_lvl_details])

func _on_level_id_completion_status_changed__for_4_pointed_star_for_02_02_hard(arg_id, arg_status, arg_lvl_details):
	if arg_id == LevelIds.LEVEL_01__STAGE_7:
		_update_lvl_details__volatile__is_show_four_pointed_star_vfx__based_on_conditions(arg_lvl_details)
	

func _on_level_layout_id_completion_status_changed__for_4_pointed_star_for_02_02_hard(arg_id, arg_status, arg_lvl_details):
	if arg_id == StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01:
		_update_lvl_details__volatile__is_show_four_pointed_star_vfx__based_on_conditions(arg_lvl_details)
	


func _update_lvl_details__volatile__is_show_four_pointed_star_vfx__based_on_conditions(arg_lvl_details):
	arg_lvl_details.volatile__is_show_four_pointed_star_vfx = GameSaveManager.is_level_id_finished(StoreOfLevels.LevelIds.LEVEL_01__STAGE_7) and !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01)
	
	#arg_lvl_details.volatile__is_show_four_pointed_star_vfx = true

#####

func generate_base_level_imp_new(arg_id):
	match arg_id:
		LevelIds.TEST:
			return load("res://LevelRelated/BaseLevelImps/Test/Level_Test01.gd").new()
		LevelIds.LEVEL_01__STAGE_1:
			return load("res://LevelRelated/BaseLevelImps/Layout01/Level_01.gd").new()
		LevelIds.LEVEL_02__STAGE_1:
			return load("res://LevelRelated/BaseLevelImps/Layout01/Level_02.gd").new()
		LevelIds.LEVEL_03__STAGE_1:
			return load("res://LevelRelated/BaseLevelImps/Layout01/Level_03.gd").new()
		LevelIds.LEVEL_04__STAGE_1:
			return load("res://LevelRelated/BaseLevelImps/Layout01/Level_04.gd").new()
		LevelIds.LEVEL_05__STAGE_1:
			return load("res://LevelRelated/BaseLevelImps/Layout01/Level_05.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_2:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_01__L2.gd").new()
		LevelIds.LEVEL_02__STAGE_2:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_02__L2.gd").new()
		LevelIds.LEVEL_03__STAGE_2:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_03__L2.gd").new()
		LevelIds.LEVEL_04__STAGE_2:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_04__L2.gd").new()
		LevelIds.LEVEL_05__STAGE_2:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_05__L2.gd").new()
		LevelIds.LEVEL_06__STAGE_2:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_06__L2.gd").new()
		
		LevelIds.LEVEL_02__STAGE_2__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_02__L2__Hard.gd").new()
		LevelIds.LEVEL_06__STAGE_2__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout02/Level_06__L2__Hard.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_3:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_01__L3.gd").new()
		LevelIds.LEVEL_02__STAGE_3:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_02__L3.gd").new()
		LevelIds.LEVEL_03__STAGE_3:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_03__L3.gd").new()
		LevelIds.LEVEL_04__STAGE_3:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_04__L3.gd").new()
		LevelIds.LEVEL_05__STAGE_3:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_05__L3.gd").new()
		
		LevelIds.LEVEL_03__STAGE_3__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_03__L3__Hard.gd").new()
		LevelIds.LEVEL_04__STAGE_3__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_04__L3__Hard.gd").new()
		LevelIds.LEVEL_05__STAGE_3__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout03/Level_05__L3__Hard.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_4:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_01__L4.gd").new()
		LevelIds.LEVEL_02__STAGE_4:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_02__L4.gd").new()
		LevelIds.LEVEL_03__STAGE_4:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_03__L4.gd").new()
		LevelIds.LEVEL_04__STAGE_4:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_04__L4.gd").new()
		LevelIds.LEVEL_05__STAGE_4:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_05__L4.gd").new()
		
		LevelIds.LEVEL_03__STAGE_4__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_03__L4__Hard.gd").new()
		LevelIds.LEVEL_04__STAGE_4__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_04__L4__Hard.gd").new()
		LevelIds.LEVEL_05__STAGE_4__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout04/Level_05__L4__Hard.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_5:
			return load("res://LevelRelated/BaseLevelImps/Layout05/Level_01__L5.gd").new()
		LevelIds.LEVEL_02__STAGE_5:
			return load("res://LevelRelated/BaseLevelImps/Layout05/Level_02__L5.gd").new()
		
		
		
		LevelIds.LEVEL_01__STAGE_SPECIAL_1:
			return load("res://LevelRelated/BaseLevelImps/LayoutSpecial01/Level_01__LSpecial1.gd").new()
		LevelIds.LEVEL_02__STAGE_SPECIAL_1:
			return load("res://LevelRelated/BaseLevelImps/LayoutSpecial01/Level_02__LSpecial1.gd").new()
		LevelIds.LEVEL_03__STAGE_SPECIAL_1:
			return load("res://LevelRelated/BaseLevelImps/LayoutSpecial01/Level_03__LSpecial1.gd").new()
		LevelIds.LEVEL_04__STAGE_SPECIAL_1:
			return load("res://LevelRelated/BaseLevelImps/LayoutSpecial01/Level_04__LSpecial1.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_01__L6.gd").new()
		LevelIds.LEVEL_02__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_02__L6.gd").new()
		LevelIds.LEVEL_03__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_03__L6.gd").new()
		LevelIds.LEVEL_04__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_04__L6.gd").new()
		LevelIds.LEVEL_05__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_05__L6.gd").new()
		LevelIds.LEVEL_06__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_06__L6.gd").new()
		LevelIds.LEVEL_07__STAGE_6:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_07__L6.gd").new()
		
		LevelIds.LEVEL_04__STAGE_6__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_04__L6__Hard.gd").new()
		LevelIds.LEVEL_04__STAGE_6__HARD_V02:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_04__L6__Hard_V02.gd").new()
		LevelIds.LEVEL_06__STAGE_6__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_06__L6__Hard.gd").new()
		LevelIds.LEVEL_06__STAGE_6__HARD_V02:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_06__L6__Hard_V02.gd").new()
		LevelIds.LEVEL_07__STAGE_6__HARD:
			return load("res://LevelRelated/BaseLevelImps/Layout06/Level_07__L6__Hard.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_7:
			return load("res://LevelRelated/BaseLevelImps/Layout07/Level_01__L7.gd").new()
		
		
		LevelIds.LEVEL_01__STAGE_SPECIAL_2:
			return load("res://LevelRelated/BaseLevelImps/LayoutSpecial02/Level_01__LSpecial2.gd").new()
		LevelIds.LEVEL_02__STAGE_SPECIAL_2:
			return load("res://LevelRelated/BaseLevelImps/LayoutSpecial02/Level_02__LSpecial2.gd").new()
	
	

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
		
		LevelIds.LEVEL_01__STAGE_1 : 1,
		LevelIds.LEVEL_02__STAGE_1 : 1,
		LevelIds.LEVEL_03__STAGE_1 : 1,
		LevelIds.LEVEL_04__STAGE_1 : 1,
		LevelIds.LEVEL_05__STAGE_1 : 1,
		
		LevelIds.LEVEL_01__STAGE_2 : 1,
		LevelIds.LEVEL_02__STAGE_2 : 1,
		LevelIds.LEVEL_03__STAGE_2 : 1,
		LevelIds.LEVEL_04__STAGE_2 : 1,
		LevelIds.LEVEL_05__STAGE_2 : 1,
		LevelIds.LEVEL_06__STAGE_2 : 1,
		
		LevelIds.LEVEL_02__STAGE_2__HARD : 1,
		LevelIds.LEVEL_06__STAGE_2__HARD : 1,
		
		
		LevelIds.LEVEL_01__STAGE_3 : 1,
		LevelIds.LEVEL_02__STAGE_3 : 1,
		LevelIds.LEVEL_03__STAGE_3 : 1,
		LevelIds.LEVEL_04__STAGE_3 : 1,
		LevelIds.LEVEL_05__STAGE_3 : 1,
		
		LevelIds.LEVEL_03__STAGE_3__HARD : 1,
		LevelIds.LEVEL_04__STAGE_3__HARD : 1,
		LevelIds.LEVEL_05__STAGE_3__HARD : 1,
		
		
		LevelIds.LEVEL_01__STAGE_4 : 1,
		LevelIds.LEVEL_02__STAGE_4 : 1,
		LevelIds.LEVEL_03__STAGE_4 : 1,
		LevelIds.LEVEL_04__STAGE_4 : 1,
		LevelIds.LEVEL_05__STAGE_4 : 1,
		
		LevelIds.LEVEL_03__STAGE_4__HARD : 1,
		LevelIds.LEVEL_04__STAGE_4__HARD : 1,
		LevelIds.LEVEL_05__STAGE_4__HARD : 1,
		
		
		LevelIds.LEVEL_01__STAGE_5 : 1,
		LevelIds.LEVEL_02__STAGE_5 : 1,
		
		#
		
		LevelIds.LEVEL_01__STAGE_SPECIAL_1 : 1,
		LevelIds.LEVEL_02__STAGE_SPECIAL_1 : 1,
		LevelIds.LEVEL_03__STAGE_SPECIAL_1 : 1,
		LevelIds.LEVEL_04__STAGE_SPECIAL_1 : 1,
		
		
		#
		
		LevelIds.LEVEL_01__STAGE_6 : 1,
		LevelIds.LEVEL_02__STAGE_6 : 1,
		LevelIds.LEVEL_03__STAGE_6 : 1,
		LevelIds.LEVEL_04__STAGE_6 : 1,
		LevelIds.LEVEL_05__STAGE_6 : 1,
		LevelIds.LEVEL_06__STAGE_6 : 1,
		LevelIds.LEVEL_07__STAGE_6 : 1,
		
		LevelIds.LEVEL_04__STAGE_6__HARD : 1,
		LevelIds.LEVEL_04__STAGE_6__HARD_V02 : 1,
		LevelIds.LEVEL_06__STAGE_6__HARD : 1,
		LevelIds.LEVEL_06__STAGE_6__HARD_V02 : 1,
		LevelIds.LEVEL_07__STAGE_6__HARD : 1,
		
		##
		
		LevelIds.LEVEL_01__STAGE_7 : 1,
		
		#
		
		LevelIds.LEVEL_01__STAGE_SPECIAL_2 : 1,
		LevelIds.LEVEL_02__STAGE_SPECIAL_2 : 1,
		
		
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
	_attempt_unlock_levels_based_on_level_status_changed(arg_id, arg_status)
	
	if _level_id_to_level_details_map.has(arg_id):
		var details = _level_id_to_level_details_map[arg_id]
		_set_level_details_configs_and_params_based_on_GSM(details)


func _set_level_details_configs_and_params_based_on_GSM(arg_details : LevelDetails):
	arg_details.is_level_locked = !GameSaveManager.is_level_id_playable(arg_details.level_id)


###
# UNLOCK REQUIRMENETS
##

func _initialize_level_id_unlock_requirmenets():
	_level_id_to_level_ids_required_for_unlock = {
		LevelIds.LEVEL_01__STAGE_1 : [],
		LevelIds.LEVEL_02__STAGE_1 : [LevelIds.LEVEL_01__STAGE_1],
		LevelIds.LEVEL_03__STAGE_1 : [LevelIds.LEVEL_02__STAGE_1],
		LevelIds.LEVEL_04__STAGE_1 : [LevelIds.LEVEL_03__STAGE_1],
		LevelIds.LEVEL_05__STAGE_1 : [LevelIds.LEVEL_04__STAGE_1],
		
		#######
		
		LevelIds.LEVEL_01__STAGE_2 : [LevelIds.LEVEL_05__STAGE_1],
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
		LevelIds.LEVEL_04__STAGE_4__HARD : [LevelIds.LEVEL_04__STAGE_4],
		LevelIds.LEVEL_05__STAGE_4__HARD : [LevelIds.LEVEL_04__STAGE_4],
		
		
		##
		
		LevelIds.LEVEL_01__STAGE_5 : [LevelIds.LEVEL_05__STAGE_4, LevelIds.LEVEL_05__STAGE_4__HARD],
		LevelIds.LEVEL_02__STAGE_5 : [LevelIds.LEVEL_01__STAGE_5],
		
		##
		
		LevelIds.LEVEL_01__STAGE_6 : [LevelIds.LEVEL_02__STAGE_5],
		LevelIds.LEVEL_02__STAGE_6 : [LevelIds.LEVEL_01__STAGE_6],
		LevelIds.LEVEL_03__STAGE_6 : [LevelIds.LEVEL_02__STAGE_6],
		LevelIds.LEVEL_04__STAGE_6 : [LevelIds.LEVEL_03__STAGE_6],
		LevelIds.LEVEL_05__STAGE_6 : [LevelIds.LEVEL_04__STAGE_6],
		LevelIds.LEVEL_06__STAGE_6 : [LevelIds.LEVEL_05__STAGE_6],
		LevelIds.LEVEL_07__STAGE_6 : [LevelIds.LEVEL_06__STAGE_6],
		
		LevelIds.LEVEL_04__STAGE_6__HARD : [LevelIds.LEVEL_04__STAGE_6],
		LevelIds.LEVEL_04__STAGE_6__HARD_V02 : [LevelIds.LEVEL_04__STAGE_6__HARD],
		LevelIds.LEVEL_06__STAGE_6__HARD : [LevelIds.LEVEL_06__STAGE_6],
		LevelIds.LEVEL_06__STAGE_6__HARD_V02 : [LevelIds.LEVEL_06__STAGE_6__HARD],
		LevelIds.LEVEL_07__STAGE_6__HARD : [LevelIds.LEVEL_06__STAGE_6],
		
		##
		
		LevelIds.LEVEL_01__STAGE_7 : [LevelIds.LEVEL_07__STAGE_6, LevelIds.LEVEL_07__STAGE_6__HARD],
		
		##
		
		LevelIds.LEVEL_02__STAGE_SPECIAL_2 : [LevelIds.LEVEL_01__STAGE_SPECIAL_2],
		
		
	}

func _attempt_unlock_levels_based_on_level_status_changed(arg_level_id, arg_status):
	if arg_status == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED:
		for candi_level_id_to_unlock in _level_id_to_level_ids_required_for_unlock.keys():
			
			var unlock : bool = false
			for x_needed in _level_id_to_level_ids_required_for_unlock[candi_level_id_to_unlock]:
				#print("testing level id needed: %s" % level_id_needed)
				
				if typeof(x_needed) == TYPE_INT:
					if _is_level_id_finished(x_needed):
						unlock = true
						break
						
					
				elif typeof(x_needed) == TYPE_ARRAY:
					if _are_all_level_ids_finished(x_needed):
						unlock = true
						break
					
				
				
			
			if unlock:
				if !GameSaveManager.is_level_id_playable(candi_level_id_to_unlock):
					#print("unlocked id: %s" % candi_level_id_to_unlock)
					GameSaveManager.set_level_id_status_completion(candi_level_id_to_unlock, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)

func _is_level_id_finished(arg_level_id):
	return GameSaveManager.is_level_id_finished(arg_level_id)

func _are_all_level_ids_finished(arg_ids : Array):
	for id in arg_ids:
		if !_is_level_id_finished(id):
			return false
	
	return true

###########################
#
###########################


func attempt_finish_level_layout__spec_02():
	#if GameSaveManager.get_level_id_status_completion(LevelIds.LEVEL_01__STAGE_SPECIAL_2) == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED:
	#	GameSaveManager.set_level_id_status_completion(LevelIds.LEVEL_01__STAGE_SPECIAL_2, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
	GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)

# on finish MAGNUM OPUS
# unlock trophy (curtain call) level
func attempt_do_unlock_actions_on_finish_level_01_of_stage_special_02():
	if GameSaveManager.get_level_id_status_completion(LevelIds.LEVEL_01__STAGE_SPECIAL_2) == GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED:
		#gets finished so no need to set
		
		var layout_ele_of_trophy_round = 15
		for i in range(3, layout_ele_of_trophy_round + 1):
			GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02, i, false)
		
		GameSaveManager.last_hovered_over_level_layout_element_id = layout_ele_of_trophy_round
		
		#
		return true
	
	return false

func directly_go_to_spec02_02_on_level_finish():
	SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
	SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel = StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_2



func attempt_unlock_stage_special_02__and_unhide_eles_to_layout_special_02():
	if can_unlock_stage_special_02():
		_unlock_stage_special_02__and_unhide_eles_to_layout_special_02()

func _unlock_stage_special_02__and_unhide_eles_to_layout_special_02():
	GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
	GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
	
	GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, 20, false)
	GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, 21, false)
	GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, 22, false)
	GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, 23, false)
	GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, 24, false)
	
	GameSaveManager.set_level_id_status_completion(LevelIds.LEVEL_01__STAGE_SPECIAL_2, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)



# u can leave at least 1 (2-1) locked and it will advance
func can_unlock_stage_special_02():
	var locked_counter = 0
	for lvl_id in _level_layout_id_to_level_id_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01]:
		if !GameSaveManager.is_level_id_finished(lvl_id):
			locked_counter += 1
			if locked_counter > 2:
				return false
	
	return !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02)




func unlock_stage_07__and_unhide_eles_to_layout_07():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_07):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_07, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 25, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 26, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 27, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 28, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 29, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 30, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, 31, false)
		


func unlock_stage_special_01__and_unhide_eles_to_layout_special_01():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 25, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 26, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 27, false)
		
		_unlock_special_stage_01_levels()

func _unlock_special_stage_01_levels():
	for level_id in _level_layout_id_to_level_id_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01]:
		GameSaveManager.set_level_id_status_completion(level_id, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
	
#	GameSaveManager.set_level_layout_id_status_completion(LevelIds.LEVEL_01__STAGE_SPECIAL_1, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
#	GameSaveManager.set_level_layout_id_status_completion(LevelIds.LEVEL_02__STAGE_SPECIAL_1, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
#	GameSaveManager.set_level_layout_id_status_completion(LevelIds.LEVEL_03__STAGE_SPECIAL_1, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
#	GameSaveManager.set_level_layout_id_status_completion(LevelIds.LEVEL_04__STAGE_SPECIAL_1, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)



func unlock_relateds_after_winning_stage_05_level_02():
	if !GameSaveManager.is_level_id_finished(LevelIds.LEVEL_02__STAGE_5):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, 13, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, 14, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, 15, false)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, 16, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, 17, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, 18, false)
		
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, 11, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, 12, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, 13, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, 14, false)
		
		# done this only now to make it unlocked in shortcut panel
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		#
		GameSaveManager.set_is_player_health_invulnerable__to_true()
		
		StoreOfLevels.set_current_level_hidden_state(StoreOfLevels.AllLevelsHiddenState.AFTER_POSTGAME_STAGE_05)

func unlock_and_goto_stage_05_level_02_on_win():
	if !GameSaveManager.is_level_id_finished(LevelIds.LEVEL_01__STAGE_5):
		SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
		SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel = StoreOfLevels.LevelIds.LEVEL_02__STAGE_5
		
		GameSaveManager.last_hovered_over_level_layout_element_id = 12  #7
		GameSaveManager.last_opened_level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05
		


func unlock_stage_05__and_unhide_eles_to_layout_05():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 17, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 18, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 19, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 20, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, 21, false)
		
		
	


func unlock_stage_04__and_unhide_eles_to_layout_04():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04):
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 18, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 19, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 20, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 21, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 22, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, 23, false)
		
		


func unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03):
		GameSaveManager.last_hovered_over_level_layout_element_id = 0 # the first one
		GameSaveManager.last_opened_level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03
		
		SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
		SingletonsAndConsts.level_id_to_go_directly_to__after_interrupt_to_return_to_screen_layout_panel = StoreOfLevels.LevelIds.LEVEL_01__STAGE_3
		
		
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 19, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 20, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 21, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 22, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 23, false)
		GameSaveManager.set_layout_id__layout_element_id__is_invis(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, 24, false)
		
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED)


func unlock_stage_02__and_start_at_stage_02_01_on_level_finish__if_appropriate():
	if !GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02):
		GameSaveManager.last_hovered_over_level_layout_element_id = 0 # the first one
		GameSaveManager.last_opened_level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02
		
		StoreOfLevels.set_current_level_hidden_state(StoreOfLevels.AllLevelsHiddenState.BEFORE_POSTGAME_STAGE_05)
		
		# do not do this yet, so that it does not show up in shortcuts
		#GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED)
		
		GameSaveManager.set_level_layout_id_status_completion(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01, GameSaveManager.LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED)
		
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

