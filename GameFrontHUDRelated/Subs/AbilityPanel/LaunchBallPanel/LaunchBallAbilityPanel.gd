extends MarginContainer


const DISABLED_MODULATE := Color(0.3, 0.3, 0.3, 1)
const ENABLED_MODULATE := Color(1, 1, 1, 1)

const COLOR_RED := Color(255/255.0, 14/255.0, 10/255.0)
const COLOR_ORANGE := Color(255/255.0, 128/255.0, 0/255.0)
const COLOR_YELLOW := Color(255/255.0, 251/255.0, 0/255.0)
const COLOR_GREEN := Color(101/255.0, 253/255.0, 78/255.0)
const COLOR_BLUE := Color(78/255.0, 123/255.0, 253/255.0)
const COLOR_VIOLET := Color(165/255.0, 78/255.0, 253/255.0)

const COLOR__NORMAL := Color(1, 1, 1, 1)
const COLOR__NORMAL_BAR_BACKGROUND_EDGE := Color("#FF8000")
const COLOR__NORMAL_BAR_FILL := Color("#191919")

const color_transition_duration : float = 1.0#0.65

#

signal toggle_button_of_mode_change_pressed()

#

var player_modi_launch_ball setget set_player_modi_launch_ball

var _rainbow_white_frame_tweener : SceneTreeTween

#

var _aim_mode_swap_button_highlight_tweener : SceneTreeTween

#

onready var ball_count_label = $FreeFormControl/BallCountLabel

#onready var ball_pic_03 = $FreeFormControl/Ball03
#onready var ball_pic_02 = $FreeFormControl/Ball02
#onready var ball_pic_01 = $FreeFormControl/Ball01
#onready var plus_sign = $FreeFormControl/PlusSign

onready var bar_background_edge = $FreeFormControl/BarBackgroundEdge
onready var bar_fill = $FreeFormControl/BarFill
onready var background__white_circles = $FreeFormControl/BackgroundWithCircles
onready var aim_mode_name_bar_edge = $FreeFormControl/ModeContainer/FreeFormControl/AimModeNameBarEdge
onready var aim_mode_name_bar_fill = $FreeFormControl/ModeContainer/FreeFormControl/AimModeNameBarFill

onready var aim_mode_icon = $FreeFormControl/ModeContainer/FreeFormControl/AimModeIcon
onready var aim_mode_label = $FreeFormControl/ModeContainer/FreeFormControl/AimModeLabel

onready var aim_mode_container = $FreeFormControl/ModeContainer
onready var aim_mode_swap_button = $FreeFormControl/ModeContainer/FreeFormControl/SwapButton


onready var free_form_control = $FreeFormControl

onready var pos_of_center_ball = $FreeFormControl/PosOfCenterBall

#

