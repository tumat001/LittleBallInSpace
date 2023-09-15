extends Line2D


signal on_idle_and_available_state_changed(arg_val)

#

var final_dest_pos : Vector2
var original_pos : Vector2
var time_to_reach_final_dest : float

#

var max_trail_length : int
var trail_color : Color = Color(0.4, 0.5, 1, 1) setget set_trail_color

var is_idle_and_available : bool = true

var trail_offset : Vector2


var _one_time_enable_per_use : bool


var _curr_time_for_reach_final_dest : float
var _dist_between_orig_and_final : float
var _reached_destination : bool

#

#func set_node_to_trail(arg_node : Node2D):
#	if is_instance_valid(node_to_trail):
#		node_to_trail.disconnect("tree_exiting", self, "_on_node_tree_exiting")
#
#	node_to_trail = arg_node
#
#	if is_instance_valid(node_to_trail):
#		node_to_trail.connect("tree_exiting", self, "_on_node_tree_exiting", [], CONNECT_ONESHOT)
#		set_process(true)
#		is_idle_and_available = false
#		emit_signal("on_idle_and_available_state_changed", is_idle_and_available)
#
#	z_as_relative = false
#	z_index = node_to_trail.z_index + z_index_modifier
#
#
#func _on_node_tree_exiting():
#	node_to_trail = null
#

#

# after setting vars/properties, call this
func configure_for_use():
	_curr_time_for_reach_final_dest = 0
	_dist_between_orig_and_final = original_pos.distance_to(final_dest_pos)
	
	is_idle_and_available = false
	_reached_destination = false
	emit_signal("on_idle_and_available_state_changed", is_idle_and_available)
	
	set_process(true)
	


#

func set_trail_color(arg_color : Color):
	trail_color = arg_color
	
	default_color = trail_color

#

func _process(delta):
	#var node_is_not_invis = !set_to_idle_and_available_if_node_is_not_visible or (is_instance_valid(node_to_trail) and (set_to_idle_and_available_if_node_is_not_visible and node_to_trail.visible))
	
	_curr_time_for_reach_final_dest += delta
	if _curr_time_for_reach_final_dest > time_to_reach_final_dest:
		_curr_time_for_reach_final_dest = time_to_reach_final_dest
	
	if _one_time_enable_per_use and !_reached_destination: #and node_is_not_invis and _one_time_enable_per_use:
		var pos_of_point = trail_offset + original_pos.move_toward(final_dest_pos, (_curr_time_for_reach_final_dest / time_to_reach_final_dest) * _dist_between_orig_and_final) - global_position
		global_rotation = 0
		
		add_point(pos_of_point)
		if get_point_count() > max_trail_length:
			remove_point(0)
		
		if _curr_time_for_reach_final_dest == time_to_reach_final_dest:
			_reached_destination = true
		
		
	else:
		if get_point_count() > 0:
			remove_point(0)
		else:
			set_process(false)
			
			is_idle_and_available = true
			emit_signal("on_idle_and_available_state_changed", is_idle_and_available)


func enable_one_time__set_by_trail_compo():
	_one_time_enable_per_use = true

func disable_one_time():
	_one_time_enable_per_use = false

