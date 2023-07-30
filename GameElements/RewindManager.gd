extends Node

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

#

const REWINDABLE_PROPERTY_NAME__CAN_BE_REWINDABLE = "is_rewindable"

const REWINDABLE_METHOD_NAME__GET_SAVE_STATE = "get_rewind_save_state"
const REWINDABLE_METHOD_NAME__LOAD_STATE = "load_into_rewind_save_state"
const REWINDABLE_METHOD_NAME__DESTROY_STATE = "destroy_from_rewind_save_state"

const REWINDABLE_METHOD_NAME__STARTED_REWIND = "stared_rewind"
const REWINDABLE_METHOD_NAME__ENDED_REWIND = "ended_rewind"

#

signal obj_removed_from_rewindables(arg_obj)

signal done_ending_rewind()

signal rewindable_datas_pop_back(arg_data_count_left)

#

var _all_registered_rewindables : Array

#

var rewind_duration : float = 20.0

#var _rewind_time_step : float = 0.1
#var _current_rewind_save_step_wait : float
#var _current_rewind_load_step_wait : float

var is_rewinding : bool


#
enum CanStoreRewindDataClauseIds {
	CAM_ROTATING = 0
}
var can_store_rewind_data_cond_clause : ConditionalClauses
var last_calculated_can_store_rewind_data : bool

#

const REWIND_COOLDOWN_AFTER_USE = 0.0#0.5
enum CanCastRewindClauseIds {
	IS_REWINDING = 0,
	IN_COOLDOWN = 1
}
var can_cast_rewind_cond_clause : ConditionalClauses
var last_calculated_can_cast_rewind : bool

var rewind_cooldown_timer : Timer

#

enum RewindMarkerData {
	NONE = 0,
	LAUNCH_BALL = 1,
	
}
var _rewindable_datas : Array
var _rewindable_marker_datas : Array

var _current_rewindable_duration_length : float

#

var _rewindable_marker_data_at_next_frame : int


const rewind_marker_data_to_img = {
	RewindMarkerData.LAUNCH_BALL : preload("res://GameFrontHUDRelated/Subs/RewindPanel/Assets/RewindPanel_Marker_LaunchBall.png")
}

##

var _rewindable_objs_in_prev_load_step : Array

##

func _enter_tree():
	SingletonsAndConsts.current_rewind_manager = self

func _exit_tree():
	SingletonsAndConsts.current_rewind_manager = null

##

func _init():
	can_store_rewind_data_cond_clause = ConditionalClauses.new()
	can_store_rewind_data_cond_clause.connect("clause_inserted", self, "_on_can_store_rewind_data_cond_clause_updated", [], CONNECT_PERSIST)
	can_store_rewind_data_cond_clause.connect("clause_removed", self, "_on_can_store_rewind_data_cond_clause_updated", [], CONNECT_PERSIST)
	_update_last_calculated_can_store_rewind_data()
	
	can_cast_rewind_cond_clause = ConditionalClauses.new()
	can_cast_rewind_cond_clause.connect("clause_inserted", self, "_on_can_cast_rewind_cond_clause_updated", [], CONNECT_PERSIST)
	can_cast_rewind_cond_clause.connect("clause_removed", self, "_on_can_cast_rewind_cond_clause_updated", [], CONNECT_PERSIST)
	_update_last_calculated_can_cast_rewind()
	

#

func _on_can_store_rewind_data_cond_clause_updated(arg_clause_id):
	_update_last_calculated_can_store_rewind_data()
	

func _update_last_calculated_can_store_rewind_data():
	last_calculated_can_store_rewind_data = can_store_rewind_data_cond_clause.is_passed

#

func _on_can_cast_rewind_cond_clause_updated(arg_clause_id):
	_update_last_calculated_can_cast_rewind()
	

func _update_last_calculated_can_cast_rewind():
	last_calculated_can_cast_rewind = can_cast_rewind_cond_clause.is_passed

#

func _ready():
	_initialize_rewind_cooldown_timer()

