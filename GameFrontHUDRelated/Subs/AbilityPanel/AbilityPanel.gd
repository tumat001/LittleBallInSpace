extends MarginContainer


var player_modi_launch_ball setget set_player_modi_launch_ball

#

onready var launch_ball_ability_panel = $LaunchBallAbilityPanel

#

func set_player_modi_launch_ball(arg_modi):
	player_modi_launch_ball = arg_modi
	
	launch_ball_ability_panel.visible = true
	launch_ball_ability_panel.player_modi_launch_ball = player_modi_launch_ball

 
