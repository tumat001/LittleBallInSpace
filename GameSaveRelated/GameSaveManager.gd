extends Node


const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
const GUI_AbstractLevelLayout = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd")

const Singleton_GameInfo = preload("res://GameSaveRelated/Singleton_GameInfo.gd")


#

signal level_layout_id_completion_status_changed(arg_id, arg_status)
signal level_id_completion_status_changed(arg_id, arg_status)
signal coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id)
signal tentative_coin_ids_collected_changed__for_curr_level(arg_tentative_coin_ids_collected_in_curr_level_id, arg_is_collected, arg_is_all_collected)
signal can_view_game_stats_changed(arg_val)
signal can_edit_tile_colors_changed(arg_val)
signal can_edit_player_aesth_changed(arg_val)
signal can_config_custom_audio_changed(arg_val)
#signal trophy_collected__with_metadata(arg_trophy, arg_metadata)
#signal trophy_uncollected__with_metadata(arg_trophy)
signal trophies_collected_changed()

signal is_player_health_on_start_zero_changed()
signal is_player_health_invulnerable__state_changed(arg_val)

signal first_time_play()

signal save_manager_initialized()
signal before_save_manager_initialized()

#


var _is_manager_initialized : bool = false


#

const player_data_file_path = "user://player_data.save"


const PLAYER_HEALTH__DIC_IDENTIFIER = "PlayerHealthOnStart"
const IS_PLAYER_HEALTH_INVUL_STATE__DIC_IDENTIFIER = "is_player_health_invulnerable"
const PLAYER_NAME__DIC_IDENTIFIER = "PlayerName"
const FIRST_TIME_OPENING__DIC_IDENTIFIER = "FirstTimeOpening"
const ANIMAL_CHOICE__DIC_IDENTIFIER = "AnimalChoice"
const LEVEL_ID_DIED_IN__DIC_IDENTIFIER = "LEVEL_ID_DIED_IN__DIC_IDENTIFIER"
const CAN_VIEW_GAME_STATS__DIC_IDENTIFIER = "CAN_VIEW_GAME_STATS__DIC_IDENTIFIER"
const CAN_EDIT_TILE_COLORS__DIC_IDENTIFIER = "CAN_EDIT_TILE_COLORS__DIC_IDENTIFIER"
const CAN_EDIT_PLAYER_AESTH__DIC_IDENTIFIER = "CAN_EDIT_PLAYER_AESTH__DIC_IDENTIFIER"
const CAN_CONFIG_CUSTOM_AUDIO__DIC_IDENTIFIER = "CAN_CONFIG_CUSTOM_AUDIO__DIC_IDENTIFIER"
const TROPHY_COLLECTED__DIC_IDENTIFIER = "TROPHY_COLLECTED"

const VERSION_NUM__DIC_IDENTIFIER = "VersionNumber"
const LAST_PLAYTHRU_IS_FROM_DEMO__DIC_IDENTIFIER = "LastPlaythruIsFromDemo"

#

const PLAYER_MAX_HEALTH = 100
const INITIAL_PLAYER_HEALTH_AT_START = PLAYER_MAX_HEALTH

#

var ignore_appdata : bool

#

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


enum IsPlayerHealthInvulTypeId {
	IS_NOT_INVUL = -1,
	UNINIT = 0,
	IS_INVUL = 1,
}
const IS_PLAYER_HEALTH_INVULNERABLE__INITIAL_VAL = IsPlayerHealthInvulTypeId.UNINIT
var is_player_health_invulnerable__state : int = IS_PLAYER_HEALTH_INVULNERABLE__INITIAL_VAL setget set_is_player_health_invulnerable__state


var can_view_game_stats : bool setget set_can_view_game_stats
var can_edit_tile_colors : bool setget set_can_edit_tile_colors
var can_edit_player_aesth : bool setget set_can_edit_player_aesth
var can_config_custom_audio : bool setget set_can_config_custom_audio


