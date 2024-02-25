extends "res://WorldRelated/AbstractWorldSlice.gd"


const CustomDefinedSingleUse_Pickupable = preload("res://ObjectsRelated/Pickupables/Subs/_CusotmDefinedSingleUse/Pickupable_CustomDefinedSingleUse.gd")
const CustomDefinedSingleUse_Pickupable_Scene = preload("res://ObjectsRelated/Pickupables/Subs/_CusotmDefinedSingleUse/Pickupable_CustomDefinedSingleUse.tscn")

const SuperStarFXDrawer = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/SuperStarFXDrawer.gd")
const SuperStarFXDrawer_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/SuperStarFXDrawer.tscn")


const ConstellationCoordBoard = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/ConstellCoordBoard.gd")
const ConstellCoordBoardRenderer_FinishedNoClear_V01 = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/ConstellCoordBoardRenderer_FinishedNoClear_V01.gd")
const ConstellCoordBoardRenderer_FinishedNoClear_V01_Scene = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/ConstellCoordBoardRenderer_FinishedNoClear_V01.tscn")
const ConstellCoordBoardRenderer_InProgress_V01 = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/ConstellCoordBoardRenderer_InProgress_V01.gd")
const ConstellCoordBoardRenderer_InProgress_V01_Scene = preload("res://MiscRelated/ConstellationRelated/ConstellCoordBoard/Renderers/ConstellCoordBoardRenderer_InProgress_V01.tscn")


const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")
const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")

const AnimalAnimSprite = preload("res://MiscRelated/SpriteRelated/AnimalAnimSpriteRelated/AnimalAnimSprite.gd")
const ColorRectContainerForAnimalAnimSprite = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/ColorRectContainerForAnimalAnimSprite.gd")
const ColorRectContainerForAnimalAnimSprite_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Subs/ColorRectContainerForAnimalAnimSprite.tscn")


const WSSS0202_EndingPanel = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/WSSS0202_EndingPanel/WSSS0202_EndingPanel.gd")
const WSSS0202_EndingPanel_Scene = preload("res://_NonMainGameRelateds/_PreGameHUDRelated/WSSS0202_EndingPanel/WSSS0202_EndingPanel.tscn")


const GameLogo_BannerSized = preload("res://_NonMainGameRelateds/GameDetails/ALBIS_GameLogo_450x260.png")
const GameLogo_BannerSized_Opaque = preload("res://_NonMainGameRelateds/GameDetails/ALBIS_GameLogo_450x260__OpaqueBackground.png")

const WSSS0202_NextArrow_Normal = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Assets/WSSS0202_NextArrow.png")
const WSSS0202_NextArrow_Highlighted = preload("res://WorldRelated/WorldSlices/Stage_Special002/Level02/Assets/WSSS0202_NextArrow_Highlighted.png")
const PlayerGUI_ButtonStandard = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_ButtonStandard/PlayerGUI_ButtonStandard.gd")
const PlayerGUI_ButtonStandard_Scene = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_ButtonStandard/PlayerGUI_ButtonStandard.tscn")

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


var prev_sprite_transition_ratio_for_trophy_segment : float = -1

#

var background_music_playlist

#

var wsss0202_ending_panel : WSSS0202_EndingPanel

#


#const CDSU_SUPER_STAR_POS = Vector2(8194, 635)
#const CDSU_SUPER_STAR_POS = Vector2(8194, 605)
const CDSU_SUPER_STAR_POS = Vector2(8494, 605)

const SUPER_STAR_FINAL_POS_OFFSET_FROM_COLLECTION_POS = Vector2(280, -160)
const SUPER_STAR_FINAL_POS_CHANGE_DURATION = 1.5
const SUPER_STAR_FINAL_POS_CHANGE_TRANS = Tween.TRANS_QUAD
const SUPER_STAR_FINAL_POS_CHANGE_EASE = Tween.EASE_OUT

const SHINE_ADDITIONAL_DELAY : float = 0.75

#

var constellation_coord_board : ConstellationCoordBoard
var constellation_renderer__in_progress : ConstellCoordBoardRenderer_InProgress_V01
var constellation_renderer__finished : ConstellCoordBoardRenderer_FinishedNoClear_V01
var viewport_for_constellation_finished__container : ViewportContainer
var viewport_for_constellation_finished : Viewport

