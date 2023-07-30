extends Node


signal first_time_play()

#

const player_data_file_path = "user://player_data.save"

#

const PLAYER_HEALTH__DIC_IDENTIFIER = "PlayerHealthOnStart"
const PLAYER_NAME__DIC_IDENTIFIER = "PlayerName"
const FIRST_TIME_OPENING__DIC_IDENTIFIER = "FirstTimeOpening"

#

const PLAYER_MAX_HEALTH = 100
const INITIAL_PLAYER_HEALTH_AT_START = PLAYER_MAX_HEALTH

#

var player_health_on_start : float = INITIAL_PLAYER_HEALTH_AT_START

var player_name : String

var first_time_opening_game : bool


#### base methods

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

#

func _ready():
	_attempt_load_existing_player_related_data()
	
	
	
	if first_time_opening_game:
		emit_signal("first_time_play")

#


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


func _save_player_data():
	var save_dict = {
		PLAYER_HEALTH__DIC_IDENTIFIER : player_health_on_start,
		PLAYER_NAME__DIC_IDENTIFIER : player_name,
		FIRST_TIME_OPENING__DIC_IDENTIFIER : first_time_opening_game
	}
	
	_save_using_dict(save_dict, player_data_file_path, "SAVE ERROR: PlayerData")

##################

func set_player(arg_player):
	arg_player.set_max_health(PLAYER_MAX_HEALTH)
	if !is_equal_approx(player_health_on_start, 0):
		arg_player.set_current_health(player_health_on_start, false)
	else:
		arg_player.set_current_health(0, false)
	
	arg_player.connect("health_reached_breakpoint", self, "_on_player_health_reached_breakpoint", [], CONNECT_PERSIST)
	arg_player.connect("all_health_lost", self, "_on_player_all_health_lost", [], CONNECT_PERSIST)
	arg_player.connect("health_restored_from_zero", self, "_on_player_health_restored_from_zero", [arg_player.health_breakpoints[0]], CONNECT_PERSIST)
	arg_player.connect("health_fully_restored", self, "_on_player_health_fully_restored", [], CONNECT_PERSIST)

func _on_player_health_reached_breakpoint(arg_breakpoint_val, arg_health_val_at_breakpoint):
	player_health_on_start = arg_health_val_at_breakpoint
	
	print("arg_health_val_at_breakpoint: %s" % arg_health_val_at_breakpoint)

func _on_player_all_health_lost():
	player_health_on_start = 0
	
	print("no health")


func _on_player_health_restored_from_zero(arg_health_val_at_lowest_breakpoint):
	player_health_on_start = arg_health_val_at_lowest_breakpoint

func _on_player_health_fully_restored():
	player_health_on_start = PLAYER_MAX_HEALTH


##

func _exit_tree():
	_save_player_data()

#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		_save_player_data()
#