enum TrophyNonVolatileId {
	WSSS0103_NO_ASSIST_MODE_USED = 0,
	WSSS0202_SUPER_STAR_COLLECTED = 1,
	WSSS0202_SUPER_STAR_COLLECTED__WHILE_BLINDED_LOW_STAR = 2,
	ALL_STARS_COLLECTED = 3,
	
}
var collected_trophy_id_to_metadata_map : Dictionary = {}
var trophy_id_to_details_map : Dictionary = {}

class TrophyDetails:
	var trophy_id : int
	var trophy_name : String
	var trophy_mini_image : Texture
	var desc : Array

###

var version_num_as_str : String
var is_last_playthru_from_demo : bool

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



###

const stage_special_01_02__data_arr_file_path = "user://stage_special_01_02_data.save"

##

const USER_DIR = "user://"
const USER_DIR__IMG_SAVE_FilePath = "ScrnShots/"


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
	
	##
	_attempt_load_existing_level_related_data()
	
	_load_stats__of_audio_manager()
	#_attempt_load_game_controls_related_data()
	
	GameSettingsManager.load_all__from_ready_of_save_manager()
	GameStatsManager.load_all__from_ready_of_save_manager()
	
	
	emit_signal("before_save_manager_initialized")
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
	
	if data.has(VERSION_NUM__DIC_IDENTIFIER):
		set_version_num_as_str(data[VERSION_NUM__DIC_IDENTIFIER])
	else:
		set_version_num_as_str(Singleton_GameInfo.get_game_version_as_text())
		ignore_appdata = true
	
	##
	
	if !ignore_appdata and data.has(PLAYER_HEALTH__DIC_IDENTIFIER):
		player_health_on_start = float(data[PLAYER_HEALTH__DIC_IDENTIFIER])
	else:
		player_health_on_start = INITIAL_PLAYER_HEALTH_AT_START
	
	##
	
	if !ignore_appdata and  data.has(IS_PLAYER_HEALTH_INVUL_STATE__DIC_IDENTIFIER):
		is_player_health_invulnerable__state = int(data[IS_PLAYER_HEALTH_INVUL_STATE__DIC_IDENTIFIER])
	else:
		is_player_health_invulnerable__state = IS_PLAYER_HEALTH_INVULNERABLE__INITIAL_VAL
	if is_player_health_invulnerable__state == IsPlayerHealthInvulTypeId.UNINIT:
		_init_is_player_health_invulnerable__state__based_on_curr_game_state__on_load_finish()
	
	##
	
	if !ignore_appdata and data.has(PLAYER_NAME__DIC_IDENTIFIER):
		player_name = data[PLAYER_NAME__DIC_IDENTIFIER]
	else:
		player_name = ""
	
	##
	
	if !ignore_appdata and data.has(FIRST_TIME_OPENING__DIC_IDENTIFIER):
		first_time_opening_game = data[FIRST_TIME_OPENING__DIC_IDENTIFIER]
	else:
		first_time_opening_game = true
	
	##
	
	if !ignore_appdata and data.has(ANIMAL_CHOICE__DIC_IDENTIFIER):
		animal_choice_id = data[ANIMAL_CHOICE__DIC_IDENTIFIER]
	else:
		animal_choice_id = AnimalChoiceId.DOG
	
	##
	
	if !ignore_appdata and data.has(LEVEL_ID_DIED_IN__DIC_IDENTIFIER):
		level_id_died_in = data[LEVEL_ID_DIED_IN__DIC_IDENTIFIER]
	else:
		level_id_died_in = -1
	
	##
	
	if !ignore_appdata and data.has(CAN_VIEW_GAME_STATS__DIC_IDENTIFIER):
		set_can_view_game_stats(data[CAN_VIEW_GAME_STATS__DIC_IDENTIFIER])
	else:
		set_can_view_game_stats(false)
	
	##
	
	if !ignore_appdata and data.has(CAN_EDIT_TILE_COLORS__DIC_IDENTIFIER):
		set_can_edit_tile_colors(data[CAN_EDIT_TILE_COLORS__DIC_IDENTIFIER])
	else:
		set_can_edit_tile_colors(false)
	
	##
	
	if !ignore_appdata and data.has(CAN_EDIT_PLAYER_AESTH__DIC_IDENTIFIER):
		set_can_edit_player_aesth(data[CAN_EDIT_PLAYER_AESTH__DIC_IDENTIFIER])
	else:
		set_can_edit_player_aesth(false)
	
	##
	
	if !ignore_appdata and data.has(CAN_CONFIG_CUSTOM_AUDIO__DIC_IDENTIFIER):
		set_can_config_custom_audio(data[CAN_CONFIG_CUSTOM_AUDIO__DIC_IDENTIFIER])
	else:
		set_can_config_custom_audio(false)
	
	##
	
	if !ignore_appdata and data.has(TROPHY_COLLECTED__DIC_IDENTIFIER):
		set_collected_trophies_and_metadata_from_save(data[TROPHY_COLLECTED__DIC_IDENTIFIER])
	else:
		set_collected_trophies_and_metadata_from_save({})
	
	##
	
	if !ignore_appdata and data.has(LAST_PLAYTHRU_IS_FROM_DEMO__DIC_IDENTIFIER):
		set_is_last_playthru_from_demo(data[LAST_PLAYTHRU_IS_FROM_DEMO__DIC_IDENTIFIER])
	else:
		set_is_last_playthru_from_demo(Singleton_GameInfo.IS_GAME_DEMO)
	

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
	
	call_deferred("_update_all_stars_collected_trophy_status")


