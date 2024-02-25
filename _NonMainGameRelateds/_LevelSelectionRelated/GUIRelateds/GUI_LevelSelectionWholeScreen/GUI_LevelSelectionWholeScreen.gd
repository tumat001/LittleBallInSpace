extends Control

const GUI_LevelLayoutEle_Tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/GUI_LevelLayoutEle_Tile.gd")
const GUI_AbstractLevelLayout = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd")
const GameBackground = preload("res://GameBackgroundRelated/GameBackground.gd")

const RectDrawNode = preload("res://MiscRelated/DrawRelated/RectDrawNode/RectDrawNode.gd")



const LEVEL_HOVER_RECT_PARTICLE__SPEED_RATIO_TO_LIN_VEL_CHANGE : float = 0.08

const LEVEL_HOVER_RECT_PARTICLE__LEN_WIDTH_INITIAL : float = 2.0
const LEVEL_HOVER_RECT_PARTICLE__LEN_WIDTH_MID : float = 4.0
const LEVEL_HOVER_RECT_PARTICLE__LEN_WIDTH_FINAL : float = 0.0

const LEVEL_HOVER_RECT_PARTICLE__MOD_A_INITIAL : float = 0.2
const LEVEL_HOVER_RECT_PARTICLE__MOD_A_MID : float = 0.4
const LEVEL_HOVER_RECT_PARTICLE__MOD_A_FINAL : float = 0.0

const LEVEL_HOVER_RECT_PARTICLE__DURATION_TO_MID : float = 0.2
const LEVEL_HOVER_RECT_PARTICLE__DURATION_TO_FINAL : float = 0.5
const LEVEL_HOVER_RECT_PARTICLE__DURATION_TOTAL : float = LEVEL_HOVER_RECT_PARTICLE__DURATION_TO_MID + LEVEL_HOVER_RECT_PARTICLE__DURATION_TO_FINAL

const LEVEL_HOVER_RECT_PARTICLE__SPEED : float = 40.0

const LEVEL_HOVER_RECT_PARTICLE__PARTICLE_COUNT_MIN : int = 3
const LEVEL_HOVER_RECT_PARTICLE__PARTICLE_COUNT_MAX : int = 5


#

signal prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)

signal triggered_circular_burst_on_curr_ele_for_victory(arg_tile_ele_for_playing_victory_animation_for, arg_level_details)
signal triggered_circular_burst_on_curr_ele_for_victory__as_additionals(arg_tile_eles)

signal current_level_layout_changed(arg_layout, arg_layout_id)

#

var _current_active_level_layout

var _layout_id_to_level_layout_map : Dictionary

var non_essential_rng : RandomNumberGenerator

#

onready var abstract_level_layout_container = $AbstractLevelLayoutContainer
onready var hud_container = $HUDContainer

onready var dialog_panel = $HUDContainer/DialogPanel
onready var level_title_tooltip_body = $HUDContainer/DialogPanel/Marginer/VBoxContainer/LevelTitleTooltipBody
onready var level_desc_tooltip_body = $HUDContainer/DialogPanel/Marginer/VBoxContainer/LevelDescTooltipBody

onready var level_details_panel = $HUDContainer/LevelDetailsPanel
onready var level_layout_shortcut_panel = $HUDContainer/LevelLayoutShortcutPanel

onready var coins_panel = $HUDContainer/VBoxContainer/CoinsPanel
onready var level_count_panel = $HUDContainer/VBoxContainer/LevelsCompletedPanel/

onready var particles_container = $ParticlesContainer
onready var circular_draw_node__circle_burst = $CircularDrawNode_CircleBurst
onready var rect_draw_node__level_hover = $RectDrawNode_LevelHovered

onready var game_background = $GameBackground

onready var stats_for_level_button = $HUDContainer/DialogPanel/Marginer/VBoxContainer/LevelTitleTooltipBody/StatsForLevelButton

onready var trophy_panel = $HUDContainer/VBoxContainer/TrophyPanel

