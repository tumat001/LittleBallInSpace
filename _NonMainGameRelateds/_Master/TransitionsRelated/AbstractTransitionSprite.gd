extends Sprite

signal transition_finished()


var queue_free_on_end_of_transition : bool = false


var is_custom_controlled__avoid_auto_tweens : bool = false


#

func _ready():
	pass


func start_transition():
	pass
	

func _on_end_of_transition():
	emit_signal("transition_finished")
	
	if queue_free_on_end_of_transition:
		queue_free()


func set_is_transition_paused(arg_val):
	pass

#