var thread_for_constellation_board_calcs : Thread
var _is_thread_for_constell_calcs_finished : bool = false

#



var cdsu_super_star
var cdsu_super_star_simulated
var super_star_fx_drawer

var special_pos_for_cam__for_super_star : Node2D
#var super_star_particles_container : Node2D


var on_constellation_show__next_button : PlayerGUI_ButtonStandard

#

var is_fast_view_constellation_mode : bool = false

##

const FAST_VIEW_CONSTELL__PLAYER_POS = Vector2(8452.689453, 656.0047)
const FAST_VIEW_CONSTELL__CAM_POS = Vector2(8583.742188, 576.004761)
const FAST_VIEW_CONSTELL__ACTUAL_STAR_POS = Vector2(8774, 445)
const FAST_VIEW_CONSTELL__SIMULATED_STAR_POS = Vector2(690.341797, 138.946533)

#

onready var vkp_left = $MiscContainer/VisIns_Move/VBoxContainer3/HBoxContainer/VBoxContainer/VKP_Left
onready var vkp_right = $MiscContainer/VisIns_Move/VBoxContainer3/HBoxContainer/VBoxContainer2/VKP_Right

onready var trajectory_editor_line = $MiscContainer/TrajectoryEditorHelper

#onready var vbox_of_instructions__01 = $MiscContainer/VBoxContainer3
onready var visual_instruction = $MiscContainer/VisIns_Move


#fast spawn = destination
onready var fast_spawn_pos_2d = $MiscContainer/FastSpawnPos2D
onready var normal_spawn_pos_2d = $PlayerSpawnCoordsContainer/Position2D


onready var vis_transition_fog_finale_trophy = $MiscContainer/VisTransFog_FinaleTrophy

onready var base_enemy = $ObjectContainer/BaseEnemy

#onready var cdsu_super_star = $MiscContainer/CDSU_SuperStar
#onready var super_star_fx_drawer = $MiscContainer/SuperStarFXDrawer

onready var misc_container = $MiscContainer


onready var pca_01 = $AreaRegionContainer/PCA_01
onready var pca_02 = $AreaRegionContainer/PCA_02
onready var pca_03 = $AreaRegionContainer/PCA_03
onready var pca_04 = $AreaRegionContainer/PCA_04
onready var pca_05 = $AreaRegionContainer/PCA_05
onready var pca_06 = $AreaRegionContainer/PCA_06
onready var pca_07 = $AreaRegionContainer/PCA_07

#

var temp_is_test : bool = false

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

func _apply_modification_to_game_elements():
	._apply_modification_to_game_elements()
	
	if GameSaveManager.is_level_id_finished(SingletonsAndConsts.current_level_details.level_id):
		is_fast_view_constellation_mode = true

func _before_player_spawned_signal_emitted__chance_for_changes(arg_player):
	._before_player_spawned_signal_emitted__chance_for_changes(arg_player)
	
	
	if temp_is_test:
		return
	
	
	if is_fast_view_constellation_mode:
		arg_player.global_position = FAST_VIEW_CONSTELL__ACTUAL_STAR_POS
		
		#var tween = create_tween()
		#tween.tween_interval(0.5)
		#tween.tween_callback(self, "_show_phase__levels_as_constellations")
		
		return
	
	####
	
	#vbox_of_instructions__01.modulate.a = 0
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
	
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided__wsss0202", [], CONNECT_ONESHOT)
	
	#
	
	var gui__level_selection_whole_screen = SingletonsAndConsts.current_master.gui__level_selection_whole_screen
	if !is_instance_valid(gui__level_selection_whole_screen):
		pass
		call_deferred("_create_then_init_gui__level_selection_whole_screen_relateds")
	else:
		gui__level_selection_whole_screen.create_and_configure_all_layout_scenes()
	
	#
	
	base_enemy.current_health = GameSettingsManager.combat__current_max_enemy_health / 100.0
	
	
	if temp_is_test:
		#var pos = Vector2(7038, 656)
		var pos = Vector2(4490, 1296)
		game_elements.get_current_player().global_position = pos
		background_music_playlist = StoreOfAudio.BGM_playlist__calm_01  ## does not matter since they affect the same bus
		_configure_custom_rules_of_trophy_round()
		return
	
	if is_fast_view_constellation_mode:
		_init_special_pos_for_cam__for_super_star()
		special_pos_for_cam__for_super_star.global_position = FAST_VIEW_CONSTELL__CAM_POS
		
		background_music_playlist = StoreOfAudio.BGM_playlist__calm_01  ## does not matter since they affect the same bus
		_configure_custom_rules_of_trophy_round()
		
		if game_elements.is_game_front_hud_initialized:
			_on_game_front_hud_initialized__fast_view_constell(game_elements.game_front_hud)
		else:
			game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized__fast_view_constell", [], CONNECT_ONESHOT)
		
		visible = false
		vis_transition_fog_finale_trophy.activate_monitor_for_player()
		
		game_elements.configure_game_state_for_cutscene_occurance(true, true)
		
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
	
	background_music_playlist = StoreOfAudio.BGM_playlist__calm_01  ## does not matter since they affect the same bus
	

