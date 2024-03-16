extends Control

const RectDrawNode = preload("res://MiscRelated/DrawRelated/RectDrawNode/RectDrawNode.gd")

const EnergyPanel_BatteryFillForeground_Normal = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground.png")
const EnergyPanel_BatteryFillForeground_Normal_Forecasted = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground_Forecasted.png")
const EnergyPanel_BatteryFillForeground_Mega = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground__MegaBattery.png")
const EnergyPanel_BatteryFillForeground_Mega_Forecasted = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground_Forecasted__MegaBattery.png")

#

const ENERGY_LABEL_STRING_FORMAT = "%s / %s"

#

var player_modi__energy setget set_player_modi__energy

#

var original_rewind_reminder_text : String


var player_health_panel
var can_show_rewind_label : bool = true

#

var _template__broken_batt_foreground_texture_rect : TextureRect

#

var _battery_break_rect_draw_node : Node2D

#

onready var energy_label = $EnergyLabel

onready var texture_progress_current = $TextureProgressCurrent
onready var texture_progress_forcasted = $TextureProgressForcasted

onready var bar_foreground_cosmetic_container = $BarForegroundCosmeticContainer
onready var rewind_reminder_label = $RewindReminder

#

func set_player_modi__energy(arg_modi):
	player_modi__energy = arg_modi
	
	player_modi__energy.connect("forecasted_or_current_energy_changed", self, "_on_modi_forecasted_or_current_energy_changed")
	player_modi__energy.connect("max_energy_changed", self, "_on_modi_max_energy_changed")
	
	player_modi__energy.connect("discarged_to_zero_energy", self, "_on_discarged_to_zero_energy")
	player_modi__energy.connect("recharged_from_no_energy", self, "_on_recharged_from_no_energy")
	
	player_modi__energy.connect("battery_visual_type_id_changed", self, "_on_battery_visual_type_id_changed")
	
	GameSettingsManager.connect("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed")
	
	if is_inside_tree():
		_update_display__for_max()
		_update_display__for_current_and_forecasted()
		_update_bar_visual_based_on_type_id()
	
	
	_update_vis_based_on_modi()
	player_modi__energy.connect("allow_display_of_energy_hud_changed", self, "_on_allow_display_of_energy_hud_changed")
	
	_update_display_based_on_is_true_instant_drain()
	player_modi__energy.connect("is_true_instant_drain_and_recharge_changed", self, "_on_is_true_instant_drain_and_recharge_changed")




func _on_modi_forecasted_or_current_energy_changed(arg_curr, arg_forcasted):
	_update_display__for_current_and_forecasted()

func _update_display__for_current_and_forecasted():
	texture_progress_current.value = player_modi__energy.get_current_energy()
	texture_progress_forcasted.value = player_modi__energy.get_forecasted_energy()
	
	_update_label()


func _on_modi_max_energy_changed(arg_val):
	_update_display__for_max()
	

func _update_display__for_max():
	texture_progress_current.max_value = player_modi__energy.get_max_energy()
	texture_progress_forcasted.max_value = player_modi__energy.get_max_energy()
	
	_update_label()

#

func _update_label():
	var curr_energy = ceil(player_modi__energy.get_current_energy())
	var max_energy = ceil(player_modi__energy.get_max_energy())
	
	energy_label.text = ENERGY_LABEL_STRING_FORMAT % [curr_energy, max_energy]


#

func _ready():
	if player_modi__energy != null:
		_update_display__for_max()
		_update_display__for_current_and_forecasted()
		visible = true
	else:
		visible = false
	
	_initialize_rewind_reminder_label()

func _initialize_rewind_reminder_label():
	rewind_reminder_label.visible = false
	original_rewind_reminder_text = rewind_reminder_label.text
	#var corrected_text = orig_text % InputMap.get_action_list("rewind")[0].as_text()
	#rewind_reminder_label.text = corrected_text
	_update_rewind_reminder_label()

func _update_rewind_reminder_label():
	var text = original_rewind_reminder_text % GameSettingsManager.get_game_control_hotkey__as_string("rewind")
	rewind_reminder_label.text = text

func _on_game_control_hotkey_changed(arg_action_name, arg_old, arg_new):
	if arg_action_name == "rewind":
		_update_rewind_reminder_label()



func _on_discarged_to_zero_energy():
	if can_show_rewind_label:
		rewind_reminder_label.visible = true
	

