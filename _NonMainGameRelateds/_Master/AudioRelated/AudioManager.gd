extends Node

#const AudioStreamPlayerComponentPool = preload("res://MiscRelated/PoolRelated/Implementations/AudioStreamPlayerComponentPool.gd")
const ValTransition = preload("res://_NonMainGameRelateds/_Master/AudioRelated/ValTransition.gd")

#

signal steam_player_stopped_and_marked_as_inactive(arg_path_name, arg_stream_player)

# save related

var data_name__background_music_volume_name : String = "backgroundmusic_volume"
var data_name__background_music_is_mute_name : String = "backgroundmusic_ismute"

var data_name__sound_fx_volume_name : String = "soundfx_volume"
var data_name__sound_fx_is_mute_name : String = "soundfx_ismute"


#

const DECIBEL_VAL__INAUDIABLE : float = -30.0   # true zero/silence cannot be met, but this should be good enough
const DECIBEL_VAL__STANDARD : float = 0.0  

#

enum MaskLevel {
	
	#MASK_02 = 2
	#MASK_01 = 1
	
	BGM = 0,
	
	Major_SoundFX = 1,
	Minor_SoundFX = 2,
	UI_SoundFX = 3,
	
}

#var total_active_stream_player_count_per_mask_level : int = 80
var mask_level_to_max_active_count_available_map : Dictionary = {
	MaskLevel.BGM : 100,
	
	MaskLevel.Major_SoundFX : 40,
	MaskLevel.Minor_SoundFX : 40,
	MaskLevel.UI_SoundFX : 40,
}


var sound_path_name_to__stream_player_node_to_is_active_map : Dictionary
var stream_player_node_to_mask_level_map : Dictionary
var mask_level_to_active_count_map : Dictionary
var source_id_to_stream_players_arr_map : Dictionary
#var _current_total_active_stream_player_count : int

var stream_player_to_linear_audio_set_param_map : Dictionary
var player_sound_type_to_stream_players_map : Dictionary
var stream_player_to_adv_params_map : Dictionary

#var audio_stream_player_component_pool : AudioStreamPlayerComponentPool

var _center_of_screen : Vector2


enum PlayerConstructionType {
	PLAIN = 0
	TWO_D = 1
}

enum PlayerSoundType {
	SOUND_FX = 0,
	BACKGROUND_MUSIC = 1,
	
	
	DEFAULT = 0,
}

const bus__sound_fx_name : String = "SoundFX"
const bus__background_name : String = "Background"

const bus__background_name__internal : String = "_BackgroundHidden"
var bus__background_name__internal__idx : int = -1


const player_sound_type_to_bus_name_map : Dictionary = {
	PlayerSoundType.SOUND_FX : bus__sound_fx_name,
	PlayerSoundType.BACKGROUND_MUSIC : bus__background_name,
}

const player_sound_type_to_bus_name_map__internal : Dictionary = {
	PlayerSoundType.SOUND_FX : bus__sound_fx_name,
	PlayerSoundType.BACKGROUND_MUSIC : bus__background_name__internal,
}


var _next_available_id : int = 0

#

var _last_calc_has_linear_set_params : bool

#

var bus__sound_fx_volume : float setget set_bus__sound_fx_volume
signal bus__sound_fx_volume_changed(arg_val)
var bus__sound_fx_bus_mute : bool setget set_bus__sound_fx_bus_mute
signal bus__sound_fx_mute_changed(arg_val)

var bus__background_music_volume : float setget set_bus__background_music_volume
signal bus__background_music_volume_changed(arg_val)
var bus__background_music_bus_mute : bool setget set_bus__background_music_bus_mute
signal bus__background_music_mute_changed(arg_val)


#

var container__pause_inherit : Node
var container__pause_process : Node
var container__pause_stop : Node

var node_pause_mode_to_container_map : Dictionary

#

const DISTANCE_FROM_2D_WITH_NO_AUDIO_CHANGE : float = 300.0
const DISTANCE_FROM_2D_TO_REACH_MINIMUM : float = 660.0 #+ DISTANCE_FROM_2D_WITH_NO_AUDIO_CHANGE

#

var game_elements

#####


