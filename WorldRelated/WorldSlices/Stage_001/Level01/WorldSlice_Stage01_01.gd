extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var vkp_left = $MiscContainer/VBoxContainer3/HBoxContainer/VBoxContainer/VKP_Left
onready var vkp_right = $MiscContainer/VBoxContainer3/HBoxContainer/VBoxContainer2/VKP_Right

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	var orig_text__left = vkp_left.text_for_keypress
	vkp_left.text_for_keypress = orig_text__left % InputMap.get_action_list("ui_left")[0].as_text()
	
	var orig_text__right = vkp_right.text_for_keypress
	vkp_right.text_for_keypress = orig_text__right % InputMap.get_action_list("ui_right")[0].as_text()
	



