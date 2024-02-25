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
const RectDrawNode = preload("res://MiscRelated/DrawRelated/RectDrawNode/RectDrawNode.gd")

const With2ndCenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/With2ndCenterBasedAttackSprite.gd")
const With2ndCenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/With2ndCenterBasedAttackSprite.tscn")
const StoreOfTrailType = preload("res://MiscRelated/TrailRelated/StoreOfTrailType.gd")
const MultipleTrailsForNodeComponent = preload("res://MiscRelated/TrailRelated/MultipleTrailsForNodeComponent.gd")


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


#var node_container_above_game_front_hud

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


#const BALL_FIRE_PARTICLE__COUNT__STR01 : int = 3
#const BALL_FIRE_PARTICLE__COUNT__STR02 : int = 5
#const BALL_FIRE_PARTICLE__COUNT__STR03 : int = 7
const BALL_FIRE_PARTICLE__ANGLE_RAND_ON_GROUND : float = PI/4
const BALL_FIRE_PARTICLE__ANGLE_RAND_ON_AIR : float = PI/2.5

const BALL_FIRE_PARTICLE__RAD_INITIAL : float = 1.0
const BALL_FIRE_PARTICLE__RAD_MID : float = 1.5
const BALL_FIRE_PARTICLE__RAD_FINAL : float = 0.0

const BALL_FIRE_PARTICLE__MOD_A_INITIAL : float = 0.2
const BALL_FIRE_PARTICLE__MOD_A_MID : float = 0.4
const BALL_FIRE_PARTICLE__MOD_A_FINAL : float = 0.0

const BALL_FIRE_PARTICLE__DURATION_TO_MID : float = 0.3
const BALL_FIRE_PARTICLE__DURATION_TO_FINAL : float = 0.65
const BALL_FIRE_PARTICLE__DURATION_TOTAL : float = BALL_FIRE_PARTICLE__DURATION_TO_MID + BALL_FIRE_PARTICLE__DURATION_TO_FINAL

var initialized_ball_fire_particle_circle_draw_node : bool
var _ball_fire_particle_circle_draw_node : Node2D

###

const PLAYER_TILE_COLL_PARTICLE__SPEED_RATIO_TO_LIN_VEL_CHANGE : float = 0.08

const PLAYER_TILE_COLL_PARTICLE__LEN_WIDTH_INITIAL : float = 2.0
const PLAYER_TILE_COLL_PARTICLE__LEN_WIDTH_MID : float = 4.0
const PLAYER_TILE_COLL_PARTICLE__LEN_WIDTH_FINAL : float = 0.0

const PLAYER_TILE_COLL_PARTICLE__MOD_A_INITIAL : float = 0.2
const PLAYER_TILE_COLL_PARTICLE__MOD_A_MID : float = 0.4
const PLAYER_TILE_COLL_PARTICLE__MOD_A_FINAL : float = 0.0

const PLAYER_TILE_COLL_PARTICLE__DURATION_TO_MID : float = 0.2
const PLAYER_TILE_COLL_PARTICLE__DURATION_TO_FINAL : float = 0.5
const PLAYER_TILE_COLL_PARTICLE__DURATION_TOTAL : float = PLAYER_TILE_COLL_PARTICLE__DURATION_TO_MID + PLAYER_TILE_COLL_PARTICLE__DURATION_TO_FINAL


const PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL : float = PI/12

var initialized_player_tile_collision_rect_draw_node : bool
var _player_tile_collision_rect_draw_node : Node2D

###

const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__COUNT : int = 8

const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__LEN_WIDTH_INITIAL : float = 1.0
const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__LEN_WIDTH_MID : float = 4.0
const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__LEN_WIDTH_FINAL : float = 0.0

const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__MOD_A_INITIAL : float = 0.2
const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__MOD_A_MID : float = 0.4
const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__MOD_A_FINAL : float = 0.0

const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__SPEED_INITIAL : float = 2.0
const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__SPEED_FINAL : float = 0.0

const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__MOD_MULTIPLIER_RAND_MAG : float = 0.15

const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__QUEUE__MIN_RAND_DELAY : float = 0.08
const PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__QUEUE__MAX_RAND_DELAY : float = 0.15


var node_2d_for_player_major_energy_spark_particle : Node2D
var player_major_energy_spark_particle_pool_component : AttackSpritePoolComponent
var trail_compo_for_player_major_energy_spark_particle : MultipleTrailsForNodeComponent

var _player_major_energy_spark_particle_queue_count : int
var _player_major_energy_spark_particle_delay_to_next : float


