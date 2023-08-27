extends Reference

const Transition_StandardFade = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/Subs/StandardFade/Transition_StandardFade.gd")

#

enum TransitionSpriteIds {
	
	NONE = 0,
	
	OUT__STANDARD_CIRCLE__BLACK = 1,
	IN__STANDARD_CIRCLE__BLACK = 2,
	
	OUT__STANDARD_CIRCLE__WHITE = 3,
	IN__STANDARD_CIRCLE__WHITE = 4,
	
	#
	
	OUT__STANDARD_FADE__BLACK__LONG = 10,
	#IN__STANDARD_FADE__BLACK = 11,
	
}


static func construct_transition_sprite(arg_id):
	var transition
	if arg_id == TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK:
		transition = _construct_transition__standard_circle()
		_configure_transition__standard_circle__to_out(transition)
		_configure_transition__any__to_black(transition)
		
	elif arg_id == TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK:
		transition = _construct_transition__standard_circle()
		_configure_transition__standard_circle__to_in(transition)
		_configure_transition__any__to_black(transition)
		
	elif arg_id == TransitionSpriteIds.OUT__STANDARD_CIRCLE__WHITE:
		transition = _construct_transition__standard_circle()
		_configure_transition__standard_circle__to_out(transition)
		_configure_transition__any__to_white(transition)
		
	elif arg_id == TransitionSpriteIds.IN__STANDARD_CIRCLE__WHITE:
		transition = _construct_transition__standard_circle()
		_configure_transition__standard_circle__to_in(transition)
		_configure_transition__any__to_white(transition)
		
	elif arg_id == TransitionSpriteIds.OUT__STANDARD_FADE__BLACK__LONG:
		transition = _construct_transition__standard_fade()
		_configure_transition__standard_fade__to_out(transition, 3.0)
		
		#transition = _construct_transition__standard_circle()
		#_configure_transition_circle__to_fade__out(transition, Color(0, 0, 0, 0), Color(0, 0, 0, 1))
	
	return transition


static func _construct_transition__standard_circle():
	var transition = load("res://_NonMainGameRelateds/_Master/TransitionsRelated/Subs/StandardCircle/Transition_StandardCircle.tscn").instance()
	
	transition.duration = 0.35
	
	return transition

static func _configure_transition__standard_circle__to_out(arg_transition):
	arg_transition.initial_ratio = 1
	arg_transition.target_ratio = 0

static func _configure_transition__standard_circle__to_in(arg_transition):
	arg_transition.initial_ratio = 0
	arg_transition.target_ratio = 1


static func _configure_transition__any__to_black(arg_transition):
	arg_transition.modulate = Color(0, 0, 0, 1)

static func _configure_transition__any__to_white(arg_transition):
	arg_transition.modulate = Color(1, 1, 1, 1)




static func _construct_transition__standard_fade():
	var transition = load("res://_NonMainGameRelateds/_Master/TransitionsRelated/Subs/StandardFade/Transition_StandardFade.tscn").instance()
	
	return transition

static func _configure_transition__standard_fade__to_out(arg_transition : Transition_StandardFade, arg_duration):
	arg_transition.modulate = Color(0, 0, 0, 0)
	
	var fade_ins = Transition_StandardFade.FadeInstruction.new()
	fade_ins.fade_duration = arg_duration
	fade_ins.fade_target_modulate = Color(0, 0, 0, 1)
	fade_ins.delay = 0
	arg_transition.add_fade_instruction(fade_ins)
	


#static func _configure_transition_circle__to_fade__out(arg_transition, arg_initial_color, arg_final_color):
#	arg_transition.initial_ratio = 1
#	arg_transition.target_ratio = 1
#
#	arg_transition.modulate = arg_initial_color
#	arg_transition.modulate_at_end = arg_final_color
#
#	arg_transition.


