extends "res://AreaRegionRelated/BaseAreaRegion.gd"


signal duration_for_capture_left_changed(arg_base_duration, arg_curr_val_left, delta, arg_is_from_rewind)
signal region_area_captured()
signal region_area_uncaptured()

#

const PCA_Drawer_Progress__Color_Outline = Color(186/255.0, 254/255.0, 202/255.0, 0.6)

#

export(float) var duration_for_capture : float = 0.75 setget set_duration_for_capture
var _is_instant_capture : bool

var _is_area_captured : bool = false

var _current_duration_for_capture_left : float

#

export(float) var ratio_duration_reduction_on_no_occupancy_per_sec : float = 0.5 setget set_ratio_duration_reduction_on_no_occupancy_per_sec

#

var can_line_be_drawn_to_self_by_pca_line_dir_drawer : bool = true

#

var player_PCA_progress_drawer__outline_color : Color
var player_PCA_progress_drawer__fill_color : Color

#

enum CaptureType {
	WIN = 0,
	
}
export(CaptureType) var capture_type : int = CaptureType.WIN setget set_capture_type
var is_capture_type_win : bool

#


var _is_player_inside : bool


#

var is_player_capture_area_region : bool = true


#

#note: when changed, does not update immediately, hence no setter
export(float) var mod_a_for_uncaptured : float = 1.0

#

onready var main_collision_shape_2d = $CollisionShape2D

##


func is_instant_capture() -> bool:
	return _is_instant_capture

func set_duration_for_capture(arg_val):
	duration_for_capture = arg_val
	
	if duration_for_capture == 0:
		_is_instant_capture = true
	else:
		_is_instant_capture = false
	
	_current_duration_for_capture_left = duration_for_capture

func set_capture_type(arg_val):
	capture_type = arg_val
	
	if capture_type == CaptureType.WIN:
		color_of_region_to_use = Color(30/255.0, 217/255.0, 2/255.0, 0.2)
		color_outline_of_region_to_use = Color(55/255.0, 109/255.0, 1/255.0, 0.2)
		outine_width_of_region_to_use = 3
		
		player_PCA_progress_drawer__outline_color = PCA_Drawer_Progress__Color_Outline
		player_PCA_progress_drawer__fill_color = Color(78/255.0, 253/255.0, 120/255.0, 0.6)
		
		is_capture_type_win = true


func set_ratio_duration_reduction_on_no_occupancy_per_sec(arg_val):
	ratio_duration_reduction_on_no_occupancy_per_sec = arg_val

#

func get_current_duration_for_capture_left() -> float:
	return _current_duration_for_capture_left

func get_baseline_duration_for_capture() -> float:
	return duration_for_capture

#

func set_is_area_captured__external(arg_val):
	_set_is_area_captured(arg_val)

func _set_is_area_captured(arg_val):
	var old_val = _is_area_captured
	_is_area_captured = arg_val
	
	if old_val != _is_area_captured:
		if _is_area_captured:
			emit_signal("region_area_captured")
			_on_region_area_captured__p_base()
			
		else:
			emit_signal("region_area_uncaptured")
			_on_region_area_uncaptured__p_base()
			


func _on_region_area_captured__p_base():
	if is_instance_valid(_active_draw_node):
		var tweener = create_tween()
		tweener.tween_property(_active_draw_node, "modulate:a", 0.0, 0.5)


func _on_region_area_uncaptured__p_base():
	if is_instance_valid(_active_draw_node):
		var tweener = create_tween()
		tweener.tween_property(_active_draw_node, "modulate:a", mod_a_for_uncaptured, 0.5)



func is_area_captured() -> bool:
	return _is_area_captured


#

func _ready():
	set_duration_for_capture(duration_for_capture)
	set_capture_type(capture_type)
	#set_ratio_duration_reduction_on_no_occupancy_per_sec(ratio_duration_reduction_on_no_occupancy_per_sec)
	
	set_monitor_entities_remaining_in_area(true)
	
	connect("region__body_remained_in_area", self, "_on_region__body_remained_in_area__e")
	connect("region__body_entered_in_area", self, "_on_region__body_entered_in_area__e")
	connect("region__body_exited_from_area", self, "_on_region__body_exited_from_area__e")
	

func _pre_ready():
	modulate.a = mod_a_for_uncaptured
	
	._pre_ready()
	
	

#

func _on_region__body_entered_in_area__e(body):
	if body.get("is_player"):
		if visible:
			_is_player_inside = true
			body.set_current_player_capture_area_region(self)


func _on_region__body_exited_from_area__e(body):
	if body.get("is_player"):
		_is_player_inside = false
		


##

func _process(delta):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if !_is_player_inside:
			if _current_duration_for_capture_left < duration_for_capture:
				_current_duration_for_capture_left += (ratio_duration_reduction_on_no_occupancy_per_sec * duration_for_capture) * delta
				
				if _current_duration_for_capture_left > duration_for_capture:
					_current_duration_for_capture_left = duration_for_capture
				
				_set_and_emit_current_duration_for_capture_left(_current_duration_for_capture_left, delta, false)


func _on_region__body_remained_in_area__e(body, delta, tracked_delta):
	if body.get("is_player"):
		if visible:
			
			if _current_duration_for_capture_left > 0:
				var intent_duration : float = _current_duration_for_capture_left
				if body.can_capture_PCA_regions:
					intent_duration -= delta
				
				_set_and_emit_current_duration_for_capture_left(intent_duration, delta, false)
				
				if _current_duration_for_capture_left <= 0:
					_current_duration_for_capture_left = 0
					
					_set_is_area_captured(true)



#

func _set_and_emit_current_duration_for_capture_left(arg_val, delta, arg_is_from_rewind):
	_current_duration_for_capture_left = arg_val
	
	emit_signal("duration_for_capture_left_changed", duration_for_capture, _current_duration_for_capture_left, delta, arg_is_from_rewind)


##########

func set_game_elements(arg_ele):
	.set_game_elements(arg_ele)
	


###################### 
# REWIND RELATED
#####################

func get_rewind_save_state():
	var save_state = .get_rewind_save_state()
	
	save_state["current_duration_for_capture_left"] = _current_duration_for_capture_left
	save_state["is_area_captured"] = _is_area_captured
	
	return save_state

func load_into_rewind_save_state(arg_state):
	.load_into_rewind_save_state(arg_state)
	
	_set_and_emit_current_duration_for_capture_left(arg_state["current_duration_for_capture_left"], 0, true)
	_set_is_area_captured(arg_state["is_area_captured"])


