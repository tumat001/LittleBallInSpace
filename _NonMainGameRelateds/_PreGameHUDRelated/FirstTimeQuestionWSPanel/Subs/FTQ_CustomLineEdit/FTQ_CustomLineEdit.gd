extends MarginContainer

signal text_entered(arg_text)


#

var is_disabled : bool = false

#

onready var line_edit = $LineEdit

#

func _on_LineEdit_text_entered(new_text : String):
	if new_text.length() >= 1 and !is_disabled:
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_Button_Click_Confirmed, 1.0, null)
		emit_signal("text_entered", new_text)
	


func grab_focus():
	line_edit.grab_focus()


func set_editable(arg_val):
	line_edit.editable = arg_val

