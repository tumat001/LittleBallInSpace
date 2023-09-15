extends "res://WorldRelated/AbstractWorldSlice.gd"

const StoreOfTrailType = preload("res://MiscRelated/TrailRelated/StoreOfTrailType.gd")
const MultipleTrailsForNodeComponent = preload("res://MiscRelated/TrailRelated/MultipleTrailsForNodeComponent.gd")


##

var _last_pcr_stuck_captured : bool
var _first_pcr_stuck_captured : bool

var _player
var _player_modi_energy

var _mod_tweener_for_stuck_label : SceneTreeTween

#

const TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO := Color("#DA5302")

#

var material_for_electrical_shock_screen : ShaderMaterial
var _electric_shock_screen__left  : Sprite
var _electric_shock_screen__right : Sprite

const ELECTRIC_SHOCK_SCREEN_SPRITE_SIZE = Vector2(400, 540)
const ELECTRIC_SHOCK_SCREEN_SPRITE_NEG_SIZE = Vector2(-400, 540)


var _broken_energy_panel_frame_texture_rect : TextureRect

#

var trail_compo_for_elec_equi_break_particle : MultipleTrailsForNodeComponent

#

var _audio_player__ramping_electrical_gen
var _audio_player__electrical_shock

#

onready var vkp_rewind = $MessegesContainer/VBoxContainer/VKP_Rewind
onready var vkp_rewind_02 = $MessegesContainer/StuckLabelContainer/VKP_Rewind

onready var stuck_label_container = $MessegesContainer/StuckLabelContainer

onready var pdar_stuck_show_warning = $AreaRegionContainer/PDAR_StuckShowWarning

onready var base_tileset_blocking_to_last_part = $TileContainer/BaseTileSet_ToggleAtCapture

onready var pca_very_last_near_battery = $AreaRegionContainer/PCAR_NearBatt

#

onready var base_tileset_electrical_equi__nomal = $MiscContainer/BaseTileSet_ElectricalGenExpl_Normal
onready var base_tileset_electrical_equi__destroyed = $MiscContainer/BaseTileSet_ElectricalGenExpl_Destroyed

#

onready var electrical_arc_sprite_01 = $MiscContainer/ElectricalArcSpriteEffect
onready var electrical_arc_sprite_02 = $MiscContainer/ElectricalArcSpriteEffect2
onready var electrical_arc_sprite_03 = $MiscContainer/ElectricalArcSpriteEffect3
onready var electrical_arc_sprite_04 = $MiscContainer/ElectricalArcSpriteEffect4
onready var electrical_arc_sprite_05 = $MiscContainer/ElectricalArcSpriteEffect5
var _all_electrical_arc_sprites : Array

#

onready var pos_of_equipment__generator = $MiscContainer/PosOfEqui_Gene
onready var pos_of_equipment__beam = $MiscContainer/PosOfEqui_Beam

#

onready var cdsu_battery = $ObjectContainer/CDSU_Battery

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

#

func _ready():
	_all_electrical_arc_sprites.append(electrical_arc_sprite_01)
	_all_electrical_arc_sprites.append(electrical_arc_sprite_02)
	_all_electrical_arc_sprites.append(electrical_arc_sprite_03)
	_all_electrical_arc_sprites.append(electrical_arc_sprite_04)
	_all_electrical_arc_sprites.append(electrical_arc_sprite_05)
	
	for arc in _all_electrical_arc_sprites:
		arc.visible = false

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	#var orig_text_rewind = vkp_rewind.text_for_keypress
	#vkp_rewind.text_for_keypress = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	vkp_rewind.game_control_action_name = "rewind"
	GameSettingsManager.set_game_control_name_string__is_hidden("rewind", false)
	
	vkp_rewind_02.game_control_action_name = "rewind"
	#var orig_text_rewind_02 = vkp_rewind_02.text_for_keypress
	#vkp_rewind_02.text_for_keypress = orig_text_rewind_02 % InputMap.get_action_list("rewind")[0].as_text()
	
	
	stuck_label_container.modulate.a = 0
	
	pca_very_last_near_battery.visible = false
	
	_player = game_elements.get_current_player()
	_player.block_health_change_cond_clauses.attempt_insert_clause(_player.BlockHealthChangeClauseIds.CUSTOM_DEFINED__01)
	
	call_deferred("_deferred_add_player_modi_energy")
	call_deferred("_deferred_init_electrical_shock_screen")
	call_deferred("_deferred_init_all_electrical_equi_particles_related")

