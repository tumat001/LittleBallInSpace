extends MarginContainer


const DISABLED_MODULATE := Color(0.3, 0.3, 0.3, 1)
const ENABLED_MODULATE := Color(1, 1, 1, 1)

const COLOR_RED := Color(255/255.0, 14/255.0, 10/255.0)
const COLOR_ORANGE := Color(255/255.0, 128/255.0, 0/255.0)
const COLOR_YELLOW := Color(255/255.0, 251/255.0, 0/255.0)
const COLOR_GREEN := Color(101/255.0, 253/255.0, 78/255.0)
const COLOR_BLUE := Color(78/255.0, 123/255.0, 253/255.0)
const COLOR_VIOLET := Color(165/255.0, 78/255.0, 253/255.0)

const color_transition_duration : float = 0.65

const COLOR__NORMAL := Color(1, 1, 1, 1)


#

var player_modi_launch_ball setget set_player_modi_launch_ball

var _rainbow_white_frame_tweener : SceneTreeTween

#

onready var ball_count_label = $FreeFormControl/BallCountLabel

onready var ball_pic_03 = $FreeFormControl/Ball03
onready var ball_pic_02 = $FreeFormControl/Ball02
onready var ball_pic_01 = $FreeFormControl/Ball01
onready var plus_sign = $FreeFormControl/PlusSign

onready var background__white_circles = $FreeFormControl/BackgroundWithCircles

#

func set_player_modi_launch_ball(arg_modi):
	player_modi_launch_ball = arg_modi
	
	player_modi_launch_ball.connect("current_ball_count_changed", self, "_on_modi_current_ball_count_changed", [], CONNECT_PERSIST)
	player_modi_launch_ball.connect("infinite_ball_count_status_changed", self, "_on_modi_infinite_ball_count_status_changed", [], CONNECT_PERSIST)
	
	_update_display_based_on_ball_count(player_modi_launch_ball.get_current_ball_count())
	_update_display_based_on_infinite_ball_count_status()
	_update_label_based_on_all_properties()
	
	var ability = player_modi_launch_ball.launch_ability
	ability.connect("updated_is_ready_for_activation", self, "_on_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	_on_updated_is_ready_for_activation(ability.is_ready_for_activation())


func _on_updated_is_ready_for_activation(arg_val):
	if arg_val:
		modulate = ENABLED_MODULATE
	else:
		modulate = DISABLED_MODULATE
	

####

func _on_modi_current_ball_count_changed(arg_count):
	_update_display_based_on_ball_count(arg_count)
	_update_label_based_on_all_properties()

func _update_display_based_on_ball_count(arg_count):
	if arg_count > 3:
		ball_pic_03.visible = true
		ball_pic_02.visible = true
		ball_pic_01.visible = true
		plus_sign.visible = true
		
	elif arg_count == 3:
		ball_pic_03.visible = true
		ball_pic_02.visible = true
		ball_pic_01.visible = true
		plus_sign.visible = false
		
	elif arg_count == 2:
		ball_pic_03.visible = false
		ball_pic_02.visible = true
		ball_pic_01.visible = true
		plus_sign.visible = false
		
	elif arg_count == 1:
		ball_pic_03.visible = false
		ball_pic_02.visible = false
		ball_pic_01.visible = true
		plus_sign.visible = false
		
	elif arg_count == 0:
		ball_pic_03.visible = false
		ball_pic_02.visible = false
		ball_pic_01.visible = false
		plus_sign.visible = false
		
	
	

func _update_label_based_on_all_properties():
	var is_infinite = player_modi_launch_ball.is_infinite_ball_count
	var count = player_modi_launch_ball.get_current_ball_count()
	
	if !is_infinite:
		ball_count_label.text = str(count)
	else:
		ball_count_label.text = "Inf (%s)" % count



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
		_rainbow_white_frame_tweener.tween_property(background__white_circles, "modulate", COLOR_RED, color_transition_duration)
		_rainbow_white_frame_tweener.tween_property(background__white_circles, "modulate", COLOR_ORANGE, color_transition_duration)
		_rainbow_white_frame_tweener.tween_property(background__white_circles, "modulate", COLOR_YELLOW, color_transition_duration)
		_rainbow_white_frame_tweener.tween_property(background__white_circles, "modulate", COLOR_GREEN, color_transition_duration)
		_rainbow_white_frame_tweener.tween_property(background__white_circles, "modulate", COLOR_BLUE, color_transition_duration)
		_rainbow_white_frame_tweener.tween_property(background__white_circles, "modulate", COLOR_VIOLET, color_transition_duration)
		

func _end_rainbow_white_frame_tweener():
	if _rainbow_white_frame_tweener != null:
		
		_rainbow_white_frame_tweener.stop()
		background__white_circles.modulate = COLOR__NORMAL
		
		_rainbow_white_frame_tweener = null