func _create_then_init_gui__level_selection_whole_screen_relateds():
	SingletonsAndConsts.current_master.load_but_do_not_show_layout_selection_whole_screen()
	SingletonsAndConsts.current_master.gui__level_selection_whole_screen.create_and_configure_all_layout_scenes()
	


func _on_game_front_hud_initialized__fast_view_constell(arg_GFH):
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)
	SingletonsAndConsts.current_game_front_hud.init_adjusted_pos_node_container__above_other_hosters()
	
	var tweener = create_tween()
	tweener.tween_interval(0.75)
	tweener.tween_callback(self, "_on_tween_wait_finished__GFH_init__fast_view_constell")

func _on_tween_wait_finished__GFH_init__fast_view_constell():
	_config_constell_board_and_related_renderers__from_thread(null)
	
	call_deferred("_show_phase__levels_as_constellations")


#

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
	#_make_vbox_of_instructions__01__visible_by_tweener()
	
	visual_instruction.start_display()
	SingletonsAndConsts.current_master.start_play_music_playlist_of_curr_level()
	
	
	_configure_custom_rules_of_trophy_round()

#func _make_vbox_of_instructions__01__visible_by_tweener():
#	var tweener = create_tween()
#	tweener.tween_property(vbox_of_instructions__01, "modulate:a", 1.0, 1.0)
#


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
	_on_portal_entry_seq07_player_entered__cap_cpa()
	call_deferred("_init_color_rect_container_for_animal_anim_sprite_and_relateds")
	call_deferred("_start_threaded_calc_for_constell_board")

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
	if is_equal_approx(prev_sprite_transition_ratio_for_trophy_segment, arg_ratio):
		return
	prev_sprite_transition_ratio_for_trophy_segment = arg_ratio
	
	var circle_bounding_size : Vector2 = SingletonsAndConsts.current_master.screen_size * (1 - arg_ratio)
	var final_ratio_for_animal_shader : float = 1
	
	var circle_bounding_length_sqr = circle_bounding_size.length()
	var screen_animal_size_length_sqr = screen_size_minus_animal_size.length()
	if circle_bounding_length_sqr >= screen_animal_size_length_sqr:
		# x -- 0 (0 being full/max)
		var curr_size_diff : Vector2 = SingletonsAndConsts.current_master.screen_size - circle_bounding_size
		
		final_ratio_for_animal_shader = (curr_size_diff / animal_size).length()
	
	######
	
	shader_mat_of_animal_anim_sprite.set_shader_param(SHADER_PARAM__CIRCLE_SIZE, final_ratio_for_animal_shader)
	
	game_elements.game_front_hud.external__set_control_container_mod_a(arg_ratio)
	
	background_music_playlist.set_volume_db__bus_interal__using_ratio(arg_ratio)
	
	if is_zero_approx(arg_ratio):
		cdsu_super_star_simulated.modulate.a = 1.0
	else:
		cdsu_super_star_simulated.modulate.a = 0.0
	
	#print("final ratio: %s, arg: %s" % [final_ratio_for_animal_shader, arg_ratio])



