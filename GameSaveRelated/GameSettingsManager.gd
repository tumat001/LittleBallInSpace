extends Node

#

signal settings_manager_initialized()

signal game_control_hotkey_changed(arg_game_control_action, arg_old_hotkey, arg_new_hotkey)
signal conflicting_game_controls_hotkey_changed(arg_last_calc_game_controls_in_conflicts)

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

const general_game_settings_file_path = "user://general_game_settings.save"
const ASSIST_MODE__CATEGORY__DIC_IDENTIFIER = "ASSIST_MODE_CATEGORY__DIC_IDENTFIER"
const CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER = "CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER"

# Assist mode
const ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER = "ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER"
var is_assist_mode_active : bool setget set_is_assist_mode_active

# Hotkey
var game_control_to_default_event : Dictionary

var _game_control_to_current_event : Dictionary   # used to compare and store pre computeds (last calc)
var _last_calc_game_controls_in_conflicts : Dictionary   # dict of arrs (string -> arr)

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
	#_attempt_load_game_hotkey_controls()
	
	_is_manager_initialized = true
	emit_signal("settings_manager_initialized")






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


####################################
## GENERAL SETTINGS
#####################################

func _save_general_game_settings_related_data():
	var assist_mode_save_dict = _generate_save_dict__for_assist_mode()
	var hotkey_save_dict = _get_game_controls_as_dict()
	
	#
	
	var general_game_settings_save_dict = {
		ASSIST_MODE__CATEGORY__DIC_IDENTIFIER : assist_mode_save_dict,
		CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER : hotkey_save_dict,
		
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
		return false

func _load_general_game_settings_using_file(arg_file : File):
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	###
	
	if data.has(ASSIST_MODE__CATEGORY__DIC_IDENTIFIER):
		_load_assist_mode_settings_using_dic(data[ASSIST_MODE__CATEGORY__DIC_IDENTIFIER])
	else:
		_load_assist_mode_settings_using_dic({})
		
	
	#
	
	if data.has(CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER):
		_load_game_hotkey_using_dic(data[CONTROL_HOTKEYS__CATEGORY__DIC_IDENTIFIER])
	else:
		pass
		#_load_game_hotkey_using_dic()
	_update_states_based_on_game_control_hotkeys__from_ready()
	
	#

######################
## ASSIST MODE

func set_is_assist_mode_active(arg_val):
	is_assist_mode_active = arg_val
	
	#todo


func _load_assist_mode_settings_using_dic(data : Dictionary):
	if data.has(ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER):
		pass
	else:
		pass
	
	

func _generate_save_dict__for_assist_mode():
	return {
		ASSIST_MODE__IS_ASSIST_MODE_ACTIVE__DIC_IDENTIFIER : is_assist_mode_active,
		
	}
	


#####################
## HOTKEY

#func reset_all_controls_to_defaults():
#	InputMap.load_from_globals()
#	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
#



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
	_update_control_conflict_based_on_game_control_hotkeys(false)
	

func _update_states_based_on_game_control_hotkeys__from_ready():
	for game_control in GAME_CONTROLS_TO_NAME_MAP.keys():
		_game_control_to_current_event[game_control] = get_game_control_action_event(game_control)
	
	_update_control_conflict_based_on_game_control_hotkeys(true)
	

func _update_control_conflict_based_on_game_control_hotkeys(arg_emit_signal : bool):
	var new_vals = {}
	for game_control_name in _game_control_to_current_event.keys():
		var curr_event : InputEventKey = _game_control_to_current_event[game_control_name]
		var conflicts = calculate_game_control_name_conflicts_when_assigned_to_hotkey(game_control_name, curr_event)
		if conflicts.size() > 0:
			new_vals[game_control_name] = conflicts
	
	
	###
	
	# probably safe to assume it will be in order
	if deep_equal(new_vals, _last_calc_game_controls_in_conflicts):
		_last_calc_game_controls_in_conflicts = new_vals
		
		if arg_emit_signal:
			emit_signal("conflicting_game_controls_hotkey_changed", _last_calc_game_controls_in_conflicts)


func can_game_control_name_share_input_action_with_game_control_name(arg_name_01, arg_name_02):
	for arr in GAME_CONTROLS_TO_ALLOW_HOTKEY_SHARING_WITH_NO_WARNING:
		if arr.has(arg_name_01) and arr.has(arg_name_02):
			return true
	
	return false

func calculate_game_control_name_conflicts_when_assigned_to_hotkey(arg_control_action_name : String, arg_captured_event : InputEventKey):
	var conflicts = []
	
	var curr_event : InputEventKey = _game_control_to_current_event[arg_control_action_name]
	for game_control_name__j in _game_control_to_current_event.keys():
		if arg_control_action_name != game_control_name__j:
			var curr_event__j : InputEventKey = _game_control_to_current_event[game_control_name__j]
			if curr_event.as_text() == curr_event__j.as_text():
				if !can_game_control_name_share_input_action_with_game_control_name(arg_control_action_name, game_control_name__j):
					conflicts.append(game_control_name__j)
	
	return conflicts

#

func get_game_control_hotkey__as_string(arg_control_action_name : String):
	var input_events = InputMap.get_action_list(arg_control_action_name)
	
	var key_char : String = ""
	if input_events.size() > 0:
		key_char = input_events[0].as_text()
	
	return key_char

func get_game_control_action_event(arg_control_action_name : String):
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

func is_game_control_hotkey_default_for_action(arg_control_action_name : String, arg_captured_event : InputEventKey):
	if if_game_control_has_default(arg_control_action_name):
		return arg_captured_event.as_text() == game_control_to_default_event[arg_control_action_name].as_text()

func if_game_control_has_default(arg_control_action_name : String):
	return game_control_to_default_event.has(arg_control_action_name)



func get_last_calc_game_control_conflicting_inputs_with_other_controls(arg_control_action_name : String) -> Array:
	if if_last_calc_game_control_has_conflicts(arg_control_action_name):
		return _last_calc_game_controls_in_conflicts[arg_control_action_name]
	else:
		return []

func if_last_calc_game_control_has_conflicts(arg_control_action_name : String):
	return _last_calc_game_controls_in_conflicts.has(arg_control_action_name)

##

func _get_game_controls_as_dict():
	var all_actions = InputMap.get_actions()
	var dict = {}
	for action_name in all_actions:
		if GAME_CONTROLS_TO_NAME_MAP.has(action_name):
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