func set_player_modi_launch_ball(arg_modi):
	player_modi_launch_ball = arg_modi
	
	player_modi_launch_ball.connect("current_ball_count_changed", self, "_on_modi_current_ball_count_changed", [], CONNECT_PERSIST)
	player_modi_launch_ball.connect("infinite_ball_count_status_changed", self, "_on_modi_infinite_ball_count_status_changed", [], CONNECT_PERSIST)
	player_modi_launch_ball.connect("can_change_aim_mode_changed", self, "_on_can_change_aim_mode_changed", [], CONNECT_PERSIST)
	
	player_modi_launch_ball.player_modi_launch_ball_node.connect("aim_mode_changed", self, "_on_aim_mode_changed", [], CONNECT_PERSIST)
	
	#_update_display_based_on_ball_count(player_modi_launch_ball.get_current_ball_count())
	_update_display_based_on_infinite_ball_count_status()
	_update_label_based_on_all_properties()
	
	var ability = player_modi_launch_ball.launch_ability
	ability.connect("updated_is_ready_for_activation", self, "_on_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	_on_updated_is_ready_for_activation(ability.is_ready_for_activation())
	
	_update_display_based_on_aim_mode(player_modi_launch_ball.player_modi_launch_ball_node.current_aim_mode)
	_update_display_based_on_can_change_aim_mode()
	

func _on_updated_is_ready_for_activation(arg_val):
	if arg_val:
		modulate = ENABLED_MODULATE
	else:
		modulate = DISABLED_MODULATE
	

####

func _on_modi_current_ball_count_changed(arg_count):
	_update_label_based_on_all_properties()

func _update_label_based_on_all_properties():
	var is_infinite = player_modi_launch_ball.is_infinite_ball_count
	var count = player_modi_launch_ball.get_current_ball_count()
	
	if !is_infinite:
		ball_count_label.text = str(count)
	else:
		ball_count_label.text = "Inf"



func _on_modi_infinite_ball_count_status_changed(arg_val):
	_update_display_based_on_infinite_ball_count_status()
	_update_label_based_on_all_properties()

func _update_display_based_on_infinite_ball_count_status():
	var is_infinite = player_modi_launch_ball.is_infinite_ball_count
	
	if is_infinite:
		_start_rainbow_white_frame_tweener()
	else:
		_end_rainbow_white_frame_tweener()
	

func _start_rainbow_white_frame_tweener():
	if _rainbow_white_frame_tweener == null:
		_rainbow_white_frame_tweener = create_tween()
		
		_rainbow_white_frame_tweener.set_loops(0)
		_rainbow_white_frame_tweener.tween_method(self, "_tween_method__rainbow_set_modulates_of_controls", COLOR_RED, COLOR_ORANGE, color_transition_duration)
		_rainbow_white_frame_tweener.tween_method(self, "_tween_method__rainbow_set_modulates_of_controls", COLOR_ORANGE, COLOR_YELLOW, color_transition_duration)
		_rainbow_white_frame_tweener.tween_method(self, "_tween_method__rainbow_set_modulates_of_controls", COLOR_YELLOW, COLOR_GREEN, color_transition_duration)
		_rainbow_white_frame_tweener.tween_method(self, "_tween_method__rainbow_set_modulates_of_controls", COLOR_GREEN, COLOR_BLUE, color_transition_duration)
		_rainbow_white_frame_tweener.tween_method(self, "_tween_method__rainbow_set_modulates_of_controls", COLOR_BLUE, COLOR_VIOLET, color_transition_duration)
		_rainbow_white_frame_tweener.tween_method(self, "_tween_method__rainbow_set_modulates_of_controls", COLOR_VIOLET, COLOR_RED, color_transition_duration)
		

func _tween_method__rainbow_set_modulates_of_controls(arg_modulate : Color):
	var dark_fill_modulate = arg_modulate * COLOR__NORMAL_BAR_FILL
	
	background__white_circles.modulate = arg_modulate
	bar_background_edge.modulate = arg_modulate
	bar_fill.modulate = dark_fill_modulate
	
	aim_mode_name_bar_edge.modulate = arg_modulate
	aim_mode_name_bar_fill.color = dark_fill_modulate

func _end_rainbow_white_frame_tweener():
	if _rainbow_white_frame_tweener != null:
		_rainbow_white_frame_tweener.stop()
		_rainbow_white_frame_tweener = null
	
	_reset_rainbow_modulates_of_controls()

func _reset_rainbow_modulates_of_controls():
	background__white_circles.modulate = COLOR__NORMAL
	bar_background_edge.modulate = COLOR__NORMAL_BAR_BACKGROUND_EDGE
	bar_fill.modulate = COLOR__NORMAL_BAR_FILL
	aim_mode_name_bar_edge.modulate = COLOR__NORMAL_BAR_BACKGROUND_EDGE
	aim_mode_name_bar_fill.color = COLOR__NORMAL_BAR_FILL

#

func _on_can_change_aim_mode_changed(arg_val):
	_update_display_based_on_can_change_aim_mode()

func _update_display_based_on_can_change_aim_mode():
	if player_modi_launch_ball.can_change_aim_mode:
		aim_mode_container.visible = true
	else:
		aim_mode_container.visible = false
	

###

func _on_SwapButton_pressed():
	player_modi_launch_ball.player_modi_launch_ball_node.toggle_current_aim_mode()
	
	emit_signal("toggle_button_of_mode_change_pressed")

func _on_aim_mode_changed(arg_mode):
	_update_display_based_on_aim_mode(arg_mode)
	

func _update_display_based_on_aim_mode(arg_mode):
	if arg_mode == player_modi_launch_ball.player_modi_launch_ball_node.AimMode.OMNI:
		aim_mode_icon.texture = preload("res://GameFrontHUDRelated/Subs/AbilityPanel/LaunchBallPanel/Assets/LaunchBall_AimMode_Omni.png")
		aim_mode_label.text = "Omni"
		
	elif arg_mode == player_modi_launch_ball.player_modi_launch_ball_node.AimMode.SNAP:
		aim_mode_icon.texture = preload("res://GameFrontHUDRelated/Subs/AbilityPanel/LaunchBallPanel/Assets/LaunchBall_AimMode_Snap.png")
		aim_mode_label.text = "Snap"
		
		
	

#############

func show_highlight_of_aim_mode_swap_button():
	if _aim_mode_swap_button_highlight_tweener != null:
		_aim_mode_swap_button_highlight_tweener.kill()
	
	var tweener = create_tween()
	tweener.set_loops()
	tweener.tween_property(aim_mode_swap_button, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tweener.tween_property(aim_mode_swap_button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	_aim_mode_swap_button_highlight_tweener = tweener

func end_highlight_of_aim_mode_swap_button():
	if _aim_mode_swap_button_highlight_tweener != null:
		_aim_mode_swap_button_highlight_tweener.kill()
		_aim_mode_swap_button_highlight_tweener = null
	

######

func template__do_brief_glowup(arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params):
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(free_form_control, "modulate", Color(1.6, 1.6, 1.6, 1.0), 0.5)
	tween.tween_interval(0.5)
	tween.tween_property(free_form_control, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	tween.tween_callback(arg_func_source, arg_func_name, [arg_func_params]).set_delay(arg_delay_for_func_call)

#

func get_pos_of_center_ball_hud_image() -> Vector2:
	return pos_of_center_ball.global_position