func _init_above_GFH_node_container__and_related_nodes():
	SingletonsAndConsts.current_game_front_hud.init_adjusted_pos_node_container__above_other_hosters()
	
	
	#var super_star_particles_container = Node2D.new()
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
	coll_shape.radius = 50
	cdsu_super_star.collision_shape.shape = coll_shape
	
	


func _create_and_init_cdsu_super_star():
	cdsu_super_star = CustomDefinedSingleUse_Pickupable_Scene.instance()
	
	
	cdsu_super_star.position = CDSU_SUPER_STAR_POS
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
	var final_pos = CDSU_SUPER_STAR_POS + SUPER_STAR_FINAL_POS_OFFSET_FROM_COLLECTION_POS
	arg_tween.tween_property(cdsu_super_star, "global_position", final_pos, SUPER_STAR_FINAL_POS_CHANGE_DURATION).set_trans(SUPER_STAR_FINAL_POS_CHANGE_TRANS).set_ease(SUPER_STAR_FINAL_POS_CHANGE_EASE)

func _tween_relocate_camera_based_on_collection_offset(arg_tween : SceneTreeTween):
	var final_pos = special_pos_for_cam__for_super_star.global_position + (SUPER_STAR_FINAL_POS_OFFSET_FROM_COLLECTION_POS / 2)
	arg_tween.tween_property(special_pos_for_cam__for_super_star, "global_position", final_pos, SUPER_STAR_FINAL_POS_CHANGE_DURATION).set_trans(SUPER_STAR_FINAL_POS_CHANGE_TRANS).set_ease(SUPER_STAR_FINAL_POS_CHANGE_EASE)


#########

func _start_sequence():
	SingletonsAndConsts.current_game_front_hud.set_control_container_visibility(false)
	
	
	#call_deferred("_show_phase__levels_as_constellations")
	
	_start_super_star_fx_drawer()
	
	#print("player_pos: %s, cam_pos: %s, actual_star_pos: %s, simulated_star_pos: %s" % [game_elements.get_current_player().global_position, special_pos_for_cam__for_super_star.global_position, cdsu_super_star.global_position, cdsu_super_star_simulated.position])

func _start_super_star_fx_drawer():
	super_star_fx_drawer.connect("draw_phase_01_standard_finished", self, "_on_star_fx_drawer_draw_phase_01_standard_finished", [], CONNECT_ONESHOT)
	super_star_fx_drawer.center_pos_basis = cdsu_super_star_simulated.global_position
	super_star_fx_drawer.start_draw_phase_01_standard()
	

func _on_star_fx_drawer_draw_phase_01_standard_finished():
	#_play_cutscene_msg()
	visible = false
	cdsu_super_star_simulated.visible = false
	color_rect_container_for_animal_anim_sprite.visible = false
	
	super_star_fx_drawer.connect("draw_phase_02_standard_finished", self, "_on_star_fx_drawer_draw_phase_02_standard_finished", [], CONNECT_ONESHOT)
	super_star_fx_drawer.start_draw_phase_02_standard()


func _on_star_fx_drawer_draw_phase_02_standard_finished():
	call_deferred("_play_cutscene_msg")


##

func _play_cutscene_msg():
	wsss0202_ending_panel = WSSS0202_EndingPanel_Scene.instance()
	wsss0202_ending_panel.show_bonus_blind_panel = _is_magnum_opus_level_completed_blind()
	game_elements.game_front_hud.add_node_to_above_other_hosters(wsss0202_ending_panel)
	
	wsss0202_ending_panel.connect("ending_panel_finished", self, "_on_wsss0202_ending_panel_finished", [], CONNECT_ONESHOT)
	wsss0202_ending_panel.start_display()
	

func _on_wsss0202_ending_panel_finished():
	wsss0202_ending_panel.visible = false
	wsss0202_ending_panel.queue_free()
	
	
	call_deferred("_show_phase__levels_as_constellations")

###

func _start_threaded_calc_for_constell_board():
	#_config_constell_board_and_related_renderers__from_thread(null)
	
	thread_for_constellation_board_calcs = Thread.new()
	thread_for_constellation_board_calcs.start(self, "_config_constell_board_and_related_renderers__from_thread", null)

