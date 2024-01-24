extends Node

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")
const RotationRequestData = Player.RotationRequestData

const GameFrontHUD = preload("res://GameFrontHUDRelated/GameFrontHUD.gd")
const GameFrontHUD_Scene = preload("res://GameFrontHUDRelated/GameFrontHUD.tscn")
const GameBackground = preload("res://GameBackgroundRelated/GameBackground.gd")
const GameBackground_Scene = preload("res://GameBackgroundRelated/GameBackground.tscn")


const BaseLevel = preload("res://LevelRelated/Classes/BaseLevel.gd")


const CenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd")
const CenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.tscn")
const AttackSpritePoolComponent = preload("res://MiscRelated/AttackSpriteRelated/GenerateRelated/AttackSpritePoolComponent.gd")

const DamageParticle_Fragment_01 = preload("res://MiscRelated/CommonParticlesRelated/DamageParticles/DamageParticle_Shrapnel_01.png")
const DamageParticle_Fragment_02 = preload("res://MiscRelated/CommonParticlesRelated/DamageParticles/DamageParticle_Shrapnel_01.png")
const DamageParticle_Fragment_03 = preload("res://MiscRelated/CommonParticlesRelated/DamageParticles/DamageParticle_Shrapnel_01.png")

const CircleDrawNode = preload("res://MiscRelated/DrawRelated/CircleDrawNode/CircleDrawNode.gd")

#

signal before_game_start_init()
signal after_game_start_init()
signal before_game_quit()
signal quiting_game_by_queue_free__on_game_quit()

signal player_spawned(arg_player)

signal game_front_hud_initialized(arg_game_front_hud)
signal game_background_initialized(arg_game_background)

signal process__sig(arg_delta)
signal phy_process__sig(arg_delta)

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


var is_game_background_initialized : bool = false
var game_background : GameBackground

#

var pause_game_at_startup : bool = false

#

var object_lifespan__ball : float = -1
var object_lifespan__tile_fragment__from_base_tile__min : float = 6.0
var object_lifespan__tile_fragment__from_base_tile__max : float = 14.0

#

var _is_in_cutscene : bool

#

var node_2d_to_receive_cam_focus__at_ready_start : Node2D

#

var damage_particle_component_pool__fragment : AttackSpritePoolComponent
var damage_particle_texture_possibility_arr : Array

var _current_player_body_texture_id : int
var player_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments : Array


var initialized_enemy_killing_shockwave_relateds : bool
var _enemy_killing_shockwave_draw_node : Node2D

#

const LIN_SPEED_OF_FRAGMENT_PER_10 : float = 150.0

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
	#
	
	set_physics_process(false)
	
	GameSettingsManager.attempt_make_game_modifications__based_on_curr_assist_mode_config__before_all()
	
	_initialize_game_background()
	_initialize_game_front_hud()
	
	#
	
	world_manager.game_elements = self
	
	
	current_base_level = SingletonsAndConsts.current_base_level
	current_base_level.apply_modification_to_game_elements(self)
	world_manager.apply_slices_modification_to_game_elements__from_ready()
	
	player_modi_manager.game_elements = self
	if !is_instance_valid(_current_player):
		var player = world_manager.get_world_slice__can_spawn_player_when_no_current_player_in_GE().spawn_player_at_spawn_coords_index()
		player_container.add_child(player)
		_set_player__and_register_signals__at_ready(player)
		
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
	
	
	#
	
	_initialize_damage_particle_component_pool__all()
	_init_player_destroy_fragments_related()
	
	####
	
	emit_signal("before_game_start_init")
	
	call_deferred("_deferred__after_init")


func _deferred__after_init():
	is_game_after_init = true
	emit_signal("after_game_start_init")
	current_base_level.after_game_init()
	
	_attempt_start_GE_record_stats()

func _attempt_start_GE_record_stats():
	GameStatsManager.connect("start_of_GE_record_stats", self, "_on_start_of_GE_record_stats", [], CONNECT_ONESHOT)
	GameStatsManager.connect("before_end_of_GE_record_stats__for_last_chance_edits", self, "_on_before_end_of_GE_record_stats__for_last_chance_edits", [], CONNECT_ONESHOT)
	
	if SingletonsAndConsts.current_level_details.immediately_start_stats_record_on_GE_ready:
		GameStatsManager.start_GE_record_stats()
	

func _on_start_of_GE_record_stats():
	set_physics_process(true)

func _physics_process(delta):
	GameStatsManager.current_GE__time += delta
	emit_signal("phy_process__sig", delta)

func _on_before_end_of_GE_record_stats__for_last_chance_edits(arg_record_stats_as_win):
	set_physics_process(false)


#

func _process(delta):
	emit_signal("process__sig", delta)

###

