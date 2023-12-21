tool
extends Node2D

#

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const VariableHistory = preload("res://MiscRelated/RewindHelperRelated/VariableHistory.gd")


#

signal player_entered(arg_player)
signal object_entered(arg_object)

signal player_entered__as_scene_transition(arg_player)

#

const COLOR_RED__P_SPRITE = Color("#620000")
const COLOR_RED__P_FRAME = Color("#c20000")

const COLOR_GREEN__P_SPRITE = Color("#006200")
const COLOR_GREEN__P_FRAME = Color("#00c200")

const COLOR_BLUE__P_SPRITE = Color("#000062")
const COLOR_BLUE__P_FRAME = Color("#0000c2")

const COLOR_WHITE__P_SPRITE = Color("#ffffff")
const COLOR_WHITE__P_FRAME = Color("#999999")



enum PortalColor {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
	
	WHITE = 3,
}

#
export(PortalColor) var portal_color : int = PortalColor.BLUE setget set_portal_color

export(bool) var is_disabled : bool setget set_is_disabled

export(NodePath) var portal_to_link_with__path : NodePath setget set_portal_to_link_with__path
var _portal_to_link_with

export(bool) var show_link_at_editor : bool = true setget set_show_link_at_editor


var _nodes_to_not_teleport_on_first_enter : Array

var _bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed : Dictionary

#

var _is_in_ready : bool = false

#

# settable only from start. no effect from changing it afterwards
export(bool) var is_scene_transition_type_portal : bool = false

#

var is_class_type_portal : bool = true

#

var _ripple_sprite : Sprite
var _ripple_sprite_shader_material : ShaderMaterial

const _ripple_duration_to_final_size = 0.75

#

enum DisableCollisionClauseId {
	IN_REWIND = 0,
	IS_DISABLED = 1,
}
var disabled_collision_cond_clauses : ConditionalClauses
var last_calculated_is_collision_disabled : bool

######

onready var portal_sprite = $PortalSprite
onready var portal_frame = $PortalFrame

onready var coll_shape_2d = $Area2D/CollisionShape2D

#

func _init():
	disabled_collision_cond_clauses = ConditionalClauses.new()
	disabled_collision_cond_clauses.connect("clause_inserted", self, "_on_disabled_collision_cond_clauses_updated")
	disabled_collision_cond_clauses.connect("clause_removed", self, "_on_disabled_collision_cond_clauses_updated")
	_update_last_calculated_is_collision_disabled()
	
	_init_rewind_variable_history()

func _on_disabled_collision_cond_clauses_updated(arg_clause_id):
	_update_last_calculated_is_collision_disabled()
	

func _update_last_calculated_is_collision_disabled():
	var old_val = last_calculated_is_collision_disabled
	last_calculated_is_collision_disabled = !disabled_collision_cond_clauses.is_passed
	
	if is_inside_tree():
		if old_val != last_calculated_is_collision_disabled or _is_in_ready:
			coll_shape_2d.set_deferred("disabled", last_calculated_is_collision_disabled)

#

func _ready():
	if !Engine.editor_hint:
		SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	
	
	_is_in_ready = true
	#
	set_process(false)
	
	_initialize_coll_shape_and_size()
	_initialize_portal_to_link_to()
	
	set_portal_color(portal_color)
	set_is_disabled(is_disabled)
	
	_initialize_is_scene_transition_type_portal()
	#
	_is_in_ready = false

func _initialize_coll_shape_and_size():
	#var texutre_size_with_scale = texture.get_size() * scale
	#var circle_shape_2d = CircleShape2D.new()
	#circle_shape_2d.radius = texutre_size_with_scale.x / 2.0
	
	var circle_shape_2d = CircleShape2D.new()
	circle_shape_2d.radius = 5.0
	
	coll_shape_2d.shape = circle_shape_2d

func _initialize_portal_to_link_to():
	_set_portal_to_link_to(get_node_or_null(portal_to_link_with__path))
	



func _set_portal_to_link_to(arg_portal):
	_portal_to_link_with = arg_portal
	
	if is_instance_valid(arg_portal):
		pass
		


#

func set_portal_color(arg_color):
	portal_color = arg_color
	
	if is_inside_tree():
		if portal_color == PortalColor.RED:
			portal_sprite.modulate = COLOR_RED__P_SPRITE
			portal_frame.modulate = COLOR_RED__P_FRAME
			
		elif portal_color == PortalColor.GREEN:
			portal_sprite.modulate = COLOR_GREEN__P_SPRITE
			portal_frame.modulate = COLOR_GREEN__P_FRAME
			
		elif portal_color == PortalColor.BLUE:
			portal_sprite.modulate = COLOR_BLUE__P_SPRITE
			portal_frame.modulate = COLOR_BLUE__P_FRAME
			
		elif portal_color == PortalColor.WHITE:
			portal_sprite.modulate = COLOR_WHITE__P_SPRITE
			portal_frame.modulate = COLOR_WHITE__P_FRAME
			
		


