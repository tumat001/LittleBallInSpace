extends "res://_NonMainGameRelateds/_Master/TransitionsRelated/AbstractTransitionSprite.gd"


onready var background = $Background
onready var load_splash = $Load

#

func start_transition():
	.start_transition()
	
	var tween = create_tween()
	tween.tween_property(load_splash, "modulate:a", 0.0, 0.5)
	tween.tween_property(background, "modulate:a", 0.0, 0.5)
	tween.tween_callback(self, "_on_tweener_finished_with_fade_inses")


func _on_tweener_finished_with_fade_inses():
	_on_end_of_transition()

func _on_end_of_transition():
	._on_end_of_transition()
	


