extends Node

const CAM_ANGLE_TURN_DURATION : float = 0.5

#

signal current_cam_rotation_changed(arg_val)

signal cam_visual_rotation_changed(arg_val)

#

var camera : Camera2D

var current_cam_rotation : float

var is_camera_rotating : bool

#

var _nodes_to_follow_camera : Array = []

##########

func _ready():
	_attempt_connect_self_to_rewind_manager()
	_attempt_connect_self_to_game_elements()

#

func _on_current_rewind_manager_changed(arg_manager):
	_attempt_connect_self_to_rewind_manager()

func _attempt_connect_self_to_rewind_manager():
	if is_instance_valid(SingletonsAndConsts.current_rewind_manager):
		SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	else:
		if !SingletonsAndConsts.is_connected("current_rewind_manager_changed", self, "_on_current_rewind_manager_changed"):
			SingletonsAndConsts.connect("current_rewind_manager_changed", self, "_on_current_rewind_manager_changed")



func _on_current_game_elements_changed(arg_ele):
	_attempt_connect_self_to_game_elements()

func _attempt_connect_self_to_game_elements():
	if is_instance_valid(SingletonsAndConsts.current_game_elements):
		SingletonsAndConsts.current_game_elements.connect("before_game_quit", self, "_on_before_game_quit__game_elements")
	else:
		if !SingletonsAndConsts.is_connected("current_game_elements_changed", self, "_on_current_game_elements_changed"):
			SingletonsAndConsts.connect("current_game_elements_changed", self, "_on_current_game_elements_changed")


func _on_before_game_quit__game_elements():
	if is_instance_valid(camera) and !camera.is_queued_for_deletion():
		camera.queue_free()


#

#func get_current_camera_2D():
#	var viewport = get_viewport()
#	if not viewport:
#		return null
#
#	var cameras_group_name = "__cameras_%d" % viewport.get_viewport_rid().get_id()
#	var cameras = get_tree().get_nodes_in_group(cameras_group_name)
#
#	for camera in cameras:
#		if camera is Camera2D and camera.current:
#			return camera
#	return null


func generate_camera():
	if !is_instance_valid(camera):
		camera = ShakeCamera2D.new() #Camera2D.new()
		camera.rotating = true
		camera.smoothing_enabled = true
		
		add_child(camera)

func set_camera_to_follow_node_2d(arg_node_2d : Node2D):
	camera.current = true
	
	var cam_parent : Node = camera.get_parent()
	if is_instance_valid(cam_parent):
		cam_parent.remove_child(camera)
	
	if arg_node_2d.has_method("receive_cam_focus__as_child"):
		arg_node_2d.receive_cam_focus__as_child(camera)
	else:
		arg_node_2d.add_child(camera)

###

func rotate_cam_to_rad(arg_rotation : float, rotate_visually : bool = true):
	var old_rotation = current_cam_rotation
	
	current_cam_rotation = arg_rotation
	emit_signal("current_cam_rotation_changed", current_cam_rotation)
	
	if rotate_visually:
		_start_rotate_cam_visually_to_rad(arg_rotation, old_rotation)


##

func _start_rotate_cam_visually_to_rad(arg_rad, old_rotation):
	#print("rad: %s, old_rot: %s" % [arg_rad, old_rotation])
	
	is_camera_rotating = true
	
	var added_rad = arg_rad + arg_rad
	var added_old_rot = arg_rad + old_rotation
	if abs(added_rad - added_old_rot) > PI/2:
		if arg_rad > 0:
			arg_rad = arg_rad - 2*PI
		else:
			arg_rad = arg_rad - 2*PI
	
#	if arg_rad > 2*PI:
#		arg_rad -= 2*PI
#	if -arg_rad > 2*PI:
#		arg_rad += 2*PI
	
	arg_rad = fmod(arg_rad, (2*PI))
	
	
	var tweener = create_tween()
	tweener.tween_method(self, "_set_actual_rotation_of_cam", camera.rotation, arg_rad, CAM_ANGLE_TURN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	

#

func _set_actual_rotation_of_cam(arg_rotation):
	if is_instance_valid(camera):
		camera.rotation = arg_rotation
	
	if is_equal_approx(arg_rotation, current_cam_rotation):
		is_camera_rotating = false
	
	emit_signal("cam_visual_rotation_changed", arg_rotation)


###

func set_non_gui_screen_shader_sprite(arg_sprite : Sprite):
	_make_node_follow_camera(arg_sprite)

func _make_node_follow_camera(arg_node_2d : Node2D):
	
	if !arg_node_2d.is_connected("tree_exiting", self, "_on_node_following_camera_tree_exiting"):
		arg_node_2d.connect("tree_exiting", self, "_on_node_following_camera_tree_exiting", [arg_node_2d])
	
	if !_nodes_to_follow_camera.has(arg_node_2d):
		_nodes_to_follow_camera.append(arg_node_2d)
	

func _on_node_following_camera_tree_exiting(arg_node_2d : Node2D):
	_nodes_to_follow_camera.erase(arg_node_2d)


func _process(delta):
	for node in _nodes_to_follow_camera:
		node.global_position = camera.global_position


###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind

var _rewinded_current_cam_rotation

func get_rewind_save_state():
	return {
		"camera.rotation" : camera.rotation,
		"current_cam_rotation" : current_cam_rotation,
		"is_camera_rotating" : is_camera_rotating,
	}
	

func load_into_rewind_save_state(arg_state):
	_set_actual_rotation_of_cam(arg_state["camera.rotation"])
	
	_rewinded_current_cam_rotation = arg_state["current_cam_rotation"]
	rotate_cam_to_rad(_rewinded_current_cam_rotation, false)
	
	is_camera_rotating = arg_state["is_camera_rotating"]

func destroy_from_rewind_save_state():
	pass
	

func restore_from_destroyed_from_rewind():
	pass
	

func stared_rewind():
	pass
	

func ended_rewind():
	if is_camera_rotating:
		rotate_cam_to_rad(_rewinded_current_cam_rotation)
	