func _set_player__and_register_signals__at_ready(arg_player : Player):
	_current_player = arg_player
	
	_current_player.connect("request_rotate", self, "_on_current_player_request_rotate", [], CONNECT_PERSIST)
	
	CameraManager.generate_camera()
	
	if !is_instance_valid(node_2d_to_receive_cam_focus__at_ready_start):
		give_camera_focus_and_follow_to_player()
	else:
		give_camera_focus_to_node(node_2d_to_receive_cam_focus__at_ready_start)

#

func give_camera_focus_and_follow_to_player():
	CameraManager.set_camera_to_follow_node_2d(_current_player)

func give_camera_focus_to_node(arg_node):
	CameraManager.set_camera_to_follow_node_2d(arg_node)

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

func _initialize_game_background():
	game_background = GameBackground_Scene.instance()
	SingletonsAndConsts.current_game_background = game_background
	
	call_deferred("_deferred_add_child__game_background")

func _deferred_add_child__game_background():
	add_child(game_background)
	move_child(game_background, 0)
	
	game_background.set_current_background_type(SingletonsAndConsts.current_level_details.background_type, true)
	
	is_game_background_initialized = true
	emit_signal("game_background_initialized", game_background)

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
		
	elif event.is_action_pressed("toggle_focus_mode"):
		if is_instance_valid(game_front_hud):
			game_front_hud.toggle_control_container_visibility__not_hides_mouse()
		
		
		
	#TEST action inputs
#	elif event.is_action_pressed("TEST_game_insta_win"):
#		var main_world_slice = world_manager.get_world_slice__can_spawn_player_when_no_current_player_in_GE()
#		main_world_slice.as_test__override__do_insta_win()


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
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		MouseManager.clear_all_requesters__for_mouse_normal_id()

func attempt_quit_game__by_queue_freeing():
	emit_signal("quiting_game_by_queue_free__on_game_quit")
	queue_free()


###############

func _initialize_damage_particle_component_pool__all():
	var is_not_initted = damage_particle_component_pool__fragment == null
	
	if is_not_initted:
		damage_particle_texture_possibility_arr = [
			DamageParticle_Fragment_01,
			DamageParticle_Fragment_02,
			DamageParticle_Fragment_03,
		]
		
		damage_particle_component_pool__fragment = AttackSpritePoolComponent.new()
		damage_particle_component_pool__fragment.source_for_funcs_for_attk_sprite = self
		damage_particle_component_pool__fragment.func_name_for_creating_attack_sprite = "_create_damage_particle__internal__fragment"
		damage_particle_component_pool__fragment.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
		damage_particle_component_pool__fragment.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster
	
	

func _create_damage_particle__internal__fragment():
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	#particle.center_pos_of_basis = arg_pos
	particle.initial_speed_towards_center = -60
	particle.speed_accel_towards_center = -40
	particle.min_starting_distance_from_center = 0
	particle.max_starting_distance_from_center = 2
	#particle.texture_to_use = preload("res://PlayerRelated/PlayerModi/Imps/LaunchBallRelated/LaunchBall_DestroyedBallParticles_White.png")
	particle.queue_free_at_end_of_lifetime = false
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.lifetime = 0.6
	particle.lifetime_to_start_transparency = 0.3
	particle.transparency_per_sec = 1 / (particle.lifetime - particle.lifetime_to_start_transparency)
	#particle.visible = true
	#particle.lifetime = 0.4
	
	return particle

func request_play_damage_particles_on_pos__fragment(arg_pos : Vector2, arg_modulate_to_use : Color):
	_play_damage_particles_on_pos__fragment(arg_pos, arg_modulate_to_use)

func _play_damage_particles_on_pos__fragment(arg_pos, arg_modulate_to_use):
	for i in 6:
		var particle : CenterBasedAttackSprite = damage_particle_component_pool__fragment.get_or_create_attack_sprite_from_pool()
		particle.center_pos_of_basis = arg_pos
		particle.modulate = arg_modulate_to_use
		#particle.texture = _get_random_texture_for_damage_particles__fragment()
		particle.set_texture_to_use(_get_random_texture_for_damage_particles__fragment())
		
		particle.reset_for_another_use()
		
		particle.lifetime = 0.4
		particle.visible = true


func _get_random_texture_for_damage_particles__fragment():
	return StoreOfRNG.randomly_select_one_element(damage_particle_texture_possibility_arr, SingletonsAndConsts.non_essential_rng)



### player destroy fragments related

func _init_player_destroy_fragments_related():
	_update_player_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments()
	GameSettingsManager.connect("player_aesth_config__body_texture_id__changed", self, "_on_player_aesth_config__body_texture_id__changed")

func _on_player_aesth_config__body_texture_id__changed(arg_id):
	if _current_player_body_texture_id != GameSettingsManager.player_aesth_config__body_texture_id:
		_update_player_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments()
	

