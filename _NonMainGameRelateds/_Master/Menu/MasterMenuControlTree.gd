extends "res://MiscRelated/ControlTreeRelated/ControlTree.gd"


const MasterMenu_AboutPage = preload("res://_NonMainGameRelateds/_Master/Menu/Subs/MasterMenu_About/MasterMenu_AboutPage.gd")
const MasterMenu_AboutPage_Scene = preload("res://_NonMainGameRelateds/_Master/Menu/Subs/MasterMenu_About/MasterMenu_AboutPage.tscn")

##

var about_page : MasterMenu_AboutPage

#

onready var main_page = $ControlContainer/MasterMenu_MainPage


func _ready():
	pause_tree_on_show = false
	use_mod_a_tweeners_for_traversing_hierarchy = false
	
	connect("hierarchy_advanced_forwards", self, "_on_hierarchy_advanced_forwards__MMCT")

func show_main_page():
	show_control__and_add_if_unadded(main_page, use_mod_a_tweeners_for_traversing_hierarchy)
	


########

func _on_hierarchy_advanced_forwards__MMCT(arg_control):
	if arg_control == main_page:
		set_show_info_button(true)
	else:
		set_show_info_button(false)

#

func _on_MasterMenuControlTree_info_button_pressed():
	show_about_page__construct_if_unconstructed()


func show_about_page__construct_if_unconstructed():
	if !is_instance_valid(about_page):
		about_page = MasterMenu_AboutPage_Scene.instance()
	
	show_control__and_add_if_unadded(about_page, use_mod_a_tweeners_for_traversing_hierarchy)

