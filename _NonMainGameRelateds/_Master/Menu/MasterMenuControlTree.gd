extends "res://MiscRelated/ControlTreeRelated/ControlTree.gd"


onready var main_page = $ControlContainer/MasterMenu_MainPage


func _ready():
	pause_tree_on_show = false
	use_mod_a_tweeners_for_traversing_hierarchy = false
	

func show_main_page():
	show_control__and_add_if_unadded(main_page, use_mod_a_tweeners_for_traversing_hierarchy)
	


