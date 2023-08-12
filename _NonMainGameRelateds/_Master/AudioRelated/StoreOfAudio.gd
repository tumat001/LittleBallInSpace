extends Node

const AudioPlayList = preload("res://_NonMainGameRelateds/_Master/AudioRelated/Classes/AudioPlayList.gd")
const AudioPlayListCatalog = preload("res://_NonMainGameRelateds/_Master/AudioRelated/Classes/AudioPlayListCatalog.gd")

#

const BGM_AUDIO_NAME_ID_PREFIX = "BGM_"
const BGM_AUDIO_FOLDER_PATH =  "res://_NonMainGameRelateds/_Master/AudioRelated/Audios/BGM/"

const BGM_STRING_IDENTIFIER__CALM_01 = "Calm01"
const BGM_STRING_IDENTIFIER__RISING_01 = "Rising01"
const BGM_STRING_IDENTIFIER__DOOM_01 = "Doom01"

# DONT CHANGE NAMES of ids -- used for finding files by its name
# SIMILARLY, do not change file names
enum AudioIds {
	
	###################
	####### BGM #######
	###################
	# EXAMPLE:
	# special
	#BGM_LastRound_AnyFaction_AnyMap_01 = 1000
	
	# CALM_01
	BGM_Calm01_01 = 1000
	BGM_Calm01_02 = 1001
	
	# RISING
	BGM_Rising01_01 = 1100
	
	# DOOM
	BGM_Doom01_01 = 1200
	
	
	####################
	
	
	
	####################
	
}

var _audio_id_to_file_path_map := {
	#NOTE: BGMs accounted for
}
var _file_path_to_audio_id_map := {}


# If not defined, then default 0.0 is used.
var _audio_id_to_custom_standard_db_map := {
	
}


#

#const BGM_PLAYLIST_ID__CALM_01 = 1
#const BGM_PLAYLIST_ID__RISING_01 = 2
#const BGM_PLAYLIST_ID__DOOM_01 = 3

enum BGMPlaylistId {
	CALM_01 = 1,
	RISING_01 = 2,
	DOOM_01 = 3,
}


var _all_BGM_stages_playlist : Array
var BGM_playlist__calm_01 : AudioPlayList
var BGM_playlist__rising_01 : AudioPlayList
var BGM_playlist__doom_01 : AudioPlayList

var BGM_playlist_catalog : AudioPlayListCatalog

const BGM_ids__calm_01__list = []
const BGM_ids__rising_01__list = []
const BGM_ids__doom_01__list = []


#

func _init():
	_add_bgm_file_names_to_file_path_map()
	
	var string_id_to_list_map : Dictionary = {
		BGM_STRING_IDENTIFIER__CALM_01 : BGM_ids__calm_01__list,
		BGM_STRING_IDENTIFIER__RISING_01 : BGM_ids__rising_01__list,
		BGM_STRING_IDENTIFIER__DOOM_01 : BGM_ids__doom_01__list,
		
	}
	_initialize_bgm_list_with_string_identifier(string_id_to_list_map)
	

func _ready():
	_initialize_bgm_stages_playlist()


#

func _add_bgm_file_names_to_file_path_map():
	for audio_name in AudioIds.keys():
		if audio_name.begins_with(BGM_AUDIO_NAME_ID_PREFIX):
			var file_name = BGM_AUDIO_FOLDER_PATH + audio_name + ".mp3"
			
			var audio_id = AudioIds[audio_name]
			_audio_id_to_file_path_map[audio_id] = file_name
			_file_path_to_audio_id_map[file_name] = audio_id

func _initialize_bgm_list_with_string_identifier(arg_string_identifier_to_list_to_add_to_map : Dictionary):
	for audio_name in AudioIds.keys():
		if audio_name.begins_with(BGM_AUDIO_NAME_ID_PREFIX):
			for string_id in arg_string_identifier_to_list_to_add_to_map.keys():
				if audio_name.find(string_id) != -1:
					var list_to_add_to = arg_string_identifier_to_list_to_add_to_map[string_id]
					list_to_add_to.append(AudioIds[audio_name])
	

func reset_bgm_playlists():
	BGM_playlist__calm_01.set_audio_ids_of_playlist(BGM_ids__calm_01__list)
	BGM_playlist__rising_01.set_audio_ids_of_playlist(BGM_ids__rising_01__list)
	BGM_playlist__doom_01.set_audio_ids_of_playlist(BGM_ids__doom_01__list)

#######

func _initialize_bgm_stages_playlist():
	BGM_playlist__calm_01 = AudioPlayList.new()
	BGM_playlist__rising_01 = AudioPlayList.new()
	BGM_playlist__doom_01 = AudioPlayList.new()
	
	
	BGM_playlist__calm_01.playlist_id = BGMPlaylistId.CALM_01
	BGM_playlist__rising_01.playlist_id = BGMPlaylistId.RISING_01
	BGM_playlist__doom_01.playlist_id = BGMPlaylistId.DOOM_01
	
	
	BGM_playlist__calm_01.playlist_name = "Calm 01"
	BGM_playlist__rising_01.playlist_name = "Rising 01"
	BGM_playlist__doom_01.playlist_name = "Doom 01"
	
	
	_all_BGM_stages_playlist.append(BGM_playlist__calm_01)
	_all_BGM_stages_playlist.append(BGM_playlist__rising_01)
	_all_BGM_stages_playlist.append(BGM_playlist__doom_01)
	
	
	BGM_playlist_catalog = AudioPlayListCatalog.new()
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.CALM_01, BGM_playlist__calm_01)
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.RISING_01, BGM_playlist__rising_01)
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.DOOM_01, BGM_playlist__doom_01)
	
	
	for playlist in _all_BGM_stages_playlist:
		playlist.set_autoplay_delay_with_node_to_host_timer(10, 20, self)
		#playlist.set_autoplay_delay_with_node_to_host_timer(0, 1, self)
		
		playlist.node_pause_mode = Node.PAUSE_MODE_PROCESS
	
	
	reset_bgm_playlists()


#######

func get_audio_file_path_of_id(arg_id):
	if _audio_id_to_file_path_map.has(arg_id):
		return _audio_id_to_file_path_map[arg_id]
	else:
		
		print("StoreOfAudio error: audio file path of id not found: %s" % [arg_id])

func get_audio_id_custom_standard_db(arg_id):
	if _audio_id_to_custom_standard_db_map.has(arg_id):
		return _audio_id_to_custom_standard_db_map[arg_id]
	else:
		return AudioManager.DECIBEL_VAL__STANDARD


func get_audio_id_from_file_path(arg_path):
	if _file_path_to_audio_id_map.has(arg_path):
		return _file_path_to_audio_id_map[arg_path]
	else:
		print("StoreOfAudio error: audio id of file path not found: %s" % [arg_path])
	


########################################

func is_BGM_playlist_id_playing(arg_playlist_id):
	return BGM_playlist_catalog.is_playlist_id_playing(arg_playlist_id)




