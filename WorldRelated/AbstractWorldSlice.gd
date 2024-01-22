
# ALTHOUGH many abstract world slices can be added in a GE,
# the coin functionality prevents that....
extends Node2D


const CenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd")
const CenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.tscn")
const With2ndCenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/With2ndCenterBasedAttackSprite.gd")
const With2ndCenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/With2ndCenterBasedAttackSprite.tscn")
const StoreOfTrailType = preload("res://MiscRelated/TrailRelated/StoreOfTrailType.gd")
const MultipleTrailsForNodeComponent = preload("res://MiscRelated/TrailRelated/MultipleTrailsForNodeComponent.gd")
const AttackSpritePoolComponent = preload("res://MiscRelated/AttackSpriteRelated/GenerateRelated/AttackSpritePoolComponent.gd")

const TextureMethodHelper = preload("res://MiscRelated/TextureRelated/TextureMethodHelper.gd")


#

const Player = preload("res://PlayerRelated/Player.gd")
const Player_Scene = preload("res://PlayerRelated/Player.tscn")

#

signal player_spawned(arg_player)


signal all_PCA_region_areas_captured()
signal all_PCA_region_areas_uncaptured()

signal PCA_region_area_captured(arg_region)
signal PCA_region_area_uncaptured(arg_region)

########

var _player_global_spawn_coords : Array

var can_spawn_player_when_no_current_player_in_GE : bool

var world_id

var game_elements setget set_game_elements

#

var _all_win_type_player_capture_area_region_to_is_captured_map : Dictionary

#

var _is_all_pca_regions_captured : bool = false

#

var _next_available_coin_id : int = 1

#

var is_player_capture_area_style_one_at_a_time__in_node_order : bool
var _current_pca_index : int

#

var _coin_audio_player : AudioStreamPlayer

#

var _all_imp_cutscene_item_particles : Array
var _item_particle_reached_dest_count : int
var _current_item_cutscene_param : PickupImportantItemCutsceneParam

var _ICIP_func_source
var _ICIP_func_name
var _ICIP_func_param

#

var _shader_mat__capture_type_win : ShaderMaterial
var _shader_mat__clear_player : ShaderMaterial
var _shader_mat__obj_destroying : ShaderMaterial

#

var star_pickup_particles_pool_component : AttackSpritePoolComponent
var trail_compo_for_star_pickup_particle : MultipleTrailsForNodeComponent

var module_x_pickup_particles_pool_component : AttackSpritePoolComponent
var trail_compo_for_module_x_pickup_particle : MultipleTrailsForNodeComponent

#

onready var tile_container = $TileContainer
onready var object_container = $ObjectContainer
onready var player_spawn_coords_container = $PlayerSpawnCoordsContainer
onready var area_region_container = $AreaRegionContainer
onready var coins_container = $CoinsContainer
onready var lights_container = $LightsContainer

####

func set_game_elements(arg_elements):
	game_elements = arg_elements
	
	game_elements.connect("before_game_start_init", self, "_on_before_game_start_init", [], CONNECT_ONESHOT)
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided__base")
	
	if !game_elements.is_game_after_init:
		game_elements.connect("after_game_start_init", self, "_on_after_game_start_init", [], CONNECT_ONESHOT)
	else:
		_on_after_game_start_init()


#

func _ready():
	_initialize_spawn_coords()
	#_initialize_coins()
	_initialize_base_tilesets()
	_attempt_init_player_capture_area_style_to_one_at_a_time()
	call_deferred("_deferred_initialize_game_background_configs_related")
	call_deferred("_init_all_star_pickup_related")

func _initialize_spawn_coords():
	for child in player_spawn_coords_container.get_children():
		_player_global_spawn_coords.append(child.global_position)


#

func spawn_player_at_spawn_coords_index(arg_i = 0):
	var player = Player_Scene.instance()
	
	var spawn_pos = _player_global_spawn_coords[arg_i]
	player.global_position = global_position + spawn_pos
	
	_before_player_spawned_signal_emitted__chance_for_changes(player)
	
	emit_signal("player_spawned", player)
	
	return player

func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	pass


####

