extends Node

const AudioPlayList = preload("res://_NonMainGameRelateds/_Master/AudioRelated/Classes/AudioPlayList.gd")
const AudioPlayListCatalog = preload("res://_NonMainGameRelateds/_Master/AudioRelated/Classes/AudioPlayListCatalog.gd")

#

const BGM_AUDIO_NAME_ID_PREFIX = "BGM_"
const SFX_AUDIO_NAME_ID_PREFIX = "SFX_"
const BGM_AUDIO_FOLDER_PATH =  "res://_NonMainGameRelateds/_Master/AudioRelated/Audios/BGM/"
const SFX_AUDIO_FOLDER_PATH =  "res://_NonMainGameRelateds/_Master/AudioRelated/Audios/SFX/"


const BGM_STRING_IDENTIFIER__CALM_01 = "Calm01"
const BGM_STRING_IDENTIFIER__RISING_01 = "Rising01"
const BGM_STRING_IDENTIFIER__DOOM_01 = "Doom01"
const BGM_STRING_IDENTIFIER__SPECIAL_01 = "Special01"

# DONT CHANGE NAMES of ids -- used for finding files by its name
# SIMILARLY, do not change file names
enum AudioIds {
	
	###################
	## BGM 
	###################
	
	# CALM_01
	BGM_Calm01_01 = 1000
	BGM_Calm01_02 = 1001
	BGM_Calm01_03 = 1002
	BGM_Calm01_04 = 1003
	BGM_Calm01_05 = 1004
	
	# RISING
	BGM_Rising01_01 = 1100
	BGM_Rising01_02 = 1101
	BGM_Rising01_02 = 1102
	
	# DOOM
	BGM_Doom01_01 = 1200
	
	
	# Special
	BGM_Special01_FakeoutSuspense = 1300
	
	
	####################
	## SFX
	######################
	
	# TileHit
	SFX_TileHit_MetalBang_LoudFullBangExplosion = 5000
	SFX_TileHit_MetalBang_Ping_HighPitchShortFull = 5001
	SFX_TileHit_MetalBang_SoftFull_LowPitchTinPlate = 5002
	SFX_TileHit_MetalBang_SoftHollow = 5003
	
	SFX_TileHit_MetalHitGlass = 5005
	
	
	
	# ROTATE
	SFX_Rotate_Standard_01 = 5100
	
	# LAUNCH
	SFX_LaunchBall_01 = 5110
	SFX_LaunchBall_02 = 5111
	SFX_LaunchBall_03 = 5112
	SFX_LaunchBall_AimModeChanged = 5113
	
	# SWITCH/BUTTON
	SFX_SwitchToggle_01 = 5120
	
	# ENERGY
	SFX_EnergyModi_LowBatteryWarning = 5130
	SFX_EnergyModi_PowerDown_01 = 5131
	SFX_EnergyModi_PowerUp_01 = 5132
	SFX_EnergyModi_RechargeAtLow = 5133
	
	# CAPTURE RELATED
	SFX_CapturePoint_Captured_02 = 5141
	SFX_CapturePoint_Capturing = 5142
	
	# LEVEL SELECTION UI
	SFX_LevelSelected_01 = 5150
	SFX_LevelUnlock_Burst_01 = 5151
	
	# REWIND
	SFX_Rewind_Beginning = 5160
	SFX_Rewind_Middle = 5161
	SFX_Rewind_Ending = 5162
	
	# REGION RELATED
	SFX_AreaRegion_ObjectDestroyed = 5170
	SFX_AreaRegion_ClearPlayer = 5171
	SFX_PDAR_PlayerReachedOutOfBoundsOfMap = 5172
	
	# PICKUPABLE RELATED
	SFX_Pickupable_Star_01 = 5180
	SFX_Pickupable_LaunchBallModi = 5181
	SFX_Pickupable_LaunchBallAmmo = 5182
	SFX_Pickupable_Battery_01 = 5183
	SFX_Pickupable_RemoteControl = 5184
	SFX_Pickupable_ModuleX = 5185
	
	# TELEPORTER RELATED
	SFX_Teleporter_EnteredTeleporter_Normal = 5190
	SFX_Teleporter_EnteredTeleporter_TransitionLong = 5191
	
	
	# GAME RELATED
	SFX_Restart_01 = 5200
	
	# TILE BREAK
	SFX_Misc_GlassBreak_Hard = 5300
	SFX_SpaceshipWall_Tile_Break = 5301
	
	
	### GUI
	SFX_GUI_Button_Hover = 5400
	SFX_GUI_LevelTile_Hover = 5401
	#SFX_GUI_LevelLayout_Enter = 5402
	SFX_GUI_InGamePauseMenu_OrMainMenu_Open = 5403
	SFX_GUI_Checkbox_Clicked = 5404
	SFX_GUI_Button_Click_Confirmed = 5405
	
