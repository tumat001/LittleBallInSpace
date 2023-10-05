extends Node


signal stats_manager_initialized()

signal start_of_GE_record_stats()
signal end_of_GE_record_stats(arg_record_stats_as_win)
signal before_end_of_GE_record_stats__for_last_chance_edits(arg_record_stats_as_win)

#

const game_stats_file_path = "user://game_stats.save"

#

#const GAME_STATS__MISC__DIC_IDENTIFIER = "GAME_STATS__MISC__DIC_IDENTIFIER"

###

# in per level:
# per win array of last x playthroughs
# per win array with highest/lowest stats for each
# num of restarts/quit
#
# in per level -> per win: include:
#	time, rotation count, balls shot, lowest energy attained, highest speed,
const GAME_STATS__PER_LEVEL__DIC_IDENTIFIER = "GAME_STATS__PER_LEVEL__DIC_IDENTIFIER"

const PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID = "per_win_of_last_x"
const PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID = "per_win_with_high_low"
const PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID = "restart_or_quit_count"
const PER_LEVEL__ATTEMPT_COUNT__DIC_ID = "attempt_count"

const PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID = "time"
const PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID = "rotation_count"
const PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID = "balls_shot"
const PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID = "lowest_energy"
const PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID = "highest_speed"
const PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID = "time_spent_in_rewind"
const PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID = "date_time_of_playthru"


var _per_level__all_data__map : Dictionary = {}
#var per_level__per_win_arr_last_x_plays__map : Dictionary
#var per_level__per_win_stat_map_with_high_low__map : Dictionary
#var per_level__restart_or_quit_count__map : Dictionary
# attempt count

#

const current_GE_unsetted__time : float = -1.0
const current_GE_unsetted__rotation_count : int = -1
const current_GE_unsetted__balls_shot_count : int = -1
const current_GE_unsetted__lowest_energy : float = INF
const current_GE_unsetted__highest_speed : float = -1.0
const current_GE_unsetted__time_spent_in_rewind : float = -1.0


var current_GE__time : float
var current_GE__rotation_count : int
var current_GE__balls_shot_count : int
var current_GE__lowest_energy : float
var current_GE__highest_speed : float
var current_GE__time_spent_in_rewind : float


#var ALL_PER_LEVEL_PER_WIN_ARR_STAT_TO_UNSETTED_MAP = {
#	PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID : current_GE_unsetted__time,
#	PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID : current_GE_unsetted__rotation_count,
#	PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID : current_GE_unsetted__balls_shot_count,
#	PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID : current_GE_unsetted__lowest_energy,
#	PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID : current_GE_unsetted__highest_speed,
#	PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID : current_GE_unsetted__time_spent_in_rewind,
#	PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID : Time.get_datetime_string_from_system()
#}

const ALL_PER_LEVEL_PER_WIN_ARR_STAT_TO_NULL_MAP__FOR_HIGH_SCORES = {
	PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID : {},
	PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID : {},
	PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID : {},
	PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID : {},
	PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID : {},
	PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID : {},
	
}

#

const per_level_per_win_recorded_limit : int = 10

#########

var _is_manager_initialized : bool

#


var _started_GE_record_stats : bool = false


#

func _init():
	_clear_and_reset_current_GE_stats()

#

func is_started_GE_record_stats():
	return _started_GE_record_stats


func start_GE_record_stats():
	if !_started_GE_record_stats:
		_started_GE_record_stats = true
		
		_connect_signals__for_ending_of_GE_recording_stats()
		
		emit_signal("start_of_GE_record_stats")

func end_GE_record_stats(arg_record_stats_as_win : bool):
	if _started_GE_record_stats:
		_started_GE_record_stats = false
		
		emit_signal("before_end_of_GE_record_stats__for_last_chance_edits", arg_record_stats_as_win)
		
		if arg_record_stats_as_win:
			_record_stats__as_win()
			
		else:
			_record_stats__as_non_win()
			
		
		_clear_and_reset_current_GE_stats()
		
		_disconnect_signals__for_ending_of_GE_recording_stats()
		
		emit_signal("end_of_GE_record_stats", arg_record_stats_as_win)


#

func _connect_signals__for_ending_of_GE_recording_stats():
	SingletonsAndConsts.current_game_elements.game_result_manager.connect("game_result_decided", self, "_on_GE_result_decided")
	SingletonsAndConsts.current_master.connect("switch_from_GE__from_quit", self, "_on_master_switch_scene_GE_quit")
	SingletonsAndConsts.current_master.connect("switch_from_GE__from_restart", self, "_on_master_swtich_scene_GE_restart")
	SingletonsAndConsts.current_game_elements.connect("quiting_game_by_queue_free__on_game_quit", self, "_on_GE_quiting_game_by_queue_free__on_game_quit")

func _disconnect_signals__for_ending_of_GE_recording_stats():
	SingletonsAndConsts.current_game_elements.game_result_manager.disconnect("game_result_decided", self, "_on_GE_result_decided")
	SingletonsAndConsts.current_master.disconnect("switch_from_GE__from_quit", self, "_on_master_switch_scene_GE_quit")
	SingletonsAndConsts.current_master.disconnect("switch_from_GE__from_restart", self, "_on_master_swtich_scene_GE_restart")
	SingletonsAndConsts.current_game_elements.disconnect("quiting_game_by_queue_free__on_game_quit", self, "_on_GE_quiting_game_by_queue_free__on_game_quit")

	