func _update_all_stars_collected_trophy_status():
	if _total_coin_collected_count != StoreOfLevels.get_total_coin_count():
		if is_trophy_collected(TrophyNonVolatileId.ALL_STARS_COLLECTED):
			set_trophy_as_uncollected(TrophyNonVolatileId.ALL_STARS_COLLECTED)
		
	else:
		if !is_trophy_collected(TrophyNonVolatileId.ALL_STARS_COLLECTED):
			set_trophy_as_collected__and_assign_metadata(TrophyNonVolatileId.ALL_STARS_COLLECTED, true)
		
	

#

func get_tentative_coin_ids_collected_in_curr_level_id__count():
	return _tentative_coin_ids_collected_in_curr_level_id.size()


func set_coin_id_as_collected__using_all_tentatives():
	for coin_id in _tentative_coin_ids_collected_in_curr_level_id:
		set_coin_id_in_level_as_collected(coin_id, SingletonsAndConsts.current_base_level_id, true)

func set_tentative_coin_id_collected_in_curr_level(arg_id, arg_is_collected):
	if arg_is_collected:
		if !_tentative_coin_ids_collected_in_curr_level_id.has(arg_id):
			_tentative_coin_ids_collected_in_curr_level_id.append(arg_id)
			
			var is_all_collected = is_all_coins_collected_in_curr_level__tentative()
			emit_signal("tentative_coin_ids_collected_changed__for_curr_level", _tentative_coin_ids_collected_in_curr_level_id, arg_is_collected, is_all_collected)
		
	else:
		if _tentative_coin_ids_collected_in_curr_level_id.has(arg_id):
			_tentative_coin_ids_collected_in_curr_level_id.erase(arg_id)
			
			emit_signal("tentative_coin_ids_collected_changed__for_curr_level", _tentative_coin_ids_collected_in_curr_level_id, arg_is_collected, false)

func is_all_coins_collected_in_curr_level__tentative() -> bool:
	var coin_count = _tentative_coin_ids_collected_in_curr_level_id.size()
	var total_for_level = StoreOfLevels.get_coin_count_for_level(SingletonsAndConsts.current_base_level_id)
	
	return coin_count == total_for_level


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