	SFX_GUI_CharacterBlip_FTQ = 5406
	
	
	# ENV
	SFX_Environment_ElectricSpark_01 = 5500
	
	
	
	# SPECIAL
	SFX_Special_ElectricGenerator = 6000
	SFX_Special_Electrical_Shock = 6001
	SFX_Special_Electrical_Explosion = 6002
	SFX_Special_Electrical_SwitchFlip = 6003
	SFX_Special_ImportantItemFound = 6004
	
	
	# COMBAT
	SFX_Laser_MainFire = 6500
	SFX_Laser_ChargeUp = 6501
	
	SFX_Player_Damage_01 = 6510
	SFX_Enemy_Damage_01 = 6520
	
	SFX_Enemy_DeathExplode = 6530
	SFX_Player_DeathExplode = 6531
	
	SFX_Enemy_ChargeBall = 6540
	SFX_Enemy_LaunchBall = 6541
	
	#######
	
	
	### COLLISION -- TILE FRAGMENTS
	SFX_TileFragments_Metal_01 = 7000
	SFX_TileFragments_Metal_02 = 7001
	SFX_TileFragments_Metal_03 = 7002
	SFX_TileFragments_Metal_04 = 7003
	SFX_TileFragments_Metal_05 = 7004
	SFX_TileFragments_Metal_06 = 7005
	
	SFX_TileFragments_Glass_01 = 7006
	SFX_TileFragments_Glass_02 = 7007
	SFX_TileFragments_Glass_03 = 7008
	SFX_TileFragments_Glass_04 = 7009
	SFX_TileFragments_Glass_05 = 7010
	#SFX_TileFragments_Glass_06 = 7011
	
	### COLLISION -- BALL
	SFX_BallCollision_Metal_01 = 7100
	SFX_BallCollision_Metal_02 = 7101
	SFX_BallCollision_Metal_03 = 7102
	
	SFX_BallCollision_ToggleableTiles_01 = 7110
	SFX_BallCollision_ToggleableTiles_02 = 7111
	
	SFX_BallCollision_Ball_01 = 7120
	SFX_BallCollision_Ball_02 = 7121
	
	SFX_BallCollision_Player_01 = 7130
	SFX_BallCollision_Player_02 = 7131
	
	SFX_BallCollision_Glass_01 = 7140
	SFX_BallCollision_Glass_02 = 7141
	SFX_BallCollision_Glass_03 = 7142
	
}

const _all_audio_ids_sfx_launch_ball_variations = [
	AudioIds.SFX_LaunchBall_01,
	AudioIds.SFX_LaunchBall_02,
	AudioIds.SFX_LaunchBall_03,
	
]


#

var _audio_id_to_file_path_map := {
	#NOTE: BGMs accounted for
}
var _file_path_to_audio_id_map := {}


# If not defined, then default 0.0 is used.
var _audio_id_to_custom_standard_db_map := {
	AudioIds.SFX_TileHit_MetalBang_Ping_HighPitchShortFull : -2,
	
	AudioIds.SFX_TileHit_MetalBang_SoftFull_LowPitchTinPlate : 10,
	AudioIds.SFX_TileHit_MetalBang_SoftHollow : 18,
	AudioIds.SFX_TileHit_MetalHitGlass : 10,
	
	AudioIds.SFX_Pickupable_Star_01 : -12,
	
	AudioIds.SFX_Pickupable_LaunchBallModi : -10,
	
	AudioIds.SFX_PDAR_PlayerReachedOutOfBoundsOfMap : -10,
	
	AudioIds.SFX_GUI_Checkbox_Clicked : -24,
	AudioIds.SFX_GUI_InGamePauseMenu_OrMainMenu_Open : -24,
	
	AudioIds.SFX_GUI_Button_Click_Confirmed : -16,
	
	AudioIds.SFX_Pickupable_Star_01 : 0,
	
	AudioIds.BGM_Calm01_01 : -4,
	
	AudioIds.SFX_Pickupable_Star_01 : -4,
	
	
	AudioIds.SFX_BallCollision_Ball_01 : -6,
	AudioIds.SFX_BallCollision_Ball_02 : -6,
	
	AudioIds.SFX_BallCollision_Glass_01 : -4,
	AudioIds.SFX_BallCollision_Glass_02 : -4,
	AudioIds.SFX_BallCollision_Glass_03 : -4,
	
	
	AudioIds.SFX_Laser_ChargeUp : 6,
	AudioIds.SFX_Laser_MainFire : 6,
	AudioIds.SFX_Enemy_ChargeBall : 2,
	AudioIds.SFX_Enemy_LaunchBall : -2,
	
	AudioIds.SFX_Player_Damage_01 : 12,
	AudioIds.SFX_Enemy_Damage_01 : 10,
	
	AudioIds.SFX_Player_DeathExplode : -9,
	AudioIds.SFX_Enemy_DeathExplode : 10,
	
}
var mute_all_game_sfx_unaffecting_volume_settings : bool = false


