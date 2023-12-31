extends MarginContainer

#

const GUI_SettingsPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/SettingsPanel/GUI_SettingsPanel.gd")
const GUI_SettingsPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/SettingsPanel/GUI_SettingsPanel.tscn")

#

signal hierarchy_emptied()

signal hierarchy_traversed_backwards(arg_control)  # control being faded away/removed
signal hierarchy_advanced_forwards(arg_control)  # contol being showed

signal info_button_pressed()

#

const CONTROL_METHOD_NAME__RECEIVED_FOCUS = "on_control_received_focus"
const CONTROL_METHOD_NAME__FULLY_VISIBLE = "on_control_fully_visible"
const CONTROL_METHOD_NAME__LOST_FOCUS = "on_control_lost_focus"
const CONTROL_METHOD_NAME__FULLY_INVISIBLE = "on_control_fully_invisible"

const CONTROL_PROPERTY_NAME__CONTROL_TREE = "control_tree"
const CONTROL_PROPERTY_NAME_OPTIONAL__MAKE_UNBACKABLE = "is_unbackable"


#

var _is_transitioning : bool

# ex: main pause, settings, additional details
# pressing ESC or backing will take from 'additional details' to 'settings'
var _current_hierarchy : Array = []
var _current_control_showing : Control  # the last element in _current_hierarchy


export(bool) var traverse_hierarchy_on_background_click : bool = true setget set_traverse_hierarchy_on_background_click
export(bool) var traverse_hierarchy_on_ESC_click : bool = true setget set_traverse_hierarchy_on_ESC_click

export(bool) var use_mod_a_tweeners_for_traversing_hierarchy : bool = false setget set_use_mod_a_tweeners_for_traversing_hierarchy

export(bool) var pause_tree_on_show : bool = true setget set_pause_tree_on_show

export(bool) var consume_all_key_inputs : bool = true

export(Color) var background_texture_rect_modulate : Color = Color("d1ffffff") setget set_background_texture_rect_modulate

#

var show_info_button : bool = false setget set_show_info_button
var show_back_button : bool = true setget set_show_back_button

#

var _disable_backing_and_esc__by_curr_control : bool

var _control_to_associated_button_list_to_show : Dictionary = {}


var can_show_settings_button_on_first_hierarchy : bool = false setget set_can_show_settings_button_on_first_hierarchy

#

var _gui_settings_panel : GUI_SettingsPanel

#

onready var control_container = $ControlContainer

onready var info_button = $TopRightButtonMarginer/HBoxContainer/InfoButton
onready var back_button = $TopRightButtonMarginer/HBoxContainer/BackButton
onready var settings_button = $TopRightButtonMarginer/HBoxContainer/SettingsButton

onready var top_right_hbox_container = $TopRightButtonMarginer/HBoxContainer

onready var background_texture_rect = $TextureRect

#

func set_background_texture_rect_modulate(arg_val):
	background_texture_rect_modulate = arg_val
	
	if is_inside_tree():
		background_texture_rect.modulate = arg_val

func get_background_texture_rect_modulate():
	return background_texture_rect_modulate

#

func set_traverse_hierarchy_on_background_click(arg_val):
	traverse_hierarchy_on_background_click = arg_val
	

func set_traverse_hierarchy_on_ESC_click(arg_val):
	traverse_hierarchy_on_ESC_click = arg_val
	

func set_use_mod_a_tweeners_for_traversing_hierarchy(arg_val):
	use_mod_a_tweeners_for_traversing_hierarchy = arg_val
	

func set_pause_tree_on_show(arg_val):
	pause_tree_on_show = arg_val
	
	if pause_tree_on_show:
		pause_mode = Node.PAUSE_MODE_PROCESS
	else:
		pause_mode = Node.PAUSE_MODE_INHERIT

#

func _ready():
	visible = false
	set_process_unhandled_key_input(false)
	set_process_input(false)
	
	for child in control_container.get_children():
		child.visible = false
		_attempt_register_control(child)
	
	#
	
	_init_top_right_hbox_container()
	set_show_info_button(show_info_button)
	set_show_back_button(show_back_button)
	set_can_show_settings_button_on_first_hierarchy(can_show_settings_button_on_first_hierarchy)
	
	set_background_texture_rect_modulate(background_texture_rect_modulate)

func show_control__and_add_if_unadded(arg_control : Control, arg_use_tweeners_for_show : bool = use_mod_a_tweeners_for_traversing_hierarchy):
	_show_control__and_add_if_unadded__internal(arg_control, arg_use_tweeners_for_show, true)

