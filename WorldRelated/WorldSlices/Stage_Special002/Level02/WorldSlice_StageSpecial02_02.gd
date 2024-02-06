extends "res://WorldRelated/AbstractWorldSlice.gd"


const CustomDefinedSingleUse_Pickupable = preload("res://ObjectsRelated/Pickupables/Subs/_CusotmDefinedSingleUse/Pickupable_CustomDefinedSingleUse.gd")
const CustomDefinedSingleUse_Pickupable_Scene = preload("res://ObjectsRelated/Pickupables/Subs/_CusotmDefinedSingleUse/Pickupable_CustomDefinedSingleUse.tscn")

const SuperStarFXDrawer = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/SuperStarFXDrawer.gd")
const SuperStarFXDrawer_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/SuperStarFXDrawer.tscn")



const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")
const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")

const AnimalAnimSprite = preload("res://MiscRelated/SpriteRelated/AnimalAnimSpriteRelated/AnimalAnimSprite.gd")
const ColorRectContainerForAnimalAnimSprite = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/ColorRectContainerForAnimalAnimSprite.gd")
const ColorRectContainerForAnimalAnimSprite_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/ColorRectContainerForAnimalAnimSprite.tscn")

#

const DURATION_OF_TRAVEL_FROM_AIR_TO_GROUND__CUTSCENE : float = 12.0

#

const SHADER_PARAM__CIRCLE_SIZE = "circle_size"
const SHADER_PARAM__SATURATION = "saturation"

#

var _current_long_transition

var _player
var _player_modi_energy

#

var color_rect_container_for_animal_anim_sprite : ColorRectContainerForAnimalAnimSprite
var animal_anim_sprite : AnimalAnimSprite

var shader_mat_of_animal_anim_sprite : ShaderMaterial
var _vision_transition_sprite_for_trophy_sequence


var animal_size : Vector2
var screen_size_minus_animal_size : Vector2

#

const SUPER_STAR_FINAL_POS_OFFSET_FROM_COLLECTION_POS = Vector2(220, -80)
const SUPER_STAR_FINAL_POS_CHANGE_DURATION = 1.5
const SUPER_STAR_FINAL_POS_CHANGE_TRANS = Tween.TRANS_QUAD
const SUPER_STAR_FINAL_POS_CHANGE_EASE = Tween.EASE_OUT

const SHINE_ADDITIONAL_DELAY : float = 0.75

#

onready var vkp_left = $MiscContainer/VBoxContainer3/HBoxContainer/VBoxContainer/VKP_Left
onready var vkp_right = $MiscContainer/VBoxContainer3/HBoxContainer/VBoxContainer2/VKP_Right

onready var trajectory_editor_line = $MiscContainer/TrajectoryEditorHelper

onready var vbox_of_instructions__01 = $MiscContainer/VBoxContainer3

#fast spawn = destination
onready var fast_spawn_pos_2d = $MiscContainer/FastSpawnPos2D
onready var normal_spawn_pos_2d = $PlayerSpawnCoordsContainer/Position2D


onready var vis_transition_fog_finale_trophy = $MiscContainer/VisTransFog_FinaleTrophy

onready var base_enemy = $ObjectContainer/BaseEnemy

#onready var cdsu_super_star = $MiscContainer/CDSU_SuperStar
#onready var super_star_fx_drawer = $MiscContainer/SuperStarFXDrawer

onready var misc_container = $MiscContainer

var cdsu_super_star
var cdsu_super_star_simulated
var super_star_fx_drawer

var special_pos_for_cam__for_super_star : Node2D
var super_star_particles_container : Node2D

##

#temptodo
var temp_is_test : bool = true

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	#as_test__override__do_insta_win__template_capture_all_points()
	pass


func _ready():
	trajectory_editor_line.visible = false
	trajectory_editor_line.queue_free()

#

