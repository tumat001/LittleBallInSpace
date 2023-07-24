extends "res://WorldRelated/AbstractWorldSlice.gd"


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_add_launch_ball_modi()

func _add_launch_ball_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	modi.starting_ball_count = 3
	
	game_elements.player_modi_manager.add_modi_to_player(modi)