# DONT Instantiate. Use methods
class PlayAdvParams:
	
	signal node_source_tree_exiting(id_source)
	
	func _init(arg_id):
		id_source = arg_id
	
	var node_source setget set_node_source
	var id_source
	
	var play_sound_type : int
	var node_pause_mode : int = Node.PAUSE_MODE_INHERIT 
	
	var is_audio_looping : bool = false
	
	#
	
	func set_node_source(arg_node):
		if is_instance_valid(node_source):
			node_source.disconnect("tree_exiting", self, "_on_node_source_tree_exiting")
		
		node_source = arg_node
		
		if is_instance_valid(node_source):
			node_source.connect("tree_exiting", self, "_on_node_source_tree_exiting")
	
	func _on_node_source_tree_exiting():
		emit_signal("node_source_tree_exiting", id_source)
		

#

func _ready():
	for mask_level in MaskLevel.values():
		mask_level_to_active_count_map[mask_level] = 0
	
	
	#audio_stream_player_component_pool = AudioStreamPlayerComponentPool.new()
	#audio_stream_player_component_pool.node_to_parent = self
	#audio_stream_player_component_pool.source_of_create_resource = self
	
	_center_of_screen = get_viewport().size / 2
	
	_update_can_do_process()
	
	##
	
	_construct_containers()


func _construct_containers():
	container__pause_process = Node.new()
	container__pause_process.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(container__pause_process)
	
	container__pause_inherit = Node.new()
	container__pause_inherit.pause_mode = Node.PAUSE_MODE_INHERIT
	add_child(container__pause_inherit)
	
	container__pause_stop = Node.new()
	container__pause_stop.pause_mode = Node.PAUSE_MODE_STOP
	add_child(container__pause_stop)
	
	node_pause_mode_to_container_map[Node.PAUSE_MODE_PROCESS] = container__pause_process
	node_pause_mode_to_container_map[Node.PAUSE_MODE_INHERIT] = container__pause_inherit
	node_pause_mode_to_container_map[Node.PAUSE_MODE_STOP] = container__pause_stop 

####

func construct_play_adv_params() -> PlayAdvParams:
	var id = _next_available_id
	_next_available_id += 1 
	return PlayAdvParams.new(id)


#############


func play_sound(arg_audio_id, 
		arg_mask_level : int, arg_construction_type : int = PlayerConstructionType.PLAIN,
		play_adv_params : PlayAdvParams = null):
	
	var stream_player = get_available_or_construct_new_audio_stream_player(arg_audio_id, arg_construction_type, play_adv_params.node_pause_mode)
	
	return play_sound__with_provided_stream_player(arg_audio_id, stream_player, arg_mask_level)


# returns bool, whether the sound is played or not based on sound count limit
func play_sound__with_provided_stream_player(arg_audio_id, arg_stream_player, 
		arg_mask_level : int, play_adv_params : PlayAdvParams = null):
	
	if StoreOfAudio.mute_all_game_sfx_unaffecting_volume_settings and (arg_mask_level == MaskLevel.Major_SoundFX or arg_mask_level == MaskLevel.Minor_SoundFX):
		return false
	
	var arg_audio_path_name = StoreOfAudio.get_audio_file_path_of_id(arg_audio_id)
	
	#if mask_level_to_active_count_map[arg_mask_level] <= total_active_stream_player_count_per_mask_level:
	if mask_level_to_active_count_map[arg_mask_level] <= mask_level_to_max_active_count_available_map[arg_mask_level]:
		if !sound_path_name_to__stream_player_node_to_is_active_map.has(arg_audio_path_name):
			sound_path_name_to__stream_player_node_to_is_active_map[arg_audio_path_name] = {}
		sound_path_name_to__stream_player_node_to_is_active_map[arg_audio_path_name][arg_stream_player] = true
		
		stream_player_node_to_mask_level_map[arg_stream_player] = arg_mask_level
		
		mask_level_to_active_count_map[arg_mask_level] += 1
		
		if play_adv_params != null:
			if !source_id_to_stream_players_arr_map.has(play_adv_params.id_source):
				source_id_to_stream_players_arr_map[play_adv_params.id_source] = []
			source_id_to_stream_players_arr_map[play_adv_params.id_source].append(arg_stream_player)
			
			if !play_adv_params.is_connected("node_source_tree_exiting", self, "_on_play_adv_param_node_source_tree_exiting"):
				play_adv_params.connect("node_source_tree_exiting", self, "_on_play_adv_param_node_source_tree_exiting")
		
		
		if play_adv_params != null:
			#arg_stream_player.bus = player_sound_type_to_bus_name_map[play_adv_params.play_sound_type]
			arg_stream_player.bus = player_sound_type_to_bus_name_map__internal[play_adv_params.play_sound_type]
		else:
			arg_stream_player.bus = player_sound_type_to_bus_name_map__internal[PlayerSoundType.DEFAULT]
			#arg_stream_player.bus = player_sound_type_to_bus_name_map[PlayerSoundType.DEFAULT]
			
		arg_stream_player.play()
		
		
		#
		
		var sound_type = PlayerSoundType.DEFAULT
		if play_adv_params != null:
			sound_type = play_adv_params.play_sound_type
		
		if !player_sound_type_to_stream_players_map.has(sound_type):
			player_sound_type_to_stream_players_map[sound_type] = []
		if !player_sound_type_to_stream_players_map[sound_type].has(arg_stream_player):
			player_sound_type_to_stream_players_map[sound_type].append(arg_stream_player)
		
		stream_player_to_adv_params_map[arg_stream_player] = play_adv_params
		
		
		return true
	else:
		return false


