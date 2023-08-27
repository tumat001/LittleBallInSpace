extends "res://_NonMainGameRelateds/_Master/TransitionsRelated/AbstractTransitionSprite.gd"



const screen_size = Vector2(960, 540)

class FadeInstruction:
	var fade_duration : float
	var fade_target_modulate : Color
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
	
	scale = screen_size
	position = screen_size

func start_transition():
	.start_transition()
	
	_started_transition = true
	
	modulate.a = 0
	
	_construct_tweener_using_curr_fade_instructions()


func _construct_tweener_using_curr_fade_instructions():
	var tweener = create_tween()
	tweener.set_parallel(true)
	for ins in _fade_instructions:
		tweener.tween_property(self, "modulate:r", ins.fade_target_modulate.r, ins.fade_duration).set_delay(ins.delay)
		tweener.tween_property(self, "modulate:g", ins.fade_target_modulate.g, ins.fade_duration).set_delay(ins.delay)
		tweener.tween_property(self, "modulate:b", ins.fade_target_modulate.b, ins.fade_duration).set_delay(ins.delay)
		tweener.tween_property(self, "modulate:a", ins.fade_target_modulate.a, ins.fade_duration).set_delay(ins.delay)
	
	tweener.set_parallel(false)
	tweener.tween_callback(self, "finished_with_fade_inses")
	
	
	#SingletonsAndConsts.current_game_elements._current_player.global_position = Vector2(0, 0)
	#global_position = SingletonsAndConsts.current_game_elements._current_player.global_position
	#print(global_position)

func finished_with_fade_inses():
	_on_end_of_transition()
