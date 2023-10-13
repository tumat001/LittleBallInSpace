extends Sprite

const COLOR_RANGE_01 = Color(253/255.0, 209/255.0, 77/255.0, 1.0)
const COLOR_RANGE_02 = Color(232/255.0, 253/255.0, 0/255.0, 1.0)


var lifetime_min
var lifetime_max

var angle_rad_start
var angle_rad_end

var dist_min
var dist_max

#

var _curr_lifetime : float

#

func randomize_all_and_start():
	randomize_color()
	reset_for_another_use()

#

func randomize_color():
	var rng : RandomNumberGenerator = SingletonsAndConsts.non_essential_rng
	var rand_r = rng.randf_range(COLOR_RANGE_01.r, COLOR_RANGE_02.r)
	var rand_g = rng.randf_range(COLOR_RANGE_01.g, COLOR_RANGE_02.g)
	var rand_b = rng.randf_range(COLOR_RANGE_01.b, COLOR_RANGE_02.b)
	
	modulate = Color(rand_r, rand_g, rand_b)


func reset_for_another_use():
	
	modulate.a = 1
	visible = true
	
	_curr_lifetime = SingletonsAndConsts.non_essential_rng.randf_range(lifetime_min, lifetime_max)
	
	_start_mod_a_and_lifetime_tweener()
	_start_pos_tweener()



func _start_mod_a_and_lifetime_tweener():
	
	var mod_a_tweener = create_tween()
	mod_a_tweener.tween_interval(_curr_lifetime / 2.0)
	mod_a_tweener.tween_property(self, "modulate:a", 0.0, _curr_lifetime/2.0)
	mod_a_tweener.tween_callback(self, "_on_mod_a_set_to_0")

func _on_mod_a_set_to_0():
	visible = false



func _start_pos_tweener():
	var rand_rad_angle = SingletonsAndConsts.non_essential_rng.randf_range(angle_rad_start, angle_rad_end)
	var rand_dist = SingletonsAndConsts.non_essential_rng.randf_range(dist_min, dist_max)
	
	var rand_pos_modif = Vector2(rand_dist, 0).rotated(rand_rad_angle)
	
	var pos_tweener = create_tween()
	pos_tweener.tween_property(self, "global_position", global_position + rand_pos_modif, _curr_lifetime)
	





