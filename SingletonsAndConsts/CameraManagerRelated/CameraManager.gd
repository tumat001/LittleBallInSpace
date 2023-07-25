extends Node

const CAM_ANGLE_TURN_DURATION : float = 0.5

#

signal current_cam_rotation_changed(arg_val)

#

var camera : Camera2D

var current_cam_rotation : float

##########

func _ready():
	pass

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
		camera = Camera2D.new()
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

func rotate_cam_to_rad(arg_rotation : float):
	var old_rotation = current_cam_rotation
	
	current_cam_rotation = arg_rotation
	emit_signal("current_cam_rotation_changed", current_cam_rotation)
	
	_start_rotate_cam_visually_to_rad(arg_rotation, old_rotation)


##

func _start_rotate_cam_visually_to_rad(arg_rad, old_rotation):
	#print("rad: %s, old_rot: %s" % [arg_rad, old_rotation])
	
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
	
	tweener.tween_property(camera, "rotation", arg_rad, CAM_ANGLE_TURN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)



################

func make_nodes_rotate_with_camera(arg_nodes : Array):
	pass
	

func make_node_rotate_with_camera(arg_node : Node2D):
	pass
	