func _show_control__and_add_if_unadded__internal(arg_control : Control, arg_use_tweeners_for_show : bool,
		arg_add_in_hierarchy : bool):
	
	#_attempt_register_control(arg_control)
	
	if !visible:
		visible = true
		
		if pause_tree_on_show:
			get_tree().paused = true
		
		set_process_unhandled_key_input(true)
		set_process_input(true)
	
	if !control_container.get_children().has(arg_control):
		add_control__but_dont_show(arg_control)
	
	_attempt_register_control(arg_control)
	
	#
	
	var prev_control = _current_control_showing
	if is_instance_valid(_current_control_showing) and _current_control_showing != arg_control:
		 _hide_control__no_traverse_thru_hierarchy__internal(prev_control)
	
	#
	
	_current_control_showing = arg_control
	if arg_add_in_hierarchy:
		attempt_add_control_to_current_hierarchy(arg_control)
	
	if _control_to_associated_button_list_to_show.has(arg_control):
		for button in _control_to_associated_button_list_to_show[arg_control]:
			button.visible = true
	
	arg_control.visible = true
	arg_control.call(CONTROL_METHOD_NAME__RECEIVED_FOCUS)
	if arg_use_tweeners_for_show:
		arg_control.modulate.a = 0
		_is_transitioning = true
		var tweener = create_tween()
		tweener.set_parallel(false)
		tweener.tween_property(arg_control, "modulate:a", 1.0, 0.5)
		tweener.tween_callback(self, "_on_control_fully_visible_from_tweener", [arg_control])
		
	else:
		arg_control.modulate.a = 1
		_is_transitioning = false
		arg_control.call(CONTROL_METHOD_NAME__FULLY_VISIBLE)
	
	
	_check_if_control_implements_necessaries__and_print_if_not(arg_control)
	
	
	if arg_control.get(CONTROL_PROPERTY_NAME_OPTIONAL__MAKE_UNBACKABLE):
		_disable_backing_and_esc__by_curr_control = true
		back_button.modulate.a = 0
		
	else:
		_disable_backing_and_esc__by_curr_control = false
		back_button.modulate.a = 1
		
	
	_update_settings_button_visiblity()
	
	emit_signal("hierarchy_advanced_forwards", arg_control)
	
	#print("curr: %s, prev: %s. hier size: %s" % [_current_control_showing, prev_control, _current_hierarchy.size()])

func attempt_add_control_to_current_hierarchy(arg_control):
	if !_current_hierarchy.has(arg_control):
		_current_hierarchy.append(arg_control)


func _on_control_fully_visible_from_tweener(arg_control):
	_is_transitioning = false
	arg_control.call(CONTROL_METHOD_NAME__FULLY_VISIBLE)

#

func add_control__but_dont_show(arg_control : Control):
	arg_control.visible = false
	_attempt_register_control(arg_control)
	control_container.add_child(arg_control)


func _attempt_register_control(arg_control):
	if !is_instance_valid(arg_control.get(CONTROL_PROPERTY_NAME__CONTROL_TREE)):
		arg_control.set(CONTROL_PROPERTY_NAME__CONTROL_TREE, self)
		
		_check_if_control_implements_necessaries__and_print_if_not(arg_control)


func _check_if_control_implements_necessaries__and_print_if_not(arg_control : Control):
	var has_received_focus = arg_control.has_method(CONTROL_METHOD_NAME__RECEIVED_FOCUS)
	var has_fully_visible = arg_control.has_method(CONTROL_METHOD_NAME__FULLY_VISIBLE)
	var has_lost_focus = arg_control.has_method(CONTROL_METHOD_NAME__LOST_FOCUS)
	var has_fully_invis = arg_control.has_method(CONTROL_METHOD_NAME__FULLY_INVISIBLE)
	var has_control_tree_var = arg_control.get(CONTROL_PROPERTY_NAME__CONTROL_TREE)
	
	if !has_received_focus or !has_fully_visible or !has_lost_focus or !has_fully_invis or !has_control_tree_var:
		print("CONTROL TREE: Control does not implement all funcs: %s, %s, %s, %s, %s" % [has_received_focus, has_fully_visible, has_lost_focus, has_fully_invis, has_control_tree_var])

#

func hide_control__and_traverse_thru_hierarchy(arg_control : Control, arg_use_tweeners : bool):
	_current_hierarchy.erase(arg_control)
	arg_control.call(CONTROL_METHOD_NAME__LOST_FOCUS)
	
	if arg_use_tweeners:
		_is_transitioning = true
		var tweener = create_tween()
		tweener.set_parallel(false)
		tweener.tween_property(arg_control, "modulate:a", 0.0, 0.5)
		tweener.tween_callback(self, "_on_control_fully_invisible_from_tweener", [arg_control, arg_use_tweeners])
		
	else:
		_is_transitioning = false
		_make_control_invis__and_proceed_thru_hierarchy(arg_control, arg_use_tweeners)
	
	emit_signal("hierarchy_traversed_backwards", arg_control)

func _hide_control__no_traverse_thru_hierarchy__internal(arg_control):
	arg_control.call(CONTROL_METHOD_NAME__LOST_FOCUS)
	
	if _control_to_associated_button_list_to_show.has(arg_control):
		for button in _control_to_associated_button_list_to_show[arg_control]:
			button.visible = false
	
	arg_control.visible = false
	arg_control.call(CONTROL_METHOD_NAME__FULLY_INVISIBLE)
	

#

