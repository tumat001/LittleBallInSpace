extends MarginContainer


const DEFAULT_DURATION_OF_TWEENERS : float = 1.25

const MOD_A__RAINBOW_RECT__COMPLETE : float = 0.39
const MOD_A__RAINBOW_RECT__NOT_COMPLETE : float = 0.0

#

var instant_change_tweener_transition : bool = false

var curr_level_completed_count : int setget set_curr_level_completed_count
var max_level_completed_count : int setget set_max_level_completed_count


var _rainbow_rect_mod_a_tweener : SceneTreeTween

onready var level_count_label = $Control/LevelCountsLabel

onready var rainbow_color_rect = $Control/RainbowColorRect

#

func _ready():
	rainbow_color_rect.modulate.a = 0
	
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
	
	if curr_level_completed_count == max_level_completed_count:
		_tween_rainbow_color_rect_mod_a(MOD_A__RAINBOW_RECT__COMPLETE)
	else:
		_tween_rainbow_color_rect_mod_a(MOD_A__RAINBOW_RECT__NOT_COMPLETE)
	



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

##

func _tween_rainbow_color_rect_mod_a(arg_new_val : float, arg_always_instant : bool = false):
	_kill_existing_rainbow_color_rect_mod_a_tweener()
	
	var duration = DEFAULT_DURATION_OF_TWEENERS
	if instant_change_tweener_transition or arg_always_instant:
		duration = 0
	_rainbow_rect_mod_a_tweener = create_tween()
	_rainbow_rect_mod_a_tweener.tween_property(rainbow_color_rect, "modulate:a", arg_new_val, duration)

func _kill_existing_rainbow_color_rect_mod_a_tweener():
	if _rainbow_rect_mod_a_tweener != null and _rainbow_rect_mod_a_tweener.is_valid():
		_rainbow_rect_mod_a_tweener.kill()


