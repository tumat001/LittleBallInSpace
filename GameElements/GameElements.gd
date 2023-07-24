extends Node

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")
const RotationRequestData = Player.RotationRequestData

const GameFrontHUD = preload("res://GameFrontHUDRelated/GameFrontHUD.gd")
const GameFrontHUD_Scene = preload("res://GameFrontHUDRelated/GameFrontHUD.tscn")


#

signal after_game_start_init()
signal before_game_quit()

#

var _current_player : Player

#

var _is_game_quitting : bool


#


var game_front_hud : GameFrontHUD

onready var world_manager = $WorldManager
onready var player_modi_manager = $PlayerModiManager

onready var other_node_hoster = $OtherNodeHoster

#

func _enter_tree():
	SingletonsAndConsts.current_game_elements = self


func _ready():
	_initialize_game_front_hud()
	
	#
	
	world_manager.game_elements = self
	#todo temp for testing
	world_manager.add_world_slice(StoreOfWorldSlices.WorldSliceIds.STAGE_01_01, Vector2(0, 0))
	# end of todo
	
	
	if !is_instance_valid(_current_player):
		var player = world_manager.get_world_slice__can_spawn_player_when_no_current_player_in_GE().spawn_player_at_spawn_coords_index()
		_set_player__and_register_signals(player)
		
	
	player_modi_manager.game_elements = self
	player_modi_manager.set_current_player(_current_player)
	
	
	####
	
	
	emit_signal("after_game_start_init")
	


func _set_player__and_register_signals(arg_player : Player):
	_current_player = arg_player
	
	_current_player.connect("request_rotate", self, "_on_current_player_request_rotate", [], CONNECT_PERSIST)
	
	
	CameraManager.generate_camera()
	CameraManager.set_camera_to_follow_node_2d(_current_player)
	

###

func _on_current_player_request_rotate(arg_rot_data : RotationRequestData):
	var angle = arg_rot_data.angle
	
	print("cam rotate to angle from request: %s" % rad2deg(angle))
	CameraManager.rotate_cam_to_rad(angle)


#

func _initialize_game_front_hud():
	game_front_hud = GameFrontHUD_Scene.instance()
	SingletonsAndConsts.current_game_front_hud = game_front_hud
	
	call_deferred("_deferred_add_child__game_front_hud")

func _deferred_add_child__game_front_hud():
	#get_tree().get_root().call_deferred("add_child", game_front_hud)
	get_tree().get_root().add_child(game_front_hud)


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

