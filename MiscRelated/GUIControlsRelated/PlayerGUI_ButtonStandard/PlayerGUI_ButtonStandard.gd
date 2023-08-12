extends MarginContainer

#

signal button_pressed()

#

const LABEL_MODULATE__NO_FOCUS = Color(0.6, 0.6, 0.6, 1.0)
const LABEL_MODULATE__HAS_FOCUS = Color(1, 1, 1, 1.0)

#

var _has_focus : bool

onready var label = $LabelContainer
onready var texture_button = $TextureButton


func _ready():
	texture_button.connect("focus_entered", self, "_on_texture_button_focus_entered")
	texture_button.connect("focus_exited", self, "_on_texture_button_focus_exited")
	texture_button.connect("mouse_entered", self, "_on_texture_button_mouse_entered")
	
	_set_has_focus(false)

func grab_focus():
	texture_button.grab_focus()

func lose_focus():
	if texture_button.has_focus():
		texture_button.release_focus()


func _on_texture_button_focus_entered():
	_set_has_focus(true)
	

func _on_texture_button_focus_exited():
	_set_has_focus(false)
	

func _on_texture_button_mouse_entered():
	grab_focus()

func _set_has_focus(arg_val):
	_has_focus = arg_val
	
	if _has_focus:
		label.modulate = LABEL_MODULATE__HAS_FOCUS
		
	else:
		label.modulate = LABEL_MODULATE__NO_FOCUS
		


#

func set_focus_neighbour_top(arg_control : Control):
	texture_button.focus_neighbour_top = arg_control.get_path()
	

func set_focus_neighbour_bottom(arg_control : Control):
	texture_button.focus_neighbour_bottom = arg_control.get_path()
	



func get_texture_button():
	return texture_button

###

func _on_TextureButton_pressed():
	emit_signal("button_pressed")


