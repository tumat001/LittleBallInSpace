extends Sprite

signal transition_finished()


var queue_free_on_end_of_transition : bool = false

#

func _ready():
	pass


func start_transition():
	pass
	

func _on_end_of_transition():
	emit_signal("transition_finished")
	
	if queue_free_on_end_of_transition:
		queue_free()

###



