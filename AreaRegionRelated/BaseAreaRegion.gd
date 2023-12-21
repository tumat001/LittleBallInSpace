extends Area2D


const CircleDrawNode = preload("res://MiscRelated/DrawRelated/CircleDrawNode/CircleDrawNode.gd")
const RectDrawNode = preload("res://MiscRelated/DrawRelated/RectDrawNode/RectDrawNode.gd")

const VariableHistory = preload("res://MiscRelated/RewindHelperRelated/VariableHistory.gd")

#

signal region__body_entered_in_area(body)
signal region__body_exited_from_area(body)
signal region__body_remained_in_area(body, delta, tracked_delta)

signal game_elements_setted()

#


var _circle_draw_node
var _rect_draw_node

var _active_draw_node  # either the circle or rect


var _entities_in_area_to_delta_map : Dictionary

#

export(Color) var color_of_region_to_use : Color = Color(0, 0, 0, 0)
export(Color) var color_outline_of_region_to_use : Color = Color(0, 0, 0, 0)
export(int) var outine_width_of_region_to_use : int = 0

var monitor_entities_remaining_in_area : bool = false setget set_monitor_entities_remaining_in_area

#

var game_elements

#

var _rect_used_for_region : Rect2

var sprite_for_shader : Sprite

#

onready var collision_shape = $CollisionShape2D

#

func _init():
	_init_rewind_variable_history()


func set_monitor_entities_remaining_in_area(arg_val):
	monitor_entities_remaining_in_area = arg_val
	
	set_process(monitor_entities_remaining_in_area)

#

func set_game_elements(arg_ele):
	game_elements = arg_ele
	
	emit_signal("game_elements_setted")

#

func _ready():
	_pre_ready()
	
	#
	
	set_monitor_entities_remaining_in_area(monitor_entities_remaining_in_area)
	
	call_deferred("_create_draw_visuals_based_on_coll_shape")
	
	SingletonsAndConsts.current_rewind_manager.connect("rewinding_started", self, "_on_rewinding_started")
	
	# if is_rewindable
	SingletonsAndConsts.current_rewind_manager.add_to_rewindables(self)
	

#

func _pre_ready():
	pass

#

func _create_draw_visuals_based_on_coll_shape():
	var shape = collision_shape.shape
	if shape != null:
		if shape is CircleShape2D:
			_create_draw_visuals__circle(shape.radius)
			
		elif shape is RectangleShape2D:
			_create_draw_visuals__rect(shape.extents)
			


##

func _create_draw_visuals__circle(arg_radius):
	if !is_instance_valid(_circle_draw_node):
		_circle_draw_node = Node2D.new()
		_circle_draw_node.set_script(CircleDrawNode)
		
		add_child(_circle_draw_node)
		
		_active_draw_node = _circle_draw_node
	
	########
	var draw_param = CircleDrawNode.DrawParams.new()
	
	draw_param.center_pos = global_position
	draw_param.current_radius = arg_radius
	draw_param.max_radius = arg_radius
	draw_param.radius_per_sec = 0
	draw_param.fill_color = color_of_region_to_use
	
	draw_param.outline_color = color_outline_of_region_to_use
	draw_param.outline_width = outine_width_of_region_to_use
	
	draw_param.lifetime_of_draw = 1
	draw_param.has_lifetime = false
	
	_circle_draw_node.add_draw_param(draw_param)
	
	


func _create_draw_visuals__rect(arg_extents : Vector2):
	if !is_instance_valid(_rect_draw_node):
		_rect_draw_node = Node2D.new()
		_rect_draw_node.set_script(RectDrawNode)
		
		#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(_rect_draw_node)
		collision_shape.add_child(_rect_draw_node)
		
		_active_draw_node = _rect_draw_node
	
	#######
	
	var rel_pos = -arg_extents
	var rect_to_use = Rect2(rel_pos.x, rel_pos.y, arg_extents.x * 2, arg_extents.y * 2)
	
	#
	
	var draw_param = RectDrawNode.DrawParams.new()
	
	draw_param = RectDrawNode.DrawParams.new()
	draw_param.fill_color = color_of_region_to_use
	
	draw_param.outline_color = color_outline_of_region_to_use
	draw_param.outline_width = outine_width_of_region_to_use
	
	draw_param.lifetime_to_start_transparency = -1
	draw_param.angle_rad = rotation
	draw_param.lifetime_of_draw = 10
	draw_param.has_lifetime = false
	draw_param.pivot_point = Vector2(0, 0)
	draw_param.initial_rect = rect_to_use
	draw_param.target_rect = draw_param.initial_rect
	
	_rect_draw_node.add_draw_param(draw_param)
	
	##
	
	_rect_used_for_region = rect_to_use