###

const LIN_SPEED_OF_FRAGMENT_PER_10 : float = 150.0

###

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
	
	call_deferred("init_player_tile_collision_particle_rect_draw_relateds")
	
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
	if _player_major_energy_spark_particle_queue_count > 0:
		_player_major_energy_spark_particle_delay_to_next -= delta
		
		if _player_major_energy_spark_particle_delay_to_next <= 0:
			if is_instance_valid(node_2d_for_player_major_energy_spark_particle):
				var repeat_count = (_player_major_energy_spark_particle_queue_count / 2) + 1
				for i in repeat_count:
					#play_player_major_energy_spark_particle__config_with_params(node_2d_for_player_major_energy_spark_particle.global_position)
					call_deferred("play_player_major_energy_spark_particle__config_with_params", node_2d_for_player_major_energy_spark_particle.global_position)
			
			_inc_randomized__player_major_energy_spark_particle_delay_to_next()
			
			_player_major_energy_spark_particle_queue_count -= 1
			if _player_major_energy_spark_particle_queue_count <= 0:
				stop_play_player_major_energy_spark_particle__queue()
	
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
	#TEST_game_insta_win with key: 0
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
		
		MouseManager.remove_all_input_mouse_reservations()
		MouseManager.remove_all_always_mouse_visible_reserve_id()
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

##########

#func init_node_container_above_game_front_hud():
#	if !is_game_front_hud_initialized:
#		return
#
#	node_container_above_game_front_hud = Node.new()
#
#	add_child(node_container_above_game_front_hud)
#
#	return node_container_above_game_front_hud

##########

func init_ball_fire_particle_circle_draw_relateds():
	if initialized_ball_fire_particle_circle_draw_node:
		return
	
	
	initialized_ball_fire_particle_circle_draw_node = true
	
	#
	
	_ball_fire_particle_circle_draw_node = Node2D.new()
	_ball_fire_particle_circle_draw_node.set_script(CircleDrawNode)
	add_child(_ball_fire_particle_circle_draw_node)

func summon_single_ball_fire_particle(arg_ball_fire_angle : float, arg_center_pos_basis : Vector2, arg_fill_color : Color, arg_particle_lin_vel : Vector2, arg_is_player_on_ground : bool):
	arg_fill_color.a = BALL_FIRE_PARTICLE__MOD_A_INITIAL
	
	var rand_radius_modif = SingletonsAndConsts.non_essential_rng.randf_range(-0.5, 0.75)
	var rand_angle
	if arg_is_player_on_ground:
		rand_angle = arg_ball_fire_angle + SingletonsAndConsts.non_essential_rng.randf_range(-BALL_FIRE_PARTICLE__ANGLE_RAND_ON_GROUND, BALL_FIRE_PARTICLE__ANGLE_RAND_ON_GROUND)
	else:
		rand_angle = arg_ball_fire_angle + SingletonsAndConsts.non_essential_rng.randf_range(-BALL_FIRE_PARTICLE__ANGLE_RAND_ON_AIR, BALL_FIRE_PARTICLE__ANGLE_RAND_ON_AIR)
	
	var rand_lifetime_modif = SingletonsAndConsts.non_essential_rng.randf_range(-0.25, 0.25)
	var rand_lifetime_modif__half = rand_lifetime_modif / 2
	
	#
	
	var draw_param = _ball_fire_particle_circle_draw_node.DrawParams.new()
	draw_param.center_pos = arg_center_pos_basis
	draw_param.current_radius = BALL_FIRE_PARTICLE__RAD_INITIAL + rand_radius_modif
	draw_param.radius_per_sec = 0
	draw_param.fill_color = arg_fill_color
	
	draw_param.outline_color = arg_fill_color #Color("#FFFFFF00")
	draw_param.outline_width = 0
	draw_param.lifetime_of_draw = BALL_FIRE_PARTICLE__DURATION_TOTAL + rand_lifetime_modif + 1.0
	draw_param.lifetime_to_start_transparency = 9999.0
	
	_ball_fire_particle_circle_draw_node.add_draw_param(draw_param)
	
	##
	
	var draw_tweener = create_tween()
	draw_tweener.set_parallel(true)
	# pos relateds
	var rand_dist = SingletonsAndConsts.non_essential_rng.randf_range(25, 60)
	var final_pos = arg_center_pos_basis + Vector2(rand_dist, 0).rotated(rand_angle + PI) + arg_particle_lin_vel
	draw_tweener.tween_property(draw_param, "center_pos", final_pos, BALL_FIRE_PARTICLE__DURATION_TOTAL + rand_lifetime_modif).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# mod a
	draw_tweener.tween_property(draw_param, "fill_color:a", BALL_FIRE_PARTICLE__MOD_A_MID, BALL_FIRE_PARTICLE__DURATION_TO_MID + rand_lifetime_modif__half)
	# radius
	draw_tweener.tween_property(draw_param, "current_radius", BALL_FIRE_PARTICLE__RAD_MID + rand_radius_modif, BALL_FIRE_PARTICLE__DURATION_TO_MID + rand_lifetime_modif__half)
	draw_tweener.set_parallel(false)

	###### DELAY
	draw_tweener.tween_interval(BALL_FIRE_PARTICLE__DURATION_TO_MID + rand_lifetime_modif__half)


	draw_tweener.set_parallel(true)
	# mod a
	draw_tweener.tween_property(draw_param, "fill_color:a", BALL_FIRE_PARTICLE__MOD_A_FINAL, BALL_FIRE_PARTICLE__DURATION_TO_FINAL + rand_lifetime_modif__half)
	# radius
	draw_tweener.tween_property(draw_param, "current_radius", BALL_FIRE_PARTICLE__RAD_FINAL, BALL_FIRE_PARTICLE__DURATION_TO_FINAL + rand_lifetime_modif__half)
	draw_tweener.set_parallel(false)
	
	
	
	return draw_param
	