func toggle_is_disabled():
	set_is_disabled(!is_disabled)

func set_is_disabled(arg_val):
	var old_val = is_disabled
	is_disabled = arg_val
	
	if is_inside_tree():
		if old_val != is_disabled or _is_in_ready:
			if is_disabled:
				modulate = Color(0.5, 0.5, 0.5, 0.85)
				portal_sprite.visible = false
				
				#_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.clear()
				clear_node_inside_portal__to_return_on_velocity_reversed()
				clear_nodes_to_not_teleport_on_first_enter()
				
				#coll_shape_2d.set_deferred("disabled", true)
				disabled_collision_cond_clauses.attempt_insert_clause(DisableCollisionClauseId.IS_DISABLED)
				
			else:
				modulate = Color(1, 1, 1, 1)
				portal_sprite.visible = true
				
				#coll_shape_2d.set_deferred("disabled", false)
				disabled_collision_cond_clauses.remove_clause(DisableCollisionClauseId.IS_DISABLED)

#



####  EDITOR ONLY

func set_portal_to_link_with__path(arg_path):
	portal_to_link_with__path = arg_path
	
	if Engine.editor_hint:
		update()

func set_show_link_at_editor(arg_val):
	show_link_at_editor = arg_val
	
	if Engine.editor_hint:
		update()


func _draw():
	if show_link_at_editor:
		var other_portal = get_node_or_null(portal_to_link_with__path)
		if is_instance_valid(other_portal):
			draw_line(global_position, other_portal.global_position, modulate, 3)

#

func _initialize_is_scene_transition_type_portal():
	if is_scene_transition_type_portal:
		connect("player_entered__as_scene_transition", self, "_on_player_entered__for_scene_transition", [], CONNECT_ONESHOT)
		
		_ripple_sprite = Sprite.new()
		_ripple_sprite.texture = preload("res://ObjectsRelated/Portals/Assets/Portal_RippleEffectForTransition.png")
		_ripple_sprite_shader_material = ShaderMaterial.new()
		_ripple_sprite_shader_material.shader = preload("res://MiscRelated/ShadersRelated/Shader_PortalRippleEffect_Transition.tres")
		_ripple_sprite.material = _ripple_sprite_shader_material
		
		_ripple_sprite_shader_material.set_shader_param("screen_size", Vector2(960, 540))
		_ripple_sprite_shader_material.set_shader_param("thickness", 0.5)
		
		add_child(_ripple_sprite)
		
		_ripple_sprite.visible = false


func _on_player_entered__for_scene_transition(arg_player):
	arg_player.visible = false
	
	#todo ripple effect not working
	#_start_show_ripple_effect()
	

func _start_show_ripple_effect():
	_ripple_sprite.visible = true
	_ripple_sprite_shader_material.set_shader_param("size", 0)
	set_process(true)


func _process(delta):
	if !Engine.editor_hint:
		var curr_size = _ripple_sprite_shader_material.get_shader_param("size")
		var final_size = (curr_size) + delta / _ripple_duration_to_final_size
		_ripple_sprite_shader_material.set_shader_param("size", final_size)
		_ripple_sprite_shader_material.set_shader_param("global_position", global_position - CameraManager.get_camera__global_position())
		
		if final_size >= 1.0:
			_end_show_ripple_effect()


func _end_show_ripple_effect():
	_ripple_sprite.visible = false
	set_process(false)


########

func add_node_to_not_teleport_on_first_enter(arg_node : Node):
	if !_nodes_to_not_teleport_on_first_enter.has(arg_node):
		_nodes_to_not_teleport_on_first_enter.append(arg_node)
		#_rewind_save__nodes_to_not_teleport_on_first_enter = _nodes_to_not_teleport_on_first_enter.duplicate(true) 
		#print("added: %s" % [_rewind_save__nodes_to_not_teleport_on_first_enter])

func remove_node_to_not_teleport_on_first_enter(arg_node : Node):
	if _nodes_to_not_teleport_on_first_enter.has(arg_node):
		_nodes_to_not_teleport_on_first_enter.erase(arg_node)
		#_rewind_save__nodes_to_not_teleport_on_first_enter = _nodes_to_not_teleport_on_first_enter.duplicate(true)
		#print("removed: %s" % [_rewind_save__nodes_to_not_teleport_on_first_enter])

func clear_nodes_to_not_teleport_on_first_enter():
	_nodes_to_not_teleport_on_first_enter.clear()
	#_rewind_save__nodes_to_not_teleport_on_first_enter = _nodes_to_not_teleport_on_first_enter.duplicate(true)