#

#############

func _ready():
	level_title_tooltip_body.bbcode_align_mode = level_title_tooltip_body.BBCodeAlignMode.CENTER
	level_title_tooltip_body.default_font_size = 32
	level_desc_tooltip_body.default_font_size = 24
	
	if GameSaveManager.is_manager_initialized():
		_initialize_coins_panel()
		_initialize_level_count_panel()
		_initialize_layout_shortcut_panel()
		
	else:
		coins_panel.visible = false
		coins_panel.display_type = coins_panel.DisplayType.NUMERICAL
		level_count_panel.visible = false
		GameSaveManager.connect("save_manager_initialized", self, "_on_save_manager_initialized", [], CONNECT_ONESHOT)
	
	connect("visibility_changed", self, "_on_visibility_changed", [], CONNECT_DEFERRED)
	_on_visibility_changed()
	
	trophy_panel.can_show_healths_related_trophies = false
	
	non_essential_rng = SingletonsAndConsts.non_essential_rng

func _on_visibility_changed():
	game_background.visible = visible
	


func _on_save_manager_initialized():
	_initialize_coins_panel()
	_initialize_level_count_panel()
	_initialize_layout_shortcut_panel()
	

#

func _initialize_coins_panel():
	coins_panel.visible = true
	coins_panel.display_type = coins_panel.DisplayType.NUMERICAL
	coins_panel.instant_change_tweener_transition = true
	coins_panel.configure_self_to_monitor_coin_status_for_whole_game()
#
#	var curr_coin_count = GameSaveManager.get_total_coin_collected_count()
#	var total_coin_count = StoreOfLevels.get_total_coin_count()
#
#	coins_panel.set_max_coin_count(total_coin_count)
#	coins_panel.set_curr_coin_count(curr_coin_count)
#
#	GameSaveManager.connect("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed")
#
#func _on_coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id):
#	var curr_coin_count = GameSaveManager.get_total_coin_collected_count()
#	coins_panel.set_curr_coin_count(curr_coin_count)
#


func _initialize_level_count_panel():
	level_count_panel.visible = true
	level_count_panel.configure_self_to_monitor_level_count_status()


func _initialize_layout_shortcut_panel():
	level_layout_shortcut_panel.set_level_selection_whole_screen__and_init(self)
	
	level_layout_shortcut_panel.connect("layout_tile_pressed", self, "_on_shortcut_panel_layout_tile_pressed")

#

func show_level_layout__last_saved_in_save_manager():
	show_level_layout(GameSaveManager.last_opened_level_layout_id, GameSaveManager.last_hovered_over_level_layout_element_id, false)


func show_level_layout(arg_layout_id, arg_layout_element_id_of_cursor, arg_is_instant_in_transition):
	if !is_instance_valid(_current_active_level_layout) or _current_active_level_layout.level_layout_id != arg_layout_id:
		for child in abstract_level_layout_container.get_children():
			if child.level_layout_id != arg_layout_id:
				_set_level_layout_as_inactive(child)
		
		#
		
		var layout_scene : GUI_AbstractLevelLayout
		if _layout_id_to_level_layout_map.has(arg_layout_id):
			layout_scene = _layout_id_to_level_layout_map[arg_layout_id]
		else:
			layout_scene = _create_and_configure_new_layout_scene(arg_layout_id)
		
		layout_scene.layout_ele_id_to_summon_cursor_to = arg_layout_element_id_of_cursor
		_set_level_layout_as_current_and_active(layout_scene)
		
		#
		
		#dont do this since gui_layout may define its own background
#		var level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(arg_layout_id)
#		game_background.set_current_background_type(level_layout_details.background_type, true)
		
		
		layout_scene.game_background = game_background
		