func _apply_modification_to_game_elements():
	pass

func _on_before_game_start_init():
	pass

func _on_after_game_start_init():
	_attempt_set_player__to_all_base_tiles()
	_initialize_area_regions()
	
	if _is_all_PCAs_are_captured():
		_on_all_PCAs_captured()
	
	_initialize_coins()

func _initialize_area_regions():
	for child in area_region_container.get_children():
		#child.set_game_elements(game_elements)
		_add_and_register_area_region(child)

func _add_and_register_area_region(arg_region):
	if !area_region_container.get_children().has(arg_region):
		area_region_container.add_child(arg_region)
	
	arg_region.set_game_elements(game_elements)
	
	if arg_region.get("is_player_capture_area_region"):
		if arg_region.is_capture_type_win:
			_config_area_region__PCAR_of_win_type(arg_region)
		
		
	elif arg_region.get("is_player_clear_area_region"):
		_config_area_region__player_clear(arg_region)
		
	elif arg_region.get("is_object_destroying_area_region"):
		_config_area_region__object_destroying(arg_region)
		
	

#

func _config_area_region__PCAR_of_win_type(arg_region):
	_all_win_type_player_capture_area_region_to_is_captured_map[arg_region] = false
	
	arg_region.connect("region_area_captured", self, "_on_PCA_region_area_captured", [arg_region])
	arg_region.connect("region_area_uncaptured", self, "_on_PCA_region_area_uncaptured", [arg_region])
	
	###
	
	_add_shine_shader_material_to_region__capture_type_win(arg_region)


func _add_shine_shader_material_to_region__capture_type_win(arg_region):
	_attempt_init_shader_mat__capture_type_win()
	
	#arg_region.construct_and_add_sprite_for_shader(_shader_mat__capture_type_win)
	arg_region.add_shader_to_collshape(_shader_mat__capture_type_win)

func _attempt_init_shader_mat__capture_type_win():
	if _shader_mat__capture_type_win == null:
		_shader_mat__capture_type_win = ShaderMaterial.new()
		_shader_mat__capture_type_win.shader = load("res://MiscRelated/ShadersRelated/Shader_Shine.tres")

#

func _config_area_region__player_clear(arg_region):
	_add_clear_shockwave_shader_material_to_region(arg_region)

func _add_clear_shockwave_shader_material_to_region(arg_region):
	_attempt_init_shader_mat__player_clear_region()
	
	arg_region.construct_and_add_sprite_for_shader(_shader_mat__clear_player)
	#arg_region.add_shader_to_collshape(_shader_mat__clear_player)
	

func _attempt_init_shader_mat__player_clear_region():
	if _shader_mat__clear_player == null:
		_shader_mat__clear_player = ShaderMaterial.new()
		_shader_mat__clear_player.shader = load("res://MiscRelated/ShadersRelated/Shader_ShockwaveForClear.tres")
	

#

func _config_area_region__object_destroying(arg_region):
	if !arg_region.is_hidden_and_silent:
		_add_obj_destroying_shader_material_to_region(arg_region)

func _add_obj_destroying_shader_material_to_region(arg_region):
	_attempt_init_shader_mat__obj_destroying_region()
	
	arg_region.construct_and_add_sprite_for_shader(_shader_mat__obj_destroying)
	#arg_region.add_shader_to_collshape(_shader_mat__obj_destroying)

func _attempt_init_shader_mat__obj_destroying_region():
	if _shader_mat__obj_destroying == null:
		_shader_mat__obj_destroying = ShaderMaterial.new()
		_shader_mat__obj_destroying.shader = load("res://MiscRelated/ShadersRelated/Shader_SpeedlinesForObjDestrRegion.tres")
	


##########

func _on_PCA_region_area_captured(arg_region):
	_all_win_type_player_capture_area_region_to_is_captured_map[arg_region] = true
	emit_signal("PCA_region_area_captured", arg_region)
	if _is_all_PCAs_are_captured():
		_on_all_PCAs_captured()

