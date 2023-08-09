extends Reference


enum TransitionSpriteIds {
	
	NONE = 0,
	
	OUT__STANDARD_CIRCLE__BLACK = 1,
	IN__STANDARD_CIRCLE__BLACK = 2,
	
	OUT__STANDARD_CIRCLE__WHITE = 3,
	IN__STANDARD_CIRCLE__WHITE = 4,
	
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