func _on_control_fully_invisible_from_tweener(arg_control, arg_use_tweeners):
	_is_transitioning = false
	_make_control_invis__and_proceed_thru_hierarchy(arg_control, arg_use_tweeners)
	

func _make_control_invis__and_proceed_thru_hierarchy(arg_control, arg_use_tweeners) -> Control:
	arg_control.visible = false
	arg_control.call(CONTROL_METHOD_NAME__FULLY_INVISIBLE)
	
	if _current_hierarchy.size() != 0:
		var control_to_show = _current_hierarchy.back()
		_show_control__and_add_if_unadded__internal(control_to_show, arg_use_tweeners, false)
		return control_to_show
	else:
		_current_control_showing = null
		visible = false
		set_process_unhandled_key_input(false)
		set_process_input(false)
		
		if pause_tree_on_show:
			get_tree().paused = false
		
		#emit_signal("hierarchy_emptied")
		call_deferred("emit_signal", "hierarchy_emptied")
		return null

func hide_current_control__and_traverse_thru_hierarchy(arg_use_tweener : bool):
	if is_instance_valid(_current_control_showing):
		hide_control__and_traverse_thru_hierarchy(_current_control_showing, arg_use_tweener)
		

func hide_control__and_traverse_thru_hierarchy__if_control(arg_control, arg_use_tweeners : bool):
	if _current_control_showing == arg_control:
		hide_control__and_traverse_thru_hierarchy(arg_control, arg_use_tweeners)

##

#func _unhandled_key_input(event):
#	if event.is_action_pressed("ui_cancel"):
#		if !_is_transitioning:
#			if traverse_hierarchy_on_ESC_click:
#				hide_current_control__and_traverse_thru_hierarchy(use_mod_a_tweeners_for_traversing_hierarchy)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			if !_is_transitioning:
				if traverse_hierarchy_on_ESC_click:
					if !_disable_backing_and_esc__by_curr_control:
						get_viewport().set_input_as_handled()
						hide_current_control__and_traverse_thru_hierarchy(use_mod_a_tweeners_for_traversing_hierarchy)
			

func _unhandled_key_input(event):
	if consume_all_key_inputs:
		get_viewport().set_input_as_handled()



func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !_is_transitioning:
				if traverse_hierarchy_on_background_click:
					hide_current_control__and_traverse_thru_hierarchy(use_mod_a_tweeners_for_traversing_hierarchy)
				
			


func is_control_first_in_current_hierarchy(arg_control):
	if _current_hierarchy.size() != 0:
		return _current_hierarchy[0] == arg_control
	else:
		return false

##############
#
###############

func _init_top_right_hbox_container():
	for child in top_right_hbox_container.get_children():
		child.focus_mode = Control.FOCUS_NONE

func set_show_info_button(arg_val):
	show_info_button = arg_val
	
	if is_inside_tree():
		info_button.visible = arg_val

func set_show_back_button(arg_val):
	show_back_button = arg_val
	
	if is_inside_tree():
		back_button.visible = arg_val



func _on_InfoButton_pressed():
	emit_signal("info_button_pressed")

func _on_BackButton_pressed():
	if !_disable_backing_and_esc__by_curr_control:
		hide_current_control__and_traverse_thru_hierarchy(use_mod_a_tweeners_for_traversing_hierarchy)
	



func create_texture_button__with_info_textures() -> TextureButton:
	var button = TextureButton.new()
	button.texture_normal = load("res://_NonMainGameRelateds/_Master/Menu/Assets/MasterMenu_MainPage_InfoButton_Normal.png")
	button.texture_hover = load("res://_NonMainGameRelateds/_Master/Menu/Assets/MasterMenu_MainPage_InfoButton_Hovered.png")
	return button

func add_custom_top_right_button__and_associate_with_control(arg_button : TextureButton, arg_control : Control):
	if !top_right_hbox_container.get_children().has(arg_button):
		arg_button.focus_mode = Control.FOCUS_NONE
		arg_button.visible = false
		top_right_hbox_container.add_child(arg_button)
		top_right_hbox_container.move_child(arg_button, 0)
		
		if !_control_to_associated_button_list_to_show.has(arg_control):
			_control_to_associated_button_list_to_show[arg_control] = []
		_control_to_associated_button_list_to_show[arg_control].append(arg_button)

################

func set_can_show_settings_button_on_first_hierarchy(arg_val):
	can_show_settings_button_on_first_hierarchy = arg_val
	
	if is_inside_tree():
		_update_settings_button_visiblity()

func _update_settings_button_visiblity():
	settings_button.visible = can_show_settings_button_on_first_hierarchy and _current_hierarchy.size() == 1



func _on_SettingsButton_pressed():
	_init_gui_settings_panel()
	_show_gui_settings_panel()

func _init_gui_settings_panel():
	if !is_instance_valid(_gui_settings_panel):
		_gui_settings_panel = GUI_SettingsPanel_Scene.instance()

func _show_gui_settings_panel():
	show_control__and_add_if_unadded(_gui_settings_panel)
	