#func remove_official_coin_ids_collected_from_tentative():
#	var coin_ids = _level_id_as_str_to_coin_ids_collected_map[str(SingletonsAndConsts.current_level_details.level_id)]
#	var erased_at_least_one : bool = false
#
#	for id in _tentative_coin_ids_collected_in_curr_level_id:
#		var id_as_str = str(id)
#		if coin_ids.has(id_as_str):
#			erased_at_least_one = true
#			coin_ids.erase(id_as_str)
#
#	if erased_at_least_one:
#		_update_coin_count_collected_in_whole_game()
#
#	clear_coin_ids_in_tentative()

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

func is_level_layout_id_finished(arg_id):
	var status = _level_layout_id_to_completion_status[arg_id]
	
	return status == LEVEL_OR_LAYOUT_COMPLETION_STATUS__FINISHED

func set_level_layout_id_status_completion(arg_id, arg_status):
	var old_val = _level_layout_id_to_completion_status[arg_id]
	_level_layout_id_to_completion_status[arg_id] = arg_status
	
	if old_val != arg_status:
		emit_signal("level_layout_id_completion_status_changed", arg_id, arg_status)

#

func _save_player_data():
	var save_dict = {
		PLAYER_HEALTH__DIC_IDENTIFIER : player_health_on_start,
		IS_PLAYER_HEALTH_INVUL_STATE__DIC_IDENTIFIER : is_player_health_invulnerable__state,
		PLAYER_NAME__DIC_IDENTIFIER : player_name,
		FIRST_TIME_OPENING__DIC_IDENTIFIER : first_time_opening_game,
		ANIMAL_CHOICE__DIC_IDENTIFIER : animal_choice_id,
		LEVEL_ID_DIED_IN__DIC_IDENTIFIER : level_id_died_in,
		CAN_VIEW_GAME_STATS__DIC_IDENTIFIER : can_view_game_stats,
		CAN_EDIT_TILE_COLORS__DIC_IDENTIFIER : can_edit_tile_colors,
		CAN_EDIT_PLAYER_AESTH__DIC_IDENTIFIER : can_edit_player_aesth,
		CAN_CONFIG_CUSTOM_AUDIO__DIC_IDENTIFIER : can_config_custom_audio,
		TROPHY_COLLECTED__DIC_IDENTIFIER : collected_trophy_id_to_metadata_map,
		VERSION_NUM__DIC_IDENTIFIER : version_num_as_str,
		LAST_PLAYTHRU_IS_FROM_DEMO__DIC_IDENTIFIER = Singleton_GameInfo.IS_GAME_DEMO,
	}
	
	_save_using_dict(save_dict, player_data_file_path, "SAVE ERROR: PlayerData")

#

func _init_is_player_health_invulnerable__state__based_on_curr_game_state__on_load_finish():
	connect("before_save_manager_initialized", self, "_on_before_save_manager_initialized__init_is_player_health_invulnerable", [], CONNECT_ONESHOT)

func _on_before_save_manager_initialized__init_is_player_health_invulnerable():
	if is_level_layout_id_finished(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05) and !GameSaveManager.ignore_appdata:
		is_player_health_invulnerable__state = IsPlayerHealthInvulTypeId.IS_INVUL
	else:
		is_player_health_invulnerable__state = IsPlayerHealthInvulTypeId.IS_NOT_INVUL
	

func is_player_health_invul():
	return is_player_health_invulnerable__state == IsPlayerHealthInvulTypeId.IS_INVUL



func set_is_player_health_invulnerable__state(arg_val):
	is_player_health_invulnerable__state = arg_val
	
	emit_signal("is_player_health_invulnerable__state_changed", arg_val)

func set_is_player_health_invulnerable__to_true():
	set_is_player_health_invulnerable__state(IsPlayerHealthInvulTypeId.IS_INVUL)


##################

