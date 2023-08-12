extends MarginContainer


var curr_level_completed_count : int setget set_curr_level_completed_count
var max_level_completed_count : int setget set_max_level_completed_count

onready var level_count_label = $Control/LevelCountsLabel


func _ready():
	_update_label_display()


func set_curr_level_completed_count(arg_val):
	curr_level_completed_count = arg_val
	
	if is_inside_tree():
		_update_label_display()

func set_max_level_completed_count(arg_val):
	max_level_completed_count = arg_val
	
	if is_inside_tree():
		_update_label_display()


func _update_label_display():
	if curr_level_completed_count >= 100 or max_level_completed_count >= 100:
		level_count_label.text = "%s/%s" % [curr_level_completed_count, max_level_completed_count]
		
	else:
		level_count_label.text = "%s / %s" % [curr_level_completed_count, max_level_completed_count]
		
	

#######

func configure_self_to_monitor_level_count_status():
	_update_counter()
	
	GameSaveManager.connect("level_id_completion_status_changed", self, "_on_level_id_completion_status_changed")
	StoreOfLevels.connect("hidden_levels_state_changed", self, "_on_hidden_levels_state_changed")

func _update_counter():
	var curr_level_count = GameSaveManager.get_total_levels_finished()
	var max_level_count = StoreOfLevels.get_all_non_hidden_level_ids().size()
	
	set_curr_level_completed_count(curr_level_count)
	set_max_level_completed_count(max_level_count)
	

func _on_level_id_completion_status_changed(arg_id, arg_status):
	_update_counter()

func _on_hidden_levels_state_changed():
	_update_counter()

