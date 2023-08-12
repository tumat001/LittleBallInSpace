extends Reference

const AudioPlayList = preload("res://_NonMainGameRelateds/_Master/AudioRelated/Classes/AudioPlayList.gd")

#

signal current_audio_playlist_playing_changed(arg_playlist_playing)

#

const NO_PLAYLIST_ID = -1

#

var _playlist_id_to_audio_playlist_map : Dictionary

var _current_audio_playlist_playing : AudioPlayList

#

var _next_audio_playlist_id_to_play
var _next_audio_id_to_play

#####


func get_current_audio_playlist():
	return _current_audio_playlist_playing
	

func is_playlist_id_playing(arg_playlist_id):
	if _current_audio_playlist_playing != null:
		return _current_audio_playlist_playing.playlist_id == arg_playlist_id

#

# arg_play_list_id is user defined (ex: BGM_Playlist (2000))
func add_audio_play_list(arg_playlist_id : int, arg_audio_play_list : AudioPlayList):
	_playlist_id_to_audio_playlist_map[arg_playlist_id] = arg_audio_play_list
	
	arg_audio_play_list.connect("current_audio_id_and_player_changed", self, "_on_playlist_current_audio_id_and_player_changed")
	arg_audio_play_list.connect("is_playing_changed", self, "_on_playlist_is_playing_changed", [arg_audio_play_list])

func _on_playlist_current_audio_id_and_player_changed(arg_audio_id, arg_player):
	pass

func _on_playlist_is_playing_changed(arg_is_playing, arg_player):
	pass
	

#########

func start_play_audio_play_list(arg_playlist_id : int, arg_audio_id = -1):
	var playlist : AudioPlayList = _playlist_id_to_audio_playlist_map[arg_playlist_id]
	
	if _current_audio_playlist_playing == null:
		_set_next_audio_playlist_id_and_audio_id__to_none()
		
		if _current_audio_playlist_playing != playlist:
			_set_current_audio_playlist_playing(playlist)
			
			#
			
			var audio_id_played = arg_audio_id
			if arg_audio_id == -1:
				audio_id_played = playlist.start_play_next_random_audio_in_playlist()
			else:
				playlist.start_play_audio_id(arg_audio_id)
			
			#print("playlist played: %s. audio id played: %s" % [playlist.playlist_name, audio_id_played])
			
		else: # if start play audio requests to play the same current playlist
			pass
			
		
	elif _current_audio_playlist_playing != null and _current_audio_playlist_playing != playlist:
		_set_next_audio_playlist_id_and_audio_id(arg_playlist_id, arg_audio_id)
		
		_current_audio_playlist_playing.linearly_set_current_player_db_to_inaudiable()
		

func _on_current_playlist_is_playing_changed(arg_is_playing, arg_player):
	if !arg_is_playing and _current_audio_playlist_playing == arg_player:
		_set_current_audio_playlist_playing(null)
		
		if _has_next_audio_playlist():
			start_play_audio_play_list(_next_audio_playlist_id_to_play, _next_audio_id_to_play)

func _set_current_audio_playlist_playing(arg_playlist):
	if _current_audio_playlist_playing != null:
		if _current_audio_playlist_playing.is_connected("is_playing_changed", self, "_on_current_playlist_is_playing_changed"):
				_current_audio_playlist_playing.disconnect("is_playing_changed", self, "_on_current_playlist_is_playing_changed")
	
	_current_audio_playlist_playing = arg_playlist
	
	if _current_audio_playlist_playing != null:
		if !_current_audio_playlist_playing.is_connected("is_playing_changed", self, "_on_current_playlist_is_playing_changed"):
			_current_audio_playlist_playing.connect("is_playing_changed", self, "_on_current_playlist_is_playing_changed", [_current_audio_playlist_playing])
	
	
	emit_signal("current_audio_playlist_playing_changed", arg_playlist)


func _set_next_audio_playlist_id_and_audio_id(arg_playlist_id, arg_audio_id):
	_next_audio_playlist_id_to_play = arg_playlist_id
	_next_audio_id_to_play = arg_audio_id

func _set_next_audio_playlist_id_and_audio_id__to_none():
	_set_next_audio_playlist_id_and_audio_id(NO_PLAYLIST_ID, AudioPlayList.NO_AUDIO_PLAYING_ID)


func _has_next_audio_playlist():
	return _next_audio_playlist_id_to_play != NO_PLAYLIST_ID

###########


func stop_play():
	if _current_audio_playlist_playing != null:
		_current_audio_playlist_playing.linearly_set_current_player_db_to_inaudiable()
	


