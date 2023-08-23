extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var vkp_rewind = $MessegesContainer/VBoxContainer/VKP_Rewind

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	var orig_text_rewind = vkp_rewind.text_for_keypress
	vkp_rewind.text_for_keypress = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	
	GameSaveManager.set_game_control_name_string__is_hidden("rewind", false)