func _deferred_add_player_modi_energy():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	modi.set_max_energy(1)
	modi.set_current_energy(1)
	modi.is_true_instant_drain_and_recharge = true
	modi.allow_display_of_energy_hud = false
	modi.is_energy_deductable = false
	
	_player_modi_energy = modi
	
	game_elements.player_modi_manager.add_modi_to_player(modi)

func _deferred_init_electrical_shock_screen():
	material_for_electrical_shock_screen = ShaderMaterial.new()
	material_for_electrical_shock_screen.shader = preload("res://MiscRelated/ShadersRelated/Shader_ElectricShockForeground.tres")
	
	
	_electric_shock_screen__left = SingletonsAndConsts.current_game_front_hud.create_sprite_shader(material_for_electrical_shock_screen)
	_electric_shock_screen__left.scale = ELECTRIC_SHOCK_SCREEN_SPRITE_NEG_SIZE
	_electric_shock_screen__left.position = Vector2(0, 540)
	
	_electric_shock_screen__right = SingletonsAndConsts.current_game_front_hud.create_sprite_shader(material_for_electrical_shock_screen)
	_electric_shock_screen__right.scale = ELECTRIC_SHOCK_SCREEN_SPRITE_SIZE
	_electric_shock_screen__right.position = Vector2(960, 540)
	
	##
	
	SingletonsAndConsts.current_game_front_hud.energy_panel.can_show_rewind_label = false
	_broken_energy_panel_frame_texture_rect = SingletonsAndConsts.current_game_front_hud.energy_panel.template__set_cosmetically_broken()

func _deferred_init_all_electrical_equi_particles_related():
	trail_compo_for_elec_equi_break_particle = MultipleTrailsForNodeComponent.new()
	trail_compo_for_elec_equi_break_particle.node_to_host_trails = self
	trail_compo_for_elec_equi_break_particle.trail_type_id = StoreOfTrailType.BASIC_TRAIL
	trail_compo_for_elec_equi_break_particle.connect("on_trail_before_attached_to_node", self, "_trail_before_attached_to_ele_equ_break_particle")
	


##



func _on_PDAR_ShowLinesForDecision_player_entered_in_area():
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	_player.is_show_lines_to_uncaptured_player_capture_regions = true
	
	var wait_tween = create_tween()
	wait_tween.tween_callback(self, "_wait_tween_over__enter_decision_area").set_delay(1.0)
	

func _wait_tween_over__enter_decision_area():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	


func _on_PCAR_First_region_area_captured():
	_first_pcr_stuck_captured = true

func _on_PCAR_First_region_area_uncaptured():
	_first_pcr_stuck_captured = false

##

func _on_PCAR_LastStuck_region_area_captured():
	_last_pcr_stuck_captured = true
	
	if _first_pcr_stuck_captured and _last_pcr_stuck_captured:
		_on_both_pcr_in_decision_tree_captured()

func _on_PCAR_LastStuck_region_area_uncaptured():
	_last_pcr_stuck_captured = false
	_attempt_tween_hide_stuck_warning()

#

func _on_PDAR_StuckShowWarning_player_entered_in_area():
	if _last_pcr_stuck_captured and !_first_pcr_stuck_captured:
		_attempt_tween_show_stuck_warning()



func _attempt_tween_show_stuck_warning():
	if _mod_tweener_for_stuck_label != null:
		_mod_tweener_for_stuck_label.kill()
	
	_mod_tweener_for_stuck_label = create_tween()
	_mod_tweener_for_stuck_label.tween_property(stuck_label_container, "modulate:a", 1.0, 0.5)


