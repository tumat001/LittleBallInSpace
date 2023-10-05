extends "res://WorldRelated/AbstractWorldSlice.gd"


const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

const DURATION_OF_TRAVEL_FROM_AIR_TO_GROUND__CUTSCENE : float = 12.0

#

var _is_first_time__do_cutscenes : bool
var _current_long_transition

var _player
var _player_modi_energy

#

onready var vkp_left = $MiscContainer/VBoxContainer3/HBoxContainer/VBoxContainer/VKP_Left
onready var vkp_right = $MiscContainer/VBoxContainer3/HBoxContainer/VBoxContainer2/VKP_Right

onready var fast_spawn_pos_2d = $MiscContainer/FastSpawnPos2D
onready var normal_spawn_pos_2d = $PlayerSpawnCoordsContainer/Position2D

onready var trajectory_editor_line = $MiscContainer/TrajectoryEditorHelper

onready var vbox_of_instructions__01 = $MiscContainer/VBoxContainer3

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _ready():
	trajectory_editor_line.visible = false
	trajectory_editor_line.queue_free()

#

func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	
	
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_01__STAGE_1):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_1)
		
		if is_fast_respawn:
			arg_player.global_position = fast_spawn_pos_2d.global_position
		else:
			_is_first_time__do_cutscenes = true
		
		
	else:
		
		_is_first_time__do_cutscenes = true
	
	
	if _is_first_time__do_cutscenes:
		#var first_time = GameSaveManager.first_time_opening_game
		GameSaveManager.first_time_opening_game = false
		
		vbox_of_instructions__01.modulate.a = 0
		SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_1, true)
		
		
		var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK)
		transition.initial_ratio = 0.2
		transition.target_ratio = 1.0
		transition.wait_at_start = 1.0
		transition.duration = 2.0
		transition.trans_type = Tween.TRANS_BOUNCE
		SingletonsAndConsts.current_master.play_transition__alter_no_states(transition)
		transition.modulate.a = 0.6
		
		transition.set_is_transition_paused(true)
		_current_long_transition = transition
	
	

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	vkp_left.game_control_action_name = "game_left"
	vkp_right.game_control_action_name = "game_right"
	
	#
	
	if _is_first_time__do_cutscenes:
		game_elements.configure_game_state_for_cutscene_occurance(false, false)
		CameraManager.start_camera_zoom_change(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL, 0.0)
	
	call_deferred("_deferred_init__for_first_time_and_not")


func _add_energy_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	modi.set_max_energy(15)
	modi.set_current_energy(0)
	modi.is_energy_deductable = false
	modi.allow_display_of_energy_hud = false
	
	modi.can_record_stats = false
	
	_player_modi_energy = modi
	



func _deferred_init__for_first_time_and_not():
	_add_energy_modi()
	
	if _is_first_time__do_cutscenes:
		_init__as_first_time__and_do_cutscenes()
	else:
		_init__as_not_first_time()


func _init__as_not_first_time():
	game_elements.player_modi_manager.add_modi_to_player(_player_modi_energy)
	
	_player_modi_energy.set_current_energy(15)

func _init__as_first_time__and_do_cutscenes():
	game_elements.player_modi_manager.add_modi_to_player(_player_modi_energy)
	
	_player = game_elements.get_current_player()
	_player.connect("on_ground_state_changed", self, "_on_player_on_ground_state_changed")
	
	if game_elements.is_game_front_hud_initialized:
		SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)
	
	_apply_force_to_make_player_goto_pos_from_air_pos()
	

func _on_game_front_hud_initialized(arg_hud):
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)

func _apply_force_to_make_player_goto_pos_from_air_pos():
	var linear_velocity_to_use = (fast_spawn_pos_2d.global_position - normal_spawn_pos_2d.global_position) / DURATION_OF_TRAVEL_FROM_AIR_TO_GROUND__CUTSCENE
	
	_player.apply_inside_induced_force(linear_velocity_to_use)




func _on_player_on_ground_state_changed(arg_val):
	if arg_val:
		_player.disconnect("on_ground_state_changed", self, "_on_player_on_ground_state_changed")
		_current_long_transition.set_is_transition_paused(false)
		
		_player.stop_player_movement()
		
		_player.player_face.play_sequence__waking_up(2.0, self, "_on_player_wakeup_sequence_finish", 0.0)
		_player_modi_energy.set_current_energy(15)
		
		CameraManager.camera.add_stress(2.0)
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion, 0.6, null)

func _on_player_wakeup_sequence_finish():
	CameraManager.reset_camera_zoom_level()
	
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(true)
	_make_vbox_of_instructions__01__visible_by_tweener()
	
	SingletonsAndConsts.current_master.start_play_music_playlist_of_curr_level()

func _make_vbox_of_instructions__01__visible_by_tweener():
	var tweener = create_tween()
	tweener.tween_property(vbox_of_instructions__01, "modulate:a", 1.0, 1.0)
	




##

func _on_PDAR_ShowCaptureLine_player_entered_in_area():
	game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true
	
	


