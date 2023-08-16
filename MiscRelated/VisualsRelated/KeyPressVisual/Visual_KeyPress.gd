tool
extends MarginContainer


export(String) var text_for_keypress : String = "%s" setget set_text_for_keypress, get_text_for_keypress


onready var key_press_label = $HBoxContainer/MiddleFillContainer/MarginContainer/KeyPressLabel


#

func set_text_for_keypress(arg_val):
	text_for_keypress = arg_val
	
	if is_inside_tree() or Engine.editor_hint:
		key_press_label.text = text_for_keypress
		

func get_text_for_keypress():
	return text_for_keypress