func set_nodes_to_not_teleport_on_first_enter(arg_arr : Array):
	_nodes_to_not_teleport_on_first_enter.clear()
	_nodes_to_not_teleport_on_first_enter.append_array(arg_arr)
	
	#_rewind_save__nodes_to_not_teleport_on_first_enter = _nodes_to_not_teleport_on_first_enter.duplicate(true)


func add_node_inside_portal__to_return_on_velocity_reversed(arg_node : RigidBody2D):
	if is_instance_valid(arg_node):
		if !_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.has(arg_node):
			var dir = arg_node.linear_velocity.normalized()
			_add_node_inside_portal__to_return_on_velocity_reversed__using_dir(arg_node, dir)
			#_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed[arg_node] = dir
			
			#if !arg_node.is_connected("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker"):
			#	arg_node.connect("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker", [arg_node])



func _on_node_tree_exiting__remove_from_inside_portal_tracker(arg_node):
	remove_node_inside_portal__to_return_on_velocity_reversed(arg_node)

func remove_node_inside_portal__to_return_on_velocity_reversed(arg_node : RigidBody2D):
	if _bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.has(arg_node):
		_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.erase(arg_node)
		
		#print("removed body")
		
		if arg_node.is_connected("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker"):
			arg_node.disconnect("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker")

func clear_node_inside_portal__to_return_on_velocity_reversed():
	for body in _bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.keys():
		if body.is_connected("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker"):
			body.disconnect("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker")

func set_nodes_inside_portal__to_return_on_velocity_reversed(arg_data : Dictionary):
	for node in arg_data:
		if !_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.has(node):
			#add_node_inside_portal__to_return_on_velocity_reversed(node)
			_add_node_inside_portal__to_return_on_velocity_reversed__using_dir(node, arg_data[node])
		else:
			remove_node_inside_portal__to_return_on_velocity_reversed(node)
		


func _add_node_inside_portal__to_return_on_velocity_reversed__using_dir(arg_node, arg_dir : Vector2):
	_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed[arg_node] = arg_dir
	
	if !arg_node.is_connected("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker"):
		arg_node.connect("tree_exiting", self, "_on_node_tree_exiting__remove_from_inside_portal_tracker", [arg_node])



#

func _physics_process(delta):
	if !Engine.editor_hint and !is_scene_transition_type_portal:
		if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
			for body in _bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed:
				var curr_direction = body.linear_velocity.normalized()
				var entry_direction = _bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed[body]
				
				if entry_direction == Vector2(0, 0):
					entry_direction = curr_direction
				
				if _is_directions_significantly_different(curr_direction, entry_direction):
					_teleport_node_to_other_linked_portal(body)
		

# also used in Player class
# DO NOT COPY PASTE as values are different
func _is_directions_significantly_different(arg_dir_01 : Vector2, arg_dir_02 : Vector2):
	if (is_zero_approx(arg_dir_01.x) and is_zero_approx(arg_dir_01.y)) or (is_zero_approx(arg_dir_02.x) and is_zero_approx(arg_dir_02.y)):
		return false
		
	else:
		if abs(angle_to_angle(arg_dir_01.angle(), arg_dir_02.angle())) > PI/2:
			return true
		else:
			return false


static func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI

#######

func _on_Area2D_body_entered(body):
	if !is_disabled:
		if is_scene_transition_type_portal:
			if body.get("is_player"):
				AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Teleporter_EnteredTeleporter_TransitionLong, 1.0, null)
				emit_signal("player_entered__as_scene_transition", body)
				return
		
		
		if is_instance_valid(_portal_to_link_with):
			if !_nodes_to_not_teleport_on_first_enter.has(body):
				#print(_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter)
				
				_teleport_node_to_other_linked_portal(body)
				
			else:
				#remove_node_to_not_teleport_on_first_enter(body)
				add_node_inside_portal__to_return_on_velocity_reversed(body)
				

