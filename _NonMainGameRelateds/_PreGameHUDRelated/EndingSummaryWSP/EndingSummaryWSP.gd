extends Control

signal ending_panel_finished()


#######

func _ready():
	start_display()


func start_display():
	var dead_heart_details = SingletonsAndConsts.current_game_front_hud.trophy_panel.get_player_dead_tex_rect_pos__and_center_pos__and_texture__and_is_vis()
	var is_dead = dead_heart_details[3]
	
	if is_dead:
		_start_display__as_dead(dead_heart_details)
	else:
		_start_display__as_alive()



func _start_display__as_dead(dead_heart_details):
	var dead_heart_glob_pos = dead_heart_details[1]
	var dead_heart_texture = dead_heart_details[2]
	

func _start_display__as_alive():
	pass
	