func _on_PCA_region_area_uncaptured(arg_region):
	_all_win_type_player_capture_area_region_to_is_captured_map[arg_region] = false
	emit_signal("PCA_region_area_uncaptured", arg_region)
	
	var old_val = _is_all_pca_regions_captured
	_is_all_pca_regions_captured = false
	if old_val != _is_all_pca_regions_captured:
		emit_signal("all_PCA_region_areas_uncaptured")


func _is_all_PCAs_are_captured():
	for PCA_region in _all_win_type_player_capture_area_region_to_is_captured_map.keys():
		if !PCA_region.is_area_captured():
			return false
	
	return true

func _on_all_PCAs_captured():
	_is_all_pca_regions_captured = true
	
	#print("ABSTRACT_WORLD_SLICE: all pcas captured")
	emit_signal("all_PCA_region_areas_captured")


func is_all_PCA_regions_captured():
	return _is_all_pca_regions_captured


func get_all_win_type_player_capture_area_region_to_is_captured_map():
	return _all_win_type_player_capture_area_region_to_is_captured_map


##

func _initialize_coins():
	var coin_count = coins_container.get_child_count()
	
	for coin in coins_container.get_children():
		_configure_coin(coin)
	
	var curr_level_id = SingletonsAndConsts.current_base_level_id
	if coin_count != StoreOfLevels.get_coin_count_for_level(curr_level_id):
		print("level with id %s not having the correct star amount." % [curr_level_id])


func _configure_coin(arg_coin):
	arg_coin.coin_id = str(_next_available_coin_id)
	_next_available_coin_id += 1
	
	if GameSaveManager.is_coin_id_collected_in_level(arg_coin.coin_id, SingletonsAndConsts.current_base_level_id):
		arg_coin.visible = false
		arg_coin.queue_free()
		
		GameSaveManager.set_tentative_coin_id_collected_in_curr_level(arg_coin.coin_id, true)
	else:
		
		if GameSettingsManager.is_assist_mode_active:
			arg_coin.configure_self_as_assist_mode_is_active()
		
		GameSaveManager.set_tentative_coin_id_collected_in_curr_level(arg_coin.coin_id, false)
	
	arg_coin.connect("collected_by_player", self, "_on_coin_collected_by_player", [arg_coin])
	arg_coin.connect("uncollected_by_player", self, "_on_coin_uncollected_by_player", [arg_coin])


#########

func _attempt_set_player__to_all_base_tiles():
	var player = game_elements.get_current_player()
	
	if is_instance_valid(player):
		if game_elements.is_connected("player_spawned", self, "_on_GE_player_spawned"):
			game_elements.disconnect("player_spawned", self, "_on_GE_player_spawned")
		
		for child in tile_container.get_children():
			child.set_player(player)
		
	else:
		if !game_elements.is_connected("player_spawned", self, "_on_GE_player_spawned"):
			game_elements.connect("player_spawned", self, "_on_GE_player_spawned")
		

func _on_GE_player_spawned(arg_player):
	_attempt_set_player__to_all_base_tiles()


##

func _initialize_base_tilesets():
	for child in tile_container.get_children():
		child.set_light_2d_glowables_node_2d_container(lights_container)


#########################

func set_true__is_player_capture_area_style_one_at_a_time__in_node_order__from_not_ready():
	if !is_player_capture_area_style_one_at_a_time__in_node_order:
		is_player_capture_area_style_one_at_a_time__in_node_order = true
		_set_player_capture_area_style_to_one_at_a_time()

func _attempt_init_player_capture_area_style_to_one_at_a_time():
	if is_player_capture_area_style_one_at_a_time__in_node_order:
		_set_player_capture_area_style_to_one_at_a_time()
	

func _set_player_capture_area_style_to_one_at_a_time():
	var index = 0
	_current_pca_index = 0
	
	for arg_region in area_region_container.get_children():
		if arg_region.get("is_player_capture_area_region"):
			if arg_region.is_capture_type_win:
				arg_region.connect("region_area_captured", self, "_on_PCA_region_area_captured__for_one_at_a_time_tracking", [arg_region])
				arg_region.connect("region_area_uncaptured", self, "_on_PCA_region_area_uncaptured__for_one_at_a_time_tracking", [arg_region])
				
				arg_region.visible = false
				
				if arg_region.is_area_captured():
					_current_pca_index = index + 1
				index += 1
	


