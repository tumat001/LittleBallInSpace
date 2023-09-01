extends Node


const GUI_AbstractLevelLayout = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd")

#

signal level_layout_id_completion_status_changed(arg_id, arg_status)
signal level_id_completion_status_changed(arg_id, arg_status)
signal coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id)


signal is_player_health_on_start_zero_changed()

signal game_control_is_hidden_changed(arg_game_control_name, arg_is_hidden)


signal first_time_play()

signal save_manager_initialized()

#


var _is_manager_initialized : bool = false


#

const player_data_file_path = "user://player_data.save"


const PLAYER_HEALTH__DIC_IDENTIFIER = "PlayerHealthOnStart"
const PLAYER_NAME__DIC_IDENTIFIER = "PlayerName"
const FIRST_TIME_OPENING__DIC_IDENTIFIER = "FirstTimeOpening"
const ANIMAL_CHOICE__DIC_IDENTIFIER = "AnimalChoice"
const LEVEL_ID_DIED_IN__DIC_IDENTIFIER = "LEVEL_ID_DIED_IN__DIC_IDENTIFIER"


const PLAYER_MAX_HEALTH = 100
const INITIAL_PLAYER_HEALTH_AT_START = PLAYER_MAX_HEALTH


var player_health_on_start : float = INITIAL_PLAYER_HEALTH_AT_START
var tentative_player_health_on_start
var level_id_died_in

var player_name : String

var first_time_opening_game : bool

enum AnimalChoiceId {
	DOG = 0,
	CAT = 1,
}
var animal_choice_id : int

###

#

const level_data_file_path = "user://level_layout_data.save"


const LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER = "last_opened_level_layout_id"
const LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER = "last_hovered_over_level_layout_element_id"

const LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER = "LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER"
const LEVEL_ID_TO_COMPLETION_STATUS__DIC_IDENTIFIER = "level_id_to_completion_status"
const LEVEL_LAYOUT_ID_COMPLETION_STATUS__DIC_IDENTIFIER = "level_layout_id_to_completion_status"


const LEVEL_ID_TO_METADATA__DIC_IDENTIFIER = "LEVEL_ID_TO_METADATA__DIC_IDENTIFIER"
#const LEVEL_ID_TO_IS_HIDDEN__DIC_IDENTIFIER = "level_id_to_override_is_hidden_val_map"
const ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER = "ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER"
const REGISTERED_LAYOUT_ID_TO_LAYOUT_ELEMENT_IDS_TO_IS_INVISIBLE_MAP__DIC_IDENTIFIER = "REGISTERED_LAYOUT_ID_TO_LAYOUT_ELEMENT_IDS_TO_IS_INVISIBLE_MAP__DIC_IDENTIFIER"


# If adding more, look at GUI_LevelDetailsPanel for appropriate changes
const LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED = -1
const LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED = 0
const LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED = 1
const LEVEL_OR_LAYOUT_COMPLETION_STATUS__HALF_FINISHED = 2



var _level_id_as_str_to_coin_ids_collected_map : Dictionary
var _total_coin_collected_count : int

var _tentative_coin_ids_collected_in_curr_level_id : Array = []


var _level_id_to_completion_status : Dictionary
var _total_levels_finished : int
var _level_layout_id_to_completion_status : Dictionary


var last_opened_level_layout_id
var last_hovered_over_level_layout_element_id


var _level_id_to_metadata_map : Dictionary


var _registered_layout_id_to_layout_element_ids_to_is_invis_map : Dictionary


#var _level_id_to_override_is_hidden_val_map : Dictionary

####

const audio_settings_file_path = "user://audio_settings.save"


####

const game_control_settings_file_path = "user://game_control_settings.save"

var _game_control_name_string_to_is_hidden_map : Dictionary
const GAME_CONTROLS_TO_NAME_MAP = {
	"ui_left" : "Move Left",
	"ui_right" : "Move Right",
	"ui_down" : "Slow to Stop",
	"game_zoom_out" : "Toggle Zoom",
	"rewind" : "Rewind",
	"game_launch_ball" : "Launch Ball",
}
const GAME_CONTROLS_TO_NOT_BE_HIDDEN_BY_DEFAULT = [
	"ui_left",
	"ui_right"
]


const GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER = "GAME_CONTROL_ID_TO_IS_HIDDEN_MAP__DIC_IDENTIFIER"


###

const stage_special_01_02__data_arr_file_path = "user://stage_special_01_02_data.save"


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