func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	
	if temp_is_test:
		return
	
	vbox_of_instructions__01.modulate.a = 0
	#SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_1, true)
	
	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK)
	transition.initial_ratio = 0.2
	transition.target_ratio = 1.0
	transition.wait_at_start = 1.0
	transition.duration = 2.0
	transition.trans_type = Tween.TRANS_BOUNCE
	SingletonsAndConsts.current_master.play_transition__alter_no_states(transition)
	transition.modulate.a = 0.6
	
	transition.set_is_transition_paused(true)
	_current_long_transition = transition


#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	
	base_enemy.current_health = GameSettingsManager.combat__current_max_enemy_health / 100.0
	
	
	if temp_is_test:
		#var pos = Vector2(7038, 656)
		var pos = Vector2(4490, 1296)
		game_elements.get_current_player().global_position = pos
		return
	
	#
	
	vkp_left.game_control_action_name = "game_left"
	vkp_right.game_control_action_name = "game_right"
	
	#
	
	game_elements.configure_game_state_for_cutscene_occurance(false, false)
	CameraManager.start_camera_zoom_change(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL, 0.0)
	
	call_deferred("_deferred_init__for_first_time_and_not")
	
	#
	
	# start
	#SingletonsAndConsts.current_game_front_hud.init_adjusted_pos_node_container__above_other_hosters()
	#_create_and_init_cdsu_super_star()
	# end

func _add_energy_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	modi.set_max_energy(15)
	modi.set_current_energy(0)
	modi.is_energy_not_deductable_cond_clauses.attempt_insert_clause(modi.IsEnergyNotDeductableClauseIds.CUSTOM_FROM_WORLD_SLICE)
	
	modi.allow_display_of_energy_hud = false
	modi.can_record_stats = true
	
	_player_modi_energy = modi
	



func _deferred_init__for_first_time_and_not():
	_add_energy_modi()
	
	if temp_is_test:
		_configure_custom_rules_of_trophy_round()
		#_init_color_rect_container_for_animal_anim_sprite_and_relateds()
		return
	
	_init__as_first_time__and_do_cutscenes()

func _init__as_first_time__and_do_cutscenes():
	game_elements.player_modi_manager.add_modi_to_player(_player_modi_energy)
	
	_player = game_elements.get_current_player()
	_player.connect("on_ground_state_changed", self, "_on_player_on_ground_state_changed")
	
	if game_elements.is_game_front_hud_initialized:
		#SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)
		_on_game_front_hud_initialized(game_elements.game_front_hud)
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)
	
	#call_deferred("_init_color_rect_container_for_animal_anim_sprite_and_relateds")
	
	_apply_force_to_make_player_goto_pos_from_air_pos()
	

func _on_game_front_hud_initialized(arg_hud):
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)

func _apply_force_to_make_player_goto_pos_from_air_pos():
	var linear_velocity_to_use = (fast_spawn_pos_2d.global_position - normal_spawn_pos_2d.global_position) / DURATION_OF_TRAVEL_FROM_AIR_TO_GROUND__CUTSCENE
	
	_player.apply_inside_induced_force(linear_velocity_to_use)




func _on_player_on_ground_state_changed(arg_val):
	if arg_val:
		_player.disconnect("on_ground_state_changed", self, "_on_player_on_ground_state_changed")
		_current_long_transition.set_is_transition_paused(false)
		
		_player.stop_player_movement()
		
		_player.player_face.play_sequence__waking_up(2.0, self, "_on_player_wakeup_sequence_finish", 0.0)
		_player_modi_energy.set_current_energy(15)
		
		CameraManager.camera.add_stress(2.0)
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion, 0.6, null)

func _on_player_wakeup_sequence_finish():
	CameraManager.reset_camera_zoom_level()
	
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(true)
	_make_vbox_of_instructions__01__visible_by_tweener()
	
	SingletonsAndConsts.current_master.start_play_music_playlist_of_curr_level()
	
	
	_configure_custom_rules_of_trophy_round()

