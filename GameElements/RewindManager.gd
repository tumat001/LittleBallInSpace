extends Node

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const Shader_GlitchEffect = preload("res://MiscRelated/ShadersRelated/Shader_GlitchEffect.tres")

#

const SAVE_STATE_KEY__IS_DEAD_BUT_RESERVED = "REWINDMANAGER_is_dead_but_reserved_for_rewind"


const REWINDABLE_PROPERTY_NAME__CAN_BE_REWINDABLE = "is_rewindable" # a bool

# ALL below are needed
const REWINDABLE_PROPERTY_NAME__IS_DEAD_BUT_RESERVED = "is_dead_but_reserved_for_rewind" # a bool

const REWINDABLE_METHOD_NAME__GET_SAVE_STATE = "get_rewind_save_state"
const REWINDABLE_METHOD_NAME__LOAD_STATE = "load_into_rewind_save_state"
const REWINDABLE_METHOD_NAME__DESTROY_STATE = "destroy_from_rewind_save_state"
const REWINDABLE_METHOD_NAME__RESTORE_FROM_DESTROYED_STATE = "restore_from_destroyed_from_rewind"

const REWINDABLE_METHOD_NAME__STARTED_REWIND = "stared_rewind"
const REWINDABLE_METHOD_NAME__ENDED_REWIND = "ended_rewind"
# End of ALL

#

signal obj_removed_from_rewindables(arg_obj)

signal done_ending_rewind()

signal rewindable_datas_pop_back(arg_data_count_left)

signal rewinding_started()

#

var _all_registered_rewindables : Array

#

var rewind_duration : float = 50.0

#var _rewind_time_step : float = 0.1
#var _current_rewind_save_step_wait : float
#var _current_rewind_load_step_wait : float

var is_rewinding : bool


#
enum CanStoreRewindDataClauseIds {
	IN_CUTSCENE = 0
}
var can_store_rewind_data_cond_clause : ConditionalClauses
var last_calculated_can_store_rewind_data : bool

#

const REWIND_COOLDOWN_AFTER_USE = 0.0#0.5
enum CanCastRewindClauseIds {
	IS_REWINDING = 0,
	IN_COOLDOWN = 1
	IS_GAME_RESULT_DECIDED = 2,
	IN_CUTSCENE = 3,
	HAS_NODES_TO_BLOCK_REWIND = 4,
}
var can_cast_rewind_cond_clause : ConditionalClauses
var last_calculated_can_cast_rewind : bool

var _nodes_to_block_rewind_cast : Array


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

#

var game_elements setget set_game_elements

##

var _rewindable_objs_in_prev_load_step : Array
var _rewindable_objs_that_are_dead_but_reserved : Array

##

var _rewind_audio_player__start : AudioStreamPlayer
var _rewind_audio_player__mid_fill_loop : AudioStreamPlayer
var _rewind_audio_player__end : AudioStreamPlayer


############

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


func add_node_to_block_rewind_cast(arg_node : Node):
	if !_nodes_to_block_rewind_cast.has(arg_node):
		_nodes_to_block_rewind_cast.append(arg_node)
		
		arg_node.connect("tree_exiting", self, "_on_node_to_block_rewind_cast__tree_exiting", [arg_node])
		
		can_cast_rewind_cond_clause.attempt_insert_clause(CanCastRewindClauseIds.HAS_NODES_TO_BLOCK_REWIND)

func _on_node_to_block_rewind_cast__tree_exiting(arg_node):
	remove_node_from_block_rewind_cast(arg_node)

func remove_node_from_block_rewind_cast(arg_node):
	if _nodes_to_block_rewind_cast.has(arg_node):
		_nodes_to_block_rewind_cast.erase(arg_node)
		
		if arg_node.is_connected("tree_exiting", self, "_on_node_to_block_rewind_cast__tree_exiting"):
			arg_node.disconnect("tree_exiting", self, "_on_node_to_block_rewind_cast__tree_exiting")
		
		if _nodes_to_block_rewind_cast.size() == 0:
			can_cast_rewind_cond_clause.remove_clause(CanCastRewindClauseIds.HAS_NODES_TO_BLOCK_REWIND)


############################

func _ready():
	_initialize_rewind_cooldown_timer()

func _initialize_rewind_cooldown_timer():
	rewind_cooldown_timer = Timer.new()
	rewind_cooldown_timer.one_shot = true
	rewind_cooldown_timer.connect("timeout", self, "_on_rewind_cooldown_timer_timeout")
	add_child(rewind_cooldown_timer)
	

#

func set_game_elements(arg_ele):
	game_elements = arg_ele
	
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided")


func _on_game_result_decided(arg_state):
	can_cast_rewind_cond_clause.attempt_insert_clause(CanCastRewindClauseIds.IS_GAME_RESULT_DECIDED)



##########################

