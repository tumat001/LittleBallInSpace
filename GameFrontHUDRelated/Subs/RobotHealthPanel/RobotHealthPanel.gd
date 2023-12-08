extends MarginContainer


const HEALTH_BAR_MODULATE__FULL = Color(98/255.0, 78/255.0, 253/255.0)
const HEALTH_BAR_MODULATE__EMPTY = Color(78/255.0, 253/255.0, 252/255.0)

const DISPLAY_SELF_DURATION_ON_HEALTH_CHANGE = 6.25

#

onready var robot_health_tex_progress = $Control/RobotHealthTextureProgress
onready var robot_health_icon = $Control/RobotHealthIcon


var _player

var display_timer

##

func set_player(arg_player):
	_player = arg_player
	
	arg_player.connect("current_robot_health_changed", self, "_on_current_robot_health_changed")
	arg_player.connect("max_robot_health_changed", self, "_on_max_robot_health_changed")
	
	_update_max_health_and_curr_health_disp(false)

##

func _on_current_robot_health_changed(arg_val):
	_update_curr_health_disp(true)
	

func _update_curr_health_disp(arg_update_panel_vis : bool):
	var curr_health = _player.get_current_robot_health()
	var max_health = _player.get_max_robot_health()
	
	robot_health_tex_progress.value = curr_health
	
	###
	
	var ratio = curr_health / max_health
	var weight = _get_weight_of_number_between_range(ratio, 0, 1)
	var final_color = _get_color_based_on_weight(weight, HEALTH_BAR_MODULATE__EMPTY, HEALTH_BAR_MODULATE__FULL)
	
	robot_health_tex_progress.modulate = final_color
	
	####
	
	if arg_update_panel_vis:
		if visible:
			display_timer.start(DISPLAY_SELF_DURATION_ON_HEALTH_CHANGE)
			
		else:
			modulate.a = 0
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1.0, 0.15)
			visible = true
			
			display_timer.start(DISPLAY_SELF_DURATION_ON_HEALTH_CHANGE)

func _get_weight_of_number_between_range(arg_num, arg_r_a, arg_r_b):
	var diff = arg_r_a - arg_r_b
	
	return (diff - (arg_num - arg_r_b)) / float(diff)

func _get_color_based_on_weight(weight_to_b, color_a, color_b):
	var finalized_color_a = color_a * (1 - weight_to_b)
	var finalized_color_b = color_b * (weight_to_b)
	return (finalized_color_a + finalized_color_b)
	



func _on_max_robot_health_changed(arg_val):
	_update_max_health_and_curr_health_disp(true)
	

func _update_max_health_and_curr_health_disp(arg_update_panel_vis : bool):
	robot_health_tex_progress.max_value = _player.get_max_robot_health()
	
	_update_curr_health_disp(arg_update_panel_vis)


#########

func _ready():
	visible = false
	_initialize_display_timer()

func _initialize_display_timer():
	display_timer = Timer.new()
	display_timer.one_shot = true
	display_timer.connect("timeout", self, "_on_display_self_timer_timeout")
	
	add_child(display_timer)


func _on_display_self_timer_timeout():
	var tweener = create_tween()
	tweener.tween_property(self, "modulate:a", 0.0, 0.5)
	tweener.tween_callback(self, "_display_timer_mod_a_reached_zero")
	

func _display_timer_mod_a_reached_zero():
	visible = false
	