# to be used by outside sources, and the node be fed to "play_sound__using_path_name"
func get_available_or_construct_new_audio_stream_player(arg_audio_id, player_construction_type : int, arg_pause_mode : int, 
		arg_play_adv_param : PlayAdvParams = null):
	
	var player
	
	var arg_path_name = StoreOfAudio.get_audio_file_path_of_id(arg_audio_id)
	
	if sound_path_name_to__stream_player_node_to_is_active_map.has(arg_path_name):
		var stream_player_node_to_is_active_map = sound_path_name_to__stream_player_node_to_is_active_map[arg_path_name]
		for player_node in stream_player_node_to_is_active_map:
			if !stream_player_node_to_is_active_map[player_node]:
				player = player_node
				break
		
		if player == null or !_is_player_of_correct_type(player, player_construction_type):
			player = _construct_new_audio_stream_player__based_on_cons_type(player_construction_type, arg_pause_mode)
		
	else:
		player = _construct_new_audio_stream_player__based_on_cons_type(player_construction_type, arg_pause_mode)
	
	
	var file = load(arg_path_name)
	
	#
	var loop_val = false
	if arg_play_adv_param != null:
		loop_val = arg_play_adv_param.is_audio_looping
	
	if file.get("loop"):
		file.loop = loop_val
	
	#
	
	player.stream = file
	player.volume_db = StoreOfAudio.get_audio_id_custom_standard_db(arg_audio_id)
	
	_connect_signals_of_stream_player(player, arg_path_name)
	
	return player


func _is_player_of_correct_type(arg_player, arg_constr_type : int):
	if arg_constr_type == PlayerConstructionType.PLAIN and arg_player is AudioStreamPlayer:
		return true
	elif arg_constr_type == PlayerConstructionType.TWO_D and arg_player is AudioStreamPlayer2D:
		return true
	
	return false

func _construct_new_audio_stream_player__based_on_cons_type(arg_cons_type : int, arg_pause_mode):
	if arg_cons_type == PlayerConstructionType.PLAIN:
		return _construct_new_audio_stream_player(arg_pause_mode)
	elif arg_cons_type == PlayerConstructionType.TWO_D:
		return _construct_new_audio_stream_player_2D(arg_pause_mode)

func _construct_new_audio_stream_player(arg_pause_mode):
	var player = AudioStreamPlayer.new()
	
	player.connect("tree_exiting", self, "_on_stream_player_queue_free", [player])
	
	node_pause_mode_to_container_map[arg_pause_mode].add_child(player)
	
	return player

func _construct_new_audio_stream_player_2D(arg_pause_mode):
	var player = AudioStreamPlayer2D.new()
	
	player.connect("tree_exiting", self, "_on_stream_player_queue_free", [player])
	
	node_pause_mode_to_container_map[arg_pause_mode].add_child(player)
	
	return player

#

