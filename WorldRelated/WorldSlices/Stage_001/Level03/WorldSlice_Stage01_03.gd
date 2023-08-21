extends "res://WorldRelated/AbstractWorldSlice.gd"


#onready var label_rewind = $MessegesContainer/Label3Rewind
#onready var label_zoomout = $MessegesContainer/Label4Zoomout

onready var vkp_rewind = $MessegesContainer/VBoxContainer/VKP_Rewind
onready var vkp_zoom_out = $MessegesContainer/VBoxContainer2/VKP_ZoomOut
onready var vkp_slow_down = $MessegesContainer/VBoxContainer3/VKPSlowDown


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	#var orig_text_rewind = label_rewind.text
	#label_rewind.text = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	 
	var orig_text_rewind = vkp_rewind.text_for_keypress
	vkp_rewind.text_for_keypress = orig_text_rewind % InputMap.get_action_list("rewind")[0].as_text()
	
	#var orig_text_zoomout = label_zoomout.text
	#label_zoomout.text = orig_text_zoomout % InputMap.get_action_list("game_zoom_out")[0].as_text()
	
	var orig_text_zoomout = vkp_zoom_out.text_for_keypress
	vkp_zoom_out.text_for_keypress = orig_text_zoomout % InputMap.get_action_list("game_zoom_out")[0].as_text()
	
	var orig_text_slowdown = vkp_slow_down.text_for_keypress
	vkp_slow_down.text_for_keypress = orig_text_slowdown % InputMap.get_action_list("ui_down")[2].as_text()
	
	