func _attempt_tween_hide_stuck_warning():
	if _mod_tweener_for_stuck_label != null:
		_mod_tweener_for_stuck_label.kill()
	
	_mod_tweener_for_stuck_label = create_tween()
	_mod_tweener_for_stuck_label.tween_property(stuck_label_container, "modulate:a", 0.0, 0.5)


################

func _on_both_pcr_in_decision_tree_captured():
	_player.is_show_lines_to_uncaptured_player_capture_regions = false
	base_tileset_blocking_to_last_part.convert_all_filled_tiles_to_unfilled()
	
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	pca_very_last_near_battery.visible = true
	
	var wait_tween = create_tween()
	wait_tween.tween_callback(self, "_wait_tween_over__both_pcr_captured").set_delay(1.0)

func _wait_tween_over__both_pcr_captured():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	



func _on_PDAR_Event_Unre_01_player_entered_in_area():
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	

func _on_PDAR_Event_Explosion_02_player_entered_in_area():
	_start_electric_shock_effects()

func _start_electric_shock_effects():
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Special_Electrical_SwitchFlip, 1.0)
	
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	_start_base_tileset_electrical_equi__nomal__overheat()
	_start_play_electrical_arcs()
	_start_show_electrical_field_on_screen()
	_play_electrical_arc_sounds()

func _start_base_tileset_electrical_equi__nomal__overheat():
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(base_tileset_electrical_equi__nomal, "modulate",TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO , 2.0).set_delay(0.5)
	tween.tween_callback(self, "_end_of_base_tileset_electrical_equi__normal__overheat")
	
	base_tileset_electrical_equi__destroyed.modulate = TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO
	
	_audio_player__ramping_electrical_gen = AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Special_ElectricGenerator, pos_of_equipment__generator.global_position, 1.0)

func _start_play_electrical_arcs():
	for arc in _all_electrical_arc_sprites:
		arc.visible = true
	

func _start_show_electrical_field_on_screen():
	_electric_shock_screen__left.visible = true
	_electric_shock_screen__right.visible = true
	
	_player_modi_energy.custom_event__tween_blackout_hud_sprite(1.0, 0.75)

func _play_electrical_arc_sounds():
	_audio_player__electrical_shock = AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Special_Electrical_Shock, 1.0)
	



####

func _end_of_base_tileset_electrical_equi__normal__overheat():
	_hide_base_tileset_electrical_equi__normal()
	_modify_player_electric_modi__after_explosion()
	_hide_electrical_arcs()
	_hide_electrical_field_on_screen()
	_stop_play_electrical_arc_sounds()
	_play_explosion_particles_and_sounds()
	_start_slow_return_to_normal_modulate__tileset_destroyed()
	
	var wait_tween = create_tween()
	wait_tween.tween_callback(self, "_wait_tween_over__after_electric_explosion").set_delay(0.75)

func _hide_base_tileset_electrical_equi__normal():
	base_tileset_electrical_equi__nomal.visible = false

func _modify_player_electric_modi__after_explosion():
	_player_modi_energy.is_true_instant_drain_and_recharge = true
	_player_modi_energy.is_energy_deductable = true
	_player_modi_energy.allow_display_of_energy_hud = true
	
	_broken_energy_panel_frame_texture_rect.visible = true


func _hide_electrical_arcs():
	for arc in _all_electrical_arc_sprites:
		arc.visible = false
	

func _hide_electrical_field_on_screen():
	var to_finish = 0.75
	
	var tweener = create_tween()
	tweener.set_parallel(true)
	tweener.tween_property(_electric_shock_screen__left, "modulate:a", 0.0, to_finish)
	tweener.tween_property(_electric_shock_screen__right, "modulate:a", 0.0, to_finish)
	tweener.tween_callback(self, "_on_electric_shock_screen_fully_hidden").set_delay(to_finish)
	
	
	_player_modi_energy.custom_event__tween_blackout_hud_sprite(0.0, 0.75)

