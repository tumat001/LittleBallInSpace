######################
# NOTE:
# WHEN ADDING ASSIST MODES or ids, check: AssistModeDetailsHelper Class

extends Node

#

const AssistModeDetailsHelper = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/AssistModePanel/Data/AssistModeDetailsHelper.gd")

#

signal settings_manager_initialized()


signal game_control_is_hidden_changed(arg_game_control_name, arg_is_hidden)


signal game_control_hotkey_changed(arg_game_control_action, arg_old_hotkey, arg_new_hotkey)
signal conflicting_game_controls_hotkey_changed(arg_last_calc_game_controls_in_conflicts)


signal any_game_modifying_assist_mode_settings_changed()
# use this to display "need restart" label
signal last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed(arg_is_changed)

signal is_assist_mode_first_time_open_changed(arg_val)
signal is_assist_mode_active_changed(arg_val)
signal assist_mode_unlocked_ids_changed(arg_ids)
signal assist_mode_id_unlock_status_changed(arg_id, arg_val)

signal assist_mode_toggle_active_mode_changed(arg_val)
# make these x_mode_changed signals have consistent argument/param count
signal assist_mode__additional_energy_mode_changed(arg_val)
signal assist_mode__energy_reduction_mode_changed(arg_val)
signal assist_mode__additional_launch_ball_mode_changed(arg_val)
signal assist_mode__pause_at_esc_mode_changed(arg_val)


signal settings_config__is_full_screen_changed(arg_val)
signal settings_config__cam_rotation_duration_changed(arg_val)

####

const game_control_settings_file_path = "user://game_control_settings.save"


const GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER = "GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER"

var _game_control_name_string_to_is_hidden_map : Dictionary
const GAME_CONTROL_HIDDEN_PLACEHOLDER_NAME : String = "?????"

const GAME_CONTROLS_TO_NAME_MAP = {
	"game_left" : "Move Left",
	"game_right" : "Move Right",
	"game_down" : "Slow to Stop",
	"game_zoom_out" : "Toggle Zoom",
	"rewind" : "Rewind",
	"game_launch_ball" : "Launch Ball",
}
const GAME_CONTROLS_TO_NOT_BE_HIDDEN_BY_DEFAULT = [
	"game_left",
	"game_right"
]
const KEY_PRESS_ACTION_BAN_FOR_GAME_CONTROLS = [
	"Escape",
	"Enter"
]

const GAME_CONTROLS_TO_ALLOW_HOTKEY_SHARING_WITH_NO_WARNING = [
	#[
	#	"game_launch_ball",
	#	"game_fire_hook",
	#]
]

##

#const hotkey_controls_file_path = "user://game_hotkey_controls.save"

##########################
## general settings

const general_game_settings_file_path = "user://general_game_settings.save"
const CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER = "CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER"
const ASSIST_MODE__CATEGORY__DIC_IDENTIFIER = "ASSIST_MODE_CATEGORY__DIC_IDENTFIER"
const SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER = "SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER"

### Hotkey
var game_control_to_default_event : Dictionary

var _game_control_to_current_event : Dictionary   # used to compare and store pre computeds (last calc)
var _last_calc_game_controls_in_conflicts : Dictionary   # dict of arrs (string -> arr)


### Assist mode
const ASSIST_MODE__TEXT_MODULATE__LIGHT = Color("#44B8FD")
const ASSIST_MODE__TEXT_MODULATE__DARK = Color("#01456D")


const ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER = "ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER"
var is_assist_mode_first_time_open : bool setget set_is_assist_mode_first_time_open


const ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER = "ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER"
var is_assist_mode_active : bool setget set_is_assist_mode_active

const ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_ToggleActiveModeId {
	FOR_THIS_LEVEL_ONLY = 0,
	FOR_ALL_LEVELS = 1,
}
const assist_mode_toggle_active_mode_id__default : int = AssistMode_ToggleActiveModeId.FOR_ALL_LEVELS
var assist_mode_toggle_active_mode_id : int setget set_assist_mode_toggle_active_mode_id


const ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER = "ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER"
enum AssistModeId {
	ADDITIONAL_ENERGY_MODE = 0,
	ENERGY_REDUC_MODE = 1,
	ADDITIONAL_LAUNCH_BALL_MODE = 2,
	PAUSE_AT_ESC_MODE = 3,
}
var _assist_mode__unlocked_ids : Array
const assist_mode__unlocked_ids__default : Array = [
	#AssistModeId.ADDITIONAL_ENERGY_MODE,
	#AssistModeId.ENERGY_REDUC_MODE,
	#AssistModeId.PAUSE_AT_ESC_MODE,
]



const ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_AdditionalEnergyModeId {
	NO_BONUS = 0,
	SMALL_BONUS = 1,
	MEDIUM_BONUS = 2,
	LARGE_BONUS = 3,
	VERY_LARGE_BONUS = 4,
}
const assist_mode__additional_energy_mode_id__details_map : Dictionary = {
	AssistMode_AdditionalEnergyModeId.NO_BONUS : 0,
	AssistMode_AdditionalEnergyModeId.SMALL_BONUS : 5,
	AssistMode_AdditionalEnergyModeId.MEDIUM_BONUS : 15,
	AssistMode_AdditionalEnergyModeId.LARGE_BONUS : 35,
	AssistMode_AdditionalEnergyModeId.VERY_LARGE_BONUS : 485,
	
}
const assist_mode__additional_energy_mode_id__default : int = AssistMode_AdditionalEnergyModeId.MEDIUM_BONUS
const assist_mode__additional_energy_mode_id__no_effect : int = AssistMode_AdditionalEnergyModeId.NO_BONUS
var assist_mode__additional_energy_mode_id : int setget set_assist_mode__additional_energy_mode_id


const ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_EnergyReductionModeId {
	REDUCABLE__NORMAL = 0,
	INFINITE = 1,
}
const assist_mode__energy_reduction_mode_id__default : int = AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL
const assist_mode__energy_reduction_mode_id__no_effect : int = AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL
var assist_mode__energy_reduction_mode_id : int setget set_assist_mode__energy_reduction_mode_id


const ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER = "ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER"
enum AssistMode_AdditionalLaunchBallModeId {
	NO_BALL = 0,
	ONE_BALL = 1,
	TWO_BALL = 2,
	THREE_BALL = 3,
	FOUR_BALL = 4,
	#INFINITE = 5,
}
const assist_mode__additional_launch_ball_mode_id__details_map : Dictionary = {
	AssistMode_AdditionalLaunchBallModeId.NO_BALL : [0, false],
	AssistMode_AdditionalLaunchBallModeId.ONE_BALL : [1, false],
	AssistMode_AdditionalLaunchBallModeId.TWO_BALL : [2, false],
	AssistMode_AdditionalLaunchBallModeId.THREE_BALL : [3, false],
	AssistMode_AdditionalLaunchBallModeId.FOUR_BALL : [4, false],
	#AssistMode_AdditionalLaunchBallModeId.INFINITE : [4, true],
}
const assist_mode__additional_launch_ball_mode_id__default : int = AssistMode_AdditionalLaunchBallModeId.ONE_BALL
const assist_mode__additional_launch_ball_mode_id__no_effect : int = AssistMode_AdditionalLaunchBallModeId.NO_BALL
var assist_mode__additional_launch_ball_mode_id : int setget set_assist_mode__additional_launch_ball_mode_id


const ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER = "ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER"
enum AssistMode_PauseAtESCModeId {
	NO_PAUSE = 0,
	PAUSE = 1,
}
const assist_mode__pause_at_esc_id__default : int = AssistMode_PauseAtESCModeId.NO_PAUSE
const assist_mode__pause_at_esc_id__no_effect : int = AssistMode_PauseAtESCModeId.NO_PAUSE
var assist_mode__pause_at_esc_id : int setget set_assist_mode__pause_at_esc_id



var assist_mode_details_helper : AssistModeDetailsHelper
var _current_assist_mode_id_to_vals_map_at_current_game_elements : Dictionary
var current_assist_mode_is_active_at_current_game_elements : bool
var current_assist_mode_is_active_at_current_game_elements__but_no_effect : bool
var assist_mode_id_to_var_name_map : Dictionary
var assist_mode_id_to_setter_method_name_map : Dictionary
var assist_mode_id_to_val_changed_signal_name_map : Dictionary
var assist_mode_id_to_no_effect_var_name_map : Dictionary

var last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config : bool


### Settings Config

const SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER = "SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER"
var settings_config__is_full_screen : bool setget set_settings_config__is_full_screen


const SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER = "SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER"
var settings_config__cam_rotation_duration : float setget set_settings_config__cam_rotation_duration
const settings_config__cam_rotation_duration__default = 0.5


####

var _is_manager_initialized : bool


##############################
#### base methods
#############################

func _save_using_dict(arg_dict, arg_file_path, arg_print_err_msg):
	var save_dict = arg_dict
	var save_file = File.new()
	
	var err_stat = save_file.open(arg_file_path, File.WRITE)
	
	if err_stat != OK:
		print(arg_print_err_msg)
		return
	
	save_file.store_line(to_json(save_dict))
	
	save_file.close()

func _save_using_arr(arg_arr, arg_file_path, arg_print_err_msg):
	var save_arr = arg_arr
	var save_file = File.new()
	
	var err_stat = save_file.open(arg_file_path, File.WRITE)
	
	if err_stat != OK:
		print(arg_print_err_msg)
		return
	
	#for ele in save_arr:
	#	save_file.store_line(to_json(ele))
	save_file.store_line(to_json(arg_arr))
	
	save_file.close()