func init_player_tile_collision_particle_rect_draw_relateds():
	if initialized_player_tile_collision_rect_draw_node:
		return
	
	initialized_player_tile_collision_rect_draw_node = true
	
	_player_tile_collision_rect_draw_node = Node2D.new()
	_player_tile_collision_rect_draw_node.set_script(RectDrawNode)
	add_child(_player_tile_collision_rect_draw_node)


func attempt_summon_player_tile_collision_particles__based_on_params(
		arg_player_lin_vel_diff : float, arg_player_lin_vel : Vector2,
		arg_modulate : Color,
		arg_player):
	
	var particle_count_per_side = _get_particle_count_per_side__based_on_param(arg_player_lin_vel_diff)
	if particle_count_per_side == 0:
		return
	
	var particle_play_offset : float = 1.0
	var pos_and_angle_details = arg_player.get_last_glob_and_rotation__pos_tile_collision__for_particle(particle_play_offset)
	var pos_of_coll = pos_and_angle_details[0]
	var angle_of_coll = pos_and_angle_details[1]
	
	var base_angle_for_left : float = angle_of_coll - PI/4 + PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL - PI/2
	var base_angle_for_right : float = angle_of_coll + PI/4 - PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL - PI/2
	
	var base_splash_speed = arg_player_lin_vel_diff * PLAYER_TILE_COLL_PARTICLE__SPEED_RATIO_TO_LIN_VEL_CHANGE
	
	#print("angle left: %s, angle right: %s, angle: %s" % [base_angle_for_left, base_angle_for_right, angle_of_coll])
	
	var non_essential_rng := SingletonsAndConsts.non_essential_rng
	
	#left
	for i in particle_count_per_side:
		var angle_modif = non_essential_rng.randf_range(-PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL, PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL)
		var angle__final_val = base_angle_for_left + angle_modif
		
		_summon_single_player_tile_collision_particle(pos_of_coll, angle__final_val, base_splash_speed, arg_modulate)
	
	#right
	for i in particle_count_per_side:
		var angle_modif = non_essential_rng.randf_range(-PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL, PLAYER_TILE_COLL_PARTICLE__ANGLE_OF_PARTICLE_FROM_COLL)
		var angle__final_val = base_angle_for_right + angle_modif
		
		_summon_single_player_tile_collision_particle(pos_of_coll, angle__final_val, base_splash_speed, arg_modulate)
	
	


func _get_particle_count_per_side__based_on_param(arg_player_lin_vel_diff):
	if arg_player_lin_vel_diff >= 300:
		return 3
	elif arg_player_lin_vel_diff >= 200:
		return 2
	elif arg_player_lin_vel_diff >= 100:
		return 1
	
	
	return 0



