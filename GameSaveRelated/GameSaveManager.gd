extends Node


const GUI_AbstractLevelLayout = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd")

#

signal coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id)


signal is_player_health_on_start_zero_changed()

signal first_time_play()

signal save_manager_initialized()

#

const player_data_file_path = "user://player_data.save"


const PLAYER_HEALTH__DIC_IDENTIFIER = "PlayerHealthOnStart"
const PLAYER_NAME__DIC_IDENTIFIER = "PlayerName"
const FIRST_TIME_OPENING__DIC_IDENTIFIER = "FirstTimeOpening"
const PLAYER_COIN__DIC_IDENTIFIER = "PLAYER_COIN_LEVEL_MAP__DIC_IDENTIFIER"

const PLAYER_MAX_HEALTH = 100
const INITIAL_PLAYER_HEALTH_AT_START = PLAYER_MAX_HEALTH

##########

var _is_manager_initialized : bool = false

#

var player_health_on_start : float = INITIAL_PLAYER_HEALTH_AT_START
var tentative_player_health_on_start

var player_name : String

var first_time_opening_game : bool


var _level_id_to_coin_ids_collected_map : Dictionary
var _total_coin_collected_count : int

############################################

const level_data_file_path = "user://level_layout_data.save"

const LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER = "last_opened_level_layout_id"
const LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER = "last_hovered_over_level_layout_element_id"

var last_opened_level_layout_id
var last_hovered_over_level_layout_element_id


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
	
	for ele in save_arr:
		save_file.store_line(to_json(ele))
	
	save_file.close()

################################

func _ready():
	_attempt_load_existing_player_related_data()
	_attempt_load_existing_level_related_data()
	
	
	
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
	
	if data.has(PLAYER_COIN__DIC_IDENTIFIER):
		_level_id_to_coin_ids_collected_map = data[PLAYER_COIN__DIC_IDENTIFIER]
		_correct_and_fill_level_id_to_coins_collected_map()
	else:
		_initialize_level_id_to_coins_collected_count_map()

func _initialize_level_id_to_coins_collected_count_map():
	_level_id_to_coin_ids_collected_map = {}
	_correct_and_fill_level_id_to_coins_collected_map()

func _correct_and_fill_level_id_to_coins_collected_map():
	for level_id in StoreOfLevels.LevelIds.values():
		if !_level_id_to_coin_ids_collected_map.has(level_id):
			_level_id_to_coin_ids_collected_map[level_id] = []
	


func is_coin_id_collected_in_level(arg_coin_id, arg_level_id):
	return _level_id_to_coin_ids_collected_map[arg_level_id].has(arg_coin_id)

func set_coin_id_in_level_as_collected(arg_coin_id, arg_level_id, arg_is_collected : bool):
	var coins_collected : Array = _level_id_to_coin_ids_collected_map[arg_level_id]
	if arg_is_collected:
		if !coins_collected.has(arg_coin_id):
			coins_collected.append(arg_coin_id)
	else:
		if coins_collected.has(arg_coin_id):
			coins_collected.erase(arg_coin_id)
		
	
	_total_coin_collected_count = _calculate_coin_count_collected_in_whole_game()
	emit_signal("coin_collected_for_level_changed", coins_collected, arg_coin_id, arg_level_id)

func _calculate_coin_count_collected_in_whole_game():
	var total = 0
	for coin_ids_collected in _level_id_to_coin_ids_collected_map.values():
		total += coin_ids_collected.size()
	
	return total



func get_coin_ids_collected_in_level(arg_level_id):
	return _level_id_to_coin_ids_collected_map[arg_level_id]


func get_total_coin_collected_count() -> int:
	return _total_coin_collected_count


#

func _save_player_data():
	var save_dict = {
		PLAYER_HEALTH__DIC_IDENTIFIER : player_health_on_start,
		PLAYER_NAME__DIC_IDENTIFIER : player_name,
		FIRST_TIME_OPENING__DIC_IDENTIFIER : first_time_opening_game,
		PLAYER_COIN__DIC_IDENTIFIER : _level_id_to_coin_ids_collected_map, 
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
	

#



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
	
	

# todo make save for last opened lvl layout id and relateds



#############################################
##
#############################################

func _exit_tree():
	_save_player_data()


