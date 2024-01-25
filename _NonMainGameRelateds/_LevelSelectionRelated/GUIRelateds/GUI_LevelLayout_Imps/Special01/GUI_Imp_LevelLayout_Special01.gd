extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"

#

onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02
onready var level_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_03


onready var layout_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To02

##

func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01


func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_1)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_1)
	level_03__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_SPECIAL_1)
	
	layout_02__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02)
	layout_02__tile.layout_ele_id_to_put_cursor_to = 27
	


func _config_signals_to_monitor_game_bg_changing_states():
	GameSaveManager.connect("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed")

func _on_coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id):
	_set_game_background_based_on_states(false)
	


func _set_game_background_based_on_states(arg_is_instant_in_transition):
	#todoimp change this. make it based on unlocked levels instead of stars
	
	#game_background.set_current_background_type(GameBackground.BackgroundTypeIds.LEVEL__SPECIAL_01, arg_is_instant_in_transition)
	#return
	
	
	var total_star_count = StoreOfLevels.get_total_coin_count()
	var star_count_collected = GameSaveManager.get_total_coin_collected_count()
	if total_star_count == star_count_collected:
		_set_game_background__as_completed(arg_is_instant_in_transition)
	elif total_star_count - 1 == star_count_collected:
		_set_game_background__as_prelude(arg_is_instant_in_transition)
	else:
		_set_game_background__as_normal(arg_is_instant_in_transition)


func _set_game_background__as_completed(arg_is_instant_in_transition):
	game_background.set_current_background_type(GameBackground.BackgroundTypeIds.LAYOUT__CHALLENGE_COMPLETED, arg_is_instant_in_transition)
	

func _set_game_background__as_prelude(arg_is_instant_in_transition):
	game_background.set_current_background_type(GameBackground.BackgroundTypeIds.LAYOUT__CHALLENGE_PRELUDE, arg_is_instant_in_transition)
	

func _set_game_background__as_normal(arg_is_instant_in_transition):
	game_background.set_current_background_type(GameBackground.BackgroundTypeIds.LAYOUT__CHALLENGE_NORMAL, arg_is_instant_in_transition)
	

#

#func set_gui_level_selection_whole_screen(arg_val):
#	.set_gui_level_selection_whole_screen(arg_val)
#


func _overridable__setup_game_background(arg_is_instant_in_transition):
	game_background = gui_level_selection_whole_screen.game_background
	_set_game_background_based_on_states(arg_is_instant_in_transition)
	_config_signals_to_monitor_game_bg_changing_states()
	
	#todoimp consider arg_is_instant_in_transition