#		# sss
#		var level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(arg_layout_id)
#		var all_stars_collected = StoreOfLevels.is_level_layout_all_associated_levels_all_coins_collected(layout_scene.level_layout_id)
#		game_background.config_self_based_on_background_params_and_update(level_layout_details.background_type, all_stars_collected, true)
#		#end of sss
		
		
		
		#call_deferred("_deferred_background_init", layout_scene, arg_is_instant_in_transition)
		
		layout_scene._overridable__setup_game_background(arg_is_instant_in_transition)
		
		if StoreOfLevels.is_level_layout_all_associated_levels_all_coins_collected(layout_scene.level_layout_id):
			game_background.request_show_brightened_star_background__star_collectible_collected()
		else:
			game_background.request_unshow_brightened_star_background__star_collectible_uncollected()
		

#func _deferred_background_init(layout_scene, arg_is_instant_in_transition):
#	layout_scene._overridable__setup_game_background(arg_is_instant_in_transition)
#
#	if StoreOfLevels.is_level_layout_all_associated_levels_all_coins_collected(layout_scene.level_layout_id):
#		game_background.request_show_brightened_star_background__star_collectible_collected()
#	else:
#		game_background.request_unshow_brightened_star_background__star_collectible_uncollected()

	



func _create_and_configure_new_layout_scene(arg_layout_id):
	var layout_scene = StoreOfLevelLayouts.generate_instance_of_layout(arg_layout_id)
	layout_scene.level_layout_id = arg_layout_id
	abstract_level_layout_container.add_child(layout_scene)
	
	layout_scene.gui_level_selection_whole_screen = self
	layout_scene.particles_container = particles_container
	
	_layout_id_to_level_layout_map[arg_layout_id] = layout_scene
	
	return layout_scene

func create_and_configure_all_layout_scenes():
	for layout_id in StoreOfLevelLayouts.LevelLayoutIds.values():
		if !_layout_id_to_level_layout_map.has(layout_id):
			var layout_scene = _create_and_configure_new_layout_scene(layout_id)
			_set_level_layout_as_inactive(layout_scene)

func get_layout_id_to_level_layout_map() -> Dictionary:
	return _layout_id_to_level_layout_map



func _set_level_layout_as_inactive(layout_scene : GUI_AbstractLevelLayout):
	layout_scene.is_layout_enabled = false
	
	if layout_scene.is_connected("currently_hovered_layout_ele_changed", self, "_on_layout_currently_hovered_layout_ele_changed"):
		layout_scene.disconnect("currently_hovered_layout_ele_changed", self, "_on_layout_currently_hovered_layout_ele_changed")
	
	if layout_scene.is_connected("prompt_entered_into_level", self, "_on_layout_prompt_entered_into_level"):
		layout_scene.disconnect("prompt_entered_into_level", self, "_on_layout_prompt_entered_into_level")
	
	if layout_scene.is_connected("prompt_entered_into_link_to_other_layout", self, "_on_layout_prompt_entered_into_link_to_other_layout"):
		layout_scene.disconnect("prompt_entered_into_link_to_other_layout", self, "_on_layout_prompt_entered_into_link_to_other_layout")
	
	if layout_scene.is_connected("triggered_circular_burst_on_curr_ele_for_victory", self, "_on_triggered_circular_burst_on_curr_ele_for_victory"):
		layout_scene.disconnect("triggered_circular_burst_on_curr_ele_for_victory", self, "_on_triggered_circular_burst_on_curr_ele_for_victory")
	
	if layout_scene.is_connected("triggered_circular_burst_on_curr_ele_for_victory__as_additionals", self, "_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals"):
		layout_scene.disconnect("triggered_circular_burst_on_curr_ele_for_victory__as_additionals", self, "_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals")


