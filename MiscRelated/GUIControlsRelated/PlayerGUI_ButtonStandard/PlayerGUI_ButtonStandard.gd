extends MarginContainer

#

signal button_pressed()

#

#const LABEL_MODULATE__DISABLED = Color(0.5, 0.5, 0.5, 0.75)
#const LABEL_MODULATE__NO_FOCUS = Color(0.7, 0.7, 0.7, 1.0)
#const LABEL_MODULATE__HAS_FOCUS__YELLOW = Color(1, 1, 1, 1.0)

const LABEL_MODULATE__DISABLED = Color(0.6, 0.6, 0.6, 0.75)
const LABEL_MODULATE__NO_FOCUS = Color("#DDDDDD")#Color(1, 1, 1, 1.0)
const LABEL_MODULATE__HAS_FOCUS__YELLOW = Color("#FDD14D")

const LABEL_MODULATE__IS_TOGGLED = Color("#9AFD8B")

#

export(bool) var can_grab_focus : bool = true setget set_can_grab_focus
export(bool) var is_disabled : bool = false setget set_is_disabled

var _has_focus : bool
var _is_mouse_inside : bool

var _is_toggled : bool

#

var _is_in_ready : bool

onready var label = $LabelContainer
onready var texture_button = $TextureButton

#

## make sure that the setted val is correct.
## use this carefully!!
#func set_is_toggled(arg_toggled):
#	_on_toggled(arg_toggled)

#func _on_toggled(arg_pressed):
#	_is_toggled = arg_pressed
#	_update_control_states()

func _update_control_states():
	if is_inside_tree():
		if !is_disabled:
			if _has_focus or _is_mouse_inside:
				
				if texture_button.toggle_mode:
					label.modulate = LABEL_MODULATE__HAS_FOCUS__YELLOW
					
				else:
					label.modulate = LABEL_MODULATE__HAS_FOCUS__YELLOW
					
				
				if !can_grab_focus:
					texture_button.focus_mode = Control.FOCUS_NONE
				
			elif _is_toggled:
				label.modulate = LABEL_MODULATE__IS_TOGGLED
				
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
	texture_button.connect("mouse_exited", self, "_on_texture_button_mouse_exited")
	#texture_button.connect("toggled", self, "_on_toggled")
	
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
	_is_mouse_inside = true
	if can_grab_focus:
		grab_focus()
		#_update_control_states is called
		
	else:
		_update_control_states()
	
	##
	
	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_Button_Hover, 1.0, null)

func _on_texture_button_mouse_exited():
	_is_mouse_inside = false
	_update_control_states()


func _set_has_focus(arg_val):
	_has_focus = arg_val
	
	_update_control_states()
	



#

func set_focus_neighbour_top(arg_control : Control):
	texture_button.focus_neighbour_top = arg_control.get_path()
	

func set_focus_neighbour_bottom(arg_control : Control):
	texture_button.focus_neighbour_bottom = arg_control.get_path()
	



func get_texture_button():
	return texture_button

#

func set_button_group(arg_button_group : ButtonGroup):
	texture_button.toggle_mode = true
	texture_button.group = arg_button_group
	
	arg_button_group.connect("pressed", self, "_on_button_group_pressed_button_changed")

func _on_button_group_pressed_button_changed(arg_button):
	if arg_button == texture_button:
		set_is_toggled(true)
	else:
		set_is_toggled(false)


func set_is_toggled(arg_pressed):
	_is_toggled = arg_pressed
	_update_control_states()

###

func _on_TextureButton_pressed():
	emit_signal("button_pressed")


#

func _on_PlayerGUI_ButtonStandard_visibility_changed():
	_is_mouse_inside = false
	lose_focus()