func set_player(arg_player):
	arg_player.set_max_health(PLAYER_MAX_HEALTH)
	if !is_equal_approx(player_health_on_start, 0):
		arg_player.set_current_health(player_health_on_start, false)
		tentative_player_health_on_start = player_health_on_start
	else:
		arg_player.set_current_health(0, false)
		tentative_player_health_on_start = 0
	
	arg_player.set_is_player_health_invulnerable(is_player_health_invul())
	
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


#

func is_player_died_in_any_level():
	return level_id_died_in != -1

##

func set_can_view_game_stats(arg_val):
	can_view_game_stats = arg_val
	
	if _is_manager_initialized:
		emit_signal("can_view_game_stats_changed", arg_val)

func set_can_edit_tile_colors(arg_val):
	can_edit_tile_colors = arg_val
	
	if _is_manager_initialized:
		emit_signal("can_edit_tile_colors_changed", arg_val)

func set_can_edit_player_aesth(arg_val):
	can_edit_player_aesth = arg_val
	
	if _is_manager_initialized:
		emit_signal("can_edit_player_aesth_changed", arg_val)

func set_can_config_custom_audio(arg_val):
	can_config_custom_audio = arg_val
	
	if _is_manager_initialized:
		emit_signal("can_config_custom_audio_changed", arg_val)


#################
# TROPHY RELATED

func set_collected_trophies_and_metadata_from_save(arg_data : Dictionary):
	for trophy_id_str in arg_data.keys():
		var metadata = arg_data[trophy_id_str]
		var trophy_id = int(trophy_id_str)
		
		collected_trophy_id_to_metadata_map[trophy_id] = metadata

func set_trophy_as_collected__and_assign_metadata(arg_trophy_id, arg_metadata):
	collected_trophy_id_to_metadata_map[arg_trophy_id] = arg_metadata
	
	#emit_signal("trophy_collected__with_metadata", arg_trophy_id, arg_metadata)
	emit_signal("trophies_collected_changed")

func is_trophy_collected(arg_id):
	return collected_trophy_id_to_metadata_map.has(arg_id)

func set_trophy_as_uncollected(arg_trophy_id):
	collected_trophy_id_to_metadata_map.erase(arg_trophy_id)
	
	#emit_signal("trophy_uncollected__with_metadata", arg_trophy_id)
	emit_signal("trophies_collected_changed")

func get_or_generate_trophy_details(arg_trophy_id):
	if trophy_id_to_details_map.has(arg_trophy_id):
		return trophy_id_to_details_map[arg_trophy_id]
	
	if !TrophyNonVolatileId.values().has(arg_trophy_id):
		return null
	
	var details : TrophyDetails = TrophyDetails.new()
	details.trophy_id = arg_trophy_id
	match arg_trophy_id:
		TrophyNonVolatileId.WSSS0103_NO_ASSIST_MODE_USED:
			var full_lvl_name = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_SPECIAL_1).level_full_name
			
			details.trophy_name = "Unassisted?!"
			details.trophy_mini_image = load("res://GameFrontHUDRelated/Subs/TrophyPanel/Assets/TrophyIcon_WSSS0103_NoAssistModeUsed.png")
			details.desc = [
				["Beaten %s without using the intended solution???" % [full_lvl_name], []],
				["I dunno how you dunnit. Either me being blind, hax, or ball manueverability.", []]
			]
		TrophyNonVolatileId.WSSS0202_SUPER_STAR_COLLECTED:
			var full_lvl_name = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2).level_full_name
			
			details.trophy_name = "%s" % full_lvl_name
			details.trophy_mini_image = load("res://GameFrontHUDRelated/Subs/TrophyPanel/Assets/TrophyIcon_WSSS0202_SuperStarCollected.png")
			details.desc = [
				["Completed %s." % full_lvl_name, []]
			]
		TrophyNonVolatileId.WSSS0202_SUPER_STAR_COLLECTED__WHILE_BLINDED_LOW_STAR:
			var full_lvl_name = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2).level_full_name
			
			details.trophy_name = "BLIND %s" % full_lvl_name
			details.trophy_mini_image = load("res://GameFrontHUDRelated/Subs/TrophyPanel/Assets/TrophyIcon_WSSS0202_SuperStarCollected_WhileBlinded.png")
			details.desc = [
				["Completed %s while blinded." % full_lvl_name, []],
				["How? and why? Really though, how and why?", []],
			]
			
		TrophyNonVolatileId.ALL_STARS_COLLECTED:
			var plain_fragment__stars = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.STAR, "stars")
			
			details.trophy_name = "All Star"
			details.trophy_mini_image = load("res://GameFrontHUDRelated/Subs/TrophyPanel/Assets/TrophyIcon_AllStarCollected.png")
			details.desc = [
				["All |0| collected!!!", [plain_fragment__stars]],
			]
			
	
	trophy_id_to_details_map[arg_trophy_id] = details
	return details

