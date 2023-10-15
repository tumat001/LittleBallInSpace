extends MarginContainer

const GSM_PerGame_SpecificGStats_ListPanel = preload("res://GameSaveRelated/GUIs/GameStatsRelated/Subs/GSM_PerGame_SpecificGStats_ListPanel/GSM_PerGame_SpecificGStats_ListPanel.gd")
const GSM_PerGame_SpecificGStats_Panel = preload("res://GameSaveRelated/GUIs/GameStatsRelated/Subs/GSM_PerGame_SpecificGStats_Panel/GSM_PerGame_SpecificGStats_Panel.gd")

#

const LABEL_VAL_DISPLAY__UNSETTED = "N/A"
const LABEL_VAL_DISPLAY__NOT_PRESENT = "N/A"


const GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID = "GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID"
const GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID = "GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID"

#todo add the icons soon
const GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP : Dictionary = {
	# game time
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest Time to Win",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# time spent in rewind
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest Rewind Duration",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# rotation
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest Rotations",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# highest speed
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Highest Speed",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# balls
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest Balls Shot",
		GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID : null
	},
	
	# lowest energy
	GameStatsManager.PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID : {
		GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID : "Lowest Energy",
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

var button_group_for_display_modes : ButtonGroup

#

onready var level_name_tooltip_body = $VBoxContainer/LevelDetailsPanel/VBoxContainer/LevelNameTooltipBody

onready var gsm_per_game_list_panel = $VBoxContainer/GameSpecificStatsHBox/GSM_PerGame_ListPanel

onready var attempt_count_val_label = $VBoxContainer/MiscDetails/VBoxContainer/HBoxAttempt/AttemptCountValLabel
onready var restart_or_quit_count_val_label = $VBoxContainer/MiscDetails/VBoxContainer/HBoxRestartOrQuit/RestartOrQuitCountValLabel

onready var button_recent_history = $VBoxContainer/GameSpecificStatsHBox/VBoxContainer/Button_RecentHistory
onready var button_high_scores = $VBoxContainer/GameSpecificStatsHBox/VBoxContainer/Button_HighScores

onready var display_mode_to_display_option_buttons_map : Dictionary = {
	DisplayListMode.RECENT: button_recent_history,
	DisplayListMode.HIGH_SCORE: button_high_scores,
}
var display_option_button_inner_button__to_display_mode_id_map : Dictionary

#

func set_show_level_name_in_specific_stat_panels(arg_val):
	if is_inside_tree():
		gsm_per_game_list_panel.show_level_name_on_per_game_panel = show_level_name_in_specific_stat_panels

#

func _ready():
	set_show_level_name_in_specific_stat_panels(show_level_name_in_specific_stat_panels)
	_configure_button_group_for_display_mode_buttons()
	_configure_display_option_button_to_display_mode_id_map()
	
#	connect("visibility_changed", self, "_on_vis_changed", [], CONNECT_DEFERRED)
#	_update_config_signals_to_listen_for_gui_input()

func _configure_button_group_for_display_mode_buttons():
	button_group_for_display_modes = ButtonGroup.new()
	for button in display_mode_to_display_option_buttons_map.values():
		#button.texture_button.group = button_group_for_display_modes
		button.set_button_group(button_group_for_display_modes)
	
	button_group_for_display_modes.connect("pressed", self, "_on_display_mode_button_pressed")

func _configure_display_option_button_to_display_mode_id_map():
	for display_mode_id in display_mode_to_display_option_buttons_map.keys():
		var button = display_mode_to_display_option_buttons_map[display_mode_id]
		
		display_option_button_inner_button__to_display_mode_id_map[button.texture_button] = display_mode_id


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
		level_name_tooltip_body.descriptions = [
			["----", []]
		]
		
	
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
		return GSM_PerGame_SpecificGStats_Panel.convert_ISO_datetime_format_info_readable(val)
		
	else:
		return str(arg_index_for_defaulting)
	


#

func _construct_per_game_list__high_scores():
	var bucket = []
	
	if _current_all_details__from_GS.has(GameStatsManager.PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID):
		var highest_stats_map = _current_all_details__from_GS[GameStatsManager.PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID]
		for game_stat_dic_id in GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP.keys():
			
			if highest_stats_map.has(game_stat_dic_id):
				var per_game_list_item = GSM_PerGame_SpecificGStats_ListPanel.PerGameListItem.new()
				per_game_list_item.button_icon = GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP[game_stat_dic_id][GAME_STAT_DISPLAY__OPTION_ICON__DISP_ID]
				per_game_list_item.button_label = GAME_STAT__TO_OPTION_DISPLAY_DETAIL_MAP[game_stat_dic_id][GAME_STAT_DISPLAY__OPTION_LABEL__DISP_ID]
				per_game_list_item.level_id = _current_level_id
				per_game_list_item.per_game_data = highest_stats_map[game_stat_dic_id]
				
				per_game_list_item.metadata = game_stat_dic_id
				
				#
				bucket.append(per_game_list_item)
				
			else:
				bucket.append(gsm_per_game_list_panel._empty_per_game_list_item)
	
	_per_game_list_item_arr__high_scores = bucket


######################

#func _on_Button_RecentHistory_button_pressed():
#	set_current_display_list_mode(DisplayListMode.RECENT)
#
#func _on_Button_HighScores_button_pressed():
#	set_current_display_list_mode(DisplayListMode.HIGH_SCORE)

func _on_display_mode_button_pressed(arg_button):
	var display_mode = display_option_button_inner_button__to_display_mode_id_map[arg_button]
	set_current_display_list_mode(display_mode)
	

func set_current_display_list_mode(arg_mode : int):
	var old_val = current_display_list_mode
	current_display_list_mode = arg_mode
	
	if old_val != arg_mode:
		if is_inside_tree():
			update_display_based_on_curr_display_list_mode()

func update_display_based_on_curr_display_list_mode():
	if current_display_list_mode == DisplayListMode.RECENT:
		_clear_and_display_item_list_in_gsm_list_panel(_per_game_list_item_arr__recent_history)
		
	elif current_display_list_mode == DisplayListMode.HIGH_SCORE:
		_clear_and_display_item_list_in_gsm_list_panel(_per_game_list_item_arr__high_scores)
		
	else:
		print("err -- GSM_PerLevel_Panel -- invalid display mode")

func _clear_and_display_item_list_in_gsm_list_panel(arg_list):
	gsm_per_game_list_panel.clear_per_game_list(false)
	var i = 0
	for item in arg_list:
		gsm_per_game_list_panel.add_per_game_list_item(item, i == 0)
		i += 1
	
	# if none
	if i == 0:
		gsm_per_game_list_panel.set_curr_per_game_item_index__and_update_display(-1)

##

#func _on_vis_changed():
#	#_update_config_signals_to_listen_for_gui_input()
#	call_deferred("_update_config_signals_to_listen_for_gui_input")
#
#func _update_config_signals_to_listen_for_gui_input():
#	if is_visible_in_tree():
#		set_process_input(true)
#	else:
#		set_process_input(false)
#
#func _input(event):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_up"):
#			pass
#		elif event.is_action_pressed("ui_down"):
#			pass
#


func _on_GSM_PerGame_ListPanel_item_changed(arg_per_game_list_item, arg_current_per_game_list_item_id):
	if arg_per_game_list_item != null:
		var game_stat_dic_id = arg_per_game_list_item.metadata
		
		gsm_per_game_list_panel.gsm_per_game_panel.set_selected_highlight_hbox_with_stat_type(game_stat_dic_id)
		
	else:
		
		gsm_per_game_list_panel.gsm_per_game_panel.set_selected_highlight_hbox_with_stat_type("")
		



#############################################
# TREE ITEM Specific methods/vars

var control_tree setget set_control_tree


func on_control_received_focus():
	pass
	

func on_control_fully_visible():
	#button_resume.grab_focus()
	var button_of_curr_mode = display_mode_to_display_option_buttons_map[current_display_list_mode]
	#button_of_curr_mode.grab_focus()
	button_of_curr_mode.set_is_toggled(true)
	

func on_control_lost_focus():
	for button in display_mode_to_display_option_buttons_map.values():
		button.lose_focus()
	

func on_control_fully_invisible():
	pass
	


func set_control_tree(arg_tree):
	control_tree = arg_tree
	

############
# END OF TREE ITEM Specific methods/vars
###########


