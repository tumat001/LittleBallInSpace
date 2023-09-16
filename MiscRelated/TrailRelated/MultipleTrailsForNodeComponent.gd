extends Reference


const StoreOfTrailType = preload("res://MiscRelated/TrailRelated/StoreOfTrailType.gd")

#

signal on_trail_constructed(arg_trail)
signal on_trail_before_attached_to_node(arg_trail, node)
signal on_trail_after_attached_to_node(arg_trail, node)

var all_associated_trails : Array = []

var trail_type_id : int

var node_to_host_trails : Node setget set_node_to_host_trails # Ex: the tower (that is going to shoot bullets that have trails)
var custom_func_name_for_adding_trail_as_child : String

func set_node_to_host_trails(arg_node):
	if is_instance_valid(node_to_host_trails):
		if node_to_host_trails.is_connected("tree_exiting", self, "_on_hosting_node_queued_free"):
			node_to_host_trails.disconnect("tree_exiting", self, "_on_hosting_node_queued_free")
	
	node_to_host_trails = arg_node
	
	if is_instance_valid(node_to_host_trails):
		if !node_to_host_trails.is_connected("tree_exiting", self, "_on_hosting_node_queued_free"):
			node_to_host_trails.connect("tree_exiting", self, "_on_hosting_node_queued_free")


#

func create_trail_for_node(arg_node):
	var trail = _get_idle_and_available_trail()
	if trail == null or !is_instance_valid(trail):
		trail = _construct_trail()
	
	emit_signal("on_trail_before_attached_to_node", trail, arg_node)
	trail.set_node_to_trail(arg_node)
	emit_signal("on_trail_after_attached_to_node", trail, arg_node)
	
	return trail

#

func _get_idle_and_available_trail():
	for trail in all_associated_trails:
		if is_instance_valid(trail) and !trail.is_queued_for_deletion() and trail.is_idle_and_available:
			trail.enable_one_time__set_by_trail_compo()
			return trail
	
	return null

func _construct_trail():
	var trail_instance = StoreOfTrailType.create_trail_type_instance(trail_type_id)
	trail_instance.enable_one_time__set_by_trail_compo()
	emit_signal("on_trail_constructed", trail_instance)
	
	trail_instance.connect("tree_exiting", self, "_on_trail_queue_free", [trail_instance], CONNECT_ONESHOT)
	
	all_associated_trails.append(trail_instance)
	
	if node_to_host_trails.has_meta(custom_func_name_for_adding_trail_as_child):
		node_to_host_trails.call(custom_func_name_for_adding_trail_as_child, trail_instance)
	else:
		node_to_host_trails.add_child(trail_instance)
	
	
	return trail_instance

func _on_trail_queue_free(arg_trail):
	all_associated_trails.erase(arg_trail)


#

func _on_hosting_node_queued_free():
	queue_free_all_trails()

func queue_free_all_trails():
	for trail in all_associated_trails:
		trail.queue_free()
	
	all_associated_trails.clear()
	