func _on_recharged_from_no_energy():
	rewind_reminder_label.visible = false
	


###

func _on_battery_visual_type_id_changed(arg_id):
	_update_bar_visual_based_on_type_id()
	

func _update_bar_visual_based_on_type_id():
	var id = player_modi__energy.battery_visual_type_id
	if id == player_modi__energy.BatteryVisualTypeId.STANDARD:
		texture_progress_current.texture_progress = EnergyPanel_BatteryFillForeground_Normal_Forecasted
		texture_progress_forcasted.texture_progress = EnergyPanel_BatteryFillForeground_Normal
		
	elif id == player_modi__energy.BatteryVisualTypeId.MEGA:
		texture_progress_current.texture_progress = EnergyPanel_BatteryFillForeground_Mega_Forecasted
		texture_progress_forcasted.texture_progress = EnergyPanel_BatteryFillForeground_Mega
		
	
	


#############

func _on_allow_display_of_energy_hud_changed(arg_val):
	_update_vis_based_on_modi()

func _update_vis_based_on_modi():
	visible = player_modi__energy.allow_display_of_energy_hud
	
	player_health_panel.can_display__by_energy_panel = player_modi__energy.allow_display_of_energy_hud

#

func _on_is_true_instant_drain_and_recharge_changed(arg_val):
	_update_display_based_on_is_true_instant_drain()

func _update_display_based_on_is_true_instant_drain():
	if player_modi__energy.is_true_instant_drain_and_recharge:
		energy_label.visible = false
		
	else:
		energy_label.visible = true
		
	

#############

func create_bar_foreground_sprite(arg_texture : Texture) -> TextureRect:
	var texture_rect = TextureRect.new()
	texture_rect.texture = arg_texture
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_foreground_cosmetic_container.add_child(texture_rect)
	
	return texture_rect

func set_texture_progresses_modulate__tween(arg_modulate : Color, arg_duration : float):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(texture_progress_current, "modulate", arg_modulate, arg_duration)
	tween.tween_property(texture_progress_forcasted, "modulate", arg_modulate, arg_duration)


#

#func template__set_cosmetically_broken():
#	var texture = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/FrameForeground/EnegyPanel_BatteryFrameForeground_Destroyed.png")
#	_template__broken_batt_foreground_texture_rect = create_bar_foreground_sprite(texture)
#	set_texture_progresses_modulate__tween(Color(0.3, 0.3, 0.3, 1.0), 0)
#
#	return _template__broken_batt_foreground_texture_rect

func template__setup_battery_break():
	_template__broken_batt_foreground_texture_rect = create_bar_foreground_sprite(null)
	set_texture_progresses_modulate__tween(Color(0.3, 0.3, 0.3, 1.0), 0)
	
	SingletonsAndConsts.current_game_front_hud.init_control_container_above_most_except_pause()
	
	_init_battery_break_rect_draw_node()
	
	return _template__broken_batt_foreground_texture_rect

func _init_battery_break_rect_draw_node():
	_battery_break_rect_draw_node = Node2D.new()
	_battery_break_rect_draw_node.set_script(RectDrawNode)
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_control_container_above_most_except_pause(_battery_break_rect_draw_node)

#

func template__play_tween_breaking__set_cosmetically_broken():
	_template__broken_batt_foreground_texture_rect.visible = true
	
	var tweener = create_tween()
	tweener.tween_interval(1.0)
	tweener.tween_callback(self, "_do_effects_of_stage_01_crack")
	tweener.tween_interval(0.4)
	tweener.tween_callback(self, "_do_effects_of_stage_02_crack")
	tweener.tween_interval(0.8)
	tweener.tween_callback(self, "_do_effects_of_stage_03_crack")
	

func _do_effects_of_stage_01_crack():
	var crack_texture = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/FrameForeground/EnegyPanel_BatteryFrameForeground_Destroyed_New01.png")
	_template__broken_batt_foreground_texture_rect.texture = crack_texture
	
	CameraManager.camera.add_stress(1.2)
	_play_battery_crack_particles(2, 1)
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_LevelSpecific_BatteryBreak01, 1.0)

