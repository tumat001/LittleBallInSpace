extends "res://MiscRelated/EnvironmentEventPlayerRelated/BaseEnvEventPlayer/BaseEnvEventPlayer.gd"


export(float) var loop_wait_min : float = 0.0
export(float) var loop_wait_max : float = 1.0

var _current_loop_wait
var is_paused : bool = false

func _on_set_as_active__true():
	._on_set_as_active__true()
	_assign_random_loop_wait()

func _assign_random_loop_wait():
	_current_loop_wait = SingletonsAndConsts.non_essential_rng.randf_range(loop_wait_min, loop_wait_max)

func _on_set_as_active__false():
	._on_set_as_active__false()
	pass
	

#

func _process(delta):
	if _is_active and !SingletonsAndConsts.current_rewind_manager.is_rewinding and !is_paused:
		_current_loop_wait -= delta
		if _current_loop_wait < 0:
			_assign_random_loop_wait()
			_execute_environment_action__loop_wait_finished()

func _execute_environment_action__loop_wait_finished():
	pass
	