#

func _on_GE_result_decided(arg_result):
	end_GE_record_stats(true)
	

func _on_master_switch_scene_GE_quit():
	end_GE_record_stats(false)
	

func _on_master_swtich_scene_GE_restart():
	end_GE_record_stats(false)
	

func _on_GE_quiting_game_by_queue_free__on_game_quit():
	end_GE_record_stats(false)



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


##############

func load_all__from_ready_of_save_manager():
	_attempt_load_all__from_game_stats_file()
	
	_is_manager_initialized = true
	emit_signal("stats_manager_initialized")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_save_ALL__game_stats_data()



func _save_ALL__game_stats_data():
	var per_level_save_dict = _generate_save_dict__for_per_level()
	
	var save_dict = {
		GAME_STATS__PER_LEVEL__DIC_IDENTIFIER : per_level_save_dict,
	}
	
	_save_using_dict(save_dict, game_stats_file_path, "SAVE ERROR: stats")


######################
# PER LEVEL STATS

func _generate_save_dict__for_per_level():
	return _per_level__all_data__map
	


func _attempt_load_all__from_game_stats_file():
	var load_file = File.new()
	
	if load_file.file_exists(game_stats_file_path):
		var err_stat = load_file.open(game_stats_file_path, File.READ)
		
		if err_stat != OK:
			print("Loading error! -- stats file")
			return false
		
		_load_per_level_stats(load_file)
		
		load_file.close()
		return true
		
	else:
		
		_load_per_level_stats(null)
		return false
	

func _load_per_level_stats(arg_file : File):
	
	var data : Dictionary
	if arg_file != null:
		data = parse_json(arg_file.get_line())
	
	if data == null:
		data = {}
	
	##
	
	_fill_per_level_data_map__with_defaults_and_preconstructeds()
	if data.has(GAME_STATS__PER_LEVEL__DIC_IDENTIFIER):
		_fill_per_level_data_map__with_save_dict(data[GAME_STATS__PER_LEVEL__DIC_IDENTIFIER])
	else:
		pass
	
	
	

func _fill_per_level_data_map__with_defaults_and_preconstructeds():
	for level_id in StoreOfLevels.get_all_level_ids__not_including_tests():
		_per_level__all_data__map[level_id] = {
			PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID : [],
			PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID : _get_filled_but_empty_high_score_stat_map(),
			PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID : 0,
			PER_LEVEL__ATTEMPT_COUNT__DIC_ID : 0,
		}

func _get_filled_but_empty_high_score_stat_map():
	return ALL_PER_LEVEL_PER_WIN_ARR_STAT_TO_NULL_MAP__FOR_HIGH_SCORES.duplicate()

func _fill_per_level_data_map__with_save_dict(data : Dictionary):
	for level_id_as_str in data.keys():
		var level_id = int(level_id_as_str)
		var all_data_of_level = data[level_id_as_str]
		
		if all_data_of_level.has(PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID):
			_per_level__all_data__map[level_id][PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID] = all_data_of_level[PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID]
		else:
			pass
		
		if all_data_of_level.has(PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID):
			_per_level__all_data__map[level_id][PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID] = all_data_of_level[PER_LEVEL__PER_WIN_STAT_MAP_WITH_HIGH_LOW__DIC_ID]
		else:
			pass
		
		if all_data_of_level.has(PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID):
			_per_level__all_data__map[level_id][PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID] = all_data_of_level[PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID]
		else:
			pass
		
		if all_data_of_level.has(PER_LEVEL__ATTEMPT_COUNT__DIC_ID):
			_per_level__all_data__map[level_id][PER_LEVEL__ATTEMPT_COUNT__DIC_ID] = all_data_of_level[PER_LEVEL__ATTEMPT_COUNT__DIC_ID]
		else:
			pass
		
		if all_data_of_level.has(PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID):
			_per_level__all_data__map[level_id][PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID] = all_data_of_level[PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID]
		

#
func _clear_and_reset_current_GE_stats():
	current_GE__time = current_GE_unsetted__time
	current_GE__rotation_count = current_GE_unsetted__rotation_count
	current_GE__balls_shot_count = current_GE_unsetted__balls_shot_count
	current_GE__lowest_energy = current_GE_unsetted__lowest_energy
	current_GE__highest_speed = current_GE_unsetted__highest_speed
	current_GE__time_spent_in_rewind = current_GE_unsetted__time_spent_in_rewind
	

