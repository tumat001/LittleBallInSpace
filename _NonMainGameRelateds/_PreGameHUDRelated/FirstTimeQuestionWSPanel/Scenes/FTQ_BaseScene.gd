extends Control

signal sequence_finished()


var _current_custom_steppable_control

#######

func start_display():
	pass
	


func emit_sequence_finished():
	emit_signal("sequence_finished")
	

#

func custom_step_current_control_tweener(arg_step : float):
	if is_instance_valid(_current_custom_steppable_control):
		_current_custom_steppable_control.custom_step_display_tweener(arg_step)
		