func _initialize_rewind_cooldown_timer():
	rewind_cooldown_timer = Timer.new()
	rewind_cooldown_timer.one_shot = true
	rewind_cooldown_timer.connect("timeout", self, "_on_rewind_cooldown_timer_timeout")
	add_child(rewind_cooldown_timer)
	

##

func add_to_rewindables(arg_obj):
	if arg_obj.get("is_rewindable"):
		if !arg_obj.has_method(REWINDABLE_METHOD_NAME__GET_SAVE_STATE) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__LOAD_STATE) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__DESTROY_STATE) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__STARTED_REWIND) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__ENDED_REWIND):
			print("RewindManager: ERR: obj %s does not have all required methods" % arg_obj)
			print("%s, %s, %s, %s, %s" % [!arg_obj.has_method(REWINDABLE_METHOD_NAME__GET_SAVE_STATE), !arg_obj.has_method(REWINDABLE_METHOD_NAME__LOAD_STATE), !arg_obj.has_method(REWINDABLE_METHOD_NAME__DESTROY_STATE), !arg_obj.has_method(REWINDABLE_METHOD_NAME__STARTED_REWIND), !arg_obj.has_method(REWINDABLE_METHOD_NAME__ENDED_REWIND)])
			print("--")
		
		#arg_obj.add_to_group(REWINDABLE_GROUP_NAME)
		_all_registered_rewindables.append(arg_obj)



#

# phyiscs process WITH STEP
#func _physics_process(delta):
#	if !is_rewinding:
#
#		if _current_rewind_save_step_wait <= 0:
#			_current_rewind_save_step_wait += _rewind_time_step
#
#			if rewind_duration / _rewind_time_step == _rewindable_datas.size():
#				_rewindable_datas.pop_front()
#
#			var rewindable_obj_to_save_state_map = {}
#			for obj in _all_registered_rewindables:
#				rewindable_obj_to_save_state_map[obj] = obj.call(REWINDABLE_METHOD_NAME__GET_SAVE_STATE)
#
#			_rewindable_datas.append(rewindable_obj_to_save_state_map)
#
#
#		else:
#			_current_rewind_save_step_wait -= delta
#
#
#	else:
#
#		if _current_rewind_load_step_wait <= 0:
#			_current_rewind_load_step_wait += _rewind_time_step
#
#
#			var rewindable_obj_to_save_state_map = _rewindable_datas.pop_back()
#
#			var objs_for_traversal = _rewindable_objs_in_prev_load_step.duplicate(false)
#			for obj in rewindable_obj_to_save_state_map.keys():
#				obj.call(REWINDABLE_METHOD_NAME__LOAD_STATE, rewindable_obj_to_save_state_map[obj])
#				objs_for_traversal.erase(obj)
#
#			_rewindable_objs_in_prev_load_step = rewindable_obj_to_save_state_map.keys()
#
#			for non_existing_obj in objs_for_traversal:
#				non_existing_obj.call(REWINDABLE_METHOD_NAME__DESTROY_STATE)
#				_remove_obj_from_all_registered_rewindables(non_existing_obj)
#
#			#
#
#			if _rewindable_datas.size() == 0:
#				_end_rewind_with_state_map(rewindable_obj_to_save_state_map)
#
#		else:
#			_current_rewind_load_step_wait -= delta
#
#
#
#


