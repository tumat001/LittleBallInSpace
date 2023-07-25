extends MarginContainer


const DISABLED_MODULATE := Color(0.3, 0.3, 0.3, 1)
const ENABLED_MODULATE := Color(1, 1, 1, 1)

#

var player_modi_launch_ball setget set_player_modi_launch_ball


#

onready var ball_count_label = $FreeFormControl/BallCountLabel

onready var ball_pic_03 = $FreeFormControl/Ball03
onready var ball_pic_02 = $FreeFormControl/Ball02
onready var ball_pic_01 = $FreeFormControl/Ball01
onready var plus_sign = $FreeFormControl/PlusSign


#

func set_player_modi_launch_ball(arg_modi):
	player_modi_launch_ball = arg_modi
	
	player_modi_launch_ball.connect("current_ball_count_changed", self, "_on_modi_current_ball_count_changed", [], CONNECT_PERSIST)
	_update_display_based_on_ball_count(player_modi_launch_ball.get_current_ball_count())
	
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
		
	
	ball_count_label.text = str(arg_count)

