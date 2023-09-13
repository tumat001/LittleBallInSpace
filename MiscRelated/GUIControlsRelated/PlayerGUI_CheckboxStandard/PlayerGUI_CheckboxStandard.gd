tool
extends MarginContainer

const StatusPic_Check = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_CheckboxStandard/Assets/PlayerGUI_CheckboxStandard_Status_Check.png")
const StatusPic_X = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_CheckboxStandard/Assets/PlayerGUI_CheckboxStandard_Status_X.png")

const CheckBoxPic_Normal = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_CheckboxStandard/Assets/PlayerGUI_CheckboxStandard_Box_Normal.png")
const CheckBoxPic_Hovered = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_CheckboxStandard/Assets/PlayerGUI_CheckboxStandard_Box_Hovered.png")
const CheckBoxPic_Disabled = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_CheckboxStandard/Assets/PlayerGUI_CheckboxStandard_Box_Disabled.png")

#

signal is_checked_changed(arg_val)
signal pressed__intent_for_reactive(arg_intent_check_val)

#

const ENABLED_MODUALTE = Color(1, 1, 1, 1)
const DISABLED_MODULATE = Color(0.6, 0.6, 0.6, 0.75)

#

export(bool) var update_properties_when_clicked_instead_of_reactive : bool = true

export(String) var label_text : String setget set_label_text

#

var _is_checked : bool

var _is_disabled : bool
var _change_modulate_based_on_is_disabled : bool

var _is_mouse_inside : bool

#

var _is_in_ready : bool

#

onready var button = $Button
onready var status_texture_rect = $HBoxContainer/Container/StatusPic
onready var box_texture_rect = $HBoxContainer/Container/BoxPic

onready var checkbox_label = $HBoxContainer/CheckboxLabel

#

func _ready():
	_is_in_ready = true
	
	set_is_checked(_is_checked, false)
	set_is_disabled(_is_disabled, _change_modulate_based_on_is_disabled)
	set_label_text(label_text)
	
	_is_in_ready = false

#

func set_label_text(arg_label_text):
	label_text = arg_label_text
	
	if is_inside_tree() or Engine.editor_hint:
		checkbox_label.text = label_text

#

func set_is_disabled(arg_val, arg_change_modulate_based_on_is_disabled):
	var old_change_val = _change_modulate_based_on_is_disabled
	var old_dis_val = _is_disabled
	_is_disabled = arg_val
	_change_modulate_based_on_is_disabled = arg_change_modulate_based_on_is_disabled
	
	if old_dis_val != arg_val or old_change_val != arg_change_modulate_based_on_is_disabled or _is_in_ready:
		if is_inside_tree():
			button.disabled = arg_val
			
			if arg_val:
				#status_texture_rect.texture = StatusPic_X
				
				if arg_change_modulate_based_on_is_disabled:
					modulate = DISABLED_MODULATE
				
			else:
				#status_texture_rect.texture = StatusPic_Check
				
				if arg_change_modulate_based_on_is_disabled:
					modulate = ENABLED_MODUALTE
			
			
			_update_box_texture_display()


func set_is_checked(arg_val, arg_emit_signal : bool = true):
	var old_val = _is_checked
	_is_checked = arg_val
	
	if old_val != arg_val or _is_in_ready:
		if is_inside_tree():
			if arg_val:
				status_texture_rect.texture = StatusPic_Check
			else:
				status_texture_rect.texture = StatusPic_X
			
			if arg_emit_signal:
				emit_signal("is_checked_changed", arg_val)


#

func _on_Button_pressed():
	if update_properties_when_clicked_instead_of_reactive:
		set_is_checked(!_is_checked, true)
	else:
		emit_signal("pressed__intent_for_reactive", !_is_checked)

#

func _on_Button_mouse_entered():
	_is_mouse_inside = true
	_update_box_texture_display()


func _on_Button_mouse_exited():
	_is_mouse_inside = false
	_update_box_texture_display()


func _on_PlayerGUI_CheckboxStandard_visibility_changed():
	_is_mouse_inside = false
	_update_box_texture_display()

#

func _update_box_texture_display():
	if _is_disabled:
		box_texture_rect.texture = CheckBoxPic_Disabled
		
	else:
		if _is_mouse_inside:
			box_texture_rect.texture = CheckBoxPic_Hovered
			
		else:
			box_texture_rect.texture = CheckBoxPic_Normal
			


