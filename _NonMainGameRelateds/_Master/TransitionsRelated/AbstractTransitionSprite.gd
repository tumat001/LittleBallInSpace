extends Sprite

signal transition_finished()



func start_transition():
	pass
	

func _on_end_of_transition():
	emit_signal("transition_finished")


