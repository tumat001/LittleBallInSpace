extends Reference


static func has_flag(arg_flag_to_test, arg_flag_total):
	return arg_flag_total & arg_flag_to_test != 0
	

static func add_flag(arg_flag_to_add, arg_flag_total):
	arg_flag_total = arg_flag_total|arg_flag_to_add
	return arg_flag_total

static func add_flags(arg_flags_to_add : Array, arg_flag_total : int = 0):
	for flag in arg_flags_to_add:
		arg_flag_total = arg_flag_total | flag
	
	return arg_flag_total

static func remove_flag(arg_flag_to_remove, arg_flag_total):
	arg_flag_total = arg_flag_total & ~arg_flag_to_remove
	return arg_flag_total


static func is_non_zero_flag(arg_flag):
	return arg_flag != 0