func _teleport_node_to_other_linked_portal(body):
	_portal_to_link_with.add_node_to_not_teleport_on_first_enter(body)
	remove_node_inside_portal__to_return_on_velocity_reversed(body)
	
	# FOR SOME REASON THIS PRINT MSG IS NEEDED???????????
	#print("body gp: %s, portal gp: %s. this msg is needed to make it work btw." % [body.global_position, _portal_to_link_with.global_position])
	# DO NOT REMOVE THESE. IT IS NEEDED TO MAKE IT WORK...
	body.global_position
	_portal_to_link_with.global_position
	# END OF DO NOT REMOVE
	
	if body.get("is_player"):
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Teleporter_EnteredTeleporter_Normal, 1.0, null)
		body.ignore_effect_based_on_pos_change__next_frame_count = 2
		#body.cancel_next_apply_ground_repelling_force__from_portal()
		#CameraManager.disable_camera_smoothing()
	
	body.global_position = _portal_to_link_with.global_position
	
	if body.get("is_player"):
		#body.cancel_next_apply_ground_repelling_force__from_portal()
		var dist = _portal_to_link_with.global_position.distance_to(global_position)
		var speed : Vector2 = body.linear_velocity
		#print(dist)
		if dist >= 1000 or speed.length() >= 500:
			#CameraManager.set_camera_glob_pos(_portal_to_link_with.global_position)
			CameraManager.make_camera_immediatelty_catch_up_to_node()
			
		#CameraManager.call_deferred("enable_camera_smoothing")
		
		emit_signal("player_entered", body)
		
	elif body.get("is_class_type_base_object"):
		emit_signal("object_entered", body)
		
	
	


func _on_Area2D_body_exited(body):
	remove_node_to_not_teleport_on_first_enter(body)
	remove_node_inside_portal__to_return_on_velocity_reversed(body)
	



###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

var rewind_variable_history : VariableHistory
var rewind_frame_index_of_last_get_save_state_by_RM

#var _rewind_save__nodes_to_not_teleport_on_first_enter
#var _rewind_save__bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed

var _rewind_most_recent_load__nodes_to_not_teleport_on_first_enter
var _rewind_most_recent_load__bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed

#

#NOTE: add vars found in get/load, plus "is_dead_but_..._rewind"
func _init_rewind_variable_history():
	rewind_variable_history = VariableHistory.new(self)
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("is_dead_but_reserved_for_rewind")
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("is_disabled")
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("_nodes_to_not_teleport_on_first_enter")
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed")
	
	
	

func is_any_state_changed() -> bool:
	rewind_variable_history.update_based_on_obj_to_track()
	var is_any_changed = rewind_variable_history.last_calc_has_last_val_changes
	rewind_variable_history.reset()
	
	return is_any_changed

#

func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		if !SingletonsAndConsts.current_rewind_manager.is_connected("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables"):
			SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
		
		visible = false
		is_dead_but_reserved_for_rewind = true
		
	else:
		.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		.queue_free()



func get_rewind_save_state():
	var save_dic = {
		"is_disabled" : is_disabled
	}
	
	save_dic["_nodes_to_not_teleport_on_first_enter"] = _nodes_to_not_teleport_on_first_enter.duplicate(true)
	save_dic["_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed"] = _bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed.duplicate(true)
	#if portal_color == PortalColor.BLUE:
	#	print("saved state: %s" % save_dic)
	
	
	#if _rewind_save__nodes_to_not_teleport_on_first_enter != null:
	#	save_dic["_rewind_save__nodes_to_not_teleport_on_first_enter"] = _rewind_save__nodes_to_not_teleport_on_first_enter.duplicate()
	#	
	#	print("saved state: %s" % save_dic)
	#	
	#	_rewind_save__nodes_to_not_teleport_on_first_enter = null
	
	return save_dic

func load_into_rewind_save_state(arg_state):
	set_is_disabled(arg_state["is_disabled"])
	
	_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter = arg_state["_nodes_to_not_teleport_on_first_enter"]
	_rewind_most_recent_load__bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed = arg_state["_bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed"]
	#if arg_state.has("_rewind_save__nodes_to_not_teleport_on_first_enter"):
	#	_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter = arg_state["_rewind_save__nodes_to_not_teleport_on_first_enter"]
	#	print("loaded from most recent load: %s" % [_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter])
	
	#if portal_color == PortalColor.BLUE:
	#	print("loaded state: %s" % arg_state)
	

func destroy_from_rewind_save_state():
	.queue_free()
	

func restore_from_destroyed_from_rewind():
	visible = true
	is_dead_but_reserved_for_rewind = false


func started_rewind():
	#print("started rewind")
	#_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter = _nodes_to_not_teleport_on_first_enter.duplicate(true)
	
	disabled_collision_cond_clauses.attempt_insert_clause(DisableCollisionClauseId.IN_REWIND)
	

func ended_rewind():
	#print("ended rewind")
	if !is_dead_but_reserved_for_rewind:
		
		#set_nodes_to_not_teleport_on_first_enter(_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter)
		#print(_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter)
		
		#_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter = null
		set_nodes_inside_portal__to_return_on_velocity_reversed(_rewind_most_recent_load__bodies_inside_portal_to_entry_direction__to_return_on_velocity_reversed)
		set_nodes_to_not_teleport_on_first_enter(_rewind_most_recent_load__nodes_to_not_teleport_on_first_enter)
		disabled_collision_cond_clauses.remove_clause(DisableCollisionClauseId.IN_REWIND)
		

