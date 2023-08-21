extends Node

const CAM_ANGLE_TURN_DURATION : float = 0.5

#

signal current_cam_rotation_changed(arg_val)

signal cam_visual_rotation_changed(arg_val)

#

const ZOOM_OUT__DEFAULT__ZOOM_LEVEL = Vector2(2.0, 2.0)
const ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION = 1.0

const DEFAULT_ZOOM_LEVEL = Vector2(1.0, 1.0)
const ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION = 0.5

#

var camera : Camera2D

var current_cam_rotation : float

var is_camera_rotating : bool

#

var _current_cam_zoom_tweener : SceneTreeTween

#

var _screen_size_half : Vector2
var _nodes_to_follow_camera : Array = []

var _nodes_to_rotate_on_camera_rotate : Array = []

#

var _current_default_zoom_out_vec
var _current_default_zoom_normal_vec

var _is_at_default_zoom : bool

#

#var _special_cam_view_position
#var _special_cam_view_zoom_level


##########

func _ready():
	#print("cam rot: %s" % fmod((-3*PI/2), (2*PI)))
	
	var screen_size_rect : Rect2 = get_viewport().get_visible_rect()
	_screen_size_half = Vector2(screen_size_rect.size.x / 2, screen_size_rect.size.y / 2)
	
	_attempt_connect_self_to_rewind_manager()
	_attempt_connect_self_to_game_elements()
	connect("cam_visual_rotation_changed", self, "_rotate_nodes_to_rotate_with_cam")
	

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
	#print("rad: %s, old_rot: %s, actual_cam_rotation: %s" % [arg_rad, old_rotation, camera.rotation])
	
	#arg_rad = fmod(arg_rad, (2*PI))
	#old_rotation = fmod(old_rotation, (2*PI))
	
	
	if abs(arg_rad) + abs(old_rotation) > PI:
		if arg_rad > 0 and old_rotation < 0:
			arg_rad = -arg_rad
		elif arg_rad < 0 and old_rotation > 0:
			old_rotation = -old_rotation
	
	
#	if camera.rotation > 0:
#		camera.rotation = fmod(camera.rotation, (2*PI))
#		print("corr pos: %s" % fmod(camera.rotation, (2*PI)))
#
#	elif camera.rotation < 0:
#		camera.rotation = -fmod(-camera.rotation, (2*PI))
#		print("corr neg: %s" % -fmod(-camera.rotation, (2*PI)))
	
	camera.rotation = fmod(camera.rotation, (2*PI))
	camera.rotation = fmod(camera.rotation, -(2*PI))
	
	if is_equal_approx(camera.rotation, -3*PI/2):
		camera.rotation = PI/2
	elif is_equal_approx(camera.rotation, 3*PI/2):
		camera.rotation = -PI/2
	
	
	if is_equal_approx(camera.rotation, -PI) and is_equal_approx(old_rotation, PI):
		camera.rotation = PI
	elif is_equal_approx(camera.rotation, PI) and is_equal_approx(old_rotation, -PI) and arg_rad < 0:
		camera.rotation = -PI
	
	
	#print("rad: %s, old_rot: %s, actual_cam_rotation: %s" % [arg_rad, old_rotation, camera.rotation])
	#print("-----------")
	
	#####
	
	is_camera_rotating = true
	
	var added_rad = arg_rad + arg_rad
	var added_old_rot = arg_rad + old_rotation
	if abs(added_rad - added_old_rot) > PI/2:
		if arg_rad > 0:
			arg_rad = arg_rad - 2*PI
		else:
			arg_rad = arg_rad - 2*PI
	
	arg_rad = fmod(arg_rad, (2*PI))
	
	#
	
	var tweener = create_tween()
	tweener.tween_method(self, "_set_actual_rotation_of_cam", camera.rotation, arg_rad, CAM_ANGLE_TURN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

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
	#make_node_rotate_with_camera(arg_sprite)

func _make_node_follow_camera(arg_node_2d : Node2D):
	if !arg_node_2d.is_connected("tree_exiting", self, "_on_node_following_camera_tree_exiting"):
		arg_node_2d.connect("tree_exiting", self, "_on_node_following_camera_tree_exiting", [arg_node_2d])
	
	if !_nodes_to_follow_camera.has(arg_node_2d):
		_nodes_to_follow_camera.append(arg_node_2d)

func _on_node_following_camera_tree_exiting(arg_node_2d : Node2D):
	_nodes_to_follow_camera.erase(arg_node_2d)


func _process(delta):
	for node in _nodes_to_follow_camera:
		node.global_position = (camera.global_position + _screen_size_half)

#

func make_node_rotate_with_camera(arg_node_2d):
	if !arg_node_2d.is_connected("tree_exiting", self, "_on_node_rotating_with_camera_tree_exiting"):
		arg_node_2d.connect("tree_exiting", self, "_on_node_rotating_with_camera_tree_exiting", [arg_node_2d])
	
	if !_nodes_to_rotate_on_camera_rotate.has(arg_node_2d):
		_nodes_to_rotate_on_camera_rotate.append(arg_node_2d)

func _on_node_rotating_with_camera_tree_exiting(arg_node_2d):
	_nodes_to_rotate_on_camera_rotate.erase(arg_node_2d)


func _rotate_nodes_to_rotate_with_cam(arg_angle):
	for node in _nodes_to_rotate_on_camera_rotate:
		node.rotation = camera.rotation

######################

func set_current_default_zoom_normal_vec(arg_zoom,
		arg_use_ease_for_change : bool, arg_duration_for_ease_of_change = ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION):
	
	_current_default_zoom_normal_vec = arg_zoom
	
	if arg_use_ease_for_change:
		start_camera_zoom_change(_current_default_zoom_normal_vec, arg_duration_for_ease_of_change)
	else:
		camera.zoom = arg_zoom
	
	_is_at_default_zoom = true

func set_current_default_zoom_out_vec(arg_zoom):
	_current_default_zoom_out_vec = arg_zoom
	

#

func start_camera_zoom_change__with_default_player_initialized_vals():
	start_camera_zoom_change(_current_default_zoom_out_vec, ZOOM_OUT__DEFAULT__DURATION_OF_TRANSITION)
	

func start_camera_zoom_change(arg_val, arg_duration):
	if _current_cam_zoom_tweener != null and _current_cam_zoom_tweener.is_running():
		_current_cam_zoom_tweener.kill()
	
	_current_cam_zoom_tweener = create_tween()
	_current_cam_zoom_tweener.tween_property(camera, "zoom", arg_val, arg_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	_is_at_default_zoom = false

func reset_camera_zoom_level():
	start_camera_zoom_change(_current_default_zoom_normal_vec, ZOOM_IN_FROM_OUT__DEFAULT__DURATION_OF_TRANSITION)
	
	_is_at_default_zoom = true


func is_at_default_zoom():
	return _is_at_default_zoom

#

func get_camera__global_position():
	return camera.global_position


func disable_camera_smoothing():
	camera.smoothing_enabled = false
func enable_camera_smoothing():
	camera.smoothing_enabled = true


func make_camera_immediatelty_catch_up_to_node():
	#camera.force_update_scroll()
	camera.reset_smoothing()
	
	#camera.align()

func set_camera_glob_pos(arg_pos):
	camera.global_position = arg_pos


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
	