func _connect_signals_of_stream_player(arg_stream_player, arg_path_name):
	if !arg_stream_player.is_connected("finished", self, "_on_stream_player_finished"):
		arg_stream_player.connect("finished", self, "_on_stream_player_finished", [arg_stream_player, arg_path_name])
	


func _on_play_adv_param_node_source_tree_exiting(arg_id):
	stop_stream_players_with_source_ids(arg_id)
	


#

func stop_stream_players_with_source_ids(arg_id):
	var remove_bucket = []
	var stream_players = source_id_to_stream_players_arr_map[arg_id]
	for player in stream_players:
		if is_instance_valid(player):
			stop_stream_player_and_mark_as_inactive(player)
		else:
			remove_bucket.append(player)
	
	for player in remove_bucket:
		source_id_to_stream_players_arr_map[arg_id].erase(player)


func _on_stream_player_finished(arg_stream_player, arg_path_name):
	stop_stream_player_and_mark_as_inactive(arg_stream_player)
	

func stop_stream_player_and_mark_as_inactive(arg_stream_player):
	if arg_stream_player.is_connected("finished", self, "_on_stream_player_finished"):
		arg_stream_player.disconnect("finished", self, "_on_stream_player_finished")
	
	var arg_path_name = arg_stream_player.stream.resource_path
	
	arg_stream_player.stop()
	
	sound_path_name_to__stream_player_node_to_is_active_map[arg_path_name][arg_stream_player] = false
	
	if stream_player_node_to_mask_level_map.has(arg_stream_player):
		var mask_level = stream_player_node_to_mask_level_map[arg_stream_player]
		mask_level_to_active_count_map[mask_level] -= 1
	
	emit_signal("steam_player_stopped_and_marked_as_inactive", arg_path_name, arg_stream_player)


func _on_stream_player_queue_free(arg_stream_player):
	remove_stream_player(arg_stream_player)

func remove_stream_player(arg_stream_player):
	var arg_path_name = arg_stream_player.stream.resource_name
	
	#var mask_level = stream_player_node_to_mask_level_map[arg_stream_player]
	
	var node_to_is_active_map
	if sound_path_name_to__stream_player_node_to_is_active_map.has(arg_path_name):
		node_to_is_active_map = sound_path_name_to__stream_player_node_to_is_active_map[arg_path_name]
		
		sound_path_name_to__stream_player_node_to_is_active_map[arg_path_name].clear()
	
	var is_active = false
	if node_to_is_active_map != null:
		is_active = node_to_is_active_map[arg_stream_player]
	
	if stream_player_node_to_mask_level_map.has(arg_stream_player):
		var mask_level = stream_player_node_to_mask_level_map[arg_stream_player]
		if is_active:
			mask_level_to_active_count_map[mask_level] -= 1
		
		stream_player_node_to_mask_level_map.erase(arg_stream_player)
	
	#stream_player_node_to_mask_level_map.erase(arg_stream_player)
	
	if stream_player_to_linear_audio_set_param_map.has(arg_stream_player):
		stream_player_to_linear_audio_set_param_map.erase(arg_stream_player)
	
	#if is_active:
	#	mask_level_to_active_count_map[mask_level] -= 1
	
	
	if stream_player_to_adv_params_map.has(arg_stream_player):
		var adv_param : PlayAdvParams = stream_player_to_adv_params_map[arg_stream_player]
		if adv_param != null:
			var sound_type = adv_param.play_sound_type
			if player_sound_type_to_stream_players_map[sound_type].has(arg_stream_player):
				player_sound_type_to_stream_players_map[sound_type].erase(arg_stream_player)
		
		stream_player_to_adv_params_map.erase(arg_stream_player)


#######

class LinearSetAudioParams:
	const ValTransition = preload("res://_NonMainGameRelateds/_Master/AudioRelated/ValTransition.gd")
	
	
	var pause_at_target_db : bool
	var stop_at_target_db : bool
	
	var target_db : float #setget set_target_db, get_target_db
	
	var time_to_reach_target_db : float = ValTransition.VALUE_UNSET
	var db_mag_inc_or_dec_per_sec : float = ValTransition.VALUE_UNSET
	
	# set by AudioManager
	var _db_val_transition : ValTransition
	
	
	func set_target_db_to_custom_standard_of_audio_id(arg_id):
		target_db = StoreOfAudio.get_audio_id_custom_standard_db(arg_id)
	


