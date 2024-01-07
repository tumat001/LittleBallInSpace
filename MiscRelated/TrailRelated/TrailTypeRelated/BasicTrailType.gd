extends Line2D


signal on_idle_and_available_state_changed(arg_val)

var node_to_trail : Node2D setget set_node_to_trail
var max_trail_length : int
var trail_color : Color = Color(0.4, 0.5, 1, 1) setget set_trail_color

var is_idle_and_available : bool = true

var set_to_idle_and_available_if_node_is_not_visible : bool = false

var trail_offset : Vector2

var can_add_points : bool = true


var _one_time_enable_per_use : bool

#

func set_node_to_trail(arg_node : Node2D):
	if is_instance_valid(node_to_trail):
		node_to_trail.disconnect("tree_exiting", self, "_on_node_tree_exiting")
	
	node_to_trail = arg_node
	
	if is_instance_valid(node_to_trail):
		node_to_trail.connect("tree_exiting", self, "_on_node_tree_exiting", [], CONNECT_ONESHOT)
		set_process(true)
		is_idle_and_available = false
		emit_signal("on_idle_and_available_state_changed", is_idle_and_available)
	
	#z_as_relative = false
	#z_index = node_to_trail.z_index + z_index_modifier
	


func _on_node_tree_exiting():
	node_to_trail = null
	


#

func set_trail_color(arg_color : Color):
	trail_color = arg_color
	
	default_color = trail_color

#

func _process(delta):
	var node_is_not_invis = !set_to_idle_and_available_if_node_is_not_visible or (is_instance_valid(node_to_trail) and (set_to_idle_and_available_if_node_is_not_visible and node_to_trail.visible))
	
	if is_instance_valid(node_to_trail) and node_is_not_invis and _one_time_enable_per_use:
		if node_to_trail.is_inside_tree():
			var pos_of_point = node_to_trail.global_position - global_position + trail_offset
			
			global_rotation = 0
			
			if can_add_points:
				add_point(pos_of_point)
			
			#for i in 2:
			if get_point_count() > max_trail_length:
				remove_point(0)
			
			#while get_point_count() > max_trail_length:
			#	remove_point(0)
			
	else:
		if is_instance_valid(node_to_trail):
			if node_to_trail.is_connected("tree_exiting", self, "_on_node_tree_exiting"):
				node_to_trail.disconnect("tree_exiting", self, "_on_node_tree_exiting")
			node_to_trail = null
		
		#
		
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


func clear_points():
	.clear_points()
