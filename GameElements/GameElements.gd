extends Node

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")
const RotationRequestData = Player.RotationRequestData

const GameFrontHUD = preload("res://GameFrontHUDRelated/GameFrontHUD.gd")
const GameFrontHUD_Scene = preload("res://GameFrontHUDRelated/GameFrontHUD.tscn")

const BaseLevel = preload("res://LevelRelated/Classes/BaseLevel.gd")

#

signal before_game_start_init()
signal after_game_start_init()
signal before_game_quit()
signal quiting_game_by_queue_free__on_game_quit()

signal player_spawned(arg_player)

signal game_front_hud_initialized(arg_game_front_hud)

#

var current_base_level : BaseLevel

#

var _current_player : Player

#

var _is_game_quitting : bool
var is_game_after_init : bool

#

var is_game_front_hud_initialized : bool = false
var game_front_hud : GameFrontHUD

#

var pause_game_at_startup : bool = false

#

var object_lifespan__ball : float = -1

#

var _is_in_cutscene : bool

#

onready var world_manager = $GameContainer/WorldManager
onready var player_modi_manager = $GameContainer/PlayerModiManager

onready var other_node_hoster = $GameContainer/OtherNodeHoster

onready var rewind_manager = $GameContainer/RewindManager

onready var game_result_manager = $GameContainer/GameResultManager

onready var player_container = $GameContainer/PlayerContainer

var non_gui_screen_sprite

#####


func get_current_player():
	return _current_player

func is_player_spawned():
	return is_instance_valid(_current_player)

#

func _enter_tree():
	SingletonsAndConsts.current_game_elements = self


func _ready():
	GameSettingsManager.attempt_make_game_modifications__based_on_curr_assist_mode_config__before_all()
	
	_initialize_game_front_hud()
	
	#
	
	world_manager.game_elements = self
	
	
	current_base_level = SingletonsAndConsts.current_base_level
	current_base_level.apply_modification_to_game_elements(self)
	
	player_modi_manager.game_elements = self
	if !is_instance_valid(_current_player):
		var player = world_manager.get_world_slice__can_spawn_player_when_no_current_player_in_GE().spawn_player_at_spawn_coords_index()
		player_container.add_child(player)
		_set_player__and_register_signals(player)
		
		GameSaveManager.set_player(player)
		game_result_manager.set_player(player)
		player_modi_manager.set_current_player(_current_player)
		
		emit_signal("player_spawned", player)
	
	
	CameraManager.set_current_default_zoom_normal_vec(SingletonsAndConsts.current_level_details.zoom_normal_vec, false)
	CameraManager.set_current_default_zoom_out_vec(SingletonsAndConsts.current_level_details.zoom_out_vec)
	
	
	#player_modi_manager.game_elements = self
	#player_modi_manager.set_current_player(_current_player)
	
	rewind_manager.game_elements = self
	
	GameSaveManager.set_game_elements(self)
	game_result_manager.set_game_elements(self)
	GameSettingsManager.attempt_make_game_modifications__based_on_curr_assist_mode_config()
	
	####
	
	emit_signal("before_game_start_init")
	call_deferred("_deferred__after_init")



func _deferred__after_init():
	is_game_after_init = true
	emit_signal("after_game_start_init")
	current_base_level.after_game_init()

#

func _set_player__and_register_signals(arg_player : Player):
	_current_player = arg_player
	
	_current_player.connect("request_rotate", self, "_on_current_player_request_rotate", [], CONNECT_PERSIST)
	
	CameraManager.generate_camera()
	give_camera_focus_and_follow_to_player()
#

func give_camera_focus_and_follow_to_player():
	CameraManager.set_camera_to_follow_node_2d(_current_player)


###

func _on_current_player_request_rotate(arg_rot_data : RotationRequestData):
	var angle = arg_rot_data.angle
	
	CameraManager.rotate_cam_to_rad(angle)


#

func _initialize_game_front_hud():
	game_front_hud = GameFrontHUD_Scene.instance()
	SingletonsAndConsts.current_game_front_hud = game_front_hud
	
	call_deferred("_deferred_add_child__game_front_hud")