func linear_set_audio_player_volume_using_params(arg_player, arg_linear_set_params : LinearSetAudioParams):
	arg_linear_set_params._db_val_transition = ValTransition.new()
	arg_linear_set_params._db_val_transition.connect("target_val_reached", self, "_on_audio_volume_target_val_reached", [arg_player, arg_linear_set_params])
	
	var final_val_inc_to_use = arg_linear_set_params.db_mag_inc_or_dec_per_sec
	if arg_player.volume_db > arg_linear_set_params.target_db:
		final_val_inc_to_use *= -1
	
	var reached_target_db = arg_linear_set_params._db_val_transition.configure_self(arg_player.volume_db, arg_player.volume_db, arg_linear_set_params.target_db, arg_linear_set_params.time_to_reach_target_db, final_val_inc_to_use, ValTransition.ValueIncrementMode.LINEAR)
	
	
	if !reached_target_db:
		stream_player_to_linear_audio_set_param_map[arg_player] = arg_linear_set_params
		
		_last_calc_has_linear_set_params = true
		_update_can_do_process()
	else:
		_on_audio_volume_target_val_reached(arg_player, arg_linear_set_params)
		if stream_player_to_linear_audio_set_param_map.has(arg_player):
			stream_player_to_linear_audio_set_param_map.erase(arg_player)
		
		_last_calc_has_linear_set_params = stream_player_to_linear_audio_set_param_map.size() != 0
		_update_can_do_process()

func _update_can_do_process():
	var can_do_process = _last_calc_has_linear_set_params
	
	set_process(can_do_process)


func _process(delta):
	var audio_players_to_remove : Array
	
	for player in stream_player_to_linear_audio_set_param_map:
		var param : LinearSetAudioParams = stream_player_to_linear_audio_set_param_map[player]
		
		var reached_target = param._db_val_transition.delta_pass(delta)
		if !reached_target:
			player.volume_db = param._db_val_transition.get_current_val()
			
		else:
			# NOTE: no need to do anything on the player as this is handled via signals
			audio_players_to_remove.append(player)
	
	for player in audio_players_to_remove:
		if stream_player_to_linear_audio_set_param_map.has(player):
			stream_player_to_linear_audio_set_param_map.erase(player)
	
	if audio_players_to_remove.size() != 0:
		_last_calc_has_linear_set_params = stream_player_to_linear_audio_set_param_map.size() != 0
		_update_can_do_process()
	


func _on_audio_volume_target_val_reached(arg_player, arg_linear_set_params : LinearSetAudioParams):
	arg_player.volume_db = arg_linear_set_params.target_db
	
	if arg_linear_set_params.pause_at_target_db:
		arg_player.stream_paused = true
	
	if arg_linear_set_params.stop_at_target_db:
		stop_stream_player_and_mark_as_inactive(arg_player)
	
	
	#_last_calc_has_linear_set_params = stream_player_to_linear_audio_set_param_map.size() != 0
	#_update_can_do_process()


#############################

func set_bus__sound_fx_volume(arg_val):
	bus__sound_fx_volume = arg_val
	
	var idx = AudioServer.get_bus_index(bus__sound_fx_name)
	AudioServer.set_bus_volume_db(idx, arg_val)
	
	emit_signal("bus__sound_fx_volume_changed", arg_val)

func set_bus__background_music_volume(arg_val):
	bus__background_music_volume = arg_val
	
	var idx = AudioServer.get_bus_index(bus__background_name)
	AudioServer.set_bus_volume_db(idx, arg_val)
	
	emit_signal("bus__background_music_volume_changed", arg_val)

#

func set_bus__sound_fx_bus_mute(arg_val):
	bus__sound_fx_bus_mute = arg_val
	
	var idx = AudioServer.get_bus_index(bus__sound_fx_name)
	AudioServer.set_bus_mute(idx, bus__sound_fx_bus_mute)
	
	emit_signal("bus__sound_fx_mute_changed", arg_val)

