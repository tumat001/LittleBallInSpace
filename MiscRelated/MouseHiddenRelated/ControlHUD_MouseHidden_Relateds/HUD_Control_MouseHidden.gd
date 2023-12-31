#DEFAULT: Visible when mouse is far. Towards invis when mouse is inside/near/farther than pos
extends Control

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

#

const screen_size = Vector2(960, 540)
const screen_size_center_displacement = -(screen_size/2)

#

enum IsActivatedCondClauseIds {
	IS_BALL_FIRE_CHARGING = 0,
}
var is_activated_cond_clause : ConditionalClauses
var last_calc_is_activated : bool


var _tweener_for_mod_a : SceneTreeTween

#

enum AutoAssignPosesOfMouseDetectionModeIds {
	NONE = 0,
	SINGLE_CENTER = 1,
	FOUR_CORNERS = 2,
	TWO_X_SIDES = 3,
	FOUR_CORNERS_AND_CENTER = 4,
	#TWO_Y_SIDES = 4,
}
export(AutoAssignPosesOfMouseDetectionModeIds) var auto_assign_poses_of_mouse_detection_mode_id : int = AutoAssignPosesOfMouseDetectionModeIds.SINGLE_CENTER
var _poses_of_mouse_distance_detection : Array

#export(bool) var allow_debug_draw : bool = false

#

export(float) var mod_a__outside_of_outer_ring : float = 1.0
export(float) var mod_a__inside_of_outer_ring : float = 1.0
export(float) var mod_a__inside_of_inner_ring : float = 0.1

#

export(float) var outer_ring__radius_start_of_reveal : float = 150 setget set_outer_ring__radius_start_of_reveal
export(float) var inner_ring__radius_max_reveal : float = 50 setget set_inner_ring__radius_max_reveal


#

var _is_mouse_inside : bool

###

func _init():
	_tweener_for_mod_a = SceneTreeTween.new()
	
	is_activated_cond_clause = ConditionalClauses.new()
	is_activated_cond_clause.connect("clause_inserted", self, "_on_is_activated_cond_clause_updated")
	is_activated_cond_clause.connect("clause_removed", self, "_on_is_activated_cond_clause_updated")
	_update_last_calc_is_activated()
	
	_connect_mouse_enter_exit_signals()


func _on_is_activated_cond_clause_updated(arg_clause_ids):
	_update_last_calc_is_activated()

func _update_last_calc_is_activated():
	last_calc_is_activated = !is_activated_cond_clause.is_passed
	_update_set_process_state()
	
	if !last_calc_is_activated:
		modulate.a = 1.0



func _update_set_process_state():
	set_process(last_calc_is_activated and !_is_mouse_inside)

#

func _connect_mouse_enter_exit_signals():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("visibility_changed", self, "_on_visibility_changed")


func _on_mouse_entered():
	_set_mouse_inside_state(true)

func _on_mouse_exited():
	_set_mouse_inside_state(false)

func _on_visibility_changed():
	_set_mouse_inside_state(false)



func _set_mouse_inside_state(arg_val):
	_is_mouse_inside = arg_val
	_update_set_process_state()

#

func set_outer_ring__radius_start_of_reveal(arg_val):
	outer_ring__radius_start_of_reveal = arg_val

func set_inner_ring__radius_max_reveal(arg_val):
	inner_ring__radius_max_reveal = arg_val

#

func _ready():
	mouse_filter = MOUSE_FILTER_PASS
	
	_assign_poses_of_mouse_distance_detection__based_on_mode()
	#_connect_mouse_enter_exit_signals()

func _assign_poses_of_mouse_distance_detection__based_on_mode():
	_poses_of_mouse_distance_detection.clear()
	
	#
	match auto_assign_poses_of_mouse_detection_mode_id:
		AutoAssignPosesOfMouseDetectionModeIds.SINGLE_CENTER:
			var x_half = rect_size.x / 2
			var y_half = rect_size.y / 2
			
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_half, y_half))
			
		AutoAssignPosesOfMouseDetectionModeIds.FOUR_CORNERS:
			var x_size = rect_size.x
			var y_size = rect_size.y
			
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(0, 0))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_size, 0))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(0, y_size))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_size, y_size))
			
			
		AutoAssignPosesOfMouseDetectionModeIds.TWO_X_SIDES:
			var x_size = rect_size.x
			
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(0, 0))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_size, 0))
			
		AutoAssignPosesOfMouseDetectionModeIds.FOUR_CORNERS_AND_CENTER:
			var x_size = rect_size.x
			var y_size = rect_size.y
			
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(0, 0))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_size, 0))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(0, y_size))
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_size, y_size))
			
			
			var x_half = rect_size.x / 2
			var y_half = rect_size.y / 2
			
			_poses_of_mouse_distance_detection.append(rect_global_position + Vector2(x_half, y_half))
			
	
	
