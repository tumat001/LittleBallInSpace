extends "res://_NonMainGameRelateds/_Master/TransitionsRelated/AbstractTransitionSprite.gd"



var screen_size = Vector2(960, 540)

class FadeInstruction:
	var fade_duration : float
	var fade_target_modulate : float
	var delay : float

var _fade_instructions : Array


var _started_transition : bool = false

##

func add_fade_instruction(arg_fade_instrction : FadeInstruction):
	if !_started_transition:
		_fade_instructions.append(arg_fade_instrction)
	else:
		print("Transition_StandardFade. attempted added fade instruction but already started transitioning")

#

func _ready():
	modulate.a = 0

func start_transition():
	.start_transition()
	
	modulate.a = 0
	
	_construct_tweener_using_curr_fade_instructions()


func _construct_tweener_using_curr_fade_instructions():
	var tweener = create_tween()
	tweener.set_parallel(false)
	for ins in _fade_instructions:
		tweener.tween_property(self, "modulate", ins.fade_target_modulate, ins.fade_duration).set_delay(ins.delay)
	
	tweener.tween_callback("finished_with_fade_inses")

func finished_with_fade_inses():
	_on_end_of_transition()