func add_to_rewindables(arg_obj):
	if arg_obj.get("is_rewindable"):
		if !_all_registered_rewindables.has(arg_obj):
			if !arg_obj.has_method(REWINDABLE_METHOD_NAME__GET_SAVE_STATE) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__LOAD_STATE) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__DESTROY_STATE) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__STARTED_REWIND) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__ENDED_REWIND) or !(REWINDABLE_PROPERTY_NAME__IS_DEAD_BUT_RESERVED in arg_obj) or !arg_obj.has_method(REWINDABLE_METHOD_NAME__RESTORE_FROM_DESTROYED_STATE):
				print("RewindManager: ERR: obj %s does not have all required methods" % arg_obj)
				print("%s, %s, %s, %s, %s, %s, %s" % [!arg_obj.has_method(REWINDABLE_METHOD_NAME__GET_SAVE_STATE), !arg_obj.has_method(REWINDABLE_METHOD_NAME__LOAD_STATE), !arg_obj.has_method(REWINDABLE_METHOD_NAME__DESTROY_STATE), !arg_obj.has_method(REWINDABLE_METHOD_NAME__STARTED_REWIND), !arg_obj.has_method(REWINDABLE_METHOD_NAME__ENDED_REWIND), REWINDABLE_PROPERTY_NAME__IS_DEAD_BUT_RESERVED in arg_obj, arg_obj.has_method(REWINDABLE_METHOD_NAME__RESTORE_FROM_DESTROYED_STATE)])
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
				var save_state = obj.call(REWINDABLE_METHOD_NAME__GET_SAVE_STATE)
				save_state[SAVE_STATE_KEY__IS_DEAD_BUT_RESERVED] = obj.get(REWINDABLE_PROPERTY_NAME__IS_DEAD_BUT_RESERVED)
				rewindable_obj_to_save_state_map[obj] = save_state
				
			
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
			
			var save_state = rewindable_obj_to_save_state_map[obj]
			var is_dead_but_reseved_from_rewind = save_state[SAVE_STATE_KEY__IS_DEAD_BUT_RESERVED]
			if is_dead_but_reseved_from_rewind:
				if !_rewindable_objs_that_are_dead_but_reserved.has(obj):
					_rewindable_objs_that_are_dead_but_reserved.append(obj)
				
			else:
				if _rewindable_objs_that_are_dead_but_reserved.has(obj):
					obj.call(REWINDABLE_METHOD_NAME__RESTORE_FROM_DESTROYED_STATE)
					
			
		_rewindable_objs_in_prev_load_step = rewindable_obj_to_save_state_map.keys()
		
		# remove permanently since the timeline of spawn has been passed (backwards)
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
		CameraManager.reset_camera_zoom_level()
		
		var rewindable_obj_to_save_state_map = _rewindable_datas.back()
		for obj in rewindable_obj_to_save_state_map:
			obj.call(REWINDABLE_METHOD_NAME__STARTED_REWIND)
		
		can_cast_rewind_cond_clause.attempt_insert_clause(CanCastRewindClauseIds.IS_REWINDING)
		is_rewinding = true
		
		SingletonsAndConsts.current_game_front_hud.rewind_panel.start_show(_rewindable_marker_datas)
		
		SingletonsAndConsts.current_game_elements.show_non_screen_gui_shader_sprite()
		
		_start_rewind_audio_play_sequence()
		
		emit_signal("rewinding_started")

func end_rewind():
	if is_rewinding:
		_end_rewind_with_state_map(_rewindable_datas.back())
		#NOTE: dont put code here unless you want player input end rewind specific codes

func _end_rewind_with_state_map(arg_state_map):
	var rewindable_obj_to_save_state_map = arg_state_map
	for obj in rewindable_obj_to_save_state_map:
		obj.call(REWINDABLE_METHOD_NAME__ENDED_REWIND)
	
	
	_rewindable_objs_in_prev_load_step.clear()
	_rewindable_objs_that_are_dead_but_reserved.clear()
	
	_end_rewind_audio_play_sequence()
	
	#emit_signal("done_ending_rewind")
	is_rewinding = false
	
	SingletonsAndConsts.current_game_front_hud.rewind_panel.end_show()
	#_current_rewind_load_step_wait = 0
	#_current_rewind_save_step_wait = 0
	
	if REWIND_COOLDOWN_AFTER_USE != 0:
		can_cast_rewind_cond_clause.attempt_insert_clause(CanCastRewindClauseIds.IN_COOLDOWN)
		rewind_cooldown_timer.start(REWIND_COOLDOWN_AFTER_USE)
	
	
	can_cast_rewind_cond_clause.remove_clause(CanCastRewindClauseIds.IS_REWINDING)
	
	SingletonsAndConsts.current_game_elements.hide_non_screen_gui_shader_sprite()
	
	
	emit_signal("done_ending_rewind")


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


###############################

func _start_rewind_audio_play_sequence():
	_rewind_audio_player__start = AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Rewind_Beginning, 1.0, null)
	_rewind_audio_player__start.connect("finished", self, "_on_rewind_audio_player__start_finished")

func _on_rewind_audio_player__start_finished():
	if _rewind_audio_player__start.is_connected("finished", self, "_on_rewind_audio_player__start_finished"):
		_rewind_audio_player__start.disconnect("finished", self, "_on_rewind_audio_player__start_finished")
	
	_rewind_audio_player__start = null
	
	_play_rewind_audio__mid_section()

func _play_rewind_audio__mid_section():
	var play_adv_param = AudioManager.construct_play_adv_params()
	play_adv_param.is_audio_looping = true
	_rewind_audio_player__mid_fill_loop = AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Rewind_Middle, 1.0, play_adv_param)
	



func _end_rewind_audio_play_sequence():
	if _rewind_audio_player__start != null:
		if _rewind_audio_player__start.is_connected("finished", self, "_on_rewind_audio_player__start_finished"):
			_rewind_audio_player__start.disconnect("finished", self, "_on_rewind_audio_player__start_finished")
		
		AudioManager.stop_stream_player_and_mark_as_inactive(_rewind_audio_player__start)
		_rewind_audio_player__start = null
	
	if _rewind_audio_player__mid_fill_loop != null:
		AudioManager.stop_stream_player_and_mark_as_inactive(_rewind_audio_player__mid_fill_loop)
		_rewind_audio_player__mid_fill_loop = null
	
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Rewind_Ending, 1.0, null)

