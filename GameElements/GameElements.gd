extends Node

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")
const RotationRequestData = Player.RotationRequestData

const GameFrontHUD = preload("res://GameFrontHUDRelated/GameFrontHUD.gd")
const GameFrontHUD_Scene = preload("res://GameFrontHUDRelated/GameFrontHUD.tscn")

const BaseLevel = preload("res://LevelRelated/Classes/BaseLevel.gd")

#

signal after_game_start_init()
signal before_game_quit()

signal player_spawned(arg_player)

#

var current_base_level : BaseLevel

#

var _current_player : Player

#

var _is_game_quitting : bool
var is_game_after_init : bool

#

var game_front_hud : GameFrontHUD

#

onready var world_manager = $WorldManager
onready var player_modi_manager = $PlayerModiManager

onready var other_node_hoster = $OtherNodeHoster

onready var rewind_manager = $RewindManager

onready var game_result_manager = $GameResultManager

onready var non_gui_screen_sprite = $NonGUIScreenShaderSprite

#

func get_current_player():
	return _current_player

#

func _enter_tree():
	SingletonsAndConsts.current_game_elements = self


func _ready():
	_initialize_game_front_hud()
	
	hide_non_screen_gui_shader_sprite()
	
	#
	
	CameraManager.set_non_gui_screen_shader_sprite(non_gui_screen_sprite)
	
	#
	
	world_manager.game_elements = self
	
	SingletonsAndConsts.initialize_current_level_configs_based_on_current_id()
	current_base_level = SingletonsAndConsts.current_base_level
	current_base_level.apply_modification_to_game_elements(self)
	
	
	if !is_instance_valid(_current_player):
		var player = world_manager.get_world_slice__can_spawn_player_when_no_current_player_in_GE().spawn_player_at_spawn_coords_index()
		_set_player__and_register_signals(player)
		
		GameSaveManager.set_player(player)
		game_result_manager.set_player(player)
		emit_signal("player_spawned", player)
	
	
	player_modi_manager.game_elements = self
	player_modi_manager.set_current_player(_current_player)
	
	rewind_manager.game_elements = self
	
	GameSaveManager.set_game_elements(self)
	game_result_manager.set_game_elements(self)
	
	####
	
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
	get_tree().get_root().add_child(game_front_hud)
	
	_current_player.initialize_health_panel_relateds()
	SingletonsAndConsts.current_game_front_hud.speed_panel.set_player(_current_player)
	SingletonsAndConsts.current_game_front_hud.robot_health_panel.set_player(_current_player)

#

func _unhandled_key_input(event):
	if event.is_action_pressed("rewind"):
		rewind_manager.attempt_start_rewind()
		
	elif event.is_action_released("rewind"):
		rewind_manager.end_rewind()
		


#######

func show_non_screen_gui_shader_sprite():
	non_gui_screen_sprite.visible = true

func hide_non_screen_gui_shader_sprite():
	non_gui_screen_sprite.visible = false

###################################

func _exit_tree():
	if !_is_game_quitting:
		_is_game_quitting = true
		emit_signal("before_game_quit")
		
		SingletonsAndConsts.current_game_elements = null
		SingletonsAndConsts.current_game_elements__other_node_hoster = null
		
		if is_instance_valid(game_front_hud):
			game_front_hud.queue_free()
		SingletonsAndConsts.current_game_front_hud = null