func _config_constell_board_and_related_renderers__from_thread(arg_01):
	_config_constell_board()
	_config_constell_in_progress_renderer()
	_config_viewport_for_constellation_finished()
	_config_constell_finished_renderer()
	_is_thread_for_constell_calcs_finished = true
	

func _config_constell_board():
	constellation_coord_board = ConstellationCoordBoard.new()
	
	#
	var gui__level_selection_whole_screen = SingletonsAndConsts.current_master.gui__level_selection_whole_screen
	
	var layout_id_to_level_layout_map = gui__level_selection_whole_screen.get_layout_id_to_level_layout_map()
	var level_layout_01 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01]
	var level_layout_02 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02]
	var level_layout_03 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03]
	var level_layout_04 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04]
	var level_layout_05 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05]
	var level_layout_06 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_06]
	var level_layout_07 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_07]
	var level_layout_spec01 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01]
	var level_layout_spec02 = layout_id_to_level_layout_map[StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02]
	
	#board top left coord
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_01, Vector2(0, 13))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_02, Vector2(37, 25))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_03, Vector2(24, 23))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_04, Vector2(13, 23))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_05, Vector2(14, 10))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_06, Vector2(15, 0))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_07, Vector2(33, 2))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_spec01, Vector2(46, 16))
	constellation_coord_board.add_gui_level_layout_to_board(level_layout_spec02, Vector2(42, 7))
	
	#linking layouts
	# 07 to 06
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(33, 2), Vector2(28, 2))
	# 06 to 05
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(20, 6), Vector2(20, 10))
	# 05 to 01
	#swapped, but whatevs. just to make it work
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(10, 14), Vector2(14, 10))
	# 05 to 04
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(21, 16), Vector2(21, 23))
	# 04 to 03
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(15, 29), Vector2(25, 29))
	# 03 to 02
	#swap
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(33, 27), Vector2(37, 29))
	# 02 to S01
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(51, 25), Vector2(51, 22))
	# S01 to S02
	constellation_coord_board.connect_coords_with_custom_path_layout_to_layout(Vector2(51, 16), Vector2(51, 13))
	

func _config_constell_in_progress_renderer():
	constellation_renderer__in_progress = ConstellCoordBoardRenderer_InProgress_V01_Scene.instance()
	constellation_renderer__in_progress.constell_coord_board = constellation_coord_board
	constellation_renderer__in_progress.update_config_based_on_curr_constell_coord_board()
	#constellation_renderer__in_progress.connect("in_progress_render_det_finished", self, "_on_in_progress_render_det_finished")
	constellation_renderer__in_progress.connect("all_finished", self, "_on_constell_in_prog_renderer_all_finished", [], CONNECT_ONESHOT)
	
	#misc_container.add_child(constellation_renderer__in_progress)   # not thread safe
	#misc_container.call_deferred("add_child", constellation_renderer__in_progress)
	game_elements.game_front_hud.call_deferred("add_node_to_above_other_hosters", constellation_renderer__in_progress)
	

func _config_viewport_for_constellation_finished():
	viewport_for_constellation_finished = Viewport.new()
	viewport_for_constellation_finished.size = SingletonsAndConsts.current_master.screen_size
	
	viewport_for_constellation_finished__container = ViewportContainer.new()
	viewport_for_constellation_finished__container.add_child(viewport_for_constellation_finished)
	viewport_for_constellation_finished__container.rect_size = SingletonsAndConsts.current_master.screen_size
	viewport_for_constellation_finished__container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	#misc_container.call_deferred("add_child", viewport_for_constellation_finished__container)
	game_elements.game_front_hud.call_deferred("add_node_to_above_other_hosters", viewport_for_constellation_finished__container)
	

func _config_constell_finished_renderer():
	constellation_renderer__finished = ConstellCoordBoardRenderer_FinishedNoClear_V01_Scene.instance()
	constellation_renderer__finished.set_board_renderer_in_progress(constellation_renderer__in_progress)
	constellation_renderer__finished.config_parent_viewport(viewport_for_constellation_finished)
	
	viewport_for_constellation_finished.call_deferred("add_child", constellation_renderer__finished)

#


