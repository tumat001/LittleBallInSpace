extends Node


const CenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd")
const CenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.tscn")
const AttackSpritePoolComponent = preload("res://MiscRelated/AttackSpriteRelated/GenerateRelated/AttackSpritePoolComponent.gd")


#

enum ObjectTypeIds {
	BALL = 0,
	TILE_FRAGMENT = 1,
	INTERACTABLE_BUTTON = 2,
	
	
	#######
	
	FRAGMENT__ENEMY_METALLIC = 10000
	
}


const BALL__MASS_NORMAL = 40.0

#

var _object_type_id_to_file_path_map : Dictionary


#

var destroyed_ball_particles_pool_component : AttackSpritePoolComponent

#

onready var PLAYER_COLLISION_SOUND_HIT : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_Player_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_Player_02,
	
]
onready var BALL_COLLISION_SOUND_HIT : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_Ball_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_Ball_02,
	
]

#onready var NONE_COLLISION_SOUND_HIT : Array = []


#######

onready var NONE__ANY_COLLISION_SOUND_LIST : Array = []

onready var FRAGMENT__ENEMY_METAILIC_SOUND_LIST := [
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_01,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_02,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_03,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_04,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_05,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_06,
]

onready var _object_id_to_fragment_collision_sound_list_map : Dictionary = {
	ObjectTypeIds.FRAGMENT__ENEMY_METALLIC : FRAGMENT__ENEMY_METAILIC_SOUND_LIST,
	
}


##

func _init():
	_object_type_id_to_file_path_map[ObjectTypeIds.BALL] = "res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.tscn"
	_object_type_id_to_file_path_map[ObjectTypeIds.TILE_FRAGMENT] = "res://ObjectsRelated/Objects/Imps/TileFragment/Object_TileFragment.tscn"
	_object_type_id_to_file_path_map[ObjectTypeIds.INTERACTABLE_BUTTON] = "res://ObjectsRelated/Objects/Imps/InteractableButton/Object_ButtonInteractable.tscn"
	

func construct_object(arg_id):
	var object = load(_object_type_id_to_file_path_map[arg_id]).instance()
	
	if arg_id == ObjectTypeIds.BALL:
		if is_instance_valid(SingletonsAndConsts.current_game_elements):
			var lifespan = SingletonsAndConsts.current_game_elements.object_lifespan__ball
			if lifespan != -1:
				object.has_finite_lifespan = true
				object.current_lifespan = lifespan
		
		object.base_object_mass = BALL__MASS_NORMAL
		object.connect("destroyed_self_caused_by_destroying_area_region", self, "_on_ball_destroyed_self_caused_by_destroying_area_region", [object])
	
	return object

###

func _ready():
	_initialize_destroyed_ball_particles_pool_component()
	SingletonsAndConsts.connect("current_game_elements_changed", self, "_on_current_game_elements_changed")
	_attempt_connect_with_current_GE()


func _on_current_game_elements_changed(arg_GE):
	#_attempt_connect_with_current_GE()
	call_deferred("_attempt_connect_with_current_GE")


func _attempt_connect_with_current_GE():
	if is_instance_valid(SingletonsAndConsts.current_game_elements):
		destroyed_ball_particles_pool_component.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
		destroyed_ball_particles_pool_component.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster
		


##### BALL SPECIFIC

func _initialize_destroyed_ball_particles_pool_component():
	destroyed_ball_particles_pool_component = AttackSpritePoolComponent.new()
	destroyed_ball_particles_pool_component.source_for_funcs_for_attk_sprite = self
	destroyed_ball_particles_pool_component.func_name_for_creating_attack_sprite = "_create_before_burst_stream_particle"
	#destroyed_ball_particles_pool_component.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
	#destroyed_ball_particles_pool_component.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster

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



#
func helper_ball__configure_as_enemy_ball_proj(arg_ball, arg_flat_dmg, arg_x_dmg__max_bonus_dmg_based_on_lin_vel):
	arg_ball.player_dmg__enabled = true
	arg_ball.enemy_dmg__enabled = false
	
	arg_ball.x_dmg__flat_dmg = arg_flat_dmg
	arg_ball.x_dmg__give_bonus_dmg_based_on_lin_vel = true
	arg_ball.x_dmg__max_bonus_dmg_based_on_lin_vel = arg_x_dmg__max_bonus_dmg_based_on_lin_vel
	arg_ball.anim_name_to_use = arg_ball.ANIM_NAME__ENEMY
	

func helper_ball__configure_as_player_ball_proj(arg_ball, arg_flat_dmg, arg_x_dmg__max_bonus_dmg_based_on_lin_vel):
	arg_ball.player_dmg__enabled = false
	arg_ball.enemy_dmg__enabled = true
	
	arg_ball.x_dmg__flat_dmg = arg_flat_dmg
	arg_ball.x_dmg__give_bonus_dmg_based_on_lin_vel = true
	arg_ball.x_dmg__max_bonus_dmg_based_on_lin_vel = arg_x_dmg__max_bonus_dmg_based_on_lin_vel

#
func helper_ball__launch_at_vec(arg_ball, arg_vec : Vector2):
	if arg_ball.is_inside_tree():
		_give_ball_veclocity(arg_ball, arg_vec)
	else:
		arg_ball.connect("after_ready", self, "_on_ball_after_ready__give_vel", [arg_ball, arg_vec])
	

func _on_ball_after_ready__give_vel(arg_ball, arg_vec : Vector2):
	_give_ball_veclocity(arg_ball, arg_vec)

func _give_ball_veclocity(ball, arg_vec):
	var body_state = Physics2DServer.body_get_direct_state(ball.get_rid())
	body_state.linear_velocity = arg_vec
	

#
func helper_ball__ignore_first_collision_with_body(arg_ball, arg_body):
	arg_body.add_object_to_not_collide_with(arg_ball)
	arg_body.add_objects_to_collide_with_after_exit(arg_ball)
	arg_body.add_objects_to_add_mask_layer_collision_after_exit(arg_ball)
	


####################
# COLLISION SOUND

func get_ball_collision__with_player__sound_list():
	return PLAYER_COLLISION_SOUND_HIT

func get_ball_collision__with_ball__sound_list():
	return BALL_COLLISION_SOUND_HIT




func get_object_id_to_fragment_collision_sound_list(arg_id):
	if _object_id_to_fragment_collision_sound_list_map.has(arg_id):
		return _object_id_to_fragment_collision_sound_list_map[arg_id]
	else:
		return NONE__ANY_COLLISION_SOUND_LIST
	
	


