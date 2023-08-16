extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var label_rewind = $MessegesContainer/Label3Rewind
onready var label_zoomout = $MessegesContainer/Label4Zoomout

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	var orig_text_rewind = label_rewind.text
	label_rewind.text = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	 
	
	var orig_text_zoomout = label_zoomout.text
	label_zoomout.text = orig_text_zoomout % InputMap.get_action_list("game_zoom_out")[0].as_text()
