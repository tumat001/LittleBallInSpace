extends Node

enum RNGSource {
	NON_ESSENTIAL = 0
}

var non_essential_rng : RandomNumberGenerator

var rng_singleton_map : Dictionary


func _init():
	for rng_id in RNGSource.values():
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		rng_singleton_map[rng_id] = rng
	
	#
	
	non_essential_rng = rng_singleton_map[RNGSource.NON_ESSENTIAL]

func get_rng(arg_id) -> RandomNumberGenerator:
	return rng_singleton_map[arg_id]
	


##

static func randomly_select_one_element(arg_eles : Array, arg_rng : RandomNumberGenerator):
	var rand_i = arg_rng.randi_range(0, arg_eles.size() - 1)
	
	return arg_eles[rand_i]


# REMOVES entries from arg_eles. 
# Must duplicate array if this is not desired
static func randomly_select_elements(arg_eles : Array, arg_rng : RandomNumberGenerator, arg_count : int):
	var bucket = []
	for i in arg_count:
		if arg_eles.size() != 0:
			var rand_i = arg_rng.randi_range(0, arg_eles.size() - 1)
			
			var ele = arg_eles[rand_i]
			bucket.append(ele)
			arg_eles.remove(rand_i)
		else:
			break
	
	return bucket