func _ready():
	_attempt_load_existing_player_related_data()
	_attempt_load_existing_level_related_data()
	
	_load_stats__of_audio_manager()
	_attempt_load_game_controls_related_data()
	
	_is_manager_initialized = true
	emit_signal("save_manager_initialized")
	
	if first_time_opening_game:
		emit_signal("first_time_play")


func is_manager_initialized() -> bool:
	return _is_manager_initialized

####################################
## PLAYER RELATED
####################################

func _attempt_load_existing_player_related_data():
	var load_file = File.new()
	
	if load_file.file_exists(player_data_file_path):
		var err_stat = load_file.open(player_data_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- Player data")
			return false
		
		_load_player_related_data(load_file)
		
		load_file.close()
		return true
		
	else:
		_load_player_related_data(null)
		return false


func _load_player_related_data(arg_file : File):
	
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	##
	
	if data.has(PLAYER_HEALTH__DIC_IDENTIFIER):
		player_health_on_start = float(data[PLAYER_HEALTH__DIC_IDENTIFIER])
	else:
		player_health_on_start = INITIAL_PLAYER_HEALTH_AT_START
	
	##
	
	if data.has(PLAYER_NAME__DIC_IDENTIFIER):
		player_name = data[PLAYER_NAME__DIC_IDENTIFIER]
	else:
		player_name = ""
	
	##
	
	if data.has(FIRST_TIME_OPENING__DIC_IDENTIFIER):
		first_time_opening_game = data[FIRST_TIME_OPENING__DIC_IDENTIFIER]
	else:
		first_time_opening_game = true
	
	##
	
	if data.has(ANIMAL_CHOICE__DIC_IDENTIFIER):
		animal_choice_id = data[ANIMAL_CHOICE__DIC_IDENTIFIER]
	else:
		animal_choice_id = AnimalChoiceId.DOG
	
	##
	
	if data.has(LEVEL_ID_DIED_IN__DIC_IDENTIFIER):
		level_id_died_in = data[LEVEL_ID_DIED_IN__DIC_IDENTIFIER]
	else:
		level_id_died_in = -1

#

func _initialize_level_id_to_coins_collected_count_map():
	_level_id_as_str_to_coin_ids_collected_map = {}
	_correct_and_fill_level_id_to_coins_collected_map()

func _correct_and_fill_level_id_to_coins_collected_map():
	for level_id in StoreOfLevels.LevelIds.values():
		level_id = str(level_id)
		if !_level_id_as_str_to_coin_ids_collected_map.has(level_id):
			_level_id_as_str_to_coin_ids_collected_map[level_id] = []
	


func is_coin_id_collected_in_level(arg_coin_id, arg_level_id):
	arg_level_id = str(arg_level_id)
	return _level_id_as_str_to_coin_ids_collected_map[arg_level_id].has(arg_coin_id)

func set_coin_id_in_level_as_collected(arg_coin_id, arg_level_id, arg_is_collected : bool):
	arg_level_id = str(arg_level_id)
	var coins_collected : Array = _level_id_as_str_to_coin_ids_collected_map[arg_level_id]
	if arg_is_collected:
		if !coins_collected.has(arg_coin_id):
			coins_collected.append(arg_coin_id)
	else:
		if coins_collected.has(arg_coin_id):
			coins_collected.erase(arg_coin_id)
		
	
	_update_coin_count_collected_in_whole_game()
	emit_signal("coin_collected_for_level_changed", coins_collected, arg_coin_id, arg_level_id)

func _update_coin_count_collected_in_whole_game():
	var total = 0
	for coin_ids_collected in _level_id_as_str_to_coin_ids_collected_map.values():
		total += coin_ids_collected.size()
	
	_total_coin_collected_count = total



func set_tentative_coin_id_collected_in_curr_level(arg_id, arg_is_collected):
	if arg_is_collected:
		if !_tentative_coin_ids_collected_in_curr_level_id.has(arg_id):
			_tentative_coin_ids_collected_in_curr_level_id.append(arg_id)
		
	else:
		if _tentative_coin_ids_collected_in_curr_level_id.has(arg_id):
			_tentative_coin_ids_collected_in_curr_level_id.erase(arg_id)
		


func get_coin_ids_collected_in_level(arg_level_id):
	arg_level_id = str(arg_level_id)
	return _level_id_as_str_to_coin_ids_collected_map[arg_level_id]


func get_total_coin_collected_count() -> int:
	return _total_coin_collected_count



func is_all_coins_collected_in_level(arg_level_id) -> bool:
	var coin_count = get_coin_ids_collected_in_level(arg_level_id).size()
	var total_for_level = StoreOfLevels.get_coin_count_for_level(arg_level_id)
	
	return coin_count == total_for_level

#

func remove_official_coin_ids_collected_from_tentative():
	var coin_ids = _level_id_as_str_to_coin_ids_collected_map[str(SingletonsAndConsts.current_level_details.level_id)]
	var erased_at_least_one : bool = false
	
	for id in _tentative_coin_ids_collected_in_curr_level_id:
		var id_as_str = str(id)
		if coin_ids.has(id_as_str):
			erased_at_least_one = true
			coin_ids.erase(id_as_str)
	
	if erased_at_least_one:
		_update_coin_count_collected_in_whole_game()
	
	clear_coin_ids_in_tentative()

func clear_coin_ids_in_tentative():
	_tentative_coin_ids_collected_in_curr_level_id.clear()

#

func _correct_level_id_to_completion_status_map(arg_map_from_save_dict : Dictionary):
	for level_id in StoreOfLevels.LevelIds.values():
		var level_id_as_str = str(level_id)
		
		if arg_map_from_save_dict.has(level_id_as_str):
			#_level_id_to_completion_status[level_id] = arg_map_from_save_dict[level_id_as_str]
			_set_level_id_status_completion__internal(level_id, arg_map_from_save_dict[level_id_as_str], false)
			
		else:
			#_level_id_to_completion_status[level_id] = LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED
			_set_level_id_status_completion__internal(level_id, LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED, false)
			
		
	
	_update_total_levels_finished()
	#print(_level_id_to_completion_status)
	
	StoreOfLevels.connect("hidden_levels_state_changed", self, "_on_hidden_levels_state_changed")
	

func _initialize_level_id_to_completion_status_map():
	for level_id in StoreOfLevels.LevelIds.values():
		#_level_id_to_completion_status[level_id] = LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED
		_set_level_id_status_completion__internal(level_id, LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED, false)
	
	for id in StoreOfLevels.level_ids_unlocked_by_default:
		#_level_id_to_completion_status[id] = LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED
		_set_level_id_status_completion__internal(id, LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED, false)
	
	_update_total_levels_finished()

func is_level_id_playable(arg_id):
	var status = _level_id_to_completion_status[arg_id]
	
	return status != LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED

func is_level_id_finished(arg_id):
	var status = _level_id_to_completion_status[arg_id]
	
	return status == LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED


func get_level_id_status_completion(arg_id):
	return _level_id_to_completion_status[arg_id]

func set_level_id_status_completion(arg_id, arg_status):
	var old_val = _level_id_to_completion_status[arg_id]
	_set_level_id_status_completion__internal(arg_id, arg_status, true)
	
	if old_val != arg_status:
		emit_signal("level_id_completion_status_changed", arg_id, arg_status)

func _set_level_id_status_completion__internal(arg_id, arg_status, arg_update_total : bool):
	_level_id_to_completion_status[arg_id] = arg_status
	
	if arg_update_total:
		_update_total_levels_finished()

func _update_total_levels_finished():
	var total = 0
	var all_non_hidden_level_ids = StoreOfLevels.get_all_non_hidden_level_ids()
	for level_id in _level_id_to_completion_status.keys():
		if all_non_hidden_level_ids.has(level_id):
			var completion_status = _level_id_to_completion_status[level_id]
			if completion_status == LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED:
				total += 1
	
	_total_levels_finished = total

func get_total_levels_finished():
	return _total_levels_finished



func _on_hidden_levels_state_changed():
	_update_total_levels_finished()

#

func _correct_level_layout_id_to_completion_status_map(arg_map_from_save_dict : Dictionary):
	for level_layout_id in StoreOfLevelLayouts.LevelLayoutIds.values():
		var level_layout_id_as_str = str(level_layout_id)
		if arg_map_from_save_dict.has(level_layout_id_as_str):
			_level_layout_id_to_completion_status[level_layout_id] = arg_map_from_save_dict[level_layout_id_as_str]
		else:
			_level_layout_id_to_completion_status[level_layout_id] = LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED


func _initialize_level_layout_id_to_completion_status_map():
	for level_layout_id in StoreOfLevelLayouts.LevelLayoutIds.values():
		_level_layout_id_to_completion_status[level_layout_id] = LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED

	for id in StoreOfLevelLayouts.level_layout_ids_unlocked_by_default:
		_level_layout_id_to_completion_status[id] = LEVEL_OR_LAYOUT_COMPLETION_STATUS__UNLOCKED



func is_level_layout_id_playable(arg_id):
	var status = _level_layout_id_to_completion_status[arg_id]
	
	return status != LEVEL_OR_LAYOUT_COMPLETION_STATUS__LOCKED

func set_level_layout_id_status_completion(arg_id, arg_status):
	var old_val = _level_layout_id_to_completion_status[arg_id]
	_level_layout_id_to_completion_status[arg_id] = arg_status
	
	if old_val != arg_status:
		emit_signal("level_layout_id_completion_status_changed", arg_id, arg_status)


#

func _save_player_data():
	var save_dict = {
		PLAYER_HEALTH__DIC_IDENTIFIER : player_health_on_start,
		PLAYER_NAME__DIC_IDENTIFIER : player_name,
		FIRST_TIME_OPENING__DIC_IDENTIFIER : first_time_opening_game,
		ANIMAL_CHOICE__DIC_IDENTIFIER : animal_choice_id,
		LEVEL_ID_DIED_IN__DIC_IDENTIFIER : level_id_died_in,
		
	}
	
	_save_using_dict(save_dict, player_data_file_path, "SAVE ERROR: PlayerData")

##################

func set_player(arg_player):
	arg_player.set_max_health(PLAYER_MAX_HEALTH)
	if !is_equal_approx(player_health_on_start, 0):
		arg_player.set_current_health(player_health_on_start, false)
		tentative_player_health_on_start = player_health_on_start
	else:
		arg_player.set_current_health(0, false)
		tentative_player_health_on_start = 0
	
	arg_player.connect("health_reached_breakpoint", self, "_on_player_health_reached_breakpoint", [], CONNECT_PERSIST)
	arg_player.connect("all_health_lost", self, "_on_player_all_health_lost", [], CONNECT_PERSIST)
	arg_player.connect("health_restored_from_zero", self, "_on_player_health_restored_from_zero", [arg_player.health_breakpoints[0]], CONNECT_PERSIST)
	arg_player.connect("health_fully_restored", self, "_on_player_health_fully_restored", [], CONNECT_PERSIST)

func _on_player_health_reached_breakpoint(arg_breakpoint_val, arg_health_val_at_breakpoint):
	tentative_player_health_on_start = arg_health_val_at_breakpoint
	

func _on_player_all_health_lost():
	tentative_player_health_on_start = 0
	
	emit_signal("is_player_health_on_start_zero_changed", true)


func _on_player_health_restored_from_zero(arg_health_val_at_lowest_breakpoint):
	tentative_player_health_on_start = arg_health_val_at_lowest_breakpoint
	
	emit_signal("is_player_health_on_start_zero_changed", false)


func _on_player_health_fully_restored():
	tentative_player_health_on_start = PLAYER_MAX_HEALTH


##

func set_game_elements(arg_elements):
	arg_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided", [arg_elements.game_result_manager])
	


func _on_game_result_decided(arg_result, arg_game_result_manager):
	if arg_result == arg_game_result_manager.GameResult.WIN:
		player_health_on_start = tentative_player_health_on_start
		
		if is_zero_approx(player_health_on_start) and level_id_died_in == -1:
			level_id_died_in = SingletonsAndConsts.current_base_level_id


#####################################
## LEVEL RELATED
####################################

func _attempt_load_existing_level_related_data():
	var load_file = File.new()
	
	if load_file.file_exists(level_data_file_path):
		var err_stat = load_file.open(level_data_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- Level data")
			return false
		
		_load_level_related_data(load_file)
		
		load_file.close()
		return true
		
	else:
		_load_level_related_data(null)
		return false
	
	


func _load_level_related_data(arg_file : File):
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	##
	
	if data.has(LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER):
		last_opened_level_layout_id = int(data[LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER])
	else:
		last_opened_level_layout_id = StoreOfLevelLayouts.FIRST_LEVEl_LAYOUT
	
	
	if data.has(LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER):
		last_hovered_over_level_layout_element_id = int(data[LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER])
	else:
		last_hovered_over_level_layout_element_id = GUI_AbstractLevelLayout.UNINITIALIZED_CURSOR
	
	
	
	if data.has(LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER):
		_level_id_as_str_to_coin_ids_collected_map = data[LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER]
		_correct_and_fill_level_id_to_coins_collected_map()
	else:
		_initialize_level_id_to_coins_collected_count_map()
	
	_update_coin_count_collected_in_whole_game()
	
	##
	
	if data.has(LEVEL_ID_TO_COMPLETION_STATUS__DIC_IDENTIFIER):
		_correct_level_id_to_completion_status_map(data[LEVEL_ID_TO_COMPLETION_STATUS__DIC_IDENTIFIER])
	else:
		_initialize_level_id_to_completion_status_map()
	
	#
	
	if data.has(LEVEL_LAYOUT_ID_COMPLETION_STATUS__DIC_IDENTIFIER):
		_correct_level_layout_id_to_completion_status_map(data[LEVEL_LAYOUT_ID_COMPLETION_STATUS__DIC_IDENTIFIER])
	else:
		_initialize_level_layout_id_to_completion_status_map()
	
	#
	
	if data.has(LEVEL_ID_TO_METADATA__DIC_IDENTIFIER):
		_correct_level_id_to_metadata_map(data[LEVEL_ID_TO_METADATA__DIC_IDENTIFIER])
	else:
		pass
	
	#
	
	if data.has(ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER):
		#_correct_level_id_to_is_hidden_map__do_unhide_based_on_data(data[LEVEL_ID_TO_IS_HIDDEN__DIC_IDENTIFIER])
		_configure_level_hidden_states_based_on_save_state(data[ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER])
	else:
		pass
	
	#
	
	if data.has(REGISTERED_LAYOUT_ID_TO_LAYOUT_ELEMENT_IDS_TO_IS_INVISIBLE_MAP__DIC_IDENTIFIER):
		_configure_registered_layout_element_ids_to_invis_map(data[REGISTERED_LAYOUT_ID_TO_LAYOUT_ELEMENT_IDS_TO_IS_INVISIBLE_MAP__DIC_IDENTIFIER])
	else:
		pass



func _correct_level_id_to_metadata_map(arg_map_from_save_dict : Dictionary):
	for id_as_str in arg_map_from_save_dict.keys():
		var id = int(id_as_str)
		_level_id_to_metadata_map[id] = arg_map_from_save_dict[id_as_str]
	

func set_metadata_of_level_id(arg_id, arg_metadata):
	_level_id_to_metadata_map[arg_id] = arg_metadata

func get_metadata_of_level_id(arg_id):
	if _level_id_to_metadata_map.has(arg_id):
		return _level_id_to_metadata_map[arg_id]
	
	return null

func has_metadata_in_level_id(arg_id):
	return _level_id_to_metadata_map.has(arg_id)


#

#func _correct_level_id_to_is_hidden_map__do_unhide_based_on_data(arg_map_from_save_dict : Dictionary):
#	var non_hidden_level_ids = []
#
#	for level_id_as_str in arg_map_from_save_dict.keys():
#		var is_hidden = arg_map_from_save_dict[level_id_as_str]
#
#		if !is_hidden:
#			non_hidden_level_ids.append(int(level_id_as_str))
#
#
#	StoreOfLevels.add_level_ids_as_non_hidden(non_hidden_level_ids)

func _configure_level_hidden_states_based_on_save_state(arg_state : int):
	StoreOfLevels.set_current_level_hidden_state(arg_state)

#

func _configure_registered_layout_element_ids_to_invis_map(arg_map_from_save_dict : Dictionary):
	for layout_id_as_str in arg_map_from_save_dict.keys():
		var layout_id = int(layout_id_as_str)
		for layout_element_id_as_str in arg_map_from_save_dict[layout_id_as_str]:
			var layout_element_id = int(layout_element_id_as_str)
			#_registered_layout_id_to_layout_element_ids_to_is_invis_map[layout_id][layout_element_id] = arg_map_from_save_dict[layout_id_as_str][layout_element_id]
			
			set_layout_id__layout_element_id__is_invis(layout_id, layout_element_id, arg_map_from_save_dict[layout_id_as_str][layout_element_id_as_str])
		
		#_registered_layout_element_ids_to_is_invis_map[id] = arg_map_from_save_dict[id_as_str]
	

func set_layout_id__layout_element_id__is_invis(arg_layout_id, arg_layout_element_id, arg_is_invis : bool):
	if !_registered_layout_id_to_layout_element_ids_to_is_invis_map.has(arg_layout_id):
		_registered_layout_id_to_layout_element_ids_to_is_invis_map[arg_layout_id] = {}
	
	_registered_layout_id_to_layout_element_ids_to_is_invis_map[arg_layout_id][arg_layout_element_id] = arg_is_invis


func is_layout_id__layout_element_id_invis__val_registered(arg_layout_id, arg_layout_element_id):
	if _registered_layout_id_to_layout_element_ids_to_is_invis_map.has(arg_layout_id):
		return _registered_layout_id_to_layout_element_ids_to_is_invis_map[arg_layout_id].has(arg_layout_element_id)
	else:
		return false

func get_layout_id__layout_element_id__is_invis(arg_layout_id, arg_layout_element_id):
	return _registered_layout_id_to_layout_element_ids_to_is_invis_map[arg_layout_id][arg_layout_element_id]



#

func save_level_and_layout_related_data():
	var save_dict = {
		LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER : last_opened_level_layout_id,
		LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER : last_hovered_over_level_layout_element_id,
		
		LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER : _level_id_as_str_to_coin_ids_collected_map,
		LEVEL_ID_TO_COMPLETION_STATUS__DIC_IDENTIFIER : _level_id_to_completion_status,
		LEVEL_LAYOUT_ID_COMPLETION_STATUS__DIC_IDENTIFIER : _level_layout_id_to_completion_status,
		
		LEVEL_ID_TO_METADATA__DIC_IDENTIFIER : _level_id_to_metadata_map,
		#LEVEL_ID_TO_IS_HIDDEN__DIC_IDENTIFIER : StoreOfLevels.get_all_level_id_to_is_hidden_map()
		ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER : StoreOfLevels.get_current_levels_hidden_state(),
		REGISTERED_LAYOUT_ID_TO_LAYOUT_ELEMENT_IDS_TO_IS_INVISIBLE_MAP__DIC_IDENTIFIER = _registered_layout_id_to_layout_element_ids_to_is_invis_map,
		
	}
	
	_save_using_dict(save_dict, level_data_file_path, "SAVE ERROR: LevelAndLayoutData")



## AUDIO RELATED --------------------------

func save_settings__of_audio_manager():
	var save_dict = AudioManager._get_save_dict_for_data()
	var err_msg = "Saving error! -- AudioManager"
	_save_using_dict(save_dict, audio_settings_file_path, err_msg)
	
	

func _load_stats__of_audio_manager():
	var load_file = File.new()
	
	if load_file.file_exists(audio_settings_file_path):
		var err_stat = load_file.open(audio_settings_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- AudioManager")
			return false
		
		AudioManager._load_save_data(load_file)
		
		load_file.close()
		return true
		
	else:
		
		AudioManager._initialize_save_data_from_scratch()
		return false



## CONTROLS RELATED

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
		
	

#

func set_game_control_name_string__is_hidden(arg_game_control_name : String, arg_is_hidden : bool):
	_game_control_name_string_to_is_hidden_map[arg_game_control_name] = arg_is_hidden
	
	emit_signal("game_control_is_hidden_changed", arg_game_control_name, arg_is_hidden)

func get_game_control_name__is_hidden(arg_game_control_name : String):
	return _game_control_name_string_to_is_hidden_map[arg_game_control_name]

func get_game_control_name_string_to_is_hidden_map__not_copy():
	return _game_control_name_string_to_is_hidden_map


#


func attempt_load_special_stage_01_02_data():
	var load_file = File.new()
	
	if load_file.file_exists(stage_special_01_02__data_arr_file_path):
		var err_stat = load_file.open(stage_special_01_02__data_arr_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- stage_special_01_02__data")
			return false
		
		var result = _load_stage_special_01_02_data(load_file)
		
		load_file.close()
		return result
		
	else:
		#_load_game_controls_related_data(null)
		return null

func _load_stage_special_01_02_data(arg_file : File):
	var data : Array
	if arg_file != null:
		data = parse_json(arg_file.get_line())
		
		#while !arg_file.eof_reached():
		#	var line = parse_json(arg_file.get_line())
		#	data.append(line)
	
	return data


# special case use.
func _save_stage_special_01_02_data(arg_data : Array):
	_save_using_arr(arg_data, stage_special_01_02__data_arr_file_path, "SAVE ERROR: SpecialStage01 02 settings")
	


#############################################
##
#############################################

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_save_player_data()
		save_level_and_layout_related_data()
		_save_game_control_related_data()

#func _exit_tree():
#	_save_player_data()
#	save_level_and_layout_related_data()
#
