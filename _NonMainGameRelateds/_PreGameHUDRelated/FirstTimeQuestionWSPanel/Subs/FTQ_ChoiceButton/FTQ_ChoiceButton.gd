extends MarginContainer

#

signal button_pressed()

#

const MODULATE_NORMAL = Color("#dddddd")
const MODULATE_HIGHLIGHTED = Color(253/255.0, 198/255.0, 33/255.0, 1.0)

#

var _has_focus : bool

#

export(String) var choice_text : String setget set_choice_text

#

onready var label = $Label
onready var texture_button = $TextureButton


#

func _ready():
	set_choice_text(choice_text)

#

func set_choice_text(arg_text):
	choice_text = arg_text
	
	if is_inside_tree():
		label.text = arg_text
		




func _on_TextureButton_focus_entered():
	_on_gain_focus__attempt_do_anims()
	

func _on_TextureButton_focus_exited():
	_on_lose_focus__attempt_do_anims()
	



func _on_gain_focus__attempt_do_anims():
	var old_val = _has_focus
	_has_focus = true
	
	if old_val != _has_focus:
		#do anims
		var tweener = create_tween()
		tweener.tween_property(label, "modulate", MODULATE_HIGHLIGHTED, 0.2)


func _on_lose_focus__attempt_do_anims():
	var old_val = _has_focus
	_has_focus = false
	
	if old_val != _has_focus:
		var tweener = create_tween()
		tweener.tween_property(label, "modulate", MODULATE_NORMAL, 0.2)
		


##

func _on_TextureButton_pressed():
	emit_signal("button_pressed")
	
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_Button_Click_Confirmed, 1.0, null)


#

func get_texture_button():
	return texture_button
	


func set_focus_neighbour_top(arg_control : Control):
	if arg_control is get_script():
		texture_button.focus_neighbour_top = arg_control.get_texture_button().get_path()
		
	else:
		texture_button.focus_neighbour_top = arg_control.get_path()
	

func set_focus_neighbour_bottom(arg_control : Control):
	if arg_control is get_script():
		texture_button.focus_neighbour_bottom = arg_control.get_texture_button().get_path()
		
	else:
		texture_button.focus_neighbour_bottom = arg_control.get_path()
	

func set_focus_neighbour_left(arg_control : Control):
	if arg_control is get_script():
		texture_button.focus_neighbour_left = arg_control.get_texture_button().get_path()
		
	else:
		texture_button.focus_neighbour_left = arg_control.get_path()
	

func set_focus_neighbour_right(arg_control : Control):
	if arg_control is get_script():
		texture_button.focus_neighbour_right = arg_control.get_texture_button().get_path()
		
	else:
		texture_button.focus_neighbour_right = arg_control.get_path()
	

#

func _on_TextureButton_mouse_entered():
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_Button_Hover, 1.0, null)
	
	grab_focus()

func grab_focus():
	texture_button.grab_focus()