#####################################
## LEVEL RELATED
####################################

func _attempt_load_existing_level_related_data():
	var load_file = File.new()
	
	if load_file.file_exists(level_data_file_path) and !ignore_appdata:
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
	
	if !ignore_appdata and data.has(LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER):
		last_opened_level_layout_id = int(data[LAST_OPENED_LEVEL_LAYOUT_ID__DIC_IDENTIFIER])
	else:
		last_opened_level_layout_id = StoreOfLevelLayouts.FIRST_LEVEl_LAYOUT
	
	
	if !ignore_appdata and data.has(LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER):
		last_hovered_over_level_layout_element_id = int(data[LAST_HOVERED_OVER_LEVEL_LAYOUT_ELEMENT_ID__DIC_IDENTIFIER])
	else:
		last_hovered_over_level_layout_element_id = GUI_AbstractLevelLayout.UNINITIALIZED_CURSOR
	
	
	
	if !ignore_appdata and data.has(LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER):
		_level_id_as_str_to_coin_ids_collected_map = data[LEVEL_ID_TO_COINS_COLLECTED__DIC_IDENTIFIER]
		_correct_and_fill_level_id_to_coins_collected_map()
	else:
		_initialize_level_id_to_coins_collected_count_map()
	
	_update_coin_count_collected_in_whole_game()
	
	##
	
	if !ignore_appdata and data.has(LEVEL_ID_TO_COMPLETION_STATUS__DIC_IDENTIFIER):
		_correct_level_id_to_completion_status_map(data[LEVEL_ID_TO_COMPLETION_STATUS__DIC_IDENTIFIER])
	else:
		_initialize_level_id_to_completion_status_map()
	
	#
	
	if !ignore_appdata and data.has(LEVEL_LAYOUT_ID_COMPLETION_STATUS__DIC_IDENTIFIER):
		_correct_level_layout_id_to_completion_status_map(data[LEVEL_LAYOUT_ID_COMPLETION_STATUS__DIC_IDENTIFIER])
	else:
		_initialize_level_layout_id_to_completion_status_map()
	
	#
	
	if !ignore_appdata and data.has(LEVEL_ID_TO_METADATA__DIC_IDENTIFIER):
		_correct_level_id_to_metadata_map(data[LEVEL_ID_TO_METADATA__DIC_IDENTIFIER])
	else:
		pass
	
	#
	
	if !ignore_appdata and data.has(ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER):
		#_correct_level_id_to_is_hidden_map__do_unhide_based_on_data(data[LEVEL_ID_TO_IS_HIDDEN__DIC_IDENTIFIER])
		_configure_level_hidden_states_based_on_save_state(data[ALL_LEVELS_HIDDEN_STATE__DIC_IDENTIFIER])
	else:
		pass
	
	#
	
	if !ignore_appdata and data.has(REGISTERED_LAYOUT_ID_TO_LAYOUT_ELEMENT_IDS_TO_IS_INVISIBLE_MAP__DIC_IDENTIFIER):
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

