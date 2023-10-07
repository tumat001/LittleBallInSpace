extends MarginContainer


onready var option_button = $VBoxContainer/OptionButton
onready var left_button = $VBoxContainer/HBoxContainer/LeftButton
onready var right_button = $VBoxContainer/HBoxContainer/RightButton
onready var gsm_per_game_panel = $VBoxContainer/HBoxContainer/GSM_PerGame_Panel

#

signal item_changed(arg_per_game_list_item, arg_current_per_game_list_item_id)

#

const NO_PER_GAME_ID = -1

#

class PerGameListItem:
	var button_icon : Texture
	var button_label : String
	var id : int = NO_PER_GAME_ID
	var level_id : int = -1
	
	var metadata
	
	var per_game_data : Dictionary


var per_game_list_item : PerGameListItem

var show_level_name_on_per_game_panel : bool = false

var show_arrows_on_zero_or_one_item_in_list : bool = true

#

var _id_to_per_game_list_item_map : Dictionary

var _current_per_game_list_item_id : int = NO_PER_GAME_ID

#

var _empty_per_game_list_item : PerGameListItem

#

func _ready():
	_empty_per_game_list_item = PerGameListItem.new()
	
	_update_config_signals_to_listen_for_gui_input()
	connect("visibility_changed", self, "_on_vis_changed", [], CONNECT_DEFERRED)

#

func add_per_game_list_item(arg_list_item : PerGameListItem, arg_set_and_update : bool):
	if arg_list_item.button_icon != null:
		option_button.add_item(arg_list_item.button_label, arg_list_item.id)
	else:
		option_button.add_icon_item(arg_list_item.button_icon, arg_list_item.button_label, arg_list_item.id)
	
	#
	
	var id = option_button.get_item_id(option_button.get_item_count() - 1)
	arg_list_item.id = id
	
	_id_to_per_game_list_item_map[arg_list_item.id] = arg_list_item
	
	if _current_per_game_list_item_id == NO_PER_GAME_ID and arg_set_and_update:
		set_curr_per_game_item_index__and_update_display(id)
	else:
		_update_left_right_and_option_button_states()

func clear_per_game_list(arg_update_disp : bool):
	_id_to_per_game_list_item_map.clear()
	option_button.clear()
	
	_current_per_game_list_item_id = NO_PER_GAME_ID
	
	if arg_update_disp:
		_update_display()


func set_curr_per_game_item_index__and_update_display(arg_index):
	_current_per_game_list_item_id = arg_index
	_emit_item_changed()
	_update_display()

func _emit_item_changed():
	var per_game_list_item = null
	if _id_to_per_game_list_item_map.has(_current_per_game_list_item_id):
		per_game_list_item = _id_to_per_game_list_item_map[_current_per_game_list_item_id]
	
	emit_signal("item_changed", per_game_list_item, _current_per_game_list_item_id)


func _update_display():
	gsm_per_game_panel.set_visibility_of_level_name_panel(show_level_name_on_per_game_panel)
	
	if _id_to_per_game_list_item_map.has(_current_per_game_list_item_id):
		var per_game_item = _id_to_per_game_list_item_map[_current_per_game_list_item_id]
		gsm_per_game_panel.set_per_game_details(per_game_item.per_game_data, per_game_item.level_id)
		
		#print("set_per_game_details -> %s" % _current_per_game_list_item_id)
	else:
		gsm_per_game_panel.set_per_game_details(_empty_per_game_list_item.per_game_data, _empty_per_game_list_item.level_id)
		_current_per_game_list_item_id = NO_PER_GAME_ID 
		
		#print("set_per_game_details -> none %s" % _current_per_game_list_item_id)
	
	_update_left_right_and_option_button_states()

func _update_left_right_and_option_button_states():
	if _id_to_per_game_list_item_map.size() > 1:
		left_button.disabled = false
		right_button.disabled = false
		
		if left_button.modulate.a == 0:
			left_button.modulate.a = 1
			right_button.modulate.a = 1
		
		option_button.disabled = false
		
	else:
		left_button.disabled = true
		right_button.disabled = true
		
		if !show_arrows_on_zero_or_one_item_in_list:
			left_button.modulate.a = 0
			right_button.modulate.a = 0
		
		option_button.disabled = true
	

###########

func _on_OptionButton_item_selected(index):
	set_curr_per_game_item_index__and_update_display(index)

func _on_LeftButton_pressed():
	shift_curr_index__to_left()

func _on_RightButton_pressed():
	shift_curr_index__to_right()


func shift_curr_index__to_left():
	var index = _get_dict_index_of_curr_item_index()
	index = _get_shifted_index(index - 1)
	option_button.select(index)
	set_curr_per_game_item_index__and_update_display(index)

func shift_curr_index__to_right():
	var index = _get_dict_index_of_curr_item_index()
	index = _get_shifted_index(index + 1)
	
	if option_button.items.size() != 0:
		option_button.select(index)
	
	set_curr_per_game_item_index__and_update_display(index)


#

func _on_vis_changed():
	#_update_config_signals_to_listen_for_gui_input()
	call_deferred("_update_config_signals_to_listen_for_gui_input")

func _update_config_signals_to_listen_for_gui_input():
	if is_visible_in_tree():
		set_process_input(true)
	else:
		set_process_input(false)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_left"):
			shift_curr_index__to_left()
		elif event.is_action_pressed("ui_right"):
			shift_curr_index__to_right()



#func _on_gui_input(event):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_left"):
#			shift_curr_index__to_left()
#		elif event.is_action_pressed("ui_right"):
#			shift_curr_index__to_right()
#


#

func _get_dict_index_of_curr_item_index() -> int:
	return _id_to_per_game_list_item_map.keys().find(_current_per_game_list_item_id)

func _get_shifted_index(arg_index):
	if arg_index < 0:
		arg_index = _id_to_per_game_list_item_map.size() - 1
	elif arg_index >= _id_to_per_game_list_item_map.size():
		arg_index = 0
	
	return arg_index