func _show_phase__levels_as_constellations():
	if _is_thread_for_constell_calcs_finished:
		# start
		#cdsu_super_star_simulated.visible = false
		#vis_transition_fog_finale_trophy.hide()
		# end
		
		_config_viewport_for_constellation_in_progress__shift()
		_config_viewport_for_constellation_finished__position()
		#constellation_renderer__in_progress.start_constellation_light_up_at_coord(Vector2(42, 7))
		var coord = Vector2(42, 7)
		#coord = Vector2(0, 16)
		constellation_renderer__in_progress.call_deferred("start_constellation_light_up_at_coord", coord)
		
	else:
		_show_phase__little_ball_in_space_logo()


func _config_viewport_for_constellation_in_progress__shift():
	var coord = Vector2(42, 7)
	#coord = Vector2(10, 14)
	var target_pos : Vector2
	if !is_fast_view_constellation_mode:
		target_pos = cdsu_super_star_simulated.position + ConstellCoordBoardRenderer_InProgress_V01.DRAW_ELE__CELL_SIZE/2
	else:
		target_pos = FAST_VIEW_CONSTELL__SIMULATED_STAR_POS + ConstellCoordBoardRenderer_InProgress_V01.DRAW_ELE__CELL_SIZE/2
	
	constellation_renderer__in_progress.shift_all_draw_pos_shift_to_make_coord_at_pos(coord, target_pos)
	

func _config_viewport_for_constellation_finished__position():
	pass
	#var pos = (CDSU_SUPER_STAR_POS - viewport_for_constellation_finished__container.rect_size)
	#viewport_for_constellation_finished__container.rect_global_position = pos


#func _on_in_progress_render_det_finished(arg_render_det_map, arg_coord):
#	print("coord done: %s. real pos: %s. dir dests: %s" % [arg_coord, constellation_renderer__in_progress._pre_calced__coord_to_pos_map[arg_coord], arg_render_det_map[ConstellCoordBoardRenderer_InProgress_V01.RENDER_DET_KEY__DIRS_AS_VEC_DESTINATION_PROGRESS]])

func _on_constell_in_prog_renderer_all_finished():
	var delay_tweener = create_tween()
	if !is_fast_view_constellation_mode:
		delay_tweener.tween_interval(5.0)
		delay_tweener.tween_callback(self, "_show_phase__little_ball_in_space_logo")
	else:
		delay_tweener.tween_interval(1.0)
		delay_tweener.tween_callback(self, "_show_phase__allow_end")

#

func _show_phase__little_ball_in_space_logo():
	var logo_tex_rect = TextureRect.new()
	logo_tex_rect.texture = GameLogo_BannerSized_Opaque
	logo_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_tex_rect.modulate.a = 0
	
	SingletonsAndConsts.current_game_front_hud.misc_center_container.add_child(logo_tex_rect)
	
	var tweener = create_tween()
	tweener.tween_property(logo_tex_rect, "modulate:a", 1.0, 1.5)
	tweener.tween_interval(3.0)
	tweener.tween_property(logo_tex_rect, "modulate:a", 0.0, 1.5)
	tweener.tween_interval(1.0)
	tweener.tween_callback(self, "_show_phase__allow_end")


#

func _show_phase__allow_end():
	call_deferred("_init_and_add_next_button_from_constellation")
	
	MouseManager.add_always_mouse_visible_reserve_id_list(MouseManager.AlwaysMouseModeVisibleReserveId.CUSTOM)
	

func _init_and_add_next_button_from_constellation():
	game_elements.game_front_hud.init_control_container_above_control_container()
	
	on_constellation_show__next_button = PlayerGUI_ButtonStandard_Scene.instance()
	game_elements.game_front_hud.add_node_to_control_container_above_control_container(on_constellation_show__next_button)
	on_constellation_show__next_button.rect_size = Vector2(1, 1)
	on_constellation_show__next_button.texture_button.texture_normal = WSSS0202_NextArrow_Normal
	on_constellation_show__next_button.texture_button.texture_hover = WSSS0202_NextArrow_Highlighted
	on_constellation_show__next_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT, true)
	
	on_constellation_show__next_button.connect("button_pressed", self, "_on_constellation_show__next_button_pressed")
	on_constellation_show__next_button.rect_position -= on_constellation_show__next_button.rect_size + Vector2(15, 0)
	
	#print(on_constellation_show__next_button.rect_global_position)

