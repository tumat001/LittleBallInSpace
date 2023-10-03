extends AnimatedSprite


const anim_name__medium = "medium"
const all_anim_names : Array = [
	anim_name__medium
]

#

const duration_per_half_revo : float = 0.12

#

func change_anim_to_anim_name(arg_name):
	play(arg_name)

#

func play_particle_effect_actions(arg_revolutions : int, arg_starting_radius, arg_ending_radius):
	var center = global_position
	var starting_rad_as_rand_vec = Vector2(arg_starting_radius, 0).rotated(SingletonsAndConsts.non_essential_rng.randf_range(0, 2*PI))
	global_position = center + starting_rad_as_rand_vec
	
	####
	var starting_x = starting_rad_as_rand_vec.x
	var starting_y = starting_rad_as_rand_vec.y
	
	var inc_per_half_revolution = (arg_ending_radius - arg_starting_radius) / (arg_revolutions * 2)
	var mult : int = -1
	
	var total_half_revos = arg_revolutions * 2
	
	var pos_tweener = create_tween()
	pos_tweener.set_parallel(false)
	for i in total_half_revos:
		var target_x = 1*(0 + (inc_per_half_revolution * i))
		var target_y = 0#1*(0 + (inc_per_half_revolution * i))
		var target_vector : Vector2 = Vector2(target_x, target_y)
		#target_vector = target_vector.rotated(PI * i)
		target_vector = Vector2(center.x + target_vector.x, center.y + target_vector.y)
		
		#pos_tweener.tween_method(self, "_set_glob_pos__using_tweener", global_position, target_vector, duration_per_half_revo, )
		
		#pos_tweener.tween_property(self, "global_position", target_vector, duration_per_half_revo)
		#pos_tweener.tween_property(self, "global_position:x", center.x + mult*(starting_x + (inc_per_half_revolution * i)), duration_per_half_revo)
		#pos_tweener.tween_property(self, "global_position:y", center.y + mult*(starting_y + (inc_per_half_revolution * i)), duration_per_half_revo)
		
		mult *= -1
	
	pos_tweener.tween_callback(self, "tweener_finished")
	
	#var misc_tweener = create_tween()
	#misc_tweener.set_parallel(true)
	#misc_tweener.tween_property(self, "modulate:a", 0.0, duration_per_half_revo * total_half_revos)
	#pos_tweener.tween_method(pos_tweener, "set_speed_scale", 1, 3, duration_per_half_revo * total_half_revos)

func tweener_finished():
	visible = false