func _make_vbox_of_instructions__01__visible_by_tweener():
	var tweener = create_tween()
	tweener.tween_property(vbox_of_instructions__01, "modulate:a", 1.0, 1.0)
	


#

func _configure_custom_rules_of_trophy_round():
	#disable zoom in
	CameraManager.set_current_default_zoom_out_vec(Vector2(1, 1))
	#disable rewind
	var rewind_manager = SingletonsAndConsts.current_rewind_manager
	rewind_manager.can_store_rewind_data_cond_clause.attempt_insert_clause(rewind_manager.CanStoreRewindDataClauseIds.CUSTOM_FROM_WORLD_SLICE_02)
	rewind_manager.can_cast_rewind_cond_clause.attempt_insert_clause(rewind_manager.CanCastRewindClauseIds.CUSTOM_FROM_WORLD_SLICE_02)
	
	

####################
# SEQUENCE 04 TO 05

func _on_PDAR_CinemStart_01_player_entered_in_area():
	var player = game_elements.get_current_player()
	player.curr_max_player_move_left_right_speed = BaseTileSet.MOMENTUM_FOR_BREAK__STRONG_GLASS_TILE / player.last_calculated_object_mass
	
	#print(player.curr_max_player_move_left_right_speed)

func _on_PDAR_Cinematic_End_player_entered_in_area():
	var player = game_elements.get_current_player()
	player.curr_max_player_move_left_right_speed = player.MAX_PLAYER_MOVE_LEFT_RIGHT_SPEED


#############
# SEQUENCE 07 -- LAST

func _on_Portal_Entry_Seq07_player_entered(arg_player):
	call_deferred("_init_color_rect_container_for_animal_anim_sprite_and_relateds")

func _init_color_rect_container_for_animal_anim_sprite_and_relateds():
	color_rect_container_for_animal_anim_sprite = ColorRectContainerForAnimalAnimSprite_Scene.instance()
	game_elements.game_front_hud.add_node_to_above_other_hosters(color_rect_container_for_animal_anim_sprite)
	color_rect_container_for_animal_anim_sprite.follow_node_pos__on_screen__centered(game_elements.get_current_player())
	
	# color rect related
	_vision_transition_sprite_for_trophy_sequence = vis_transition_fog_finale_trophy.get_transition_sprite()
	
	# animal sprite
	animal_anim_sprite = color_rect_container_for_animal_anim_sprite.animal_anim_sprite
	var animal_sprite_frames_to_use : SpriteFrames = _get_animal_sprite_frames_to_use_based_on_GSM()
	_give_color_rect_container_reverse_circle_shader__and_config_shader_relateds()
	_init_animal_is_dead_config()
	animal_anim_sprite.config_set_sprite_frames(animal_sprite_frames_to_use)
	animal_anim_sprite.config_set_player_to_watch_speed(game_elements.get_current_player())
	_init_animal_size()
	screen_size_minus_animal_size = SingletonsAndConsts.current_master.screen_size - animal_size
	
	# vision fog related
	vis_transition_fog_finale_trophy.activate_monitor_for_player()
	
	
	#shader_mat_of_animal_anim_sprite.set_shader_param(SHADER_PARAM__CIRCLE_SIZE, 0)
	
	##start
#	var tweener = create_tween()
#	tweener.tween_method(self, "_on_vision_transition_sprite_for_trophy_sequence_circle_ratio_changed", 0.9, 1.0, 3.0)
#	tweener.tween_method(self, "_on_vision_transition_sprite_for_trophy_sequence_circle_ratio_changed", 1.0, 0.9, 3.0)
#	tweener.set_loops()
	## -- end
	
	
	# star
	call_deferred("_init_above_GFH_node_container__and_related_nodes")


func _init_animal_is_dead_config():
	if GameSaveManager.is_player_died_in_any_level():
		animal_anim_sprite.config_as_dead()
		shader_mat_of_animal_anim_sprite.set_shader_param(SHADER_PARAM__SATURATION, 0.0)

