extends Reference



var obj_to_track : Object setget set_obj_to_track


var var_name_to_last_val_map : Dictionary
var func_name_to_last_val_map : Dictionary

var var_name_with_changes_to_val_map : Dictionary
var func_name_with_changes_to_val_map : Dictionary
var last_calc_has_last_val_changes : bool

###

func add_var_name__for_tracker__based_on_obj(arg_var_name : String):
	var val = obj_to_track.get(arg_var_name)
	add_var_name__for_tracker(arg_var_name, val)

func add_var_name__for_tracker(arg_var_name : String, arg_val):
	var_name_to_last_val_map[arg_var_name] = arg_val
	
	force_set_last_calc_has_changes()


func add_func_name__for_tracker__based_on_obj(arg_func_name : String):
	var val = obj_to_track.call(arg_func_name)
	add_func_name__for_tracker(arg_func_name, val)

func add_func_name__for_tracker(arg_func_name : String, arg_val):
	func_name_to_last_val_map[arg_func_name] = arg_val
	
	force_set_last_calc_has_changes()

#

func set_var_name_val(arg_var_name, arg_val, arg_update_last_calc_has_changes : bool = true):
	var old_val = var_name_to_last_val_map[arg_var_name]
	
	if !if_vals_are_equal(old_val, arg_val): #old_val != arg_val:
		var_name_with_changes_to_val_map[arg_var_name] = arg_val
		var_name_to_last_val_map[arg_var_name] = arg_val
		
		if arg_update_last_calc_has_changes:
			force_set_last_calc_has_changes()

func set_func_name_val(arg_func_name, arg_val, arg_update_last_calc_has_changes : bool = true):
	var old_val = func_name_to_last_val_map[arg_func_name]
	
	if !if_vals_are_equal(old_val, arg_val): #old_val != arg_val:
		func_name_with_changes_to_val_map[arg_func_name] = arg_val
		func_name_to_last_val_map[arg_func_name] = arg_val
		
		if arg_update_last_calc_has_changes:
			force_set_last_calc_has_changes()


func if_vals_are_equal(arg_A_val, arg_B_val):
	if arg_A_val is Dictionary and arg_B_val is Dictionary:
		return arg_A_val.hash() == arg_B_val.hash()
	else:
		return arg_A_val == arg_B_val

func force_set_last_calc_has_changes():
	last_calc_has_last_val_changes = true


#

func reset():
	last_calc_has_last_val_changes = false
	var_name_with_changes_to_val_map.clear()
	func_name_with_changes_to_val_map.clear()

#############

func _init(arg_obj_to_track):
	set_obj_to_track(arg_obj_to_track)

func set_obj_to_track(arg_obj_to_track):
	obj_to_track = arg_obj_to_track
	

func update_based_on_obj_to_track(arg_update_last_calc_has_changes : bool = true):
	for var_name in var_name_to_last_val_map.keys():
		var curr_val = obj_to_track.get(var_name)
		
		set_var_name_val(var_name, curr_val, arg_update_last_calc_has_changes)
	
	for func_name in func_name_to_last_val_map.keys():
		var curr_val = obj_to_track.call(func_name)
		
		set_func_name_val(func_name, curr_val, arg_update_last_calc_has_changes)


