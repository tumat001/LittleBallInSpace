extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var prepare_yourself_label = $MiscContainer/PrepareYourselfLabel

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	



func _ready():
	prepare_yourself_label.modulate.a = 0

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	


##

func _on_PDAR_PrepareYourself_player_entered_in_area():
	var tweener = create_tween()
	tweener.tween_property(prepare_yourself_label, "modulate:a", 1.0, 0.75)
	

