tool
extends MarginContainer

#

signal value_changed(arg_val)
signal current_custom_min_spaces_of_spin_box__from_auto_adjust_or_ready(arg_val)

#

var _is_in_ready : bool

export(String) var label_text : String setget set_label_text
export(String) var spin_box_suffix : String setget set_spin_box_suffix
export(bool) var adjust_min_spaces_of_spin_box_based_on_suffix : bool = false setget set_adjust_min_spaces_of_spin_box_based_on_suffix
export(bool) var custom_min_spaces_of_spin_box : int setget set_custom_min_spaces_of_spin_box
var _current_custom_min_spaces_of_spin_box : int

#

var _ignore_next_value_changed_signal : bool

#

var _spin_box_theme : Theme

#

onready var label = $HBoxContainer/Label
onready var spin_box = $HBoxContainer/Container/SpinBox

##

func _ready():
	_is_in_ready = true
	
	_init_spin_box_theme()
	set_label_text(label_text)
	_configure_spinbox()
	
	_is_in_ready = false
	
	
	_update_min_spaces_of_theme(true)

#

func set_spin_box_suffix(arg_suffix):
	spin_box_suffix = arg_suffix
	
	if is_inside_tree():
		spin_box.suffix = arg_suffix
		_update_min_spaces_of_theme(false)

func set_adjust_min_spaces_of_spin_box_based_on_suffix(arg_val):
	adjust_min_spaces_of_spin_box_based_on_suffix = arg_val
	
	if is_inside_tree():
		_update_min_spaces_of_theme(adjust_min_spaces_of_spin_box_based_on_suffix)

func set_custom_min_spaces_of_spin_box(arg_val):
	custom_min_spaces_of_spin_box = arg_val
	
	if is_inside_tree():
		_update_min_spaces_of_theme(false)

func _update_min_spaces_of_theme(arg_from_auto_adjust : bool):
	var old_val = _current_custom_min_spaces_of_spin_box
	var new_val
	if adjust_min_spaces_of_spin_box_based_on_suffix:
		new_val = spin_box_suffix.length() + 1
	else:
		new_val = custom_min_spaces_of_spin_box
	
	if old_val != new_val:
		_spin_box_theme.set_constant("minimum_spaces", "constants", new_val)
		
		if arg_from_auto_adjust:
			emit_signal("current_custom_min_spaces_of_spin_box__from_auto_adjust_or_ready", _current_custom_min_spaces_of_spin_box)


#

func set_label_text(arg_label_text):
	label_text = arg_label_text
	
	if is_inside_tree() or Engine.editor_hint:
		label.text = label_text

func _init_spin_box_theme():
	_spin_box_theme = spin_box.theme

func _configure_spinbox():
	spin_box.connect("value_changed", self, "_on_spin_box_value_changed")


#


func _on_spin_box_value_changed(arg_val):
	if !_ignore_next_value_changed_signal:
		emit_signal("value_changed", arg_val)
	
	_ignore_next_value_changed_signal = false

#

func set_value(arg_val, arg_block_signal : bool):
	_ignore_next_value_changed_signal = arg_block_signal
	
	spin_box.value = arg_val


