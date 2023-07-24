extends "res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd"

const BaseAbility = preload("res://MiscRelated/AbilityRelated/BaseAbility.gd")

const PlayerModi_LaunchBall_Node = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall_Node.gd")
const PlayerModi_LaunchBall_Node_Scene = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall_Node.tscn")

const Object_Ball = preload("res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.gd")

##

var starting_launch_strength : float = 5000.0
var launch_strength_per_sec : float = 10000.0
var launch_strength_initial_delay : float = 0.75
var max_launch_strength : float = 15000.0

var launch_peak_wait_before_alternate : float = 2.0

#

var starting_ball_count : int
var ball_mass : float = 20.0


var _player
var _game_elements

var _current_ball_count : int
var _launch_ability : BaseAbility

#

var player_modi_launch_ball_node : PlayerModi_LaunchBall_Node

#

func _init().(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL):
	pass


######

func apply_modification_to_player_and_game_elements(arg_player, arg_game_elements):
	.apply_modification_to_player_and_game_elements(arg_player, arg_game_elements)
	
	#
	_player = arg_player
	_game_elements = arg_game_elements
	_current_ball_count = starting_ball_count
	
	arg_player.connect("unhandled_key_input_received", self, "_on_player_unhandled_key_input__for_modi")
	#arg_player.connect("body_shape_exited", self, "_on_body_shape_exited")
	
	_initialize_player_modi_launch_ball_node()

###

func _initialize_player_modi_launch_ball_node():
	player_modi_launch_ball_node = PlayerModi_LaunchBall_Node_Scene.instance()
	
	player_modi_launch_ball_node.set_node_to_follow(_player)
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(player_modi_launch_ball_node)
	#SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(player_modi_launch_ball_node)
	


######

func _on_player_unhandled_key_input__for_modi(event):
	#if !event.echo:
	if event.is_action_pressed("game_launch_ball"):
		_begin_charge_ball()
		
	elif event.is_action_released("game_launch_ball"):
		_attempt_launch_ball()
		

func _begin_charge_ball():
	player_modi_launch_ball_node.begin_launch_charge(starting_launch_strength, launch_strength_per_sec, max_launch_strength, launch_strength_initial_delay, launch_peak_wait_before_alternate)
	


func _attempt_launch_ball():
	player_modi_launch_ball_node.end_launch_charge()
	
	
	var ball_and_player_force = _calculate_launch_force_of_ball_and_player(player_modi_launch_ball_node.current_launch_force)
	
	_player.apply_inside_induced_force(ball_and_player_force[1])
	
	#
	
	_create_ball__and_launch_at_vector(_player.global_position, ball_and_player_force[0])

func _calculate_launch_force_of_ball_and_player(arg_launch_strength : float):
	var mouse_pos : Vector2 = _player.get_global_mouse_position()
	var angle = _player.global_position.angle_to_point(mouse_pos)
	var launch_vector = Vector2(arg_launch_strength, 0).rotated(angle)
	
	var ball_launch_vector = -launch_vector / ball_mass
	var player_launch_vector = launch_vector / _player.last_calculated_object_mass
	
	return [ball_launch_vector, player_launch_vector]


func _create_ball__and_launch_at_vector(arg_pos, arg_vec):
	var ball : Object_Ball = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.BALL)
	ball.base_object_mass = ball_mass
	ball.global_position = _player.global_position
	ball.connect("after_ready", self, "_on_ball_after_ready", [ball, arg_vec])
	
	_player.add_object_to_not_collide_with(ball)
	_player.add_objects_to_collide_with_after_exit(ball)
	_player.add_objects_to_add_mask_layer_collision_after_exit(ball)
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(ball)


func _on_ball_after_ready(ball, arg_vec):
	var body_state = Physics2DServer.body_get_direct_state(ball.get_rid())
	body_state.linear_velocity = arg_vec
	



#func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
#	if body


#####

func remove_modification_from_player_and_game_elements(arg_player, arg_ele):
	.remove_modification_from_player_and_game_elements(arg_player, arg_ele)
	
	arg_player.disconnect("unhandled_key_input_received", self, "_on_player_unhandled_key_input__for_modi")
	
	_uninit_player_modi_launch_ball_node()


func _uninit_player_modi_launch_ball_node():
	if is_instance_valid(player_modi_launch_ball_node) and !player_modi_launch_ball_node.is_queued_for_deletion():
		player_modi_launch_ball_node.queue_free()
	


