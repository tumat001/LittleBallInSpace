extends MarginContainer

#

signal button_pressed()

#

const LABEL_MODULATE__DISABLED = Color(0.25, 0.25, 0.25, 0.6)

const LABEL_MODULATE__NO_FOCUS = Color(0.6, 0.6, 0.6, 1.0)
const LABEL_MODULATE__HAS_FOCUS = Color(1, 1, 1, 1.0)

#

export(bool) var can_grab_focus : bool = true setget set_can_grab_focus
export(bool) var is_disabled : bool = false setget set_is_disabled

var _has_focus : bool

#

var _is_in_ready : bool

onready var label = $LabelContainer
onready var texture_button = $TextureButton

#

func _update_control_states():
	if is_inside_tree():
		if !is_disabled:
			if _has_focus or !can_grab_focus:
				label.modulate = LABEL_MODULATE__HAS_FOCUS
				
				if !can_grab_focus:
					texture_button.focus_mode = Control.FOCUS_NONE
				
			else:
				label.modulate = LABEL_MODULATE__NO_FOCUS
				texture_button.focus_mode = Control.FOCUS_ALL
			
			texture_button.disabled = false
			
		else:
			label.modulate = LABEL_MODULATE__DISABLED
			texture_button.disabled = true
			texture_button.focus_mode = Control.FOCUS_NONE


#

func set_can_grab_focus(arg_val):
	can_grab_focus = arg_val
	
	if !_is_in_ready:
		_update_control_states()

#

func set_is_disabled(arg_val):
	is_disabled = arg_val
	
	if !_is_in_ready:
		_update_control_states()


#

func _ready():
	_is_in_ready = true
	
	texture_button.connect("focus_entered", self, "_on_texture_button_focus_entered")
	texture_button.connect("focus_exited", self, "_on_texture_button_focus_exited")
	texture_button.connect("mouse_entered", self, "_on_texture_button_mouse_entered")
	
	_set_has_focus(false)
	set_can_grab_focus(can_grab_focus)
	set_is_disabled(is_disabled)
	
	_is_in_ready = false
	_update_control_states()

func grab_focus():
	if can_grab_focus and !is_disabled:
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
	
	_update_control_states()
	
#	if !is_disabled:
#		if _has_focus or !can_grab_focus:
#			label.modulate = LABEL_MODULATE__HAS_FOCUS
#
#		else:
#			label.modulate = LABEL_MODULATE__NO_FOCUS
#
#
#	else:
#


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


