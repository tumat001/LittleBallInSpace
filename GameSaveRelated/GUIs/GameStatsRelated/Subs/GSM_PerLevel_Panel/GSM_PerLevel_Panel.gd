extends MarginContainer

const GSM_PerGame_SpecificGStats_ListPanel = preload("res://GameSaveRelated/GUIs/GameStatsRelated/Subs/GSM_PerGame_SpecificGStats_ListPanel/GSM_PerGame_SpecificGStats_ListPanel.gd")

#

const LABEL_VAL_DISPLAY__UNSETTED = "N/A"
const LABEL_VAL_DISPLAY__NOT_PRESENT = "N/A"


const GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID = "GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID"
const GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID = "GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID"

#todo add the icons soon
const GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP : Dictionary = {
	# game time
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest time to win",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# rotation
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest rotations",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# balls
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest balls shot",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# lowest energy
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest energy",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# highest speed
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Highest Speed",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# time spent in rewind
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest rewind duration",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
}

#

var _current_all_details__from_GS : Dictionary
var _current_level_id : int


var _per_game_list_item_arr__recent_history : Array
var _per_game_list_item_arr__high_scores : Array

#

enum DisplayListMode {
	RECENT = 0,
	HIGH_SCORE = 1,
	#FIRST = 2,
}
var current_display_list_mode : int = DisplayListMode.RECENT

#

export(bool) var show_level_name_in_specific_stat_panels: bool = false setget set_show_level_name_in_specific_stat_panels

#

onready var level_name_tooltip_body = $VBoxContainer/GameSpecificStatsHBox/GSM_PerGame_ListPanel/VBoxContainer/HBoxContainer/GSM_PerGame_Panel/VBoxContainer/LevelDetailsPanel/VBoxContainer/LevelNameTooltipBody

onready var gsm_per_game_list_panel = $HBoxContainer/GSM_PerGame_ListPanel

onready var attempt_count_val_label = $VBoxContainer/MiscDetails/VBoxContainer/HBoxAttempt/AttemptCountValLabel
onready var restart_or_quit_count_val_label = $VBoxContainer/MiscDetails/VBoxContainer/HBoxRestartOrQuit/RestartOrQuitCountValLabel

#

func set_show_level_name_in_specific_stat_panels(arg_val):
	if is_inside_tree():
		gsm_per_game_list_panel.show_level_name_on_per_game_panel = show_level_name_in_specific_stat_panels

#

func _ready():
	set_show_level_name_in_specific_stat_panels(show_level_name_in_specific_stat_panels)
	

#

func set_level_id_to_display_for(arg_lvl_id):
	_current_level_id = arg_lvl_id
	
	var all_details__from_GS : Dictionary = GameStatsManager.get_per_level_all_data_of_lvl(arg_lvl_id)
	_current_all_details__from_GS = all_details__from_GS
	
	# attempt count
	if all_details__from_GS.has(GameStatsManager.PER_LEVEL__ATTEMPT_COUNT__DIC_ID):
		attempt_count_val_label.text = str(all_details__from_GS[GameStatsManager.PER_LEVEL__ATTEMPT_COUNT__DIC_ID])
	else:
		attempt_count_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	# restart count
	if all_details__from_GS.has(GameStatsManager.PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID):
		restart_or_quit_count_val_label.text = str(all_details__from_GS[GameStatsManager.PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID])
	else:
		restart_or_quit_count_val_label.text = LABEL_VAL_DISPLAY__NOT_PRESENT
	
	
	# level id
	var level_details = StoreOfLevels.generate_or_get_level_details_of_id(arg_lvl_id)
	if level_details != null:
		level_name_tooltip_body.descriptions = level_details.level_full_name
	else:
		level_name_tooltip_body.descriptions = ["----", []]
		
	
	level_name_tooltip_body.update_display()
	
	
	####
	
	_construct_per_game_list__recent_history()
	_construct_per_game_list__high_scores()
	
	#
	
	update_display_based_on_curr_display_list_mode()

func _construct_per_game_list__recent_history():
	
	if _current_all_details__from_GS.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID):
		var last_x_played_game_details = _current_all_details__from_GS[GameStatsManager.PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID]
		#gsm_per_game_list_panel.add
		_per_game_list_item_arr__recent_history = _construct_per_game_list_item_arr__using_details_arr(last_x_played_game_details, null)
		
		#for item in per_game_list_item_arr:
		#	gsm_per_game_list_panel.add_per_game_list_item(item)


func _construct_per_game_list_item_arr__using_details_arr(game_details_arr : Array, arg_icon_to_use : Texture = null) -> Array:
	var bucket = []
	for game_details in game_details_arr:
		var per_game_list_item = GSM_PerGame_SpecificGStats_ListPanel.PerGameListItem.new()
		per_game_list_item.button_icon = arg_icon_to_use
		per_game_list_item.button_label = _get_button_label_for_data__for_recent_history(game_details, bucket.size())
		per_game_list_item.level_id = _current_level_id
		per_game_list_item.per_game_data = game_details
		
		#
		bucket.append(per_game_list_item)
	
	return bucket

func _get_button_label_for_data__for_recent_history(arg_game_details, arg_index_for_defaulting):
	if arg_game_details.has(GameStatsManager.PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID):
		var val = arg_game_details[GameStatsManager.PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID]
		return GSM_PerGame_SpecificGStats_ListPanel.convert_ISO_datetime_format_info_readable(val)
		
	else:
		return str(arg_index_for_defaulting)
	


#

func _construct_per_game_list__high_scores():
	var bucket = []
	
	if _current_all_details__from_GS.has(GameStatsManager.PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID):
		var highest_stats_map = _current_all_details__from_GS[GameStatsManager.PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID]
		for game_stat_dic_id in GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP.keys():
			
			var per_game_list_item = GSM_PerGame_SpecificGStats_ListPanel.PerGameListItem.new()
			per_game_list_item.button_icon = GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP[game_stat_dic_id][GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID]
			per_game_list_item.button_label = GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP[game_stat_dic_id][GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID]
			per_game_list_item.level_id = _current_level_id
			per_game_list_item.per_game_data = highest_stats_map[game_stat_dic_id]
			
			#
			bucket.append(per_game_list_item)
	
	_per_game_list_item_arr__high_scores = bucket


######################

func _on_Button_RecentHistory_button_pressed():
	set_current_display_list_mode(DisplayListMode.RECENT)

func _on_Button_HighScores_button_pressed():
	set_current_display_list_mode(DisplayListMode.HIGH_SCORE)



func set_current_display_list_mode(arg_mode : int):
	var old_val = current_display_list_mode
	current_display_list_mode = arg_mode
	
	if old_val != arg_mode:
		if is_inside_tree():
			update_display_based_on_curr_display_list_mode()

func update_display_based_on_curr_display_list_mode():
	if current_display_list_mode == DisplayListMode.RECENT:
		gsm_per_game_list_panel.clear_per_game_list()
		for item in _per_game_list_item_arr__recent_history:
			gsm_per_game_list_panel.add_per_game_list_item(item)
		
	elif current_display_list_mode == DisplayListMode.HIGH_SCORE:
		gsm_per_game_list_panel.clear_per_game_list()
		for item in _per_game_list_item_arr__high_scores:
			gsm_per_game_list_panel.add_per_game_list_item(item)
		
		