func set_bus__background_music_bus_mute(arg_val):
	bus__background_music_bus_mute = arg_val
	
	var idx = AudioServer.get_bus_index(bus__background_name)
	AudioServer.set_bus_mute(idx, bus__background_music_bus_mute)
	
	emit_signal("bus__background_music_mute_changed", arg_val)

#

func set_bus__background_music_volume__internal(arg_val):
	if bus__background_name__internal__idx == -1:
		bus__background_name__internal__idx = AudioServer.get_bus_index(bus__background_name__internal)
	AudioServer.set_bus_volume_db(bus__background_name__internal__idx, arg_val)

func get_bus__background_music_volume__internal():
	if bus__background_name__internal__idx == -1:
		bus__background_name__internal__idx = AudioServer.get_bus_index(bus__background_name__internal)
	
	return bus__background_name__internal__idx


####################

func _get_save_dict_for_data():
	var save_dict = {
		data_name__background_music_volume_name : bus__background_music_volume,
		data_name__background_music_is_mute_name : bus__background_music_bus_mute,
		
		data_name__sound_fx_volume_name : bus__sound_fx_volume,
		data_name__sound_fx_is_mute_name : bus__sound_fx_bus_mute,
		
	}
	
	return save_dict



func _load_save_data(arg_file : File):
	var save_dict = parse_json(arg_file.get_line())
	
	if !save_dict is Dictionary:
		save_dict = {}
	
	_initialize_stats_with_save_dict(save_dict)

func _initialize_save_data_from_scratch():
	_initialize_stats_with_save_dict({})


func _initialize_stats_with_save_dict(arg_save_dict : Dictionary):
	_initialize_background_music_relateds(arg_save_dict)
	_initialize_sound_fx_relateds(arg_save_dict)
	


func _initialize_background_music_relateds(arg_save_dict : Dictionary):
	if arg_save_dict.has(data_name__background_music_volume_name):
		var volume = floor(arg_save_dict[data_name__background_music_volume_name])
		set_bus__background_music_volume(volume)
		
	else:
		pass
	
	if arg_save_dict.has(data_name__background_music_is_mute_name):
		set_bus__background_music_bus_mute(arg_save_dict[data_name__background_music_is_mute_name])
		
	else:
		pass


func _initialize_sound_fx_relateds(arg_save_dict : Dictionary):
	if arg_save_dict.has(data_name__sound_fx_volume_name):
		var volume = floor(arg_save_dict[data_name__sound_fx_volume_name])
		set_bus__sound_fx_volume(volume)
		
	else:
		pass
	
	if arg_save_dict.has(data_name__sound_fx_is_mute_name):
		set_bus__sound_fx_bus_mute(arg_save_dict[data_name__sound_fx_is_mute_name])
		
	else:
		pass


#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		GameSaveManager.save_settings__of_audio_manager()
#
#		#get_tree().quit() # default behavior



#############################
# HELPER
##############################

func helper__linearly_set_player_db_to_audiable(player, audio_id, time_to_reach_target_db):
	var params = AudioManager.LinearSetAudioParams.new()
	params.pause_at_target_db = false
	params.stop_at_target_db = false
	#params.target_db =
	params.set_target_db_to_custom_standard_of_audio_id(audio_id)
	
	params.time_to_reach_target_db = time_to_reach_target_db
	
	linear_set_audio_player_volume_using_params(player, params)

func helper__linearly_set_current_player_db_to_inaudiable(player, time_to_reach_target_db):
	var params = AudioManager.LinearSetAudioParams.new()
	params.pause_at_target_db = false
	params.stop_at_target_db = true
	params.target_db = AudioManager.DECIBEL_VAL__INAUDIABLE
	
	params.time_to_reach_target_db = time_to_reach_target_db
	
	linear_set_audio_player_volume_using_params(player, params)


#########

