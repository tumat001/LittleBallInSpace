extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var vision_fog = $MiscContainer/VisionFog

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _ready():
	vision_fog.visible = true
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	


##

func _on_PDAR_FogLifter_player_entered_in_area():
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	vision_fog.start_hide_fog()
	vision_fog.connect("fog_hide_finished", self, "_on_fog_hide_finished", [], CONNECT_ONESHOT)

func _on_fog_hide_finished():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	