func _on_electric_shock_screen_fully_hidden():
	_electric_shock_screen__left.visible = false
	_electric_shock_screen__right.visible = false


func _stop_play_electrical_arc_sounds():
	_audio_player__ramping_electrical_gen.stop()
	_audio_player__electrical_shock.stop()


func _start_slow_return_to_normal_modulate__tileset_destroyed():
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(base_tileset_electrical_equi__destroyed, "modulate", Color(1, 1, 1, 1), 8.0)



func _play_explosion_particles_and_sounds():
	for i in 12:
		var pos__01 = pos_of_equipment__generator.global_position
		call_deferred("_deferred_create_burst_particle", pos__01)
		
		var pos__02 = pos_of_equipment__beam.global_position
		call_deferred("_deferred_create_burst_particle", pos__02)
	
	CameraManager.camera.add_stress(1.8)
	
	
	AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Special_Electrical_Explosion, pos_of_equipment__generator.global_position, 1.0)


func _wait_tween_over__after_electric_explosion():
	#game_elements.configure_game_state_for_end_of_cutscene_occurance(false)
	SingletonsAndConsts.current_game_front_hud.template__start_focus_on_energy_panel__with_glow_up(0.4, self, "_finished_energy_panel_brief_focus_and_glow_up", null)

func _finished_energy_panel_brief_focus_and_glow_up(arg_param):
	game_elements.configure_game_state_for_end_of_cutscene_occurance(false)
	


############

func _on_PDAR_Event_Rewi_03_player_entered_in_area():
	_player.is_show_lines_to_uncaptured_player_capture_regions = true
	
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	


##

func _on_CDSU_Battery_player_entered_self__custom_defined():
	_start_item_cutscene()

func _start_item_cutscene():
	var param = PickupImportantItemCutsceneParam.new()
	param.item_texture = cdsu_battery.sprite.texture
	param.staring_pos = cdsu_battery.global_position
	param.ending_pos = _player.global_position
	
	helper__start_cutscene_of_pickup_important_item(param, self, "_on_item_cutscene_end", null)
	

func _on_item_cutscene_end(arg_params):
	_player_modi_energy.is_true_instant_drain_and_recharge = false
	_player_modi_energy.set_max_energy(15)
	
	SingletonsAndConsts.current_game_front_hud.energy_panel.template__set_to_normal__from_cosmetically_broken()
	
	call_deferred("_deferred_on_item_cutscene_end")


func _deferred_on_item_cutscene_end():
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)



###################################
#


func _deferred_create_burst_particle(arg_pos):
	var particle = CenterBasedAttackSprite_Scene.instance()
	
	particle.center_pos_of_basis = arg_pos
	particle.initial_speed_towards_center = -200
	particle.speed_accel_towards_center = 200
	particle.min_starting_distance_from_center = 0
	particle.max_starting_distance_from_center = 2
	particle.texture_to_use = preload("res://WorldRelated/WorldSlices/Stage_001/Level02/Assets/DestroyedElectricalEqui_Particle.png")
	particle.queue_free_at_end_of_lifetime = true
	particle.turn_invisible_at_end_of_lifetime = true
	
	particle.lifetime = 1.0
	particle.lifetime_to_start_transparency = 0.7
	particle.transparency_per_sec = 1 / (particle.lifetime - particle.lifetime_to_start_transparency)
	#particle.visible = true
	#particle.lifetime = 0.4
	
	particle.modulate = TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO
	
	particle.connect("ready", self, "_on_particle_ready", [particle], CONNECT_ONESHOT)
	SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(particle)
	
	return particle

func _on_particle_ready(arg_particle):
	trail_compo_for_elec_equi_break_particle.create_trail_for_node(arg_particle)
	

func _trail_before_attached_to_ele_equ_break_particle(arg_trail, arg_particle_node):
	arg_trail.max_trail_length = 11
	arg_trail.trail_color = TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO
	arg_trail.width = 5
	
	arg_trail.set_to_idle_and_available_if_node_is_not_visible = true