#	update()
#
#
##temptodo
#func _draw():
#	if true: #allow_debug_draw:
#		print("rectpos center: %s" % [rect_global_position + (rect_size / 2)])
#		for pos in _poses_of_mouse_distance_detection:
#			draw_circle(pos - rect_global_position, 20, Color.green)
#
#			print("pos: %s" % pos)

#####

func _process(delta):
	_update_modulate_based_on_conditions()
	

func _update_modulate_based_on_conditions():
	if _is_mouse_inside:
		set_mod_a(mod_a__inside_of_inner_ring)
		return
	
	#######
	
	var mouse_position = get_viewport().get_mouse_position()
	var mouse_position__from_center = get_viewport().get_mouse_position() - screen_size_center_displacement
	#var own_position__from_center = rect_global_position - screen_size_center_displacement  #get_global_transform_with_canvas().origin - screen_size_center_displacement
	var candidate_pos : Vector2
	var candidate_dist : float = 9999999
	for pos in _poses_of_mouse_distance_detection:
		var dist = mouse_position.distance_to(pos)
		if dist < candidate_dist:
			candidate_pos = pos
			candidate_dist = dist
			
	
	var candidate_position__from_center = candidate_pos - screen_size_center_displacement
	
#	if mouse_position__from_center.length_squared() > candidate_position__from_center.length_squared():
#		if abs(mouse_position__from_center.angle()) - abs(candidate_position__from_center.angle()) < PI/8:
#			set_mod_a(mod_a__inside_of_inner_ring)
#			return
	
	#
	
	_do_actions_based_on_dist(candidate_dist)



func _do_actions_based_on_dist(arg_dist):
	if arg_dist > outer_ring__radius_start_of_reveal:
		#outside outer
		_pos_is_outside_of_outer_ring(arg_dist)
	elif arg_dist < inner_ring__radius_max_reveal:
		#inside inner
		_pos_is_inside_of_inner_ring(arg_dist)
	elif arg_dist > inner_ring__radius_max_reveal:
		#inside outer
		_pos_is_inside_of_outer_ring(arg_dist)


func _pos_is_outside_of_outer_ring(arg_dist):
	_set_mod_a__dist__outside_of_outer_ring(arg_dist)

func _pos_is_inside_of_outer_ring(arg_dist):
	_set_mod_a__dist__inside_of_outer_ring(arg_dist)

func _pos_is_inside_of_inner_ring(arg_dist):
	_set_mod_a__dist__inside_of_inner_ring(arg_dist)



func _set_mod_a__dist__outside_of_outer_ring(arg_dist):
	set_mod_a(mod_a__outside_of_outer_ring)
	

func _set_mod_a__dist__inside_of_outer_ring(arg_dist):
	#var mod_a_to_use = _tweener_for_mod_a.interpolate_value(mod_a__inside_of_outer_ring, (mod_a__inside_of_inner_ring - mod_a__inside_of_outer_ring), (arg_dist - inner_ring__radius_max_reveal), (outer_ring__radius_start_of_reveal - inner_ring__radius_max_reveal), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#mod_a_to_use = 1 - mod_a_to_use
	var mod_a_to_use = _tweener_for_mod_a.interpolate_value(mod_a__inside_of_outer_ring, -(mod_a__inside_of_inner_ring - mod_a__inside_of_outer_ring), (inner_ring__radius_max_reveal - arg_dist), (outer_ring__radius_start_of_reveal - inner_ring__radius_max_reveal), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	mod_a_to_use = (1 - mod_a_to_use) + mod_a__inside_of_inner_ring
	set_mod_a(mod_a_to_use)
	

func _set_mod_a__dist__inside_of_inner_ring(arg_dist):
	set_mod_a(mod_a__inside_of_inner_ring)
	


func set_mod_a(arg_val):
	modulate.a = arg_val


