extends "res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd"

const BaseAbility = preload("res://MiscRelated/AbilityRelated/BaseAbility.gd")

const PlayerModi_LaunchBall_Node = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall_Node.gd")
const PlayerModi_LaunchBall_Node_Scene = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/PlayerModi_LaunchBall_Node.tscn")

const Object_Ball = preload("res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.gd")

##

const CenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd")
const CenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.tscn")
const AttackSpritePoolComponent = preload("res://MiscRelated/AttackSpriteRelated/GenerateRelated/AttackSpritePoolComponent.gd")

#

signal current_ball_count_changed(arg_val)
signal infinite_ball_count_status_changed(arg_val)

signal can_change_aim_mode_changed(arg_val)

##

# if changing this, look at dmg calculation of BaseEnemy _calc_damage_of_obj_ball
var starting_launch_strength : float = 5000.0  #125
var launch_strength_per_sec : float = 10000.0    #250
var launch_strength_initial_delay : float = 0.75
var max_launch_strength : float = 15000.0   #375

var launch_peak_wait_before_alternate : float = 2.0

var button_factor_to_strength_gain_ratio : float = (max_launch_strength - starting_launch_strength) / 10.0

#

#const allow_mouse_scroll_to_modify_strength : bool = true

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
const ACTIVATION_BLOCK_CLAUSE_ID__BLOCK_PLAYER_GAME_ACTIONS = -12

#

var player_modi_launch_ball_node : PlayerModi_LaunchBall_Node
var can_change_aim_mode : bool = true setget set_can_change_aim_mode


#

var show_player_trajectory_line : bool setget set_show_player_trajectory_line

#

var destroyed_ball_particles_pool_component : AttackSpritePoolComponent

#

var is_class_type_player_modi_launch_ball : bool = true

#

#var BALL_GROUP_ID = "Object_LaunchBallGroup"
#var active_ball_count : int

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
	arg_player.connect("unhandled_mouse_button_input_received", self, "_on_player_unhandled_mouse_button_input_received__for_modi")
	arg_player.connect("last_calc_block_player_game_actions_changed", self, "_on_player_last_calc_block_player_game_actions_changed")
	
	_construct_ability()
	_initialize_player_modi_launch_ball_node()
	
	#
	
	_add_self_to_ability_panel__front_hud()
	
	#
	
	set_current_ball_count(starting_ball_count)
	
	#
	
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	
	#
	
	_initialize_destroyed_ball_particles_pool_component()
	
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
		cancel_modi_launch_ball_charge()
		
	else:
		launch_ability.activation_conditional_clauses.remove_clause(ACTIVATION_BLOCK_CLAUSE_ID__NOT_ENOUGH_ENERGY)



func _on_player_last_calc_block_player_game_actions_changed(arg_val):
	if arg_val:
		launch_ability.activation_conditional_clauses.attempt_insert_clause(ACTIVATION_BLOCK_CLAUSE_ID__BLOCK_PLAYER_GAME_ACTIONS)
		cancel_modi_launch_ball_charge()
		
	else:
		launch_ability.activation_conditional_clauses.remove_clause(ACTIVATION_BLOCK_CLAUSE_ID__BLOCK_PLAYER_GAME_ACTIONS)
		



func cancel_modi_launch_ball_charge():
	if player_modi_launch_ball_node.is_charging_launch():
		player_modi_launch_ball_node.end_launch_charge()
		_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
	
	


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
	
	player_modi_launch_ball_node.show_player_trajectory_line = show_player_trajectory_line
	player_modi_launch_ball_node.connect("can_change_aim_mode_changed", self, "_on_can_change_aim_mode_changed")
	
	player_modi_launch_ball_node.connect("ended_launch_charge", self, "_on_modi_launch_ball_node__ended_launch_charge")
	
	set_can_change_aim_mode(can_change_aim_mode)

func _on_can_change_aim_mode_changed(arg_val):
	emit_signal("can_change_aim_mode_changed", arg_val)


func _on_modi_launch_ball_node__ended_launch_charge():
	MouseManager.remove_request_change_mouse_normal_id(self)

######