################################

func load_all__from_ready_of_save_manager():
	_attempt_load_game_controls_related_data()
	_attempt_load_general_game_settings()
	
	
	assist_mode_details_helper = AssistModeDetailsHelper.new()
	
	_is_manager_initialized = true
	emit_signal("settings_manager_initialized")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_save_game_control_related_data()
		_save_general_game_settings_related_data()


#################
## CONTROLS RELATED
###################

func _save_game_control_related_data():
	var save_dict = {
		GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER : _game_control_name_string_to_is_hidden_map,
	}
	
	_save_using_dict(save_dict, game_control_settings_file_path, "SAVE ERROR: Control settings")



func _attempt_load_game_controls_related_data():
	var load_file = File.new()
	
	if load_file.file_exists(game_control_settings_file_path):
		var err_stat = load_file.open(game_control_settings_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- Game control settings data")
			return false
		
		_load_game_controls_related_data(load_file)
		
		load_file.close()
		return true
		
	else:
		_load_game_controls_related_data(null)
		return false

func _load_game_controls_related_data(arg_file : File):
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	###
	
	if data.has(GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER):
		_game_control_name_string_to_is_hidden_map = data[GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER]
	else:
		_initialize_game_control_name_string_map__from_nothing()
		
	


func _initialize_game_control_name_string_map__from_nothing():
	for control_name in GAME_CONTROLS_TO_NAME_MAP.keys():
		if GAME_CONTROLS_TO_NOT_BE_HIDDEN_BY_DEFAULT.has(control_name):
			_game_control_name_string_to_is_hidden_map[control_name] = false
		else:
			_game_control_name_string_to_is_hidden_map[control_name] = true
		


func is_string_game_control_name(arg_text : String):
	return GAME_CONTROLS_TO_NAME_MAP.keys().has(arg_text)

#

func set_game_control_name_string__is_hidden(arg_game_control_name : String, arg_is_hidden : bool):
	_game_control_name_string_to_is_hidden_map[arg_game_control_name] = arg_is_hidden
	
	emit_signal("game_control_is_hidden_changed", arg_game_control_name, arg_is_hidden)

func get_game_control_name__is_hidden(arg_game_control_name : String):
	return _game_control_name_string_to_is_hidden_map[arg_game_control_name]

func get_game_control_name_string_to_is_hidden_map__not_copy():
	return _game_control_name_string_to_is_hidden_map


func is_any_game_control_name_hidden() -> bool:
	for is_hidden in _game_control_name_string_to_is_hidden_map.values():
		if is_hidden:
			return true
	
	return false

####################################
## GENERAL SETTINGS
#####################################

func _save_general_game_settings_related_data():
	var assist_mode_save_dict = _generate_save_dict__for_assist_mode()
	var hotkey_save_dict = _get_game_controls_as_dict()
	var settings_save_dict = _get_settings_as_save_dict()
	
	#
	
	var general_game_settings_save_dict = {
		ASSIST_MODE__CATEGORY__DIC_IDENTIFIER : assist_mode_save_dict,
		CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER : hotkey_save_dict,
		SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER : settings_save_dict
	}
	
	_save_using_dict(general_game_settings_save_dict, general_game_settings_file_path, "SAVE ERROR: general game settings")

func _attempt_load_general_game_settings():
	var load_file = File.new()
	
	if load_file.file_exists(general_game_settings_file_path):
		var err_stat = load_file.open(general_game_settings_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- General game settings")
			return false
		
		_load_general_game_settings_using_file(load_file)
		
		load_file.close()
		return true
		
	else:
		
		_load_general_game_settings_using_file(null)
		return false

func _load_general_game_settings_using_file(arg_file : File):
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	###
	
	_update_game_control_to_default_event_map()
	if data.has(CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER):
		_load_game_hotkey_using_dic(data[CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER])
	else:
		pass
		#_load_game_hotkey_using_dic()
	_update_states_based_on_game_control_hotkeys__from_ready()
	
	
	#
	
	_init_assist_mode_id_to_x_name_map()
	_init_assist_mode_rel_signals()
	if data.has(ASSIST_MODE__CATEGORY__DIC_IDENTIFIER):
		_load_assist_mode_settings_using_dic(data[ASSIST_MODE__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_assist_mode_settings_using_dic({})
		
	
	#
	
	if data.has(SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER):
		_load_settings_config_using_dic(data[SETTINGS_CONFIG__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_settings_config_using_dic({})
	
	#
	
#	GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE, true)
#	GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE, true)
#	GameSettingsManager.set_assist_mode_id_unlocked_status(GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE, true)

	

#####################
## HOTKEY

#func reset_all_controls_to_defaults():
#	InputMap.load_from_globals()
#	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
#


func _update_game_control_to_default_event_map():
	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
		game_control_to_default_event[game_control] = get_game_control_input_key_event(game_control)
	


func set_game_control_new_hotkey__using_captured_event(arg_control_action_name : String, arg_captured_event : InputEventKey):
	var old_key_char = get_game_control_hotkey__as_string(arg_control_action_name)
	var new_key_char = arg_captured_event.as_text()
	
	if old_key_char != new_key_char:
		InputMap.action_erase_events(arg_control_action_name)
		InputMap.action_add_event(arg_control_action_name, arg_captured_event)
		
		_update_states_based_on_changed_game_control_hotkeys(arg_control_action_name, arg_captured_event)
		emit_signal("game_control_hotkey_changed", arg_control_action_name, old_key_char, new_key_char)

func _update_states_based_on_changed_game_control_hotkeys(arg_control_action_name, arg_captured_event):
	_game_control_to_current_event[arg_control_action_name] = arg_captured_event
	
	_update_control_conflict_based_on_game_control_hotkeys(_is_manager_initialized)
	

func _update_states_based_on_game_control_hotkeys__from_ready():
	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
		_game_control_to_current_event[game_control] = get_game_control_input_key_event(game_control)
	
	_update_control_conflict_based_on_game_control_hotkeys(true)
	

func _update_control_conflict_based_on_game_control_hotkeys(arg_emit_signal : bool):
	var new_vals = {}
	for game_control_name in _game_control_to_current_event.keys():
		var curr_event : InputEventKey = _game_control_to_current_event[game_control_name]
		var conflicts = calculate_game_control_name_conflicts_when_assigned_to_hotkey(game_control_name, curr_event)
		if conflicts.size() > 0:
			new_vals[game_control_name] = conflicts
	
	
	###
	
	## probably safe to assume it will be in order
	if !deep_equal(new_vals, _last_calc_game_controls_in_conflicts):
		_last_calc_game_controls_in_conflicts = new_vals
		
		if arg_emit_signal:
			emit_signal("conflicting_game_controls_hotkey_changed", _last_calc_game_controls_in_conflicts)


func can_game_control_name_share_input_action_with_game_control_name(arg_name_01, arg_name_02):
	for arr in GAME_CONTROLS_TO_ALLOW_HOTKEY_SHARING_WITH_NO_WARNING:
		if arr.has(arg_name_01) and arr.has(arg_name_02):
			return true
	
	return false

func calculate_game_control_name_conflicts_when_assigned_to_hotkey(arg_control_action_name : String, arg_captured_event : InputEventKey) -> Array:
	var conflicts = []
	
	var curr_event : InputEventKey = arg_captured_event #_game_control_to_current_event[arg_control_action_name]
	for game_control_name__j in _game_control_to_current_event.keys():
		if arg_control_action_name != game_control_name__j:
			var curr_event__j : InputEventKey = _game_control_to_current_event[game_control_name__j]
			if curr_event.as_text() == curr_event__j.as_text():
				if !can_game_control_name_share_input_action_with_game_control_name(arg_control_action_name, game_control_name__j):
					conflicts.append(game_control_name__j)
	
	return conflicts

func calculate_game_control_name_conflicts_when_assigned_to_hotkey__as_control_names(arg_control_action_name : String, arg_captured_event : InputEventKey) -> Array:
	var conflicts_game_control_action_name = calculate_game_control_name_conflicts_when_assigned_to_hotkey(arg_control_action_name, arg_captured_event)
	return convert_game_control_actions_into_names(conflicts_game_control_action_name)

func convert_game_control_actions_into_names(arg_actions : Array) -> Array:
	var bucket = []
	
	for game_control in arg_actions:
		if GAME_CONTROLS_TO_NAME_MAP.has(game_control):
			bucket.append(GAME_CONTROLS_TO_NAME_MAP[game_control])
		else:
			bucket.append(game_control)
	
	return bucket


#

func get_game_control_hotkey__as_string(arg_control_action_name : String):
	var input_events = InputMap.get_action_list(arg_control_action_name)
	
	var key_char : String = ""
	if input_events.size() > 0:
		key_char = input_events[0].as_text()
	
	return key_char

func get_game_control_input_key_event(arg_control_action_name : String):
	var input_events = InputMap.get_action_list(arg_control_action_name)
	if input_events.size() > 0:
		return input_events[0]
	
	return null

func allow_hotkey_to_be_assigned_to_game_control__ignoring_conflicts(arg_captured_event : InputEventKey, arg_control_action_name : String):
	var new_key_char = arg_captured_event.as_text()
	if KEY_PRESS_ACTION_BAN_FOR_GAME_CONTROLS.has(new_key_char):
		return false
		
	else:
		return true



func reset_game_control_hotkey_to_default(arg_control_action_name : String):
	if if_game_control_has_default(arg_control_action_name):
		set_game_control_new_hotkey__using_captured_event(arg_control_action_name, game_control_to_default_event[arg_control_action_name])

func is_game_control_hotkey_default_for_action(arg_control_action_name : String, arg_captured_event : InputEventKey) -> bool:
	if arg_captured_event == null:
		return false
	
	if if_game_control_has_default(arg_control_action_name):
		return arg_captured_event.as_text() == game_control_to_default_event[arg_control_action_name].as_text()
	else:
		return false

func if_game_control_has_default(arg_control_action_name : String) -> bool:
	return game_control_to_default_event.has(arg_control_action_name)

func get_game_control_default(arg_control_action_name : String) -> InputEventKey:
	return game_control_to_default_event[arg_control_action_name]




func get_last_calc_game_control_conflicting_inputs_with_other_controls(arg_control_action_name : String) -> Array:
	if if_last_calc_game_control_has_conflicts(arg_control_action_name):
		return _last_calc_game_controls_in_conflicts[arg_control_action_name]
	else:
		return []

func if_last_calc_game_control_has_conflicts(arg_control_action_name : String):
	return _last_calc_game_controls_in_conflicts.has(arg_control_action_name)

##

func _get_game_controls_as_dict():
	#var all_actions = InputMap.get_actions()
	var dict = {}
	for action_name in GAME_CONTROLS_TO_NAME_MAP.keys():
		var input_events = InputMap.get_action_list(action_name)
		dict[action_name] = _convert_input_events_to_basic_prop_arr(input_events)
	
	return dict

func _convert_input_events_to_basic_prop_arr(arg_input_events : Array):
	var bucket = []
	for event in arg_input_events:
		# Order matters, since this is accessed by _load_game_hotkey_using_file
		bucket.append([event.echo, event.pressed, event.scancode])
	
	return bucket



func _load_game_hotkey_using_dic(data : Dictionary):
	#var data = parse_json(arg_file.get_line())
	if data != null:
		for action_name in data.keys():
			var event_data : Array = data[action_name]
			InputMap.action_erase_events(action_name)
			
			for i in event_data.size():
				var key_event : InputEventKey = InputEventKey.new()
				var key_data = event_data[i]
				key_event.echo = key_data[0]
				key_event.pressed = key_data[1]
				key_event.scancode = key_data[2]
				
				InputMap.action_add_event(action_name, key_event)



######################
## ASSIST MODE

func _init_assist_mode_id_to_x_name_map():
	assist_mode_id_to_var_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "assist_mode__additional_energy_mode_id"
	assist_mode_id_to_var_name_map[AssistModeId.ENERGY_REDUC_MODE] = "assist_mode__energy_reduction_mode_id"
	assist_mode_id_to_var_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "assist_mode__additional_launch_ball_mode_id"
	assist_mode_id_to_var_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "assist_mode__pause_at_esc_id"
	
	assist_mode_id_to_setter_method_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "set_assist_mode__additional_energy_mode_id"
	assist_mode_id_to_setter_method_name_map[AssistModeId.ENERGY_REDUC_MODE] = "set_assist_mode__energy_reduction_mode_id"
	assist_mode_id_to_setter_method_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "set_assist_mode__additional_launch_ball_mode_id"
	assist_mode_id_to_setter_method_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "set_assist_mode__pause_at_esc_id"
	
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "assist_mode__additional_energy_mode_changed"
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.ENERGY_REDUC_MODE] = "assist_mode__energy_reduction_mode_changed"
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "assist_mode__additional_launch_ball_mode_changed"
	assist_mode_id_to_val_changed_signal_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "assist_mode__pause_at_esc_mode_changed"
	
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.ADDITIONAL_ENERGY_MODE] = "assist_mode__additional_energy_mode_id__no_effect"
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.ENERGY_REDUC_MODE] = "assist_mode__energy_reduction_mode_id__no_effect"
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = "assist_mode__additional_launch_ball_mode_id__no_effect"
	assist_mode_id_to_no_effect_var_name_map[AssistModeId.PAUSE_AT_ESC_MODE] = "assist_mode__pause_at_esc_id__no_effect"
	


func _init_assist_mode_rel_signals():
	connect("any_game_modifying_assist_mode_settings_changed", self, "_on_any_game_modifying_assist_mode_settings_changed__for_GE")
	
	if is_instance_valid(SingletonsAndConsts.current_master):
		_connect_signals_with_master()
	else:
		SingletonsAndConsts.connect("current_master_setted", self, "_on_current_master_setted", [], CONNECT_ONESHOT)


func _load_assist_mode_settings_using_dic(data : Dictionary):
	if data.has(ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER):
		set_is_assist_mode_first_time_open(data[ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER])
	else:
		set_is_assist_mode_first_time_open(false)
	
	if data.has(ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER):
		set_is_assist_mode_active(data[ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER])
	else:
		set_is_assist_mode_active(false)
	
	if data.has(ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER):
		var arr_with_str = data[ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER]
		set_assist_mode_ids_unlocked_status__using_array(_convert_arr_of_string_to_arr_of_int(arr_with_str))
	else:
		set_assist_mode_ids_unlocked_status__using_array(assist_mode__unlocked_ids__default)
	
	
	
	if data.has(ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode_toggle_active_mode_id(int(id_as_str))
	else:
		set_assist_mode_toggle_active_mode_id(assist_mode_toggle_active_mode_id__default)
	
	if data.has(ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode__additional_energy_mode_id(int(id_as_str))
	else:
		set_assist_mode__additional_energy_mode_id(assist_mode__additional_energy_mode_id__default)
	
	if data.has(ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode__energy_reduction_mode_id(int(id_as_str))
	else:
		set_assist_mode__energy_reduction_mode_id(assist_mode__energy_reduction_mode_id__default)
	
	if data.has(ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER]
		set_assist_mode__additional_launch_ball_mode_id(int(id_as_str))
	else:
		set_assist_mode__additional_launch_ball_mode_id(assist_mode__additional_launch_ball_mode_id__default)
	
	if data.has(ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER):
		var id_as_str = data[ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER]
		set_assist_mode__pause_at_esc_id(int(id_as_str))
	else:
		set_assist_mode__pause_at_esc_id(assist_mode__pause_at_esc_id__default)
	


func _convert_arr_of_string_to_arr_of_int(arg_arr : Array):
	var bucket = []
	for num_as_str in arg_arr:
		bucket.append(int(num_as_str))
	return bucket



func _generate_save_dict__for_assist_mode():
	return {
		ASSIST_MODE__FIRST_TIME_OPENING_ASSIST_MODE_PANEL__DIC_IDENTIFIER : is_assist_mode_first_time_open,
		ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER : is_assist_mode_active,
		ASSIST_MODE__UNLOCKED_IDS__DIC_IDENTIFIER : _assist_mode__unlocked_ids,
		ASSIST_MODE__TOGGLE_ACTIVE_MODE_ID__DIC_IDENTIFIER : assist_mode_toggle_active_mode_id,
		
		ASSIST_MODE__ADDITIONAL_ENERGY_MODE_ID__DIC_IDENTIFIER : assist_mode__additional_energy_mode_id,
		ASSIST_MODE__ENERGY_REDUCTION_MODE_ID__DIC_IDENTIFIER : assist_mode__energy_reduction_mode_id,
		ASSIST_MODE__ADDITIONAL_LAUNCH_BALL_MODE_ID__DIC_IDENTIFIER : assist_mode__additional_launch_ball_mode_id,
		ASSIST_MODE__PAUSE_AT_ESC_ID__DIC_IDENTIFIER : assist_mode__pause_at_esc_id,
		
	}


func is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals():
	if is_current_assist_mode__additional_energy__has_effect():
		return true
	
	if is_current_assist_mode__energy_reduction__has_effect():
		return true
	
	if is_current_assist_mode__additional_launch_ball__has_effect():
		return true
	
	if is_current_assist_mode__pause_at_esc__has_effect():
		return true
	
	###
	
	return false

#

func set_is_assist_mode_first_time_open(arg_val):
	var old_val = is_assist_mode_first_time_open
	is_assist_mode_first_time_open = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("is_assist_mode_first_time_open_changed", arg_val)


func _any_game_modifying_assist_mode_config_changed():
	emit_signal("any_game_modifying_assist_mode_settings_changed")

func set_is_assist_mode_active(arg_val):
	var old_val = is_assist_mode_active
	is_assist_mode_active = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("is_assist_mode_active_changed", arg_val)
			if is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals():
				_any_game_modifying_assist_mode_config_changed()

func set_assist_mode_toggle_active_mode_id(arg_val):
	var old_val = assist_mode_toggle_active_mode_id
	assist_mode_toggle_active_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode_toggle_active_mode_changed", arg_val)
			#_any_game_modifying_assist_mode_config_changed()


func set_assist_mode_id_unlocked_status(arg_id, arg_is_unlocked_val):
	if arg_is_unlocked_val:
		if !_assist_mode__unlocked_ids.has(arg_id):
			_assist_mode__unlocked_ids.append(arg_id)
			
			if _is_manager_initialized:
				emit_signal("assist_mode_id_unlock_status_changed", arg_id, arg_is_unlocked_val)
				emit_signal("assist_mode_unlocked_ids_changed", _assist_mode__unlocked_ids)
	else:
		if _assist_mode__unlocked_ids.has(arg_id):
			_assist_mode__unlocked_ids.erase(arg_id)
			
			if _is_manager_initialized:
				emit_signal("assist_mode_id_unlock_status_changed", arg_id, arg_is_unlocked_val)
				emit_signal("assist_mode_unlocked_ids_changed", _assist_mode__unlocked_ids)
	
	#print("%s, %s, %s" % [arg_id, arg_is_unlocked_val, _assist_mode__unlocked_ids])

# all other ids not found here will be locked
func set_assist_mode_ids_unlocked_status__using_array(arg_ids_to_set_as_unlocked):
	for id in AssistModeId.values():
		if arg_ids_to_set_as_unlocked.has(id):
			set_assist_mode_id_unlocked_status(id, true)
		else:
			set_assist_mode_id_unlocked_status(id, false)

func is_assist_mode_id_unlocked(arg_id):
	return _assist_mode__unlocked_ids.has(arg_id)

func is_all_assist_mode_ids_unlocked():
	return _assist_mode__unlocked_ids.size() == AssistModeId.size()

func is_any_assist_mode_id_unlocked():
	return _assist_mode__unlocked_ids.size() != 0

####

func set_assist_mode__additional_energy_mode_id(arg_val):
	var old_val = assist_mode__additional_energy_mode_id
	assist_mode__additional_energy_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__additional_energy_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func get_assist_mode__additional_energy_amount_from_current_id():
	return assist_mode__additional_energy_mode_id__details_map[assist_mode__additional_energy_mode_id]

func get_assist_mode__additional_energy_amount_from_id(arg_id):
	return assist_mode__additional_energy_mode_id__details_map[arg_id]

func is_current_assist_mode__additional_energy__has_effect():
	return assist_mode__additional_energy_mode_id != assist_mode__additional_energy_mode_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.ADDITIONAL_ENERGY_MODE)

#

func set_assist_mode__energy_reduction_mode_id(arg_val):
	var old_val = assist_mode__energy_reduction_mode_id
	assist_mode__energy_reduction_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__energy_reduction_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func is_current_assist_mode__energy_reduction__has_effect():
	return assist_mode__energy_reduction_mode_id != assist_mode__energy_reduction_mode_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.ENERGY_REDUC_MODE)


#

func set_assist_mode__additional_launch_ball_mode_id(arg_val):
	var old_val = assist_mode__additional_launch_ball_mode_id
	assist_mode__additional_launch_ball_mode_id = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__additional_launch_ball_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func is_current_assist_mode__additional_launch_ball__has_effect():
	return assist_mode__additional_launch_ball_mode_id != assist_mode__additional_launch_ball_mode_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE)

func get_assist_mode__additional_launch_ball_details_from_current_id():
	return assist_mode__additional_launch_ball_mode_id__details_map[assist_mode__additional_launch_ball_mode_id]

#

func set_assist_mode__pause_at_esc_id(arg_val):
	var old_val = assist_mode__pause_at_esc_id
	assist_mode__pause_at_esc_id = arg_val
	
	#print("setted pause at esc %s" % arg_val)
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("assist_mode__pause_at_esc_mode_changed", arg_val)
			_any_game_modifying_assist_mode_config_changed()

func is_current_assist_mode__pause_at_esc__has_effect():
	return assist_mode__pause_at_esc_id != assist_mode__pause_at_esc_id__no_effect and is_assist_mode_id_unlocked(AssistModeId.PAUSE_AT_ESC_MODE)

#### ASSIST MODE GAME MODI
func attempt_make_game_modifications__based_on_curr_assist_mode_config__before_all():
	_before_game__register_current_assist_mode_id_vals()
	_before_game__setup_assist_mode__plause_on_esc_changes()
	

func attempt_make_game_modifications__based_on_curr_assist_mode_config():
	if is_assist_mode_active and !SingletonsAndConsts.current_level_details.ignore_assist_mode_modifications:
		_before_game__setup_modifications__based_on_curr_assist_mode_config()
		

func _before_game__setup_modifications__based_on_curr_assist_mode_config():
	_before_game__setup_assist_mode__player_modi__changes()
	

# Player modi related assist modif
func _before_game__setup_assist_mode__player_modi__changes():
	SingletonsAndConsts.current_game_elements.player_modi_manager.connect("before_modi_is_configured", self, "_on_before_modi_is_configured__for_assist_mode")
	

func _on_before_modi_is_configured__for_assist_mode(arg_modi):
	if arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.ENERGY:
		if is_current_assist_mode__additional_energy__has_effect():
			arg_modi.make_assist_mode_modification__additional_energy()
		
		if is_current_assist_mode__energy_reduction__has_effect():
			arg_modi.make_assist_mode_modification__energy_reduction_mode()
		
	elif arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL:
		if is_current_assist_mode__additional_launch_ball__has_effect():
			arg_modi.make_assist_mode_modification__additional_launch_ball()
	

func _before_game__setup_assist_mode__plause_on_esc_changes():
	if is_current_assist_mode__pause_at_esc__has_effect():
		if assist_mode__pause_at_esc_id == AssistMode_PauseAtESCModeId.PAUSE:
			SingletonsAndConsts.current_game_elements.pause_game_at_startup = true
		elif assist_mode__pause_at_esc_id == AssistMode_PauseAtESCModeId.NO_PAUSE:
			SingletonsAndConsts.current_game_elements.pause_game_at_startup = false



func _before_game__register_current_assist_mode_id_vals():
	for id in AssistModeId.values():
		var curr_val = get(assist_mode_id_to_var_name_map[id])
		_current_assist_mode_id_to_vals_map_at_current_game_elements[id] = curr_val
	
	current_assist_mode_is_active_at_current_game_elements = is_assist_mode_active
	current_assist_mode_is_active_at_current_game_elements__but_no_effect = !is_any_game_modifying_assist_mode_can_make_changes_based_on_curr_vals()
	
	last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config = false

func _on_any_game_modifying_assist_mode_settings_changed__for_GE():
	if is_instance_valid(SingletonsAndConsts.current_game_elements):
		var old_val = last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config
		
		if _is_any_change_difference_from_assist_mode_config_to_current_GE_assist_mode_config():
			last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config = true
		else:
			last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config = false
		
		if old_val != last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config:
			emit_signal("last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config_changed", last_calc_is_any_difference_from_assist_mode_config_to_curr_GE_config)


func _is_any_change_difference_from_assist_mode_config_to_current_GE_assist_mode_config() -> bool:
	if current_assist_mode_is_active_at_current_game_elements != is_assist_mode_active:
		return true
	
	for id in AssistModeId.values():
		var config_val = get(assist_mode_id_to_var_name_map[id])
		var curr_val = _current_assist_mode_id_to_vals_map_at_current_game_elements[id]
		if config_val != curr_val:
			return true
	
	return false

func get_curr_val_of_assist_mode_id(arg_assist_mode_id):
	return get(assist_mode_id_to_var_name_map[arg_assist_mode_id])

func set_curr_val_of_assist_mode_id(arg_assist_mode_id, arg_val):
	var setter_method_name = assist_mode_id_to_setter_method_name_map[arg_assist_mode_id]
	call(setter_method_name, arg_val)

func get_val_changed_signal_name_of_assist_mode_id(arg_assist_mode_id):
	return assist_mode_id_to_val_changed_signal_name_map[arg_assist_mode_id]

func get_no_effect_val_of_assist_mode_id(arg_assist_mode_id):
	return get(assist_mode_id_to_no_effect_var_name_map[arg_assist_mode_id])



##

func _on_current_master_setted(arg_master):
	_connect_signals_with_master()

func _connect_signals_with_master():
	SingletonsAndConsts.current_master.connect("switching_from_game_elements__non_restart__transition_ended", self, "_on_switching_from_game_elements__non_restart__transition_ended")

func _on_switching_from_game_elements__non_restart__transition_ended():
	if assist_mode_toggle_active_mode_id == AssistMode_ToggleActiveModeId.FOR_THIS_LEVEL_ONLY:
		set_is_assist_mode_active(false)



####################

#tood save and load this
func set_settings_config__is_full_screen(arg_val):
	var old_val = settings_config__is_full_screen
	settings_config__is_full_screen = arg_val
	
	OS.window_fullscreen = arg_val
	
	if _is_manager_initialized:
		emit_signal("settings_config__is_full_screen_changed", arg_val)

func _get_settings_config__is_full_screen__from_proj_settings():
	return ProjectSettings.get_setting("display/window/size/fullscreen")


func set_settings_config__cam_rotation_duration(arg_val):
	var old_val = settings_config__cam_rotation_duration
	settings_config__cam_rotation_duration = arg_val
	
	if old_val != arg_val:
		if _is_manager_initialized:
			emit_signal("settings_config__cam_rotation_duration_changed", arg_val)
		



func _load_settings_config_using_dic(data : Dictionary):
	if data.has(SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER):
		set_settings_config__is_full_screen(data[SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER])
	else:
		set_settings_config__is_full_screen(_get_settings_config__is_full_screen__from_proj_settings())
	
	if data.has(SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER):
		set_settings_config__cam_rotation_duration(data[SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER])
	else:
		set_settings_config__cam_rotation_duration(settings_config__cam_rotation_duration__default)


#

func _get_settings_as_save_dict():
	return {
		SETTINGS_CONFIG__IS_FULL_SCREEN__DIC_IDENTIFIER : settings_config__is_full_screen,
		SETTINGS_CONFIG__CAM_ROTATION_DURATION__DIC_IDENTIFIER : settings_config__cam_rotation_duration,
		
	}

