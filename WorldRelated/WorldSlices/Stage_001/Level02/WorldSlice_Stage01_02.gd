extends "res://WorldRelated/AbstractWorldSlice.gd"



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

#

onready var vkp_rewind = $MessegesContainer/VBoxContainer/VKP_Rewind
onready var vkp_rewind_02 = $MessegesContainer/StuckLabelContainer/VKP_Rewind

onready var stuck_label_container = $MessegesContainer/StuckLabelContainer

onready var pdar_stuck_show_warning = $AreaRegionContainer/PDAR_StuckShowWarning

onready var base_tileset_blocking_to_last_part = $TileContainer/BaseTileSet_ToggleAtCapture

onready var pca_very_last_near_battery = $AreaRegionContainer/PCAR_NearBatt

#

onready var base_tileset_electrical_equi__nomal = $TileContainer/BaseTileSet_ElectricalGenExpl_Normal
onready var base_tileset_electrical_equi__destroyed = $MiscContainer/BaseTileSet_ElectricalGenExpl_Destroyed

#

onready var electrical_arc_sprite_01 = $MiscContainer/ElectricalArcSpriteEffect
onready var electrical_arc_sprite_02 = $MiscContainer/ElectricalArcSpriteEffect2
onready var electrical_arc_sprite_03 = $MiscContainer/ElectricalArcSpriteEffect3
onready var electrical_arc_sprite_04 = $MiscContainer/ElectricalArcSpriteEffect4
onready var electrical_arc_sprite_05 = $MiscContainer/ElectricalArcSpriteEffect5
var _all_electrical_arc_sprites : Array

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
	
	
	_electric_shock_screen__left = SingletonsAndConsts.current_game_front_hud.create_sprite_shader(material)
	_electric_shock_screen__left.scale = ELECTRIC_SHOCK_SCREEN_SPRITE_SIZE
	_electric_shock_screen__left.position = Vector2(0, 540)
	
	_electric_shock_screen__right = SingletonsAndConsts.current_game_front_hud.create_sprite_shader(material)
	_electric_shock_screen__right.scale = ELECTRIC_SHOCK_SCREEN_SPRITE_NEG_SIZE
	_electric_shock_screen__right.position = Vector2(960, 540)
	

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
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	_start_base_tileset_electrical_equi__nomal__overheat()
	_start_play_electrical_arcs()
	_start_show_electrical_field_on_screen()
	_play_electrical_arc_sounds()

func _start_base_tileset_electrical_equi__nomal__overheat():
	# todo play sound effect for ramping up of electical equi
	
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(base_tileset_electrical_equi__nomal, "modulate",TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO , 2.0).set_delay(0.5)
	tween.tween_callback(self, "_end_of_base_tileset_electrical_equi__normal__overheat")
	
	base_tileset_electrical_equi__destroyed.modulate = TILESET_ELECTRICAL_EQUIPMENT_MODULATE_TO_TRANSITION_TO


func _start_play_electrical_arcs():
	for arc in _all_electrical_arc_sprites:
		arc.visible = true
	

func _start_show_electrical_field_on_screen():
	_electric_shock_screen__left.visible = true
	_electric_shock_screen__right.visible = true

func _play_electrical_arc_sounds():
	#todo
	pass
	



####

func _end_of_base_tileset_electrical_equi__normal__overheat():
	_hide_base_tileset_electrical_equi__normal()
	_modify_player_electric_modi__after_explosion()
	_hide_electrical_arcs()
	_hide_electrical_field_on_screen()
	_stop_play_electrical_arc_sounds()
	_play_explosion_particles_and_sound()
	
	var wait_tween = create_tween()
	wait_tween.tween_callback(self, "_wait_tween_over__after_electric_explosion").set_delay(0.75)

func _hide_base_tileset_electrical_equi__normal():
	base_tileset_electrical_equi__nomal.visible = false

func _modify_player_electric_modi__after_explosion():
	_player_modi_energy.is_true_instant_drain_and_recharge = true
	_player_modi_energy.is_energy_deductable = true
	_player_modi_energy.allow_display_of_energy_hud = true
	

func _hide_electrical_arcs():
	for arc in _all_electrical_arc_sprites:
		arc.visible = false
	

func _hide_electrical_field_on_screen():
	var to_finish = 0.75
	
	var tweener = create_tween()
	tweener.tween_property(_electric_shock_screen__left, "modulate:a", 0.0, to_finish)
	tweener.tween_property(_electric_shock_screen__right, "modulate:a", 0.0, to_finish)
	tweener.tween_callback(self, "_on_electric_shock_screen_fully_hidden").set_delay(to_finish)

func _on_electric_shock_screen_fully_hidden():
	_electric_shock_screen__left.visible = false
	_electric_shock_screen__right.visible = false


func _stop_play_electrical_arc_sounds():
	pass
	#todo


func _start_slow_return_to_normal_modulate__tileset_destroyed():
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(base_tileset_electrical_equi__destroyed, "modulate", Color(1, 1, 1, 1), 8.0)



func _play_explosion_particles_and_sound():
	pass
	
	





func _wait_tween_over__after_electric_explosion():
	game_elements.configure_game_state_for_end_of_cutscene_occurance(false)
	

############

func _on_PDAR_Event_Rewi_03_player_entered_in_area():
	_player.is_show_lines_to_uncaptured_player_capture_regions = true
	
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	