func _init_animal_size():
	animal_size = animal_anim_sprite.sprite_size
	if animal_size.x > animal_size.y:
		animal_size = Vector2(animal_size.x, animal_size.x)
	else:
		animal_size = Vector2(animal_size.y, animal_size.y)
	

func _get_animal_sprite_frames_to_use_based_on_GSM():
	match GameSaveManager.animal_choice_id:
		GameSaveManager.AnimalChoiceId.CAT:
			return load("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Res/SFAnimal_Cat.tres")
		GameSaveManager.AnimalChoiceId.DOG:
			return load("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Res/SFAnimal_Dog.tres")


func _give_color_rect_container_reverse_circle_shader__and_config_shader_relateds():
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = load("res://MiscRelated/ShadersRelated/Shader_CircleTransitionReversed.tres")
	shader_mat.set_shader_param(SHADER_PARAM__CIRCLE_SIZE, 1.05)
	shader_mat.set_shader_param(SHADER_PARAM__SATURATION, 1.0)
	#shader_mat.set_shader_param("noise", animal_anim_sprite)
	
	shader_mat_of_animal_anim_sprite = shader_mat
	color_rect_container_for_animal_anim_sprite.animal_anim_sprite.material = shader_mat
	
	_vision_transition_sprite_for_trophy_sequence.connect("circle_ratio_changed", self, "_on_vision_transition_sprite_for_trophy_sequence_circle_ratio_changed")

func _on_vision_transition_sprite_for_trophy_sequence_circle_ratio_changed(arg_ratio):
	var circle_bounding_size : Vector2 = SingletonsAndConsts.current_master.screen_size * (1 - arg_ratio)
	var final_ratio : float = 1
	
	var circle_bounding_length_sqr = circle_bounding_size.length()
	var screen_animal_size_length_sqr = screen_size_minus_animal_size.length()
	if circle_bounding_length_sqr >= screen_animal_size_length_sqr:
		# x -- 0 (0 being full/max)
		var curr_size_diff : Vector2 = SingletonsAndConsts.current_master.screen_size - circle_bounding_size
		
		final_ratio = (curr_size_diff / animal_size).length()
	
	shader_mat_of_animal_anim_sprite.set_shader_param(SHADER_PARAM__CIRCLE_SIZE, final_ratio)
	
	
	###
	game_elements.game_front_hud.external__set_control_container_mod_a(arg_ratio)
	
	#print("final ratio: %s, arg: %s" % [final_ratio, arg_ratio])



func _init_above_GFH_node_container__and_related_nodes():
	SingletonsAndConsts.current_game_front_hud.init_adjusted_pos_node_container__above_other_hosters()
	
	
	var super_star_particles_container = Node2D.new()
	_create_and_init_super_star_fx_drawer_node()
	_create_and_init_cdsu_super_star()
	
	
	##
	#note: does not work. try something else (putting node in GFH other non screen hosters perhaps?)
#	var node_container_above_game_front_hud = SingletonsAndConsts.current_game_elements.init_node_container_above_game_front_hud()
#	node_container_above_game_front_hud.add_child(super_star_particles_container)
#	node_container_above_game_front_hud.add_child(super_star_fx_drawer)
#	node_container_above_game_front_hud.add_child(cdsu_super_star)
	
	#
	var coll_shape = CircleShape2D.new()
	coll_shape.radius = 20
	cdsu_super_star.collision_shape.shape = coll_shape
	
	