func _physics_process(delta):
	if !is_rewinding:
		
		if last_calculated_can_store_rewind_data:
			_current_rewindable_duration_length = _rewindable_datas.size() / float(Engine.iterations_per_second)
			if rewind_duration <= _current_rewindable_duration_length: #* Engine.iterations_per_second == _rewindable_datas.size():
				_rewindable_datas.pop_front()
				_rewindable_marker_datas.pop_front()
			
			var rewindable_obj_to_save_state_map = {}
			for obj in _all_registered_rewindables:
				rewindable_obj_to_save_state_map[obj] = obj.call(REWINDABLE_METHOD_NAME__GET_SAVE_STATE)
			
			_rewindable_datas.append(rewindable_obj_to_save_state_map)
			
			#
			
			_rewindable_marker_datas.append(_rewindable_marker_data_at_next_frame)
			_rewindable_marker_data_at_next_frame = RewindMarkerData.NONE
		
	else:
		
		var rewindable_obj_to_save_state_map = _rewindable_datas.pop_back()
		
		var objs_for_traversal = _rewindable_objs_in_prev_load_step.duplicate(false)
		for obj in rewindable_obj_to_save_state_map.keys():
			obj.call(REWINDABLE_METHOD_NAME__LOAD_STATE, rewindable_obj_to_save_state_map[obj])
			objs_for_traversal.erase(obj)
			
		_rewindable_objs_in_prev_load_step = rewindable_obj_to_save_state_map.keys()
		
		for non_existing_obj in objs_for_traversal:
			non_existing_obj.call(REWINDABLE_METHOD_NAME__DESTROY_STATE)
			_remove_obj_from_all_registered_rewindables(non_existing_obj)
		
		#
		
		_rewindable_marker_datas.pop_back()
		_current_rewindable_duration_length = _rewindable_datas.size() / float(Engine.iterations_per_second)
		
		emit_signal("rewindable_datas_pop_back", _rewindable_marker_datas.size())
		
		if _rewindable_datas.size() == 0:
			_end_rewind_with_state_map(rewindable_obj_to_save_state_map)
		
		

#

func attempt_start_rewind():
	if last_calculated_can_cast_rewind:
		var rewindable_obj_to_save_state_map = _rewindable_datas.back()
		for obj in rewindable_obj_to_save_state_map:
			obj.call(REWINDABLE_METHOD_NAME__STARTED_REWIND)
		
		can_cast_rewind_cond_clause.attempt_insert_clause(CanCastRewindClauseIds.IS_REWINDING)
		is_rewinding = true
		
		SingletonsAndConsts.current_game_front_hud.rewind_panel.start_show(_rewindable_marker_datas)


func end_rewind():
	if is_rewinding:
		_end_rewind_with_state_map(_rewindable_datas.back())



func _end_rewind_with_state_map(arg_state_map):
	var rewindable_obj_to_save_state_map = arg_state_map
	for obj in rewindable_obj_to_save_state_map:
		obj.call(REWINDABLE_METHOD_NAME__ENDED_REWIND)
	
	
	_rewindable_objs_in_prev_load_step.clear()
	
	emit_signal("done_ending_rewind")
	is_rewinding = false
	
	SingletonsAndConsts.current_game_front_hud.rewind_panel.end_show()
	#_current_rewind_load_step_wait = 0
	#_current_rewind_save_step_wait = 0
	
	if REWIND_COOLDOWN_AFTER_USE != 0:
		can_cast_rewind_cond_clause.attempt_insert_clause(CanCastRewindClauseIds.IN_COOLDOWN)
		rewind_cooldown_timer.start(REWIND_COOLDOWN_AFTER_USE)
	
	
	can_cast_rewind_cond_clause.remove_clause(CanCastRewindClauseIds.IS_REWINDING)
	


######

func _remove_obj_from_all_registered_rewindables(arg_obj):
	_all_registered_rewindables.erase(arg_obj)
	
	emit_signal("obj_removed_from_rewindables", arg_obj)

func is_obj_registered_in_rewindables(arg_obj):
	return _all_registered_rewindables.has(arg_obj)

##

func attempt_set_rewindable_marker_data_at_next_frame(arg_marker_id):
	if _rewindable_marker_data_at_next_frame == RewindMarkerData.NONE:
		_rewindable_marker_data_at_next_frame = arg_marker_id

func force_set_rewindable_marker_data_at_next_frame(arg_marker_id):
	_rewindable_marker_data_at_next_frame = arg_marker_id

func is_mark_type_not_none(arg_marker_id):
	return arg_marker_id != RewindMarkerData.NONE

func get_texture_for_mark_type(arg_marker_id):
	return rewind_marker_data_to_img[arg_marker_id]



func get_current_rewindable_duration_length():
	return _current_rewindable_duration_length