func helper__play_sound_effect__2d(arg_id, arg_pos : Vector2, arg_volume_ratio : float, arg_adv_param : PlayAdvParams = null, arg_mask_level : int = MaskLevel.Major_SoundFX):
	#return play_sound(arg_id, MaskLevel.Major_SoundFX, PlayerConstructionType.TWO_D, arg_adv_param)
	var pause_mode_of_player = PAUSE_MODE_INHERIT
	if arg_adv_param != null:
		pause_mode_of_player = arg_adv_param.node_pause_mode
	
	var sound_player : AudioStreamPlayer2D = get_available_or_construct_new_audio_stream_player(arg_id, PlayerConstructionType.TWO_D, pause_mode_of_player, arg_adv_param)
	sound_player.global_position = arg_pos
	sound_player.volume_db = _convert_ratio_using_num_range(arg_volume_ratio, DECIBEL_VAL__INAUDIABLE, StoreOfAudio.get_audio_id_custom_standard_db(arg_id))
	play_sound__with_provided_stream_player(arg_id, sound_player, arg_mask_level, arg_adv_param)
	
	return sound_player

func helper__play_sound_effect__plain(arg_id, arg_volume_ratio : float, arg_adv_param : PlayAdvParams = null, arg_mask_level : int = MaskLevel.Major_SoundFX):
	#return play_sound(arg_id, MaskLevel.Major_SoundFX, PlayerConstructionType.PLAIN, arg_adv_param)
	var pause_mode_of_player = PAUSE_MODE_INHERIT
	if arg_adv_param != null:
		pause_mode_of_player = arg_adv_param.node_pause_mode
	
	
	var sound_player : AudioStreamPlayer = get_available_or_construct_new_audio_stream_player(arg_id, PlayerConstructionType.PLAIN, pause_mode_of_player, arg_adv_param)
	sound_player.volume_db = _convert_ratio_using_num_range(arg_volume_ratio, DECIBEL_VAL__INAUDIABLE, StoreOfAudio.get_audio_id_custom_standard_db(arg_id))
	play_sound__with_provided_stream_player(arg_id, sound_player, arg_mask_level, arg_adv_param)
	
	return sound_player


func helper__play_sound_effect__2d__lower_volume_based_on_dist(arg_id, arg_pos : Vector2, arg_volume_ratio : float, arg_adv_param : PlayAdvParams = null, arg_mask_level : int = MaskLevel.Major_SoundFX):
	#return play_sound(arg_id, MaskLevel.Major_SoundFX, PlayerConstructionType.TWO_D, arg_adv_param)
	var pause_mode_of_player = PAUSE_MODE_INHERIT
	if arg_adv_param != null:
		pause_mode_of_player = arg_adv_param.node_pause_mode
	
	var sound_player : AudioStreamPlayer2D = get_available_or_construct_new_audio_stream_player(arg_id, PlayerConstructionType.TWO_D, pause_mode_of_player, arg_adv_param)
	sound_player.global_position = arg_pos
	var final_volume = _convert_ratio_using_num_range(arg_volume_ratio, DECIBEL_VAL__INAUDIABLE, StoreOfAudio.get_audio_id_custom_standard_db(arg_id))
	
	
	var screen_pos = CameraManager.get_camera__screen_center_position()
	var ratio_02 = _calculate_volume_ratio_based_on_dist(screen_pos, arg_pos)
	
	#print("ratio: %s, dist: %s" % [ratio_02, screen_pos.distance_to(arg_pos)])
	final_volume = _convert_ratio_using_num_range(ratio_02, DECIBEL_VAL__INAUDIABLE, final_volume)
	
	sound_player.volume_db = final_volume
	play_sound__with_provided_stream_player(arg_id, sound_player, arg_mask_level, arg_adv_param)
	return sound_player


func _convert_ratio_using_num_range(arg_ratio, arg_min, arg_max):
	var diff = arg_max - arg_min
	
	return arg_min + (diff * arg_ratio)


func _calculate_volume_ratio_based_on_dist(arg_pos_01 : Vector2, arg_pos_02 : Vector2):
	var ratio = 1
	
	var dist = arg_pos_01.distance_to(arg_pos_02)
	if dist <= 300:
		return ratio
	
	dist -= 300
	ratio = _convert_num_to_ratio_using_num_range(dist, DISTANCE_FROM_2D_TO_REACH_MINIMUM, 0, 0)
	
	return ratio


#func _convert_num_to_ratio_using_num_range(arg_num, arg_min, arg_max, arg_minimum_ratio):
#	pass

func _convert_num_to_ratio_using_num_range(arg_num, arg_min, arg_max, arg_minimum_ratio):
	var diff = arg_max - arg_min
	
	return max((arg_num - arg_min) / diff, arg_minimum_ratio)


#