func _do_effects_of_stage_02_crack():
	var crack_texture = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/FrameForeground/EnegyPanel_BatteryFrameForeground_Destroyed_New02.png")
	_template__broken_batt_foreground_texture_rect.texture = crack_texture
	
	CameraManager.camera.add_stress(1.2)
	_play_battery_crack_particles(2, 1)
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_LevelSpecific_BatteryBreak02, 1.0)

func _do_effects_of_stage_03_crack():
	var crack_texture = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/FrameForeground/EnegyPanel_BatteryFrameForeground_Destroyed_New03.png")
	_template__broken_batt_foreground_texture_rect.texture = crack_texture
	
	CameraManager.camera.add_stress(1.4)
	_play_battery_crack_particles(10, 4)
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_LevelSpecific_BatteryBreak03, 1.0)

#

func _play_battery_crack_particles(arg_count_of_bottom : int, arg_count_of_sides : int):
	var rng = SingletonsAndConsts.non_essential_rng
	for i in arg_count_of_bottom:
		var details = _get_rand_battery_particles_details__from_below(rng)
		_play_single_battery_crack_particle__from_details(rng, details)
		var details2 = _get_rand_battery_particles_details__from_top(rng)
		_play_single_battery_crack_particle__from_details(rng, details2)
	
	for i in arg_count_of_sides:
		var details = _get_rand_battery_particles_details__from_left(rng)
		_play_single_battery_crack_particle__from_details(rng, details)
		var details2 = _get_rand_battery_particles_details__from_right(rng)
		_play_single_battery_crack_particle__from_details(rng, details2)

func _play_single_battery_crack_particle__from_details(arg_rng : RandomNumberGenerator, details : Array):
	_construct_rect_draw_param_and_tweener_for_battery_break_particle(Color("#654C01"),
		0.9, 0.9, 0.0,
		3, 5, 0,
		details[2], 0.5,
		details[0], details[1])

func _get_rand_battery_particles_details__from_below(arg_rng : RandomNumberGenerator):
	var rand_x_pos = arg_rng.randf_range(texture_progress_current.rect_global_position.x, (texture_progress_current.rect_global_position.x + texture_progress_current.rect_size.x))
	var y_pos = texture_progress_current.rect_global_position.y + texture_progress_current.rect_size.y
	var initial_pos = Vector2(rand_x_pos, y_pos)
	
	#var rand_angle = arg_rng.randf_range(PI/8, 7*PI/8)
	var center_pos = (texture_progress_current.rect_global_position + texture_progress_current.rect_size/2)
	var rand_angle = initial_pos.angle_to_point(center_pos)
	var rand_dist = arg_rng.randf_range(30, 50)
	
	
	var final_pos = initial_pos + Vector2(rand_dist, 0).rotated(rand_angle)
	
	var rand_lifetime : float = arg_rng.randf_range(1.0, 1.75)
	
	return [initial_pos, final_pos, rand_lifetime]


func _get_rand_battery_particles_details__from_top(arg_rng : RandomNumberGenerator):
	var rand_x_pos = arg_rng.randf_range(texture_progress_current.rect_global_position.x, (texture_progress_current.rect_global_position.x + texture_progress_current.rect_size.x))
	var y_pos = texture_progress_current.rect_global_position.y
	var initial_pos = Vector2(rand_x_pos, y_pos)
	
	#var rand_angle = arg_rng.randf_range(PI/8, 7*PI/8)
	var center_pos = (texture_progress_current.rect_global_position + texture_progress_current.rect_size/2)
	var rand_angle = initial_pos.angle_to_point(center_pos)
	var rand_dist = arg_rng.randf_range(30, 50)
	
	
	var final_pos = initial_pos + Vector2(rand_dist, 0).rotated(rand_angle)
	
	var rand_lifetime : float = arg_rng.randf_range(1.0, 1.75)
	
	return [initial_pos, final_pos, rand_lifetime]


func _get_rand_battery_particles_details__from_left(arg_rng : RandomNumberGenerator):
	var rand_y_pos = arg_rng.randf_range(texture_progress_current.rect_global_position.y, (texture_progress_current.rect_global_position.y + texture_progress_current.rect_size.y))
	var x_pos = texture_progress_current.rect_global_position.x #+ texture_progress_current.rect_size.x
	var initial_pos = Vector2(x_pos, rand_y_pos)
	
	#var rand_angle = arg_rng.randf_range(PI/8, 7*PI/8)
	var center_pos = (texture_progress_current.rect_global_position + texture_progress_current.rect_size/2)
	var rand_angle = initial_pos.angle_to_point(center_pos)
	var rand_dist = arg_rng.randf_range(30, 50)
	
	
	var final_pos = initial_pos + Vector2(rand_dist, 0).rotated(rand_angle)
	
	var rand_lifetime : float = arg_rng.randf_range(1.0, 1.75)
	
	return [initial_pos, final_pos, rand_lifetime]