func _create_and_init_cdsu_super_star():
	cdsu_super_star = CustomDefinedSingleUse_Pickupable_Scene.instance()
	
	
	cdsu_super_star.position = Vector2(8194, 635)
	#cdsu_super_star.position = Vector2(7194, 617)
	cdsu_super_star.is_destroy_self_on_player_entered = false
	cdsu_super_star.connect("player_entered_self__custom_defined", self, "_on_CDSU_SuperStar_player_entered_self__custom_defined", [], CONNECT_ONESHOT)
	misc_container.add_child(cdsu_super_star)
	
	#cdsu_super_star.sprite.texture = load("res://ObjectsRelated/Pickupables/Subs/Coin/Assets/Pickupable_Coin_Pic__SuperStar.png")
	
	##
	
	cdsu_super_star_simulated = Sprite.new()
	cdsu_super_star_simulated.texture = load("res://ObjectsRelated/Pickupables/Subs/Coin/Assets/Pickupable_Coin_Pic__SuperStar.png")
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_adjusted_pos_node_container(cdsu_super_star_simulated, cdsu_super_star)
	
	##
	
	var shader_mat_for_star = ShaderMaterial.new()
	shader_mat_for_star.shader = preload("res://MiscRelated/ShadersRelated/Shader_PickupableOutline_Rainbow.tres")
	
	#cdsu_super_star.material = shader_mat_for_star
	cdsu_super_star_simulated.material = shader_mat_for_star
	

func _create_and_init_super_star_fx_drawer_node():
	super_star_fx_drawer = SuperStarFXDrawer_Scene.instance()
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_above_other_hosters(super_star_fx_drawer)

###

func _on_CDSU_SuperStar_player_entered_self__custom_defined():
	_init_special_pos_for_cam__for_super_star()
	#_do_all_tween_related_to_super_star_collection()
	call_deferred("_do_all_tween_related_to_super_star_collection")
	
	game_elements.configure_game_state_for_cutscene_occurance(true, true)

func _init_special_pos_for_cam__for_super_star():
	special_pos_for_cam__for_super_star = Node2D.new()
	special_pos_for_cam__for_super_star.global_position = CameraManager.camera.get_camera_screen_center() #game_elements.get_current_player().global_position
	
	SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(special_pos_for_cam__for_super_star)
	CameraManager.set_camera_to_follow_node_2d(special_pos_for_cam__for_super_star)

func _do_all_tween_related_to_super_star_collection():
	var tween = create_tween()
	tween.set_parallel(true)
	_tween_relocate_super_star_based_on_collection_offset(tween)
	_tween_relocate_camera_based_on_collection_offset(tween)
	#
	var delay_tween = create_tween()
	delay_tween.tween_interval(SUPER_STAR_FINAL_POS_CHANGE_DURATION + SHINE_ADDITIONAL_DELAY)
	delay_tween.tween_callback(self, "_start_sequence")

func _tween_relocate_super_star_based_on_collection_offset(arg_tween : SceneTreeTween):
	var final_pos = cdsu_super_star.global_position + SUPER_STAR_FINAL_POS_OFFSET_FROM_COLLECTION_POS
	arg_tween.tween_property(cdsu_super_star, "global_position", final_pos, SUPER_STAR_FINAL_POS_CHANGE_DURATION).set_trans(SUPER_STAR_FINAL_POS_CHANGE_TRANS).set_ease(SUPER_STAR_FINAL_POS_CHANGE_EASE)

func _tween_relocate_camera_based_on_collection_offset(arg_tween : SceneTreeTween):
	var final_pos = special_pos_for_cam__for_super_star.global_position + (SUPER_STAR_FINAL_POS_OFFSET_FROM_COLLECTION_POS / 2)
	arg_tween.tween_property(special_pos_for_cam__for_super_star, "global_position", final_pos, SUPER_STAR_FINAL_POS_CHANGE_DURATION).set_trans(SUPER_STAR_FINAL_POS_CHANGE_TRANS).set_ease(SUPER_STAR_FINAL_POS_CHANGE_EASE)


#########

func _start_sequence():
	_start_super_star_fx_drawer("")
	

func _start_super_star_fx_drawer(arg_func_name_to_call_on_end):
	super_star_fx_drawer.center_pos_of_lines = cdsu_super_star_simulated.global_position
	super_star_fx_drawer.start_draw()
	