func _set_level_layout_as_current_and_active(layout_scene : GUI_AbstractLevelLayout):
	GameSaveManager.last_opened_level_layout_id = layout_scene.level_layout_id
	SingletonsAndConsts.current_level_layout_id = layout_scene.level_layout_id
	
	_current_active_level_layout = layout_scene
	
	layout_scene.is_layout_enabled = true
	
	layout_scene.connect("currently_hovered_layout_ele_changed", self, "_on_layout_currently_hovered_layout_ele_changed")
	layout_scene.connect("prompt_entered_into_level", self, "_on_layout_prompt_entered_into_level")
	layout_scene.connect("prompt_entered_into_link_to_other_layout", self, "_on_layout_prompt_entered_into_link_to_other_layout")
	layout_scene.connect("triggered_circular_burst_on_curr_ele_for_victory", self, "_on_triggered_circular_burst_on_curr_ele_for_victory")
	layout_scene.connect("triggered_circular_burst_on_curr_ele_for_victory__as_additionals", self, "_on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals")
	
	_on_layout_currently_hovered_layout_ele_changed(layout_scene.get_currently_hovered_layout_ele_id(), layout_scene.get_currently_hovered_tile())
	
	emit_signal("current_level_layout_changed", _current_active_level_layout, _current_active_level_layout.level_layout_id)

#


func _update_level_desc_tooltip_body(arg_currently_hovered_tile):
	var arg_level_details = arg_currently_hovered_tile.level_details
	var arg_level_layout_details = arg_currently_hovered_tile.level_layout_details
	
	if arg_level_details != null:
		level_title_tooltip_body.default_font_color = arg_level_details.get_title_color_based_on_level_type()
		
		level_title_tooltip_body.descriptions = arg_level_details.level_name
		level_desc_tooltip_body.descriptions = arg_level_details.level_desc
		
		level_title_tooltip_body.update_display()
		level_desc_tooltip_body.update_display()
		
	elif arg_level_layout_details != null:
		level_title_tooltip_body.default_font_color = Color("#dddddd")
		
		level_title_tooltip_body.descriptions = arg_level_layout_details.level_layout_name
		level_desc_tooltip_body.descriptions = arg_level_layout_details.level_layout_desc
		
		level_title_tooltip_body.update_display()
		level_desc_tooltip_body.update_display()
		
	else:
		level_title_tooltip_body.descriptions = []
		level_desc_tooltip_body.descriptions = []
		
		level_title_tooltip_body.update_display()
		level_desc_tooltip_body.update_display()
		
	

#

func play_victory_animation_on_level_id(arg_level_id) -> bool:
	if is_instance_valid(_current_active_level_layout):
		return _current_active_level_layout.play_victory_animation_on_level_id(arg_level_id)
	else:
		return false

func play_victory_animation_on_level_ids__as_additonals(arg_level_ids) -> bool:
	if is_instance_valid(_current_active_level_layout):
		return _current_active_level_layout.play_victory_animation_on_level_ids__as_additonals(arg_level_ids)
	else:
		return false

#

func _on_layout_currently_hovered_layout_ele_changed(arg_id, arg_currently_hovered_tile):
	_update_level_desc_tooltip_body(arg_currently_hovered_tile)
	_update_level_details_panel(arg_currently_hovered_tile.level_details)
	_update_stats_button_visibility(arg_currently_hovered_tile.level_details)

func _update_level_details_panel(arg_level_details):
	if arg_level_details != null:
		level_details_panel.set_level_details(arg_level_details)
		
	else:
		level_details_panel.hide_contents()
		
	

func _update_stats_button_visibility(arg_level_details):
	if arg_level_details != null:
		_attempt_set_visibility_of_stats_for_level_button(true)
	else:
		_attempt_set_visibility_of_stats_for_level_button(false)

func _attempt_set_visibility_of_stats_for_level_button(arg_val):
	if GameSaveManager.can_view_game_stats:
		stats_for_level_button.visible = arg_val
	else:
		stats_for_level_button.visible = false

#

func _on_layout_prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	emit_signal("prompt_entered_into_level", arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)
	