func _get_rand_battery_particles_details__from_right(arg_rng : RandomNumberGenerator):
	var rand_y_pos = arg_rng.randf_range(texture_progress_current.rect_global_position.y, (texture_progress_current.rect_global_position.y + texture_progress_current.rect_size.y))
	var x_pos = texture_progress_current.rect_global_position.x + texture_progress_current.rect_size.x
	var initial_pos = Vector2(x_pos, rand_y_pos)
	
	#var rand_angle = arg_rng.randf_range(PI/8, 7*PI/8)
	var center_pos = (texture_progress_current.rect_global_position + texture_progress_current.rect_size/2)
	var rand_angle = initial_pos.angle_to_point(center_pos)
	var rand_dist = arg_rng.randf_range(30, 50)
	
	
	var final_pos = initial_pos + Vector2(rand_dist, 0).rotated(rand_angle)
	
	var rand_lifetime : float = arg_rng.randf_range(1.0, 1.75)
	
	return [initial_pos, final_pos, rand_lifetime]


func _construct_rect_draw_param_and_tweener_for_battery_break_particle(arg_modulate : Color,
		arg_mod_a_start : float, arg_mod_a_mid : float, arg_mod_a_end : float,
		arg_xy_start : float, arg_xy_mid : float, arg_xy_end : float,
		arg_lifetime : float, arg_lifetime_ratio_of_mid_to_end : float,
		arg_center_pos_initial : Vector2, arg_center_pos_final : Vector2):
	
	arg_modulate.a = arg_mod_a_start
	
	var draw_param = _battery_break_rect_draw_node.DrawParams.new()
	draw_param.fill_color = arg_modulate
	draw_param.outline_color = arg_modulate
	draw_param.outline_width = 0
	
	draw_param.lifetime_to_start_transparency = -1
	draw_param.angle_rad = 0
	draw_param.lifetime_of_draw = arg_lifetime + 0.3
	draw_param.has_lifetime = true
	draw_param.pivot_point = Vector2(0, 0)
	
	var size = Vector2(arg_xy_start, arg_xy_start)
	var initial_rect = Rect2(arg_center_pos_initial - (size/2), size)
	draw_param.initial_rect = initial_rect
	
	_battery_break_rect_draw_node.add_draw_param(draw_param)
	
	########
	
	var lifetime_to_mid = arg_lifetime * arg_lifetime_ratio_of_mid_to_end
	var lifetime_to_end = arg_lifetime - lifetime_to_mid
	
	var tweener = create_tween()
	tweener.set_parallel(true)
	tweener.tween_property(draw_param, "current_rect:position", arg_center_pos_final, arg_lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tweener.tween_property(draw_param, "current_rect:size", Vector2(arg_xy_mid, arg_xy_mid), lifetime_to_mid)
	tweener.tween_property(draw_param, "fill_color:a", arg_mod_a_mid, lifetime_to_mid)
	tweener.set_parallel(false)
	
	tweener.tween_interval(lifetime_to_mid)
	tweener.set_parallel(true)
	tweener.tween_property(draw_param, "current_rect:size", Vector2(arg_xy_end, arg_xy_end), lifetime_to_end)
	tweener.tween_property(draw_param, "fill_color:a", arg_mod_a_end, lifetime_to_end)
	

##

func template__set_to_normal__from_cosmetically_broken():
	if is_instance_valid(_template__broken_batt_foreground_texture_rect):
		_template__broken_batt_foreground_texture_rect.visible = false
		_template__broken_batt_foreground_texture_rect.queue_free()
	set_texture_progresses_modulate__tween(Color(1, 1, 1, 1.0), 1.0)

#

func template__do_brief_glowup(arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params):
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "modulate", Color(1.6, 1.6, 1.6, 1.0), 0.5)
	tween.tween_interval(0.5)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	tween.tween_callback(arg_func_source, arg_func_name, [arg_func_params]).set_delay(arg_delay_for_func_call)