func _on_rewinding_started():
	for entity in _entities_in_area_to_delta_map.keys():
		emit_signal("region__body_exited_from_area", entity)
	
	_entities_in_area_to_delta_map.clear()

func _on_BaseAreaRegion_body_exited(body):
	_entities_in_area_to_delta_map.erase(body)
	
	emit_signal("region__body_exited_from_area", body)


func _on_BaseAreaRegion_body_entered(body):
	_entities_in_area_to_delta_map[body] = 0
	
	emit_signal("region__body_entered_in_area", body)


func _process(delta):
	for entity in _entities_in_area_to_delta_map.keys():
		var tracked_delta = _entities_in_area_to_delta_map[entity]
		_entities_in_area_to_delta_map[entity] = tracked_delta + delta
		
		emit_signal("region__body_remained_in_area", entity, delta, tracked_delta)
	

#

func construct_and_add_sprite_for_shader(arg_material : ShaderMaterial):
	sprite_for_shader = Sprite.new()
	sprite_for_shader.texture = preload("res://MiscRelated/ShadersRelated/Assets/ShaderImgTemplate_Trans1x1.png")
	sprite_for_shader.centered = true
	sprite_for_shader.scale = _rect_used_for_region.size
	sprite_for_shader.position = _rect_used_for_region.size / 2
	sprite_for_shader.material = arg_material
	
	collision_shape.add_child(sprite_for_shader)
	
	return sprite_for_shader

func add_shader_to_collshape(arg_material : ShaderMaterial):
	if is_instance_valid(_rect_draw_node):
		_rect_draw_node.material = arg_material
		
		return sprite_for_shader

###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

var rewind_variable_history : VariableHistory
var rewind_frame_index_of_last_get_save_state_by_RM

#

#NOTE: add vars found in get/load, plus "is_dead_but_..._rewind"
func _init_rewind_variable_history():
	rewind_variable_history = VariableHistory.new(self)
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("is_dead_but_reserved_for_rewind")
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("_entities_in_area_to_delta_map")
	rewind_variable_history.add_var_name__for_tracker__based_on_obj("transform")


func is_any_state_changed() -> bool:
	rewind_variable_history.update_based_on_obj_to_track()
	var is_any_changed = rewind_variable_history.last_calc_has_last_val_changes
	rewind_variable_history.reset()
	
	return is_any_changed



func queue_free():
	if SingletonsAndConsts.current_rewind_manager.is_obj_registered_in_rewindables(self):
		if !SingletonsAndConsts.current_rewind_manager.is_connected("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables"):
			SingletonsAndConsts.current_rewind_manager.connect("obj_removed_from_rewindables", self, "_on_obj_removed_from_rewindables")
		
		collision_shape.set_deferred("disabled", true)
		visible = false
		is_dead_but_reserved_for_rewind = true
		
	else:
		.queue_free()
		

func _on_obj_removed_from_rewindables(arg_obj):
	if arg_obj == self:
		.queue_free()


func get_rewind_save_state():
	return {
		"entities_in_area_to_delta_map" : _entities_in_area_to_delta_map.duplicate(),
		"transform" : transform,
	}
	

func load_into_rewind_save_state(arg_state):
	_entities_in_area_to_delta_map = arg_state["entities_in_area_to_delta_map"]
	transform = arg_state["transform"]
	


func destroy_from_rewind_save_state():
	.queue_free()
	

func restore_from_destroyed_from_rewind():
	#collision_shape.set_deferred("disabled", false)
	visible = true
	is_dead_but_reserved_for_rewind = false

func started_rewind():
	collision_shape.set_deferred("disabled", true)
	

func ended_rewind():
	if !is_dead_but_reserved_for_rewind:
		collision_shape.set_deferred("disabled", false)
	


