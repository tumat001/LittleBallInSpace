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


#

var _all_registered_rewindables : Array

#

var rewind_duration : float = 8.0

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

#var _rewindable_node_to_save_state_map : Dictionary
var _rewindable_datas : Array

var _rewindable_objs_in_prev_load_step : Array

#

func _enter_tree():
	SingletonsAndConsts.current_rewind_manager = self

func _exit_tree():
	SingletonsAndConsts.current_rewind_manager = null

#

func _init():
	can_store_rewind_data_cond_clause = ConditionalClauses.new()
	can_store_rewind_data_cond_clause.connect("clause_inserted", self, "_on_can_store_rewind_data_cond_clause_updated", [], CONNECT_PERSIST)
	can_store_rewind_data_cond_clause.connect("clause_removed", self, "_on_can_store_rewind_data_cond_clause_updated", [], CONNECT_PERSIST)
	_update_last_calculated_can_store_rewind_data()

func _on_can_store_rewind_data_cond_clause_updated(arg_clause_id):
	_update_last_calculated_can_store_rewind_data()
	

func _update_last_calculated_can_store_rewind_data():
	last_calculated_can_store_rewind_data = can_store_rewind_data_cond_clause.is_passed

#

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
		
		
		if rewind_duration * Engine.iterations_per_second == _rewindable_datas.size():
			_rewindable_datas.pop_front()
		
		var rewindable_obj_to_save_state_map = {}
		for obj in _all_registered_rewindables:
			rewindable_obj_to_save_state_map[obj] = obj.call(REWINDABLE_METHOD_NAME__GET_SAVE_STATE)
		
		_rewindable_datas.append(rewindable_obj_to_save_state_map)
		
		
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
		
		if _rewindable_datas.size() == 0:
			_end_rewind_with_state_map(rewindable_obj_to_save_state_map)
		
		
		
	

#

func start_rewind():
	var rewindable_obj_to_save_state_map = _rewindable_datas.back()
	for obj in rewindable_obj_to_save_state_map:
		obj.call(REWINDABLE_METHOD_NAME__STARTED_REWIND)
	
	is_rewinding = true

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
	
	#_current_rewind_load_step_wait = 0
	#_current_rewind_save_step_wait = 0
	


######

func _remove_obj_from_all_registered_rewindables(arg_obj):
	_all_registered_rewindables.erase(arg_obj)
	
	emit_signal("obj_removed_from_rewindables", arg_obj)

func is_obj_registered_in_rewindables(arg_obj):
	return _all_registered_rewindables.has(arg_obj)


