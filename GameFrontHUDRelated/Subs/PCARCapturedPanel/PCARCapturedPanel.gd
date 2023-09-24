extends MarginContainer


var curr_capture_count : int setget set_curr_capture_count
var max_capture_count : int setget set_max_capture_count

var world_manager

#

onready var capture_label = $Control/CapturedLabel

#

func _ready():
	_update_display()

#

func set_curr_capture_count(arg_val):
	var old_val = curr_capture_count
	curr_capture_count = arg_val
	
	if old_val != arg_val:
		if is_inside_tree():
			_update_display()

func set_max_capture_count(arg_val):
	var old_val = max_capture_count
	max_capture_count = arg_val
	
	if old_val != arg_val:
		if is_inside_tree():
			_update_display()


func _update_display():
	if curr_capture_count >= 100 or max_capture_count >= 100:
		capture_label.text = "%s/%s" % [curr_capture_count, max_capture_count]
		
	else:
		capture_label.text = "%s / %s" % [curr_capture_count, max_capture_count]
	

#

func configure_self_to_monitor_curr_world_manager():
	world_manager = SingletonsAndConsts.current_game_elements.world_manager
	
	world_manager.connect("PCA_captured_count_changed", self, "_on_world_manager_PCA_captured_count_changed")
	set_max_capture_count(world_manager.get_total_pca_count())
	set_curr_capture_count(world_manager.get_current_captured_pca_count())

func _on_world_manager_PCA_captured_count_changed(arg_curr_count, arg_max_count):
	set_max_capture_count(arg_max_count)
	set_curr_capture_count(arg_curr_count)
	