func _summon_single_player_tile_collision_particle(arg_final_val_center_pos : Vector2, arg_final_val_angle : float, 
		arg_speed : float, 
		arg_modulate : Color):
	
	var non_essential_rng := SingletonsAndConsts.non_essential_rng
	
	var lifetime_modif : float = non_essential_rng.randf_range(-0.15, 0.15)
	var lifetime__final_val = PLAYER_TILE_COLL_PARTICLE__DURATION_TOTAL + lifetime_modif
	
	var lifetime_to_mid__final_val = PLAYER_TILE_COLL_PARTICLE__DURATION_TO_MID + lifetime_modif/2
	var lifetime_to_final__final_val = PLAYER_TILE_COLL_PARTICLE__DURATION_TO_FINAL + lifetime_modif/2
	
	var speed_ratio_modif = non_essential_rng.randf_range(-0.1, 0.1)
	var speed__final_val = arg_speed + (arg_speed * speed_ratio_modif)
	
	var final_center_pos__final_calced_pos = Vector2(speed__final_val, 0).rotated(arg_final_val_angle) + arg_final_val_center_pos
	
	var mod_a_modif : float = non_essential_rng.randf_range(-0.1, 0.1)
	var mod_a_initial__final_val = PLAYER_TILE_COLL_PARTICLE__MOD_A_INITIAL + mod_a_modif
	var mod_a_mid__final_val = PLAYER_TILE_COLL_PARTICLE__MOD_A_MID + mod_a_modif
	arg_modulate.a = mod_a_initial__final_val
	
	var length_wid_modif : float = non_essential_rng.randf_range(-0.1, 0.1)
	var len_wid_initial__final_val = PLAYER_TILE_COLL_PARTICLE__LEN_WIDTH_INITIAL + length_wid_modif
	var len_wid_mid__final_val = PLAYER_TILE_COLL_PARTICLE__LEN_WIDTH_MID + length_wid_modif
	
	
	var draw_param : RectDrawNode.DrawParams = _construct_rect_draw_param__player_tile_collision_particle(arg_final_val_center_pos, arg_modulate, lifetime__final_val, len_wid_initial__final_val)
	_tween_player_tile_collision_rect_draw_param__using_params(draw_param, lifetime_to_mid__final_val, lifetime_to_final__final_val, final_center_pos__final_calced_pos, mod_a_mid__final_val, PLAYER_TILE_COLL_PARTICLE__MOD_A_FINAL, len_wid_mid__final_val, 0.0)
	

func _construct_rect_draw_param__player_tile_collision_particle(arg_center_pos : Vector2, arg_modulate : Color,
		 arg_lifetime : float, arg_length_width : float) -> RectDrawNode.DrawParams:
	
	#
	
	var draw_param = _player_tile_collision_rect_draw_node.DrawParams.new()
	
	draw_param.fill_color = arg_modulate
	
	draw_param.outline_color = arg_modulate
	draw_param.outline_width = 0
	
	draw_param.lifetime_to_start_transparency = -1
	draw_param.angle_rad = 0
	draw_param.lifetime_of_draw = arg_lifetime + 0.3
	draw_param.has_lifetime = true
	draw_param.pivot_point = Vector2(0, 0)
	
	var size = Vector2(arg_length_width, arg_length_width)
	var initial_rect = Rect2(arg_center_pos - (size/2), size)
	draw_param.initial_rect = initial_rect
	
	_player_tile_collision_rect_draw_node.add_draw_param(draw_param)
	
	return draw_param

