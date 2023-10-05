extends MarginContainer


onready var option_button = $VBoxContainer/OptionButton
onready var left_button = $VBoxContainer/HBoxContainer/LeftButton
onready var right_button = $VBoxContainer/HBoxContainer/RightButton
onready var gsm_per_game_panel = $VBoxContainer/HBoxContainer/GSM_PerGame_Panel

#

const NO_PER_GAME_ID = -1

#

class PerGameListItem:
	var button_icon : Texture
	var button_label : String
	var id : int = NO_PER_GAME_ID
	var level_id : int = -1
	
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


func clear_per_game_list(arg_update_disp : bool):
	_id_to_per_game_list_item_map.clear()
	option_button.clear()
	
	if arg_update_disp:
		_update_display()

func set_curr_per_game_item_index__and_update_display(arg_index):
	_current_per_game_list_item_id = arg_index
	_update_display()

func _update_display():
	gsm_per_game_panel.set_visibility_of_level_name_panel(show_level_name_on_per_game_panel)
	
	if _id_to_per_game_list_item_map.has(_current_per_game_list_item_id):
		var per_game_item = _id_to_per_game_list_item_map[_current_per_game_list_item_id]
		gsm_per_game_panel.set_per_game_details(per_game_item.per_game_data, per_game_item.level_id)
		#todo
		print("set_per_game_details -> %s" % _current_per_game_list_item_id)
	else:
		gsm_per_game_panel.set_per_game_details(_empty_per_game_list_item.per_game_data, _empty_per_game_list_item.level_id)
		_current_per_game_list_item_id = NO_PER_GAME_ID 
		#todo
		print("set_per_game_details -> none %s" % _current_per_game_list_item_id)
	
	#
	
	if _id_to_per_game_list_item_map.size() > 1:
		left_button.disabled = false
		right_button.disabled = false
		
		if left_button.modulate.a == 0:
			left_button.modulate.a = 1
			right_button.modulate.a = 1
		
	else:
		left_button.disabled = true
		right_button.disabled = true
		
		if !show_arrows_on_zero_or_one_item_in_list:
			left_button.modulate.a = 0
			right_button.modulate.a = 0
		
	

###########

func _on_OptionButton_item_selected(index):
	set_curr_per_game_item_index__and_update_display(index)

func _on_LeftButton_pressed():
	var index = _get_dict_index_of_curr_item_index()
	index = _get_shifted_index(index)
	set_curr_per_game_item_index__and_update_display(index)

func _on_RightButton_pressed():
	var index = _get_dict_index_of_curr_item_index()
	index = _get_shifted_index(index)
	set_curr_per_game_item_index__and_update_display(index)


#

func _get_dict_index_of_curr_item_index() -> int:
	return _id_to_per_game_list_item_map.keys().find(_current_per_game_list_item_id)

func _get_shifted_index(arg_index):
	if arg_index < 0:
		arg_index = _id_to_per_game_list_item_map.size() - 1
	elif arg_index >= _id_to_per_game_list_item_map.size():
		arg_index = 0
	
	return arg_index