#
func _record_stats__as_win():
	var stats_dict = {}
	stats_dict[PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID] = current_GE__time
	stats_dict[PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID] = current_GE__rotation_count
	stats_dict[PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID] = current_GE__balls_shot_count
	stats_dict[PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID] = current_GE__lowest_energy
	stats_dict[PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID] = current_GE__highest_speed
	stats_dict[PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID] = current_GE__time_spent_in_rewind
	stats_dict[PER_LEVEL__PER_WIN_ARR__DATE_TIME_OF_PLAYTHRU__DIC_ID] = Time.get_datetime_string_from_system()
	
	_push_stats_in_last_x_played(stats_dict)
	_attempt_push_stats_in_high_low_stats(stats_dict)
	
	_per_level__all_data__map[SingletonsAndConsts.current_base_level_id][PER_LEVEL__ATTEMPT_COUNT__DIC_ID] += 1

func _push_stats_in_last_x_played(arg_stats):
	var level_stats_arr__last_x_played : Array = _per_level__all_data__map[SingletonsAndConsts.current_base_level_id][PER_LEVEL__PER_WIN_ARR_LAST_X_PLAYS__DIC_ID]
	while level_stats_arr__last_x_played.size() > per_level_per_win_recorded_limit:
		level_stats_arr__last_x_played.pop_front()
	
	level_stats_arr__last_x_played.append(arg_stats)


func _attempt_push_stats_in_high_low_stats(arg_stats):
	var level_stats_high_low_map : Dictionary = _per_level__all_data__map[SingletonsAndConsts.current_base_level_id]
	
	#time
	_attempt_push_stats__in_x_stat(arg_stats, level_stats_high_low_map,
			PER_LEVEL__PER_WIN_ARR__TIME__DIC_ID, current_GE_unsetted__time,
			"_stat_comparator__not_unsetted__time")
	
	#rotation count
	_attempt_push_stats__in_x_stat(arg_stats, level_stats_high_low_map,
			PER_LEVEL__PER_WIN_ARR__ROTATION_COUNT__DIC_ID, current_GE_unsetted__rotation_count,
			"_stat_comparator__not_unsetted__rotation_count")
	
	#balls shot
	_attempt_push_stats__in_x_stat(arg_stats, level_stats_high_low_map,
			PER_LEVEL__PER_WIN_ARR__BALLS_SHOT_COUNT__DIC_ID, current_GE_unsetted__balls_shot_count,
			"_stat_comparator__not_unsetted__balls_shot_count")
	
	#lowest energy
	_attempt_push_stats__in_x_stat(arg_stats, level_stats_high_low_map,
			PER_LEVEL__PER_WIN_ARR__LOWEST_ENERGY__DIC_ID, current_GE_unsetted__lowest_energy,
			"_stat_comparator__not_unsetted__lowest_energy")
	
	#highest speed
	_attempt_push_stats__in_x_stat(arg_stats, level_stats_high_low_map,
			PER_LEVEL__PER_WIN_ARR__HIGHEST_SPEED__DIC_ID, current_GE_unsetted__highest_speed,
			"_stat_comparator__not_unsetted__highest_speed")
	
	#time spent in rewind
	_attempt_push_stats__in_x_stat(arg_stats, level_stats_high_low_map,
			PER_LEVEL__PER_WIN_ARR__TIME_SPENT_IN_REWIND__DIC_ID, current_GE_unsetted__time_spent_in_rewind,
			"_stat_comparator__not_unsetted__time_spent_in_rewind")
	
	


func _attempt_push_stats__in_x_stat(arg_stats : Dictionary, level_stats_high_low_map : Dictionary,
		X_DIC_ID : String, arg_unsetted_x_stat_var, 
		x_stat_comparator_func_name : String):
	
	if !level_stats_high_low_map.has(X_DIC_ID):
		level_stats_high_low_map[X_DIC_ID] = arg_stats
	else:
		var recorded_x_stat = level_stats_high_low_map[X_DIC_ID]
		
		if arg_stats[X_DIC_ID] != arg_unsetted_x_stat_var:
			if call(x_stat_comparator_func_name, recorded_x_stat):
				level_stats_high_low_map[X_DIC_ID] = arg_stats
			else:
				pass


func _stat_comparator__not_unsetted__time(arg_recorded_stat):
	return arg_recorded_stat > current_GE__time

func _stat_comparator__not_unsetted__rotation_count(arg_recorded_stat):
	return arg_recorded_stat > current_GE__rotation_count

func _stat_comparator__not_unsetted__balls_shot_count(arg_recorded_stat):
	return arg_recorded_stat > current_GE__balls_shot_count

func _stat_comparator__not_unsetted__lowest_energy(arg_recorded_stat):
	return arg_recorded_stat > current_GE__lowest_energy

func _stat_comparator__not_unsetted__highest_speed(arg_recorded_stat):
	return arg_recorded_stat < current_GE__highest_speed

func _stat_comparator__not_unsetted__time_spent_in_rewind(arg_recorded_stat):
	return arg_recorded_stat > current_GE__time_spent_in_rewind



#
func _record_stats__as_non_win():
	_per_level__all_data__map[SingletonsAndConsts.current_base_level_id][PER_LEVEL__RESTART_OR_QUIT_COUNT__DIC_ID] += 1
	_per_level__all_data__map[SingletonsAndConsts.current_base_level_id][PER_LEVEL__ATTEMPT_COUNT__DIC_ID] += 1



func get_per_level_all_data_of_lvl(arg_id):
	return _per_level__all_data__map[arg_id]

#######################