func _on_PCA_region_area_captured__for_one_at_a_time_tracking(curr_pca):
	_current_pca_index += 1
	if _all_win_type_player_capture_area_region_to_is_captured_map.size() > _current_pca_index:
		var next_pca = _all_win_type_player_capture_area_region_to_is_captured_map.keys()[_current_pca_index]
		next_pca.visible = true
	
	curr_pca.visible = false

func _on_PCA_region_area_uncaptured__for_one_at_a_time_tracking(curr_pca):
	_current_pca_index -= 1
	var prev_pca = _all_win_type_player_capture_area_region_to_is_captured_map.keys()[_current_pca_index]
	prev_pca.visible = false
	curr_pca.visible = true
	
	var next_pca = _all_win_type_player_capture_area_region_to_is_captured_map.keys()[_current_pca_index + 1]
	next_pca.visible = false

func make_first_pca_region_visible():
	#_all_win_type_player_capture_area_region_to_is_captured_map.keys()[0].visible = true
	make_first_uncaptured_pca_region_visible()

func make_first_uncaptured_pca_region_visible():
	for pca in _all_win_type_player_capture_area_region_to_is_captured_map.keys():
		var is_cap = _all_win_type_player_capture_area_region_to_is_captured_map[pca]
		if !is_cap:
			pca.visible = true
			return


############

func set_enable_base_tileset_generate_tooltips(arg_val):
	for tileset in tile_container.get_children():
		tileset.can_generate_tooltips = arg_val



######
# HELPER
######


const DIST_OF_ITEM_PARTICLE_FROM_PLAYER : float = 36.0
class PickupImportantItemCutsceneParam:
	var item_texture : Texture
	var staring_pos : Vector2
	var ending_pos : Vector2

# make it do the circle thing animation
func helper__start_cutscene_of_pickup_important_item(arg_param : PickupImportantItemCutsceneParam,
		arg_func_source, arg_func_name, arg_params):
	
	_current_item_cutscene_param = arg_param
	
	#CameraManager.set_current_default_zoom_normal_vec__to_default_zoom_out_val(true)
	#CameraManager.start_camera_zoom_change(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL, CameraManager.ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION)
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	call_deferred("_start_item_pickup_particles", arg_param)
	
	CameraManager.start_camera_zoom_change(Vector2(0.5, 0.5), CameraManager.ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION)
	
	#var wait_tween = create_tween()
	#wait_tween.set_parallel(false)
	#wait_tween.tween_interval(3.0)
	#wait_tween.tween_callback(self, "_on_wait_tween_finished__cutscene_for_pickup", [arg_func_source, arg_func_name, arg_params])
	
	#
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallModi, 1.0, null)
	
	_ICIP_func_source = arg_func_source
	_ICIP_func_name = arg_func_name
	_ICIP_func_param = arg_params
	
	game_elements.get_current_player().player_face.play_sequence__upgrading()


func _start_item_pickup_particles(arg_param : PickupImportantItemCutsceneParam):
	var atlas_texture_to_top_left_pos_modi_map = TextureMethodHelper.generate_atlas_textures_and_pos_modifier_map__for_texture(arg_param.item_texture, 5, 5)
	#var center_based_attk_sprites_list = TextureMethodHelper.generate_center_based_attk_sprite__from_atlas_textures_and_pos_modifier_map(atlas_texture_map, arg_param.staring_pos, With2ndCenterBasedAttackSprite_Scene)
	
	var idx = 0
	var total_idx = atlas_texture_to_top_left_pos_modi_map.size() - 1
	for texture in atlas_texture_to_top_left_pos_modi_map:
		var pos_modi__top_left_based = atlas_texture_to_top_left_pos_modi_map[texture]
		var pos_modi__center_based = TextureMethodHelper.convert_pos_modi_top_left_based__into_center_based(arg_param.item_texture.get_size(), pos_modi__top_left_based)
		
		var attk_sprite = _configure_CBAS_item_pickup_particle(texture, arg_param, idx, total_idx, pos_modi__center_based)
		idx += 1



