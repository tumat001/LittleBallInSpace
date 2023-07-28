extends MarginContainer

const TextureRectComponentPool = preload("res://MiscRelated/PoolRelated/Imps/TextureRectComponentPool.gd")

#const HealthPanel_FillForeground_01 = preload("res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForeground_Type01.png")
#const HealthPanel_FillForeground_02 = preload("res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForeground_Type02.png")
#const HealthPanel_FillForeground_03 = preload("res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForeground_Type03.png")

#

const SEPARATOR_X_STARTING_POS = 14
const SEPARATOR_X_ENDING_POS = 214
const SEPARATOR_Y_POS = 2

#

var health_separator_texture_rect_compo_pool : TextureRectComponentPool

#

class DisplayParams:
	var player
	
	var health_breakpoints : Array
	var max_health
	var current_health
	var is_dead

var _player

#

const DISPLAY_SELF_DURATION_ON_HEALTH_CHANGE : float = 2.0
var display_timer : Timer

#

onready var health_icon = $Control/HealthIcon
onready var health_texture_progress = $Control/HealthTextureProgress
onready var health_sepa_container = $Control/HealthSeparatorContainer

#

func _ready():
	_init_health_separator_texture_rect_compo_pool()
	visible = false
	
	#
	
	_initialize_display_timer()

func _init_health_separator_texture_rect_compo_pool():
	health_separator_texture_rect_compo_pool = TextureRectComponentPool.new()
	health_separator_texture_rect_compo_pool.node_to_listen_for_queue_free = SingletonsAndConsts.current_game_elements
	health_separator_texture_rect_compo_pool.node_to_parent = health_sepa_container
	health_separator_texture_rect_compo_pool.source_of_create_resource = self
	health_separator_texture_rect_compo_pool.func_name_for_create_resource = "_create_texture_rect__for_sepa_pool"


func _create_texture_rect__for_sepa_pool():
	var sepa = TextureRect.new()
	sepa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sepa.texture = preload("res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_FillForegroundSeparator.png")
	
	return sepa

#

func _initialize_display_timer():
	display_timer = Timer.new()
	display_timer.one_shot = true
	display_timer.connect("timeout", self, "_on_display_self_timer_timeout")
	
	add_child(display_timer)


func _on_display_self_timer_timeout():
	var tweener = create_tween()
	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	tweener.tween_callback(self, "_display_timer_mod_a_reached_zero")
	

func _display_timer_mod_a_reached_zero():
	visible = false
	

#

func _construct_separators_based_on_health_breakpoints(arg_param : DisplayParams):
	for percent in arg_param.health_breakpoints:
		var x_pos = _convert_percent_using_num_range(percent, SEPARATOR_X_STARTING_POS, SEPARATOR_X_ENDING_POS)
		
		var texture = health_separator_texture_rect_compo_pool.get_or_create_resource_from_pool()
		texture.rect_position.y = SEPARATOR_Y_POS
		texture.rect_position.x = x_pos
		texture.visible = true
		


func _convert_percent_using_num_range(arg_percent, arg_min, arg_max):
	var diff = arg_max - arg_min
	
	return arg_min + (diff * arg_percent / 100)


#

func configure_update_to_param(arg_param : DisplayParams):
	health_texture_progress.max_value = arg_param.max_health
	health_texture_progress.value = arg_param.current_health
	
	_construct_separators_based_on_health_breakpoints(arg_param)
	
	_player = arg_param.player
	
	_update_display_based_on_player_is_dead_state()
	
	_player.connect("current_health_changed", self, "_on_player_current_health_changed")
	_player.connect("all_health_lost", self, "_on_player_all_health_lost")
	_player.connect("health_restored_from_zero", self, "_on_player_health_restored_from_zero")

func _on_player_current_health_changed(arg_val):
	health_texture_progress.value = arg_val
	
	#
	var arg_max_val = _player.get_max_health()
	var arg_breakpoints = _player.health_breakpoints
	
	var setted_texture : bool = false
	var percent = arg_val * 100 / arg_max_val
	for hp_breakpoint in arg_breakpoints:
		if percent < hp_breakpoint:
			var texture = load(_player.health_breakpoint_to_bar_texture_file_path_map[hp_breakpoint])
			health_texture_progress.texture_progress = texture
			setted_texture = true
	if !setted_texture:
		var texture = load(_player.above_highest_health_breakpoint_texture_file_path)
		health_texture_progress.texture_progress = texture
	
	if visible:
		display_timer.start(DISPLAY_SELF_DURATION_ON_HEALTH_CHANGE)
		
	else:
		modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.5)
		visible = true
		
		display_timer.start(DISPLAY_SELF_DURATION_ON_HEALTH_CHANGE)


func _on_player_all_health_lost():
	_update_display_based_on_player_is_dead_state()

func _on_player_health_restored_from_zero():
	_update_display_based_on_player_is_dead_state()
	


func _update_display_based_on_player_is_dead_state():
	if _player.is_no_health():
		health_icon.texture = preload("res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_Heart_Dead.png")
		
	else:
		health_icon.texture = preload("res://GameFrontHUDRelated/Subs/HealthPanel/Assets/HealthPanel_Heart_Alive.png")
		
	


