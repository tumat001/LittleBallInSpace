extends Node

#

const LevelLayoutDetails = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/LevelLayoutDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

enum LevelLayoutIds {
	#NONE = -1
	
	LAYOUT_01 = 1
	LAYOUT_02 = 2,
	
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
	if arg_id == LevelLayoutIds.LAYOUT_02:
		scene_ref = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/02/GUI_Imp_LevelLayout_02.tscn")
	
	
	return scene_ref.instance()


#

func get_or_construct_layout_details(arg_id) -> LevelLayoutDetails:
	if !GameSaveManager.is_manager_initialized():
		print("StoreOfLevelLayouts: generating level layout details but save manager not initialized")
		return null
	
	
	if _layout_id_to_layout_details_map.has(arg_id):
		return _layout_id_to_layout_details_map[arg_id]
	
	##
	
	var details : LevelLayoutDetails
	
	if arg_id == LevelLayoutIds.LAYOUT_01:
		_set_details_transition_types__to_usual_circle_types(details)
		
	
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