#func _on_wait_tween_finished__cutscene_for_pickup(arg_func_source, arg_func_name, arg_params):
#	#CameraManager.set_current_default_zoom_normal_vec__to_default_zoom_normal_val(true)
#	#CameraManager.start_camera_zoom_change(CameraManager.DEFAULT_ZOOM_LEVEL, CameraManager.ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION)
#	CameraManager.reset_camera_zoom_level()
#
#	arg_func_source.call(arg_func_name, arg_params)


#

func _configure_CBAS_item_pickup_particle(texture : Texture, arg_param : PickupImportantItemCutsceneParam, arg_idx, arg_total_idx, arg_pos_modi : Vector2):
	var attk_sprite = With2ndCenterBasedAttackSprite_Scene.instance()
	attk_sprite.texture_to_use = texture
	
	#
	
	#attk_sprite.reset_for_another_use_on_ready = false
	
	var pos_modi_from_dest = _calculate_pos_modi_from_final_dest_center__for_item_particle(arg_idx, arg_total_idx)
	var circle_arc_dest = arg_param.ending_pos + pos_modi_from_dest
	attk_sprite.center_pos_of_basis = circle_arc_dest
	#attk_sprite.center_pos_of_basis = arg_param.staring_pos + arg_pos_modi
	
	
	attk_sprite.use_override__initial_pos = true
	var initial_pos = arg_param.staring_pos + arg_pos_modi
	attk_sprite.override__initial_pos = initial_pos
	attk_sprite.position = initial_pos
	
	attk_sprite.is_enabled_mov_toward_center = true
	
	attk_sprite.initial_speed_towards_center = 60
	attk_sprite.speed_accel_towards_center = -8
	attk_sprite.min_speed_towards_center = 40
	
	attk_sprite.min_starting_angle = 0
	attk_sprite.max_starting_angle = 0
	
	_all_imp_cutscene_item_particles.append(attk_sprite)
	
	SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(attk_sprite)
	
	attk_sprite.connect("reached_center_pos_of_basis", self, "_on_imp_cutscene_item_particle_reached_center_pos_of_basis", [], CONNECT_ONESHOT)
	
	var tweener = create_tween()
	tweener.tween_property(attk_sprite, "modulate", Color("#4DFDFC"), 0.3)
	
	#var dist = attk_sprite.center_pos_of_basis.distance_to(arg_param.staring_pos)
	#attk_sprite.min_starting_distance_from_center = dist
	#attk_sprite.max_starting_distance_from_center = dist
	


func _calculate_pos_modi_from_final_dest_center__for_item_particle(arg_idx, arg_total_idx):
	var angle = (360 * arg_idx * 2 / float(arg_total_idx) - 90)
	return Vector2(DIST_OF_ITEM_PARTICLE_FROM_PLAYER, 0).rotated(deg2rad(angle))


func _on_imp_cutscene_item_particle_reached_center_pos_of_basis():
	_item_particle_reached_dest_count += 1
	if _item_particle_reached_dest_count == _all_imp_cutscene_item_particles.size():
		var wait_tween = create_tween()
		wait_tween.tween_interval(0.5)
		wait_tween.tween_callback(self, "_make_all_imp_cutscene_item_particles_go_to_final_pos")

func _make_all_imp_cutscene_item_particles_go_to_final_pos():
	var i = 0
	for particle in _all_imp_cutscene_item_particles:
		particle.secondary_center = _current_item_cutscene_param.ending_pos
		particle.secondary_speed_accel_towards_center = 200
		particle.secondary_initial_speed_towards_center = 40
		
		particle._configure_self_to_change_to_secondary_center()
		
		if i == 0:
			particle.connect("reached_final_destination", self, "_on_any_item_particle_reached_final_destination", [], CONNECT_PERSIST)
		i += 1
		
	



func _on_any_item_particle_reached_final_destination():
	for particle in _all_imp_cutscene_item_particles:
		particle.queue_free()
	
	_ICIP_func_source.call(_ICIP_func_name, _ICIP_func_param)
	
	CameraManager.reset_camera_zoom_level()
	
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Special_ImportantItemFound, 1.0, null)
	
	game_elements.get_current_player().player_face.end_sequence__upgrading()