func _on_player_unhandled_mouse_button_input_received__for_modi(event : InputEventMouseButton):
	if _is_launch_ability_ready:
		if event.button_index == BUTTON_LEFT and !event.is_echo() and !event.doubleclick:
			if event.pressed:
				_attempt_begin_charge_ball()
			else:
				_attempt_launch_ball()
			
			###
		if GameSettingsManager.last_calc__unlocked_status__mouse_scroll_launch_ball and player_modi_launch_ball_node.is_charging_launch():
			if event.button_index == BUTTON_WHEEL_UP:
				player_modi_launch_ball_node.increment_current_launch__from_using_mouse_wheel(_calculate_increment_using_wheel_factor(event.factor) * 1)
				
			elif event.button_index == BUTTON_WHEEL_DOWN:
				player_modi_launch_ball_node.increment_current_launch__from_using_mouse_wheel(_calculate_increment_using_wheel_factor(event.factor) * -1)


func _calculate_increment_using_wheel_factor(arg_factor : float):
	return button_factor_to_strength_gain_ratio * arg_factor

#

func _on_player_unhandled_key_input__for_modi(event):
	if _is_launch_ability_ready:
		if event.is_action_pressed("game_launch_ball"):
			_attempt_begin_charge_ball()
			
		elif event.is_action_released("game_launch_ball"):
			_attempt_launch_ball()
			

func _attempt_begin_charge_ball():
	if !player_modi_launch_ball_node.is_charging_launch():
		player_modi_launch_ball_node.begin_launch_charge(starting_launch_strength, launch_strength_per_sec, max_launch_strength, launch_strength_initial_delay, launch_peak_wait_before_alternate)
		
		if _player.is_player_modi_energy_set:
			_player.player_modi__energy.set_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL, energy_consume_on_launch)
			
		
		_player.player_face.play_sequence__charging_launch_ball()
		
		MouseManager.request_change_mouse_normal_id(self, MouseManager.MouseNormalSpriteTypeId.TARGET_RETICLE)


func _attempt_launch_ball():
	if player_modi_launch_ball_node.is_charging_launch():
		player_modi_launch_ball_node.end_launch_charge()
		
		
		var ball_and_player_force = _calculate_launch_force_of_ball_and_player(player_modi_launch_ball_node.current_launch_force)
		
		if !_player.is_on_ground():
			_player.apply_inside_induced_force__with_counterforce_speed_if_applicable(ball_and_player_force[1])
		
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
		AudioManager.helper__play_sound_effect__2d(launch_ball_sfx_id, _player.global_position, volume_ratio, null)
		
		if GameStatsManager.is_started_GE_record_stats():
			GameStatsManager.current_GE__balls_shot_count += 1


func force_launch_ball_at_pos__min_speed(arg_pos):
	var angle_to_use = _player.global_position.angle_to_point(arg_pos)
	var ball_and_player_force = _calculate_launch_force_of_ball_and_player__using_angle(starting_launch_strength, angle_to_use)
	
	var ball = _create_ball__and_launch_at_vector(_player.global_position, ball_and_player_force[0])
	
	SingletonsAndConsts.current_rewind_manager.attempt_set_rewindable_marker_data_at_next_frame(SingletonsAndConsts.current_rewind_manager.RewindMarkerData.LAUNCH_BALL)
	
	return ball


func _calculate_launch_force_of_ball_and_player(arg_launch_strength : float):
	#var mouse_pos : Vector2 = _player.get_global_mouse_position()
	#var angle = _player.global_position.angle_to_point(mouse_pos)
	var angle = player_modi_launch_ball_node.last_calc_angle_of_node_to_mouse
	return _calculate_launch_force_of_ball_and_player__using_angle(arg_launch_strength, angle)

func _calculate_launch_force_of_ball_and_player__using_angle(arg_launch_strength : float, angle):
	var launch_vector = Vector2(arg_launch_strength, 0).rotated(angle)
	
	var ball_launch_vector = -launch_vector / ball_mass
	var player_launch_vector = launch_vector / _player.last_calculated_object_mass
	
	return [ball_launch_vector, player_launch_vector]
	



func _create_ball__and_launch_at_vector(arg_pos, arg_vec):
	var ball = create_ball__for_any_use(false)
	ball.global_position = _player.global_position
	ball.connect("after_ready", self, "_on_ball_after_ready__give_vel", [ball, arg_vec])
	
	_player.add_object_to_not_collide_with(ball)
	_player.add_objects_to_collide_with_after_exit(ball)
	_player.add_objects_to_add_mask_layer_collision_after_exit(ball)
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(ball)
	
	return ball

