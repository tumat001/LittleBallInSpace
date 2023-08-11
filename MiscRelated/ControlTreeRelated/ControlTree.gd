extends MarginContainer

#

signal hierarchy_emptied()

#

const CONTROL_METHOD_NAME__RECEIVED_FOCUS = "on_control_received_focus"
const CONTROL_METHOD_NAME__FULLY_VISIBLE = "on_control_fully_visible"
const CONTROL_METHOD_NAME__LOST_FOCUS = "on_control_lost_focus"
const CONTROL_METHOD_NAME__FULLY_INVISIBLE = "on_control_fully_invisible"

const CONTROL_PROPERTY_NAME__CONTROL_TREE = "control_tree"

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

#

onready var control_container = $ControlContainer

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
	#set_process_unhandled_key_input(false)
	set_process_input(false)
	
	for child in control_container.get_children():
		child.visible = false
		_register_control(child)


func show_control__and_add_if_unadded(arg_control : Control, arg_use_tweeners_for_show : bool):
	_show_control__and_add_if_unadded__internal(arg_control, arg_use_tweeners_for_show, true)

func _show_control__and_add_if_unadded__internal(arg_control : Control, arg_use_tweeners_for_show : bool,
		arg_add_in_hierarchy : bool):
	
	_register_control(arg_control)
	
	if !visible:
		visible = true
		
		if pause_tree_on_show:
			get_tree().paused = true
		
		#set_process_unhandled_key_input(true)
		set_process_input(true)
	
	if !control_container.get_children().has(arg_control):
		add_control__but_dont_show(arg_control)
	
	_current_control_showing = arg_control
	
	if arg_add_in_hierarchy and !_current_hierarchy.has(arg_control):
		_current_hierarchy.append(arg_control)
	
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
		_is_transitioning = false
		arg_control.call(CONTROL_METHOD_NAME__FULLY_VISIBLE)
	
	
	_check_if_control_implements_necessaries__and_print_if_not(arg_control)

func _on_control_fully_visible_from_tweener(arg_control):
	_is_transitioning = false
	arg_control.call(CONTROL_METHOD_NAME__FULLY_VISIBLE)

#

func add_control__but_dont_show(arg_control : Control):
	arg_control.visible = false
	_register_control(arg_control)
	control_container.add_child(arg_control)
	
func _register_control(arg_control):
	
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
		

func _on_control_fully_invisible_from_tweener(arg_control, arg_use_tweeners):
	_is_transitioning = false
	_make_control_invis__and_proceed_thru_hierarchy(arg_control, arg_use_tweeners)
	

func _make_control_invis__and_proceed_thru_hierarchy(arg_control, arg_use_tweeners):
	arg_control.visible = false
	arg_control.call(CONTROL_METHOD_NAME__FULLY_INVISIBLE)
	
	if _current_hierarchy.size() != 0:
		_show_control__and_add_if_unadded__internal(_current_hierarchy.pop_back(), arg_use_tweeners, false)
		
	else:
		_current_control_showing = null
		visible = false
		#set_process_unhandled_key_input(false)
		set_process_input(false)
		
		if pause_tree_on_show:
			get_tree().paused = false
		
		emit_signal("hierarchy_emptied")
		

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
					get_viewport().set_input_as_handled()
					hide_current_control__and_traverse_thru_hierarchy(use_mod_a_tweeners_for_traversing_hierarchy)
					

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if !_is_transitioning:
				if traverse_hierarchy_on_background_click:
					hide_current_control__and_traverse_thru_hierarchy(use_mod_a_tweeners_for_traversing_hierarchy)
				
			