############

func _on_coin_collected_by_player(arg_coin):
	_coin_audio_player = AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Pickupable_Star_01, 1.0, null)
	_coin_audio_player.connect("finished", self, "_on_coin_audio_player_finished", [], CONNECT_ONESHOT)
	
	_update_game_background_configs_related()
	_on_star_pickuped_by_player__for_particle_show(arg_coin)

func _on_coin_audio_player_finished():
	_coin_audio_player = null

func _on_coin_uncollected_by_player(arg_coin):
	if _coin_audio_player != null:
		_coin_audio_player.stop()
		_coin_audio_player = null
	
	_update_game_background_configs_related()

#

func _deferred_initialize_game_background_configs_related():
	if game_elements.is_game_background_initialized:
		call_deferred("_update_game_background_configs_related")
	else:
		game_elements.connect("game_background_initialized", self, "_on_game_background_initialized", [], CONNECT_ONESHOT)

func _on_game_background_initialized(arg_game_background):
	#_update_game_background_configs_related()
	call_deferred("_update_game_background_configs_related")

func _update_game_background_configs_related():
	if GameSaveManager.is_all_coins_collected_in_curr_level__tentative():
		request_show_brightened_star_background__star_collectible_collected()
	else:
		request_unshow_brightened_star_background__star_collectible_uncollected()


func request_show_brightened_star_background__star_collectible_collected():
	game_elements.game_background.request_show_brightened_star_background__star_collectible_collected()
	

func request_unshow_brightened_star_background__star_collectible_uncollected():
	game_elements.game_background.request_unshow_brightened_star_background__star_collectible_uncollected()
	


#####

func init_all_module_x_pickup_related():
	if trail_compo_for_module_x_pickup_particle == null:
		trail_compo_for_module_x_pickup_particle = MultipleTrailsForNodeComponent.new()
		trail_compo_for_module_x_pickup_particle.node_to_host_trails = self
		trail_compo_for_module_x_pickup_particle.trail_type_id = StoreOfTrailType.BASIC_TRAIL
		trail_compo_for_module_x_pickup_particle.connect("on_trail_before_attached_to_node", self, "_trail_before_attached_to_module_x_pickup_particle")
		
		module_x_pickup_particles_pool_component = AttackSpritePoolComponent.new()
		module_x_pickup_particles_pool_component.source_for_funcs_for_attk_sprite = self
		module_x_pickup_particles_pool_component.func_name_for_creating_attack_sprite = "_create_module_x_particle_pickup_particle__for_pool_compo"
		module_x_pickup_particles_pool_component.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
		module_x_pickup_particles_pool_component.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster

func _trail_before_attached_to_module_x_pickup_particle(arg_trail, arg_particle_node):
	arg_trail.max_trail_length = 15
	arg_trail.trail_color = Color("#3D0179")
	arg_trail.width = 7
	
	arg_trail.set_to_idle_and_available_if_node_is_not_visible = true
	

func _create_module_x_particle_pickup_particle__for_pool_compo():
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	particle.texture_to_use = preload("res://ObjectsRelated/Pickupables/Subs/_CusotmDefinedSingleUse/Pickupable_Module_Stats_PickupParticle.png")
	particle.queue_free_at_end_of_lifetime = false
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.initial_speed_towards_center = -200
	particle.speed_accel_towards_center = 200
	
	particle.lifetime_to_start_transparency = 0.7
	particle.transparency_per_sec = 1 / (particle.lifetime - particle.lifetime_to_start_transparency)
	
	particle.reset_for_another_use_on_ready = false
	
	return particle
	

func create_and_show_module_x_particle_pickup_particles__and_do_relateds(arg_pos, arg_angle_rad_modifier = 0):
	for i in 8:
		var particle : CenterBasedAttackSprite = module_x_pickup_particles_pool_component.get_or_create_attack_sprite_from_pool()
		
		particle.center_pos_of_basis = arg_pos
		
		particle.lifetime = 1.3
		
		trail_compo_for_star_pickup_particle.create_trail_for_node(particle)
		
		var angle = ((45) * i) + arg_angle_rad_modifier
		particle.min_starting_angle = angle
		particle.max_starting_angle = angle
		
		particle.rotation = angle
		
		particle.min_starting_distance_from_center = 5
		particle.max_starting_distance_from_center = 5
		
		
		particle.reset_for_another_use()
	
	##
	
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Pickupable_ModuleX, 1.0, null)