func remove_metadata_of_level_id(arg_id):
	_level_id_to_metadata_map.erase(arg_id)

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
	
	if load_file.file_exists(audio_settings_file_path) and !ignore_appdata:
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




###


#func attempt_load_special_stage_01_02_data():
#	var load_file = File.new()
#
#	if load_file.file_exists(stage_special_01_02__data_arr_file_path):
#		var err_stat = load_file.open(stage_special_01_02__data_arr_file_path, File.READ)
#
#		if err_stat != OK:
#			print("Loading error! -- stage_special_01_02__data")
#			return false
#
#		var result = _load_stage_special_01_02_data(load_file)
#
#		load_file.close()
#		return result
#
#	else:
#		#_load_game_controls_related_data(null)
#		return null
#
#func _load_stage_special_01_02_data(arg_file : File):
#	var data : Array
#	if arg_file != null:
#		data = parse_json(arg_file.get_line())
#
#		#while !arg_file.eof_reached():
#		#	var line = parse_json(arg_file.get_line())
#		#	data.append(line)
#
#	return data
#
#
## special case use.
#func _save_stage_special_01_02_data(arg_data : Array):
#	_save_using_arr(arg_data, stage_special_01_02__data_arr_file_path, "SAVE ERROR: SpecialStage01 02 settings")
#


#

func save_viewport_img_in_scrnshot_folder():
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	
	var dir = Directory.new()
	dir.open(USER_DIR)
	if !dir.dir_exists(USER_DIR__IMG_SAVE_FilePath):
		dir.make_dir(USER_DIR__IMG_SAVE_FilePath)
	
	var dir_of_img_save_filepath = Directory.new()
	dir_of_img_save_filepath.open(USER_DIR + USER_DIR__IMG_SAVE_FilePath)
	
	var file_count = _get_file_count_in_dir(dir_of_img_save_filepath)
	var final_file_name = "%s%03d.png" % ["scrnshot_", (file_count + 1)]
	
	
	image.save_png(USER_DIR + USER_DIR__IMG_SAVE_FilePath + final_file_name)
	

func _get_file_count_in_dir(dir : Directory) -> int:
	var file_count = 0
	
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			file_count += 1
	
	dir.list_dir_end()
	
	return file_count

func get_absolute_path_of__user_dir__img_save_filepath():
	var abs_dir_to_user_path = OS.get_user_data_dir()
	return "%s/%s" % [abs_dir_to_user_path, USER_DIR__IMG_SAVE_FilePath]


##

func set_version_num_as_str(arg_str : String):
	version_num_as_str = arg_str
	
	if arg_str != Singleton_GameInfo.get_game_version_as_text():
		pass
		#note: this is where u do changes, eventually

func set_is_last_playthru_from_demo(arg_is_demo : bool):
	is_last_playthru_from_demo = arg_is_demo

func is_last_playthru_from_demo__and_curr_is_non_demo():
	return is_last_playthru_from_demo and !Singleton_GameInfo.IS_GAME_DEMO



#func clear_all_files_in_appdata():
#	pass
	#OS.move_to_trash(USER_DIR)
#	var dir = Directory.new()
#	if dir.open(USER_DIR) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			OS.move_to_trash("%s%s" % [USER_DIR, file_name])
#			file_name = dir.get_next()
#
#	else:
#		pass
#

#############################################
##
#############################################

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_all_save_states__even_from_other_managers()


func save_all_save_states__even_from_other_managers():
	_save_player_data()
	save_level_and_layout_related_data()
	GameSettingsManager.save_all_related_datas()
	GameStatsManager.save_ALL__game_stats_data()
	save_settings__of_audio_manager()
	

#func _exit_tree():
#	_save_player_data()
#	save_level_and_layout_related_data()
#