func create_ball__for_any_use(arg_add_child : bool) -> Object_Ball:
	var ball : Object_Ball = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.BALL)
	ball.base_object_mass = ball_mass
	
	if !is_infinite_ball_count:
		ball.randomize_color_modulate__except_red()
	else:
		ball.tween_rainbow_color()
	
	ball.connect("destroyed_self_caused_by_destroying_area_region", self, "_on_ball_destroyed_self_caused_by_destroying_area_region", [ball])
	#ball.connect()
	#ball.connect("restore_from_destroyed_from_rewind", self, "_on_ball_restore_from_destroyed_from_rewind", [ball])
	
	if arg_add_child:
		SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(ball)
	
	#active_ball_count += 1
	#ball.add_to_group(BALL_GROUP_ID)
	#_adjust_balls_volume_ratio_based_on_balls_in_game()
	
	return ball

#func _adjust_balls_volume_ratio_based_on_balls_in_game():
#	pass
#



func _on_ball_after_ready__give_vel(ball, arg_vec):
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
		if launch_ability != null:
			launch_ability.activation_conditional_clauses.remove_clause(ACTIVATION_BLOCK_CLAUSE_ID__NO_BALLS_LEFT)
	
	emit_signal("current_ball_count_changed", arg_count)

func decrement_ball_count_by_one():
	set_current_ball_count(_current_ball_count - 1)

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

#

func _initialize_destroyed_ball_particles_pool_component():
	destroyed_ball_particles_pool_component = AttackSpritePoolComponent.new()
	destroyed_ball_particles_pool_component.source_for_funcs_for_attk_sprite = self
	destroyed_ball_particles_pool_component.func_name_for_creating_attack_sprite = "_create_before_burst_stream_particle"
	destroyed_ball_particles_pool_component.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
	destroyed_ball_particles_pool_component.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster

func _create_before_burst_stream_particle():
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	#particle.center_pos_of_basis = arg_pos
	particle.initial_speed_towards_center = -40
	particle.speed_accel_towards_center = -20
	particle.min_starting_distance_from_center = 0
	particle.max_starting_distance_from_center = 2
	particle.texture_to_use = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/LaunchBall_DestroyedBallParticles_White.png")
	particle.queue_free_at_end_of_lifetime = false
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.lifetime = 0.4
	particle.lifetime_to_start_transparency = 0.2
	particle.transparency_per_sec = 1 / (particle.lifetime - particle.lifetime_to_start_transparency)
	#particle.visible = true
	#particle.lifetime = 0.4
	
	return particle

func _on_ball_destroyed_self_caused_by_destroying_area_region(arg_area_region, arg_ball):
	_play_particles_on_pos(arg_ball.global_position, arg_ball.modulate)

func _play_particles_on_pos(arg_pos, arg_modulate_to_use):
	for i in 6:
		var particle : CenterBasedAttackSprite = destroyed_ball_particles_pool_component.get_or_create_attack_sprite_from_pool()
		particle.center_pos_of_basis = arg_pos
		particle.modulate = arg_modulate_to_use
		
		particle.reset_for_another_use()
		
		particle.lifetime = 0.4
		particle.visible = true


#func _on_ball_restore_from_destroyed_from_rewind(ball):
#	_adjust_balls_volume_ratio_based_on_balls_in_game()
#

#######

func set_can_change_aim_mode(arg_val):
	can_change_aim_mode = arg_val
	
	if is_instance_valid(player_modi_launch_ball_node):
		player_modi_launch_ball_node.can_change_aim_mode = arg_val
	

###########


func make_assist_mode_modification__additional_launch_ball():
	var launch_ball_details = GameSettingsManager.get_assist_mode__additional_launch_ball_details_from_current_id()
	set_current_ball_count(_current_ball_count + launch_ball_details[0])
	
	if launch_ball_details[1]:
		if !is_infinite_ball_count:
			set_is_infinite_ball_count(true)


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
	


func started_rewind():
	if player_modi_launch_ball_node.is_charging_launch():
		player_modi_launch_ball_node.end_launch_charge()
		_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
	
	

func ended_rewind():
	_player.player_modi__energy.remove_forecasted_energy_consume(_player.player_modi__energy.ForecastConsumeId.LAUNCH_BALL)
	
	