func _on_constellation_show__next_button_pressed():
	
	if !is_fast_view_constellation_mode:
		_on_winning_capture__cap_cpa__and_all_if_not()
		
		on_constellation_show__next_button.visible = false
		var tweener = create_tween()
		tweener.tween_property(viewport_for_constellation_finished__container, "modulate:a", 0.0, 1.25)
		
	else:
		SingletonsAndConsts.switch_to_level_selection_scene__from_game_elements__from_quit()

##

#func _end_level():
#	_play_inner_transition_to_level_selection()
#	game_elements.game_result_manager.end_game__as_win()
#
#
#func _play_inner_transition_to_level_selection():
#	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__CIRCLE_SPEC_02_02)
#	transition.initial_ratio = 0.0
#	transition.target_ratio = 1.0
#	transition.wait_at_start = 0.0
#	transition.duration = 8.0
#	transition.trans_type = Tween.TRANS_LINEAR
#	transition.queue_free_on_end_of_transition = true
#	SingletonsAndConsts.current_master.play_transition__alter_no_states(transition)
#
#

#############

func _on_game_result_decided__wsss0202(arg_result):
	if game_elements.game_result_manager.is_game_result_win():
		_attempt_unlock_trophy__super_star_collected()
		_attempt_unlock_trophy__super_star_collected_while_blinded__if_conditions_met()
		
		StoreOfLevels.attempt_finish_level_layout__spec_02()

func _attempt_unlock_trophy__super_star_collected():
	var trophy_id = GameSaveManager.TrophyNonVolatileId.WSSS0202_SUPER_STAR_COLLECTED
	if !GameSaveManager.is_trophy_collected(trophy_id):
		GameSaveManager.set_trophy_as_collected__and_assign_metadata(trophy_id, null)

func _attempt_unlock_trophy__super_star_collected_while_blinded__if_conditions_met():
	if !_is_magnum_opus_level_completed_blind():
		return
	
	var trophy_id = GameSaveManager.TrophyNonVolatileId.WSSS0202_SUPER_STAR_COLLECTED__WHILE_BLINDED_LOW_STAR
	if !GameSaveManager.is_trophy_collected(trophy_id):
		GameSaveManager.set_trophy_as_collected__and_assign_metadata(trophy_id, null)

func _is_magnum_opus_level_completed_blind():
	var magnum_opus_lvl_id = StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2
	return GameSaveManager.has_metadata_in_level_id(magnum_opus_lvl_id)


##

func _exit_tree():
	if thread_for_constellation_board_calcs != null:
		thread_for_constellation_board_calcs.wait_to_finish()


#

func _on_Portal_Entry_Seq02_player_entered(arg_player):
	pca_01.set_is_area_captured__external(true)

func _on_Portal_Entry_Seq03_player_entered(arg_player):
	pca_02.set_is_area_captured__external(true)

func _on_Portal_Entry_Seq04_player_entered(arg_player):
	pca_03.set_is_area_captured__external(true)

func _on_Portal_Entry_Seq05_player_entered(arg_player):
	pca_04.set_is_area_captured__external(true)

func _on_Portal_Entry_Seq06_player_entered(arg_player):
	pca_05.set_is_area_captured__external(true)

func _on_portal_entry_seq07_player_entered__cap_cpa():
	pca_06.set_is_area_captured__external(true)

func _on_winning_capture__cap_cpa__and_all_if_not():
	pca_07.set_is_area_captured__external(true)
	
	if !pca_01.is_area_captured():
		pca_01.set_is_area_captured__external(true)
	if !pca_02.is_area_captured():
		pca_02.set_is_area_captured__external(true)
	if !pca_03.is_area_captured():
		pca_03.set_is_area_captured__external(true)
	if !pca_04.is_area_captured():
		pca_04.set_is_area_captured__external(true)
	if !pca_05.is_area_captured():
		pca_05.set_is_area_captured__external(true)
	if !pca_06.is_area_captured():
		pca_06.set_is_area_captured__external(true)
	


###############################
###