func _deferred_add_child__game_front_hud():
	#get_tree().get_root().call_deferred("add_child", game_front_hud)
	add_child(game_front_hud)
	
	_current_player.initialize_health_panel_relateds()
	SingletonsAndConsts.current_game_front_hud.speed_panel.set_player(_current_player)
	SingletonsAndConsts.current_game_front_hud.robot_health_panel.set_player(_current_player)
	
	non_gui_screen_sprite = SingletonsAndConsts.current_game_front_hud.non_gui_screen_sprite
	#CameraManager.set_non_gui_screen_shader_sprite(non_gui_screen_sprite)
	hide_non_screen_gui_shader_sprite()
	
	is_game_front_hud_initialized = true
	emit_signal("game_front_hud_initialized", game_front_hud)

#

func _unhandled_key_input(event):
	if is_player_spawned():
		if _current_player.last_calc_block_all_inputs:
			return
	
	if game_result_manager.is_game_result_decided:
		return
	
	#####
	
	if event.is_action_pressed("rewind") and !GameSettingsManager.get_game_control_name__is_hidden("rewind"):
		rewind_manager.attempt_start_rewind()
		
	elif event.is_action_released("rewind") and !GameSettingsManager.get_game_control_name__is_hidden("rewind"):
		rewind_manager.end_rewind()
		
		
	elif event.is_action_pressed("ui_cancel"):
		if is_instance_valid(game_front_hud):
			game_front_hud.show_in_game_pause_control_tree()
		
	elif event.is_action_pressed("toggle_hide_hud"):
		if is_instance_valid(game_front_hud):
			game_front_hud.toggle_control_container_visibility()
	


#######

func show_non_screen_gui_shader_sprite():
	non_gui_screen_sprite.visible = true

func hide_non_screen_gui_shader_sprite():
	non_gui_screen_sprite.visible = false

####


func configure_game_state_for_cutscene_occurance(arg_stop_player_movement : bool,
		arg_reset_cam_zoom_to_default : bool):
	
	if !_is_in_cutscene:
		_is_in_cutscene = true
		
		
		ban_rewind_manager_to_store_and_cast_rewind()
		
		if is_instance_valid(_current_player):
			_current_player.stop_all_persisting_actions()
			_current_player.block_all_inputs_cond_clauses.attempt_insert_clause(_current_player.BlockAllInputsClauseIds.IN_CUTSCENE)
			_current_player.block_health_change_cond_clauses.attempt_insert_clause(_current_player.BlockHealthChangeClauseIds.IN_CUTSCENE)
			
			if arg_stop_player_movement:
				_current_player.stop_player_movement()
			
		
		if arg_reset_cam_zoom_to_default:
			CameraManager.reset_camera_zoom_level()
		
		if is_instance_valid(game_front_hud):
			game_front_hud.hide_in_game_pause_control_tree()


func configure_game_state_for_end_of_cutscene_occurance(arg_reenable_store_and_cast_rewind : bool):
	if _is_in_cutscene:
		_is_in_cutscene = false
		
		if arg_reenable_store_and_cast_rewind:
			allow_rewind_manager_to_store_and_cast_rewind()
		
		if is_instance_valid(_current_player):
			_current_player.block_all_inputs_cond_clauses.remove_clause(_current_player.BlockAllInputsClauseIds.IN_CUTSCENE)
			_current_player.block_health_change_cond_clauses.remove_clause(_current_player.BlockHealthChangeClauseIds.IN_CUTSCENE)


func ban_rewind_manager_to_store_and_cast_rewind():
	rewind_manager.can_store_rewind_data_cond_clause.attempt_insert_clause(rewind_manager.CanStoreRewindDataClauseIds.IN_CUTSCENE)
	rewind_manager.can_cast_rewind_cond_clause.attempt_insert_clause(rewind_manager.CanCastRewindClauseIds.IN_CUTSCENE)
	

func allow_rewind_manager_to_store_and_cast_rewind():
	rewind_manager.can_store_rewind_data_cond_clause.remove_clause(rewind_manager.CanStoreRewindDataClauseIds.IN_CUTSCENE)
	rewind_manager.can_cast_rewind_cond_clause.remove_clause(rewind_manager.CanCastRewindClauseIds.IN_CUTSCENE)
	

####################################

func _exit_tree():
	if !_is_game_quitting:
		_is_game_quitting = true
		emit_signal("before_game_quit")
		
		SingletonsAndConsts.current_game_elements = null
		SingletonsAndConsts.current_game_elements__other_node_hoster = null
		
		if is_instance_valid(game_front_hud):
			game_front_hud.queue_free()
		SingletonsAndConsts.current_game_front_hud = null
	

func attempt_quit_game__by_queue_freeing():
	emit_signal("quiting_game_by_queue_free__on_game_quit")
	queue_free()


###############



