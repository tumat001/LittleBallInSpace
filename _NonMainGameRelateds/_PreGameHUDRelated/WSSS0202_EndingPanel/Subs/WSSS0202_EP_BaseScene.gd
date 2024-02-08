extends Control


signal sequence_finished()



func start_display():
	pass
	


func emit_sequence_finished():
	emit_signal("sequence_finished")
	