func _on_layout_prompt_entered_into_link_to_other_layout(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	#var level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(arg_currently_hovered_tile.layout_id_to_link_to)
	var curr_level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(SingletonsAndConsts.current_level_layout_id)
	
	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(curr_level_layout_details.transition_id__entering_layout__out)
	transition.circle_center = arg_currently_hovered_tile.get_center_position()
	transition.connect("transition_finished", self, "_on_transition_in__from_old_layout_finished", [arg_currently_hovered_tile, curr_level_layout_details, transition])
	SingletonsAndConsts.current_master.play_transition(transition)

func _on_transition_in__from_old_layout_finished(arg_hovered_tile, arg_level_layout_details, arg_old_transition):
	show_level_layout(arg_hovered_tile.level_layout_details.level_layout_id, arg_hovered_tile.layout_ele_id_to_put_cursor_to, false)
	arg_old_transition.queue_free()
	
	#NOTE: see if anything has changed. Commented this since this does nothing...
	#var level_layout_of_in__instance = StoreOfLevelLayouts.generate_instance_of_layout(arg_hovered_tile.level_layout_details.level_layout_id)
	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(arg_hovered_tile.level_layout_details.transition_id__entering_layout__in)
	transition.queue_free_on_end_of_transition = true
	transition.circle_center = arg_hovered_tile.get_center_position()
	SingletonsAndConsts.current_master.play_transition(transition)



func play_circular_draw_node__circle_burst__for_victory(arg_pos : Vector2):
	var draw_params = circular_draw_node__circle_burst.DrawParams.new()
	draw_params.center_pos = arg_pos
	draw_params.current_radius = 20
	draw_params.radius_per_sec = 130
	draw_params.fill_color = Color(1, 1, 1, 0.0)
	
	draw_params.outline_color = Color(1, 1, 1, 0.6)
	draw_params.outline_width = 8
	
	draw_params.lifetime_of_draw = 0.6
	draw_params.lifetime_to_start_transparency = draw_params.lifetime_of_draw - 0.2
	
	circular_draw_node__circle_burst.add_draw_param(draw_params)
	
	

func _on_triggered_circular_burst_on_curr_ele_for_victory(arg_tile_ele_for_playing_victory_animation_for, arg_level_details):
	emit_signal("triggered_circular_burst_on_curr_ele_for_victory", arg_tile_ele_for_playing_victory_animation_for, arg_level_details)

func _on_triggered_circular_burst_on_curr_ele_for_victory__as_additionals(arg_tile_eles):
	emit_signal("triggered_circular_burst_on_curr_ele_for_victory__as_additionals", arg_tile_eles)
	

###


func play_rect_draw_node__rect_particles_on_level_hover(arg_gui_level_tile : GUI_LevelLayoutEle_Tile):
	var level_details = arg_gui_level_tile.level_details
	
	var rand_particle_count = non_essential_rng.randi_range(LEVEL_HOVER_RECT_PARTICLE__PARTICLE_COUNT_MIN, LEVEL_HOVER_RECT_PARTICLE__PARTICLE_COUNT_MAX)
	var modulate_i : int = 0
	for i in rand_particle_count:
		
		var pos_to_use = arg_gui_level_tile.get_center_position()
		var modulate_to_use = level_details.modulates_for_level_hover_list[modulate_i]
		
		for j in 2:
			_play_rect_draw_node__single_rect_particle_on_level_hover(pos_to_use, modulate_to_use)
		
		##
		
		modulate_i += 1
		if level_details.modulates_for_level_hover_list.size() <= modulate_i:
			modulate_i = 0
		

func _play_rect_draw_node__single_rect_particle_on_level_hover(arg_pos : Vector2, arg_modulate : Color):
	
	var lifetime_modif : float = non_essential_rng.randf_range(-0.15, 0.15)
	var lifetime__final_val = LEVEL_HOVER_RECT_PARTICLE__DURATION_TOTAL + lifetime_modif
	
	var lifetime_to_mid__final_val = LEVEL_HOVER_RECT_PARTICLE__DURATION_TO_MID + lifetime_modif/2
	var lifetime_to_final__final_val = LEVEL_HOVER_RECT_PARTICLE__DURATION_TO_FINAL + lifetime_modif/2
	
	var speed_ratio_modif = non_essential_rng.randf_range(-0.2, 0.2)
	var speed__final_val = LEVEL_HOVER_RECT_PARTICLE__SPEED + (LEVEL_HOVER_RECT_PARTICLE__SPEED * speed_ratio_modif)
	
	var arg_final_val_angle = non_essential_rng.randf_range(0, 2*PI)
	
	var final_center_pos__final_calced_pos = Vector2(speed__final_val, 0).rotated(arg_final_val_angle) + arg_pos
	
	var mod_a_modif : float = non_essential_rng.randf_range(-0.1, 0.1)
	var mod_a_initial__final_val = LEVEL_HOVER_RECT_PARTICLE__MOD_A_INITIAL + mod_a_modif
	var mod_a_mid__final_val = LEVEL_HOVER_RECT_PARTICLE__MOD_A_MID + mod_a_modif
	arg_modulate.a = mod_a_mid__final_val
	
	var length_wid_modif : float = non_essential_rng.randf_range(-0.1, 0.1)
	var len_wid_initial__final_val = LEVEL_HOVER_RECT_PARTICLE__LEN_WIDTH_INITIAL + length_wid_modif
	var len_wid_mid__final_val = LEVEL_HOVER_RECT_PARTICLE__LEN_WIDTH_MID + length_wid_modif
	
	
	var draw_param : RectDrawNode.DrawParams = _construct_rect_draw_param__rect_particles_on_level_hover(arg_pos, arg_modulate, lifetime__final_val, len_wid_initial__final_val)
	_tween_rect_particles_on_level_hover_rect_draw_param__using_params(draw_param, lifetime_to_mid__final_val, lifetime_to_final__final_val, final_center_pos__final_calced_pos, mod_a_mid__final_val, 0.0, len_wid_mid__final_val, 0.0)


func _construct_rect_draw_param__rect_particles_on_level_hover(arg_center_pos : Vector2, 
		arg_base_modulate : Color, arg_total_lifetime : float, arg_length_width : float):
	
	var draw_param = rect_draw_node__level_hover.DrawParams.new()
	
	
	var rand_modulate = arg_base_modulate * non_essential_rng.randf_range(0.6, 1.0)
	rand_modulate.a = 0.75
	draw_param.fill_color = rand_modulate
	draw_param.outline_color = rand_modulate
	draw_param.outline_width = 0
	
	draw_param.lifetime_to_start_transparency = -1
	draw_param.angle_rad = 0
	draw_param.lifetime_of_draw = arg_total_lifetime + 0.3
	draw_param.has_lifetime = true
	draw_param.pivot_point = Vector2(0, 0)
	
	var size = Vector2(arg_length_width, arg_length_width)
	var initial_rect = Rect2(arg_center_pos - (size/2), size)
	draw_param.initial_rect = initial_rect
	
	rect_draw_node__level_hover.add_draw_param(draw_param)
	
	
	return draw_param

func _tween_rect_particles_on_level_hover_rect_draw_param__using_params(arg_rect_draw_param : RectDrawNode.DrawParams, 
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
	

##

func _on_shortcut_panel_layout_tile_pressed(arg_tile, arg_id):
	if SingletonsAndConsts.current_master.can_level_layout_do_action(): #!SingletonsAndConsts.current_master._is_transitioning and !SingletonsAndConsts.current_master._is_in_game_or_loading_to_game:
		show_level_layout(arg_id, arg_tile.layout_ele_id_to_put_cursor_to, true)


#########

func get_current_active_level_layout() -> GUI_AbstractLevelLayout:
	return _current_active_level_layout

#

func _on_StatsForLevelButton_pressed():
	SingletonsAndConsts.current_master.gs_gui_control_tree.show_gsm_level_panel(_current_active_level_layout.get_currently_hovered_tile().level_details.level_id)
	