func _update_player_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments():
	_current_player_body_texture_id = GameSettingsManager.player_aesth_config__body_texture_id
	
	var player_body_texture = GameSettingsManager.player_aesth__get_texture_of_body_texture_id(_current_player_body_texture_id)#get_current_player().main_body_sprite.get_body_texture()
	player_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments = TileConstants.generate_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments__for_any_no_save(player_body_texture, 16)
	


func deferred_generate_player_break_fragments(arg_top_left_pos, arg_center_pos):
	call_deferred("generate_player_break_fragments", arg_top_left_pos, arg_center_pos, get_current_player().main_body_sprite.get_body_modulate())

func generate_player_break_fragments(arg_top_left_pos, arg_center_pos, arg_modulate : Color):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		var fragments = TileConstants.generate_object_tile_fragments__for_any_no_save(arg_top_left_pos, player_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments, 20)
		for fragment in fragments:
			fragment.modulate = arg_modulate
			SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(fragment)
			
			_set_fragment_lin_vel_based_on_poses(fragment, arg_center_pos)
		

func _set_fragment_lin_vel_based_on_poses(arg_fragment : RigidBody2D, arg_center_pos : Vector2):
	var pos_of_frag = arg_fragment.global_position
	var dist_from_center = arg_center_pos.distance_to(pos_of_frag)
	var angle = arg_center_pos.angle_to_point(pos_of_frag)
	var speed = LIN_SPEED_OF_FRAGMENT_PER_10 * dist_from_center / 10
	
	var lin_vel = Vector2(speed, 0).rotated(angle)
	arg_fragment.linear_velocity = lin_vel


#

func generate_random_object_lifespan__tile_fragment__from_base_tile():
	return SingletonsAndConsts.non_essential_rng.randi_range(object_lifespan__tile_fragment__from_base_tile__min, object_lifespan__tile_fragment__from_base_tile__max)


##########

func initialize_all_enemy_killing_shockwave_relateds():
	if !initialized_enemy_killing_shockwave_relateds:
		initialized_enemy_killing_shockwave_relateds = true
		
		_enemy_killing_shockwave_draw_node = Node2D.new()
		_enemy_killing_shockwave_draw_node.set_script(CircleDrawNode)
		add_child(_enemy_killing_shockwave_draw_node)
	
	


func play_enemy_killing_shockwave_ring__custom_params(arg_origin, arg_initial_radius : float, arg_final_radius : float, arg_duration_to_full_radius : float, arg_color : Color):
	var arg_additional_lifetime = 0.2
	
	var draw_param = _enemy_killing_shockwave_draw_node.UpdateTickingDrawParams.new()
	
	draw_param.center_pos = arg_origin
	draw_param.current_radius = arg_initial_radius
	draw_param.max_radius = 9999
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = arg_color#Color(95/255.0, 131/255.0, 236/255.0, arg_mod_a)
	draw_param.outline_width = 4
	
	draw_param.lifetime_of_draw = arg_duration_to_full_radius + arg_additional_lifetime
	draw_param.has_lifetime = true
	
	draw_param.lifetime_to_start_transparency = arg_duration_to_full_radius
	
	#note: remove this if copypasting to others
	draw_param.can_emit_signal__current_radius_changed = true
	draw_param.tick_amount_per_reset = 6
	
	_enemy_killing_shockwave_draw_node.add_draw_param(draw_param)
	
	#
	
	#draw_param.connect("current_radius_changed", self, "_on_enemy_killing_shockwave_draw_param__curr_radius_changed", [draw_param])
	draw_param.connect("update_tick", self, "_on_enemy_killing_shockwave_draw_param__update_tick", [draw_param])
	
	var tweener = create_tween()
	tweener.tween_property(draw_param, "current_radius", arg_final_radius, arg_duration_to_full_radius).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweener.tween_property(draw_param, "current_radius", arg_final_radius + (arg_final_radius / 3.0), arg_additional_lifetime)
	tweener.tween_callback(self, "_on_enemy_killing_draw_param_finished_draw", [draw_param])


#func _on_enemy_killing_shockwave_draw_param__curr_radius_changed(arg_radius, arg_draw_param):
#	pass
#

func _on_enemy_killing_shockwave_draw_param__update_tick(arg_draw_param):
	_destory_enemies_based_on_draw_param(arg_draw_param)

func _on_enemy_killing_draw_param_finished_draw(arg_draw_param):
	_destory_enemies_based_on_draw_param(arg_draw_param)
	


func _destory_enemies_based_on_draw_param(arg_draw_param):
	var radius = arg_draw_param.current_radius
	var center_pos = arg_draw_param.center_pos
	
	for enemy in get_tree().get_nodes_in_group(SingletonsAndConsts.GROUP_NAME__BASE_ENEMY):
		var dist_from_center = enemy.global_position.distance_to(center_pos)
		if dist_from_center < radius:
			
			enemy.queue_free()
			enemy.play_damage_audio__on_death()

