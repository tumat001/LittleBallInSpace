extends MarginContainer

const Singleton_GameInfo = preload("res://GameSaveRelated/Singleton_GameInfo.gd")


var _credits_page

#############################################
# TREE ITEM Specific methods/vars

var control_tree


func on_control_received_focus():
	pass
	

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	pass

func on_control_fully_invisible():
	pass
	

############
# END OF TREE ITEM Specific methods/vars
###########


func _on_Button_Credits_button_pressed():
	_init_credits_page()
	control_tree.show_control__and_add_if_unadded(_credits_page)

func _init_credits_page():
	if !is_instance_valid(_credits_page):
		_credits_page = preload("res://_NonMainGameRelateds/_Master/Menu/Subs/MasterMenu_CreditsPage/MasterMenu_CreditsPage.tscn").instance()
		control_tree.add_control__but_dont_show(_credits_page)
		

#

func _ready() -> void:
	var version_label = $DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/ContentControlContainer/VersionLabel
	version_label.text = version_label.text % Singleton_GameInfo.get_game_version_as_text()
