extends MarginContainer


signal selected_item_changed(arg_item, arg_item_id)

signal pressed__intent_for_reactive(arg_intent_item, arg_intent_item_id)

#

const ENABLED_MODUALTE = Color(1, 1, 1, 1)
const DISABLED_MODULATE = Color(0.6, 0.6, 0.6, 0.75)

var _is_disabled : bool
var _change_modulate_based_on_is_disabled : bool

#

export(bool) var update_properties_when_clicked_instead_of_reactive : bool = true

#

class SelectorItem:
	var display_value : String
	var id
	

var _all_id_to_selector_item_map : Dictionary
var _current_id_selected
var _current_index : int

#

var _silence_signals : bool = false
var _is_in_ready : bool

#

onready var left_button = $HBoxContainer/LeftButton
onready var right_button = $HBoxContainer/RightButton

onready var label = $HBoxContainer/LabelMarginer/Label

#

func _ready():
	_is_in_ready = true
	
	set_is_disabled(_is_disabled, _change_modulate_based_on_is_disabled)
	
	_is_in_ready = false

func set_is_disabled(arg_val, arg_change_modulate_based_on_is_disabled):
	var old_change_val = _change_modulate_based_on_is_disabled
	var old_dis_val = _is_disabled
	_is_disabled = arg_val
	_change_modulate_based_on_is_disabled = arg_change_modulate_based_on_is_disabled
	
	if old_dis_val != arg_val or old_change_val != arg_change_modulate_based_on_is_disabled or _is_in_ready:
		if is_inside_tree():
			left_button.disabled = arg_val
			right_button.disabled = arg_val
			
			if arg_val:
				if arg_change_modulate_based_on_is_disabled:
					modulate = DISABLED_MODULATE
				
			else:
				if arg_change_modulate_based_on_is_disabled:
					modulate = ENABLED_MODUALTE
				



#

func set_selector_items(arg_items : Array, arg_selected_item, arg_silence_signals : bool):
	_remove_all_selector_items()
	for item in arg_items:
		_add_selector_item(item)
	
	if arg_silence_signals:
		_silence_signals = true
	_set_selected_item(arg_selected_item)
	_silence_signals = false

func _add_selector_item(arg_item : SelectorItem):
	_all_id_to_selector_item_map[arg_item.id] = arg_item
	

func _remove_all_selector_items():
	_all_id_to_selector_item_map.clear()
	

func _set_selected_item(arg_selected_item : SelectorItem):
	var index_of_item = _all_id_to_selector_item_map.values().find(arg_selected_item)
	_current_index = index_of_item
	_current_id_selected = arg_selected_item.id
	_update_based_on_selected_id()

func _set_selected_item__using_index(arg_index):
	var all_ids = _all_id_to_selector_item_map.keys()
	arg_index = _get_corrected_index(arg_index)
	
	var id = all_ids[arg_index]
	_current_index = arg_index
	_current_id_selected = id
	_update_based_on_selected_id()

func _get_corrected_index(arg_index):
	var size = _all_id_to_selector_item_map.size()
	
	if arg_index >= size:
		arg_index = 0
	elif arg_index < 0:
		arg_index = size - 1
	
	return arg_index

func _update_based_on_selected_id():
	var item = _all_id_to_selector_item_map[_current_id_selected]
	label.text = item.display_value
	
	if !_silence_signals:
		emit_signal("selected_item_changed", item, _current_id_selected)

###

func _on_LeftButton_pressed():
	if update_properties_when_clicked_instead_of_reactive:
		_set_selected_item__using_index(_current_index - 1)
	else:
		_emit_pressed__intent_for_reactive_signal__with_item_index(_current_index - 1)

func _on_RightButton_pressed():
	if update_properties_when_clicked_instead_of_reactive:
		_set_selected_item__using_index(_current_index + 1)
	else:
		_emit_pressed__intent_for_reactive_signal__with_item_index(_current_index + 1)

#

func _emit_pressed__intent_for_reactive_signal__with_item_index(arg_index):
	arg_index = _get_corrected_index(arg_index)
	var item = _all_id_to_selector_item_map[arg_index]
	
	emit_signal("pressed__intent_for_reactive", item, arg_index)


#

func get_selected_item():
	return _all_id_to_selector_item_map[_current_id_selected]
	

#

func set_modulate_for_label(arg_modulate : Color):
	label.modulate = arg_modulate
	

