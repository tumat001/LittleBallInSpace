extends "res://MiscRelated/ControlTreeRelated/ControlTree.gd"


onready var in_game_pause__main_page = $ControlContainer/InGamePause_MainPage


func _ready():
	pause_tree_on_show = SingletonsAndConsts.current_game_elements.pause_game_at_startup #false
	use_mod_a_tweeners_for_traversing_hierarchy = false
	

func show_in_game_pause_main_page():
	show_control__and_add_if_unadded(in_game_pause__main_page, use_mod_a_tweeners_for_traversing_hierarchy)
	

