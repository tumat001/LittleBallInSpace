extends Node

#

const LevelLayoutDetails = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/LevelLayoutDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

enum LevelLayoutIds {
	#NONE = -1
	
	LAYOUT_01 = 1
	LAYOUT_02 = 2,
	LAYOUT_03 = 3,
	LAYOUT_04 = 4,
	LAYOUT_05 = 5,
	LAYOUT_06 = 6,
	LAYOUT_07 = 7,
	
	LAYOUT_SPECIAL_01 = 1000
	
}

const FIRST_LEVEl_LAYOUT = LevelLayoutIds.LAYOUT_01

#

var level_layout_ids_unlocked_by_default = [
	FIRST_LEVEl_LAYOUT,
]

#

var _layout_id_to_layout_details_map : Dictionary

##

func _ready():
	_initialize_for__and_check_for_game_save_manager()

#########

func generate_instance_of_layout(arg_id):
	var scene_ref
	
	if arg_id == LevelLayoutIds.LAYOUT_01:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/01/GUI_Imp_LevelLayout_01.tscn")
	elif arg_id == LevelLayoutIds.LAYOUT_02:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/02/GUI_Imp_LevelLayout_02.tscn")
	elif arg_id == LevelLayoutIds.LAYOUT_03:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/03/GUI_Imp_LevelLayout_03.tscn")
	elif arg_id == LevelLayoutIds.LAYOUT_04:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/04/GUI_Imp_LevelLayout_04.tscn")
	elif arg_id == LevelLayoutIds.LAYOUT_05:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/05/GUI_Imp_LevelLayout_05.tscn")
	elif arg_id == LevelLayoutIds.LAYOUT_06:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/06/GUI_Imp_LevelLayout_06.tscn")
	elif arg_id == LevelLayoutIds.LAYOUT_07:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/07/GUI_Imp_LevelLayout_07.tscn")
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_SPECIAL_01:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/Special01/GUI_Imp_LevelLayout_Special01.tscn")
	
	
	return scene_ref.instance()


#

func get_or_construct_layout_details(arg_id) -> LevelLayoutDetails:
	if !GameSaveManager.is_manager_initialized():
		print("StoreOfLevelLayouts: generating level layout details but save manager not initialized")
		return null
	
	
	if _layout_id_to_layout_details_map.has(arg_id):
		return _layout_id_to_layout_details_map[arg_id]
	
	##
	
	var details : LevelLayoutDetails = LevelLayoutDetails.new()
	
	details.level_layout_id = arg_id
	
	
	if arg_id == LevelLayoutIds.LAYOUT_01:
		details.level_layout_name = [
			["Beginning", []]
		]
		details.level_layout_desc = [
			["Where it all began", []]
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout01.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "1"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_02:
		details.level_layout_name = [
			["Ball", []]
		]
		details.level_layout_desc = [
			
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout02.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "2"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_03:
		details.level_layout_name = [
			["Portal", []]
		]
		details.level_layout_desc = [
			
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout03.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "3"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_04:
		details.level_layout_name = [
			["Glass", []]
		]
		details.level_layout_desc = [
			["If you like to break stuffs, then this is for you!", []]
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout04.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "4"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_05:
		details.level_layout_name = [
			["Return", []]
		]
		details.level_layout_desc = [
			
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout05.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "5"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_SPECIAL_01:
		details.level_layout_name = [
			["Specials", []]
		]
		details.level_layout_desc = [
			["The true challenges, series A", []],
			["Also has other levels that don't fit anywhere", []]
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayoutSpecial01.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "A"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_06:
		details.level_layout_name = [
			["Pressure", []]
		]
		details.level_layout_desc = [
			["Action packed!", []]
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout06.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "6"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
		
	elif arg_id == LevelLayoutIds.LAYOUT_07:
		details.level_layout_name = [
			["Angular", []]
		]
		details.level_layout_desc = [
			#["", []]
		]
		
		_set_details_transition_types__to_usual_circle_types(details)
		
		details.texture_of_level_tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/SpecificAssets/LevelLayout_Tile_Circle__LevelLayout07.png")
		details.modulate_of_level_tile = Color(1, 1, 1, 1)
		
		details.level_layout_label_on_tile = "7"
		details.level_label_text_color = Color("#dddddd")
		#details.level_label_outline_color = Color("#dddddd")
		details.has_outline_color = false
		
	
	
	_set_layout_details_configs_and_params_based_on_GSM(details)
	
	_layout_id_to_layout_details_map[arg_id] = details
	
	return details


#

func _initialize_for__and_check_for_game_save_manager():
	if GameSaveManager.is_manager_initialized():
		_initialize_monitor_of_level_layout_status_changes()
	else:
		GameSaveManager.connect("save_manager_initialized", self, "_on_save_manager_initialized", [], CONNECT_ONESHOT)
		
	

func _on_save_manager_initialized():
	_initialize_monitor_of_level_layout_status_changes()
	


##

func _initialize_monitor_of_level_layout_status_changes():
	GameSaveManager.connect("level_layout_id_completion_status_changed", self, "_on_GSM_level_layout_id_completion_status_changed")


func _on_GSM_level_layout_id_completion_status_changed(arg_id, arg_status):
	if _layout_id_to_layout_details_map.has(arg_id):
		var details = _layout_id_to_layout_details_map[arg_id]
		
		_set_layout_details_configs_and_params_based_on_GSM(details)


func _set_layout_details_configs_and_params_based_on_GSM(arg_details : LevelLayoutDetails):
	arg_details.is_level_layout_locked = !GameSaveManager.is_level_layout_id_playable(arg_details.level_layout_id) #(arg_details.level_id)
	


##########################
# HELPERS
#########################

# All black
func _set_details_transition_types__to_usual_circle_types(arg_details : LevelLayoutDetails):
	arg_details.transition_id__entering_layout__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__entering_layout__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_layout__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_layout__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK


