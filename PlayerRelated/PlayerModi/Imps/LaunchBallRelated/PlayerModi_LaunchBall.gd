extends "res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd"

const BaseAbility = preload("res://MiscRelated/AbilityRelated/BaseAbility.gd")

const PlayerModi_LaunchBall_Node = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall_Node.gd")
const PlayerModi_LaunchBall_Node_Scene = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall_Node.tscn")

const Object_Ball = preload("res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.gd")

#

signal current_ball_count_changed(arg_val)
signal infinite_ball_count_status_changed(arg_val)

##

var starting_launch_strength : float = 5000.0
var launch_strength_per_sec : float = 10000.0
var launch_strength_initial_delay : float = 0.75
var max_launch_strength : float = 15000.0

var launch_peak_wait_before_alternate : float = 2.0

#

var energy_consume_on_launch : float = 4.0

#

var starting_ball_count : int
var ball_mass : float = 40.0


var _player
var _game_elements

var _current_ball_count : int setget set_current_ball_count, get_current_ball_count

var is_infinite_ball_count : bool = false setget set_is_infinite_ball_count

#

var launch_ability : BaseAbility
var _is_launch_ability_ready : bool

const ACTIVATION_BLOCK_CLAUSE_ID__NO_BALLS_LEFT = -10
const ACTIVATION_BLOCK_CLAUSE_ID__NOT_ENOUGH_ENERGY = -11

#

var player_modi_launch_ball_node : PlayerModi_LaunchBall_Node

#

var show_player_trajectory_line : bool setget set_show_player_trajectory_line

#

func _init().(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL):
	pass


######

func apply_modification_to_player_and_game_elements(arg_player, arg_game_elements):
	.apply_modification_to_player_and_game_elements(arg_player, arg_game_elements)
	
	#
	_player = arg_player
	_game_elements = arg_game_elements
	
	arg_player.connect("unhandled_key_input_received", self, "_on_player_unhandled_key_input__for_modi")
	
	_construct_ability()
	_initialize_player_modi_launch_ball_node()
	
	#
	
	_add_self_to_ability_panel__front_hud()
	
	#
	
	set_current_ball_count(starting_ball_count)
	
	#
	
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	
	#_configure_to_player__with_energy_modi()
	call_deferred("_configure_to_player__with_energy_modi")

#

func _configure_to_player__with_energy_modi():
	if !_player.is_player_modi_energy_set:
		_game_elements.player_modi_manager.connect("modi_added_to_player", self, "_on_modi_added_to_player")
	else:
		_configure_with_energy_modi(_player.player_modi__energy)

func _on_modi_added_to_player(arg_modi):
	if arg_modi.modi_id == StoreOfPlayerModi.PlayerModiIds.ENERGY:
		_game_elements.player_modi_manager.disconnect("modi_added_to_player", self, "_on_modi_added_to_player")
		_configure_with_energy_modi(_player.player_modi__energy)
		


func _configure_with_energy_modi(arg_modi):
	arg_modi.connect("current_energy_changed", self, "_on_energy_modi_current_energy_changed")
	_update_self_based_on_current_energy_of_modi()

func _on_energy_modi_current_energy_changed(arg_val):
	_update_self_based_on_current_energy_of_modi()

func _update_self_based_on_current_energy_of_modi():
	if energy_consume_on_launch > _player.player_modi__energy.get_current_energy():
		launch_ability.activation_conditional_clauses.attempt_insert_clause(ACTIVATION_BLOCK_CLAUSE_ID__NOT_ENOUGH_ENERGY)
		
		if player_modi_launch_ball_node.is_charging_launch():
			player_modi_launch_ball_node.end_launch_charge()
			_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
		
	else:
		launch_ability.activation_conditional_clauses.remove_clause(ACTIVATION_BLOCK_CLAUSE_ID__NOT_ENOUGH_ENERGY)

####

func _construct_ability():
	launch_ability = BaseAbility.new()
	
	launch_ability.is_timebound = true
	
	launch_ability.connect("updated_is_ready_for_activation", self, "_on_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	_is_launch_ability_ready = launch_ability.is_ready_for_activation()

func _on_updated_is_ready_for_activation(arg_val):
	_is_launch_ability_ready = arg_val
	
	

#

func _initialize_player_modi_launch_ball_node():
	player_modi_launch_ball_node = PlayerModi_LaunchBall_Node_Scene.instance()
	
	player_modi_launch_ball_node.set_node_to_follow(_player)
	player_modi_launch_ball_node.launch_ability = launch_ability
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(player_modi_launch_ball_node)
	#SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(player_modi_launch_ball_node)
	
	player_modi_launch_ball_node.show_player_trajectory_line = show_player_trajectory_line


######

func _on_player_unhandled_key_input__for_modi(event):
	#if !event.echo:
	if _is_launch_ability_ready:
		if event.is_action_pressed("game_launch_ball"):
			_begin_charge_ball()
			
		elif event.is_action_released("game_launch_ball"):
			_attempt_launch_ball()
			

func _begin_charge_ball():
	player_modi_launch_ball_node.begin_launch_charge(starting_launch_strength, launch_strength_per_sec, max_launch_strength, launch_strength_initial_delay, launch_peak_wait_before_alternate)
	
	if _player.is_player_modi_energy_set:
		_player.player_modi__energy.set_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL, energy_consume_on_launch)
		


func _attempt_launch_ball():
	player_modi_launch_ball_node.end_launch_charge()
	
	
	var ball_and_player_force = _calculate_launch_force_of_ball_and_player(player_modi_launch_ball_node.current_launch_force)
	
	if !_player.is_on_ground():
		_player.apply_inside_induced_force(ball_and_player_force[1])
	
	#
	
	_create_ball__and_launch_at_vector(_player.global_position, ball_and_player_force[0])
	if !is_infinite_ball_count:
		set_current_ball_count(_current_ball_count - 1)
	
	#
	
	if _player.is_player_modi_energy_set:
		_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
		_player.player_modi__energy.dec_current_energy(energy_consume_on_launch)
	
	#
	
	SingletonsAndConsts.current_rewind_manager.attempt_set_rewindable_marker_data_at_next_frame(SingletonsAndConsts.current_rewind_manager.RewindMarkerData.LAUNCH_BALL)
	
	#
	
	var strength_factor_from_0_to_2 = player_modi_launch_ball_node.get_launch_force_as_range_from_0_to_2()
	var volume_ratio
	if strength_factor_from_0_to_2 == 0:
		volume_ratio = 0.33
	elif strength_factor_from_0_to_2 == 1:
		volume_ratio = 0.66
	else:
		volume_ratio = 1
	
	var launch_ball_sfx_id = StoreOfAudio.get_randomized_sfx_id__launch_ball()
	AudioManager.helper__play_sound_effect__2d__major(launch_ball_sfx_id, _player.global_position, volume_ratio, null)
	


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
	



#####

func remove_modification_from_player_and_game_elements(arg_player, arg_ele):
	.remove_modification_from_player_and_game_elements(arg_player, arg_ele)
	
	arg_player.disconnect("unhandled_key_input_received", self, "_on_player_unhandled_key_input__for_modi")
	
	_uninit_player_modi_launch_ball_node()


func _uninit_player_modi_launch_ball_node():
	if is_instance_valid(player_modi_launch_ball_node) and !player_modi_launch_ball_node.is_queued_for_deletion():
		player_modi_launch_ball_node.queue_free()
	

######

func set_current_ball_count(arg_count):
	_current_ball_count = arg_count
	
	if _current_ball_count < 0:
		_current_ball_count = 0
		
	
	if _current_ball_count == 0:
		launch_ability.activation_conditional_clauses.attempt_insert_clause(ACTIVATION_BLOCK_CLAUSE_ID__NO_BALLS_LEFT)
		
		if player_modi_launch_ball_node.is_charging_launch():
			player_modi_launch_ball_node.end_launch_charge()
			_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
		
	else:
		launch_ability.activation_conditional_clauses.remove_clause(ACTIVATION_BLOCK_CLAUSE_ID__NO_BALLS_LEFT)
	
	emit_signal("current_ball_count_changed", arg_count)

func get_current_ball_count():
	return _current_ball_count
	

#

func set_is_infinite_ball_count(arg_val):
	is_infinite_ball_count = arg_val
	
	emit_signal("infinite_ball_count_status_changed", arg_val)

#

func _add_self_to_ability_panel__front_hud():
	SingletonsAndConsts.current_game_front_hud.ability_panel.player_modi_launch_ball = self
	


#

func set_show_player_trajectory_line(arg_val):
	show_player_trajectory_line = arg_val
	
	if is_instance_valid(player_modi_launch_ball_node):
		player_modi_launch_ball_node.show_player_trajectory_line = show_player_trajectory_line

###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool


func get_rewind_save_state():
	return {
		"current_ball_count" : _current_ball_count,
		"is_infinite_ball_count" : is_infinite_ball_count,
		
		"launch_ability_save_state" : launch_ability.get_rewind_save_state(),
	}


func load_into_rewind_save_state(arg_state):
	set_current_ball_count(arg_state["current_ball_count"])
	set_is_infinite_ball_count(arg_state["is_infinite_ball_count"])
	launch_ability.load_into_rewind_save_state(arg_state["launch_ability_save_state"])
	

func destroy_from_rewind_save_state():
	pass
	

func restore_from_destroyed_from_rewind():
	pass
	


func stared_rewind():
	if player_modi_launch_ball_node.is_charging_launch():
		player_modi_launch_ball_node.end_launch_charge()
		_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
	
	

func ended_rewind():
	_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
	
	