#

#const BGM_PLAYLIST_ID__CALM_01 = 1
#const BGM_PLAYLIST_ID__RISING_01 = 2
#const BGM_PLAYLIST_ID__DOOM_01 = 3

enum BGMPlaylistId {
	CALM_01 = 1,
	RISING_01 = 2,
	DOOM_01 = 3,
	
	SPECIALS_01 = 10
}


var _all_BGM_stages_playlist : Array
var BGM_playlist__calm_01 : AudioPlayList
var BGM_playlist__rising_01 : AudioPlayList
var BGM_playlist__doom_01 : AudioPlayList
var BGM_playlist__special_01 : AudioPlayList

var BGM_playlist_catalog : AudioPlayListCatalog

const BGM_ids__calm_01__list = []
const BGM_ids__rising_01__list = []
const BGM_ids__doom_01__list = []
const BGM_ids__special_01__list = []

#

func _init():
	_add_bgm_file_names_to_file_path_map()
	
	var string_id_to_list_map : Dictionary = {
		BGM_STRING_IDENTIFIER__CALM_01 : BGM_ids__calm_01__list,
		BGM_STRING_IDENTIFIER__RISING_01 : BGM_ids__rising_01__list,
		BGM_STRING_IDENTIFIER__DOOM_01 : BGM_ids__doom_01__list,
		BGM_STRING_IDENTIFIER__SPECIAL_01 : BGM_ids__special_01__list,
		
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
			
		elif audio_name.begins_with(SFX_AUDIO_NAME_ID_PREFIX):
			var file_name = SFX_AUDIO_FOLDER_PATH + audio_name + ".wav"
			
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
	BGM_playlist__special_01.set_audio_ids_of_playlist(BGM_ids__special_01__list)

#######

func _initialize_bgm_stages_playlist():
	BGM_playlist__calm_01 = AudioPlayList.new()
	BGM_playlist__rising_01 = AudioPlayList.new()
	BGM_playlist__doom_01 = AudioPlayList.new()
	BGM_playlist__special_01 = AudioPlayList.new()
	
	BGM_playlist__calm_01.playlist_id = BGMPlaylistId.CALM_01
	BGM_playlist__rising_01.playlist_id = BGMPlaylistId.RISING_01
	BGM_playlist__doom_01.playlist_id = BGMPlaylistId.DOOM_01
	BGM_playlist__special_01.playlist_id = BGMPlaylistId.SPECIALS_01
	
	BGM_playlist__special_01.autoplay_to_same_audio_id = true
	
	BGM_playlist__calm_01.playlist_name = "Calm 01"
	BGM_playlist__rising_01.playlist_name = "Rising 01"
	BGM_playlist__doom_01.playlist_name = "Doom 01"
	BGM_playlist__special_01.playlist_name = "Specials 01"
	
	
	_all_BGM_stages_playlist.append(BGM_playlist__calm_01)
	_all_BGM_stages_playlist.append(BGM_playlist__rising_01)
	_all_BGM_stages_playlist.append(BGM_playlist__doom_01)
	_all_BGM_stages_playlist.append(BGM_playlist__special_01)
	
	
	BGM_playlist_catalog = AudioPlayListCatalog.new()
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.CALM_01, BGM_playlist__calm_01)
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.RISING_01, BGM_playlist__rising_01)
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.DOOM_01, BGM_playlist__doom_01)
	BGM_playlist_catalog.add_audio_play_list(BGMPlaylistId.SPECIALS_01, BGM_playlist__special_01)
	
	
	for playlist in _all_BGM_stages_playlist:
		playlist.set_autoplay_delay_with_node_to_host_timer(10, 20, self)
		#playlist.set_autoplay_delay_with_node_to_host_timer(0, 1, self)
		
		playlist.node_pause_mode = Node.PAUSE_MODE_PROCESS
		playlist.bus_internal_name = AudioManager.bus__background_name__internal
	
	#
	
	BGM_playlist__special_01.set_autoplay_delay_with_node_to_host_timer(3, 5, self)
	
	#
	
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


#

func get_randomized_sfx_id__launch_ball():
	return StoreOfRNG.randomly_select_one_element(_all_audio_ids_sfx_launch_ball_variations, StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL))