func _tween_player_tile_collision_rect_draw_param__using_params(arg_rect_draw_param : RectDrawNode.DrawParams, 
		arg_lifetime_to_mid : float, arg_lifetime_from_mid_to_end : float,
		arg_final_center_pos : Vector2, 
		arg_mid_color_mod_a : float, arg_final_color_mod_a : float,
		arg_mid_length_width : float, arg_final_length_width : float):
	
	
	var full_lifetime = arg_lifetime_to_mid + arg_lifetime_from_mid_to_end
	
	var tweener = create_tween()
	tweener.set_parallel(true)
	tweener.tween_property(arg_rect_draw_param, "current_rect:position", arg_final_center_pos, full_lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tweener.tween_property(arg_rect_draw_param, "current_rect:size", Vector2(arg_mid_length_width, arg_mid_length_width), arg_lifetime_to_mid)
	tweener.tween_property(arg_rect_draw_param, "fill_color:a", arg_mid_color_mod_a, arg_lifetime_to_mid)
	tweener.set_parallel(false)
	
	tweener.tween_interval(arg_lifetime_to_mid)
	tweener.set_parallel(true)
	tweener.tween_property(arg_rect_draw_param, "current_rect:size", Vector2(arg_final_length_width, arg_final_length_width), arg_lifetime_from_mid_to_end)
	tweener.tween_property(arg_rect_draw_param, "fill_color:a", arg_final_color_mod_a, arg_lifetime_from_mid_to_end)
	


###

func initialize_all_player_major_energy_spark_particle_relateds():
	_initialize_player_major_energy_spark_particle_pool()
	_initialize_trail_compo_for_player_major_energy_spark()
	


func _initialize_player_major_energy_spark_particle_pool():
	player_major_energy_spark_particle_pool_component = AttackSpritePoolComponent.new()
	player_major_energy_spark_particle_pool_component.source_for_funcs_for_attk_sprite = self
	player_major_energy_spark_particle_pool_component.func_name_for_creating_attack_sprite = "_create_player_major_energy_spark_particle"
	player_major_energy_spark_particle_pool_component.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
	player_major_energy_spark_particle_pool_component.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster
	

func _create_player_major_energy_spark_particle():
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	#particle.center_pos_of_basis = arg_pos
	#particle.initial_speed_towards_center = -40
	#particle.speed_accel_towards_center = -20
	particle.min_starting_distance_from_center = 10
	particle.max_starting_distance_from_center = 16
	particle.texture_to_use = preload("res://PlayerRelated/PlayerParticles/EnergySpark/PlayerParticle_EnergySpark_White1x1.png") 
	particle.queue_free_at_end_of_lifetime = false
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.modulate.a = 0.0
	#particle.visible = true
	#particle.lifetime = 0.4
	
	return particle




func stop_play_player_major_energy_spark_particle__queue():
	_player_major_energy_spark_particle_delay_to_next = 0
	_player_major_energy_spark_particle_queue_count = 0

func play_player_major_energy_spark_particle__config_with_params_to_node_2d__queue_amount(arg_node_2d : Node2D, arg_count : int):
	node_2d_for_player_major_energy_spark_particle = arg_node_2d
	_inc_randomized__player_major_energy_spark_particle_delay_to_next()
	
	_player_major_energy_spark_particle_queue_count = arg_count

func _inc_randomized__player_major_energy_spark_particle_delay_to_next():
	_player_major_energy_spark_particle_delay_to_next += SingletonsAndConsts.non_essential_rng.randf_range(PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__QUEUE__MIN_RAND_DELAY, PLAYER_MAJOR_ENERGY_SPARK_PARTICLE__QUEUE__MAX_RAND_DELAY)


func play_player_major_energy_spark_particle__config_with_params(arg_pos : Vector2):
	var non_essential_rng = SingletonsAndConsts.non_essential_rng
	
	var particle : CenterBasedAttackSprite = player_major_energy_spark_particle_pool_component.get_or_create_attack_sprite_from_pool()
	particle.center_pos_of_basis = arg_pos
	
	
	particle.initial_speed_towards_center = non_essential_rng.randf_range(-55, -85)
	particle.speed_accel_towards_center = non_essential_rng.randf_range(-10, -30)
	particle.lifetime = non_essential_rng.randf_range(0.3, 0.5)
	particle.lifetime_to_start_transparency = non_essential_rng.randf_range(0.1, 0.2)
	particle.transparency_per_sec = 1 / (particle.lifetime - particle.lifetime_to_start_transparency)
	
	particle.reset_for_another_use()
	
	particle.visible = true
	
	#
	
	trail_compo_for_player_major_energy_spark_particle.create_trail_for_node(particle)


func _initialize_trail_compo_for_player_major_energy_spark():
	trail_compo_for_player_major_energy_spark_particle = MultipleTrailsForNodeComponent.new()
	trail_compo_for_player_major_energy_spark_particle.node_to_host_trails = self
	trail_compo_for_player_major_energy_spark_particle.trail_type_id = StoreOfTrailType.BASIC_TRAIL
	trail_compo_for_player_major_energy_spark_particle.connect("on_trail_before_attached_to_node", self, "_trail_before_attached_to_player_energy_spark_particle")
	

func _trail_before_attached_to_player_energy_spark_particle(arg_trail, arg_particle_node):
	var non_essential_rng = SingletonsAndConsts.non_essential_rng
	
	#
	
	arg_trail.max_trail_length = non_essential_rng.randi_range(7, 12)
	arg_trail.trail_color = Color("#FDC621") * non_essential_rng.randf_range(0.6, 1.0)
	arg_trail.trail_color.a = 0.7
	arg_trail.width = non_essential_rng.randi_range(1, 4)
	
	arg_trail.set_to_idle_and_available_if_node_is_not_visible = true