#

func _init_all_star_pickup_related():
	trail_compo_for_star_pickup_particle = MultipleTrailsForNodeComponent.new()
	trail_compo_for_star_pickup_particle.node_to_host_trails = self
	trail_compo_for_star_pickup_particle.trail_type_id = StoreOfTrailType.BASIC_TRAIL
	trail_compo_for_star_pickup_particle.connect("on_trail_before_attached_to_node", self, "_trail_before_attached_to_star_pickup_particle")
	
	star_pickup_particles_pool_component = AttackSpritePoolComponent.new()
	star_pickup_particles_pool_component.source_for_funcs_for_attk_sprite = self
	star_pickup_particles_pool_component.func_name_for_creating_attack_sprite = "_create_star_particle_pickup_particle__for_pool_compo"
	star_pickup_particles_pool_component.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
	star_pickup_particles_pool_component.node_to_parent_attack_sprites = SingletonsAndConsts.current_game_elements__other_node_hoster

func _create_star_particle_pickup_particle__for_pool_compo():
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	particle.texture_to_use = preload("res://ObjectsRelated/Pickupables/Subs/Coin/Assets/StarParticlePickup/StarParticlePickup_Pic.png")
	particle.queue_free_at_end_of_lifetime = false
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.initial_speed_towards_center = -200
	particle.speed_accel_towards_center = 200
	
	particle.lifetime_to_start_transparency = 0.7
	particle.transparency_per_sec = 1 / (particle.lifetime - particle.lifetime_to_start_transparency)
	
	particle.reset_for_another_use_on_ready = false
	
	return particle


func create_and_show_star_particle_pickup_particle(arg_pos, arg_angle, arg_dist):
	var particle : CenterBasedAttackSprite = star_pickup_particles_pool_component.get_or_create_attack_sprite_from_pool()
	
	particle.center_pos_of_basis = arg_pos
	
	particle.lifetime = 1.0
	
	trail_compo_for_star_pickup_particle.create_trail_for_node(particle)
	
	particle.min_starting_angle = arg_angle
	particle.max_starting_angle = arg_angle
	
	particle.min_starting_distance_from_center = arg_dist
	particle.max_starting_distance_from_center = arg_dist
	
	particle.rotation = arg_angle
	
	particle.reset_for_another_use()
	
	return particle

#func _on_particle_ready(arg_particle):
#	trail_compo_for_star_pickup_particle.create_trail_for_node(arg_particle)
#	

func _trail_before_attached_to_star_pickup_particle(arg_trail, arg_particle_node):
	arg_trail.max_trail_length = 11
	arg_trail.trail_color = Color("#FDC621")
	arg_trail.width = 5
	
	arg_trail.set_to_idle_and_available_if_node_is_not_visible = true



func _on_star_pickuped_by_player__for_particle_show(arg_star : Node2D):
	var edge_poses = arg_star.get_all_poses()
	for edge_pos in edge_poses:
		var star_pos = arg_star.global_position
		var edge_angle = rad2deg(edge_pos.angle())
		var edge_length = edge_pos.length()
		
		create_and_show_star_particle_pickup_particle(star_pos, edge_angle, edge_length)


#######

func _on_game_result_decided__base(arg_result):
	if arg_result == game_elements.game_result_manager.GameResult.WIN:
		_on_game_result_decided__win__base()
		

func _on_game_result_decided__win__base():
	pass
	


####

func as_test__override__do_insta_win():
	print("WorldSlice does not implement -- as_test__override__do_insta_win. %s" % [name])
	assert(false)
	

func as_test__override__do_insta_win__template_capture_all_points():
	for pca in get_all_win_type_player_capture_area_region_to_is_captured_map():
		if !pca.is_area_captured():
			pca.set_is_area_captured__external(true)
	



