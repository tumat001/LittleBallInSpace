
const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")


signal ability_activated()

signal current_time_cd_changed(current_time_cd)
signal current_time_cd_reached_zero()

signal updated_is_ready_for_activation(is_ready)

signal started_time_cooldown(max_time_cd, current_time_cd)


#

enum ActivationClauses {
	
}

enum CounterDecreaseClauses {
	
}


const ON_ABILITY_CAST_NO_COOLDOWN : float = -1.0
const ABILITY_MINIMUM_COOLDOWN : float = 0.1


var is_timebound : bool = false
var _time_max_cooldown : float = 0
var _time_current_cooldown : float = 0 

var activation_conditional_clauses : ConditionalClauses
var counter_decrease_clauses : ConditionalClauses


#######

func _init():
	activation_conditional_clauses = ConditionalClauses.new()
	activation_conditional_clauses.connect("clause_inserted", self, "emit_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	activation_conditional_clauses.connect("clause_removed", self, "emit_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	
	#
	
	counter_decrease_clauses = ConditionalClauses.new()
	#counter_decrease_clauses.blacklisted_clauses.append(CounterDecreaseClauses.ROUND_ONGOING_STATE)
	
	

# Activation related

func activate_ability(forced : bool = false):
	if is_ready_for_activation() or forced:
		emit_signal("ability_activated")


func is_ready_for_activation() -> bool:
	if is_time_ready():
		return activation_conditional_clauses.is_passed
	else:
		return false


func is_time_ready() -> bool:
	return (is_timebound and _time_current_cooldown <= 0) or (!is_timebound)


# Setting of cooldown

func start_time_cooldown(arg_cooldown : float, ignore_self_cd : bool = false):
	if is_timebound:
		var cooldown = 0
		if !ignore_self_cd:
			cooldown = _get_cd_to_use(arg_cooldown)
		else:
			cooldown = arg_cooldown
		
		_time_max_cooldown = cooldown
		_time_current_cooldown = cooldown
		
		emit_signal("started_time_cooldown", _time_max_cooldown, _time_current_cooldown)
		emit_signal("current_time_cd_changed", _time_current_cooldown)
		emit_updated_is_ready_for_activation(0)


func _get_cd_to_use(cd_of_source : float) -> float:
	if cd_of_source == ON_ABILITY_CAST_NO_COOLDOWN:
		return ON_ABILITY_CAST_NO_COOLDOWN
	
	var final_cd : float = cd_of_source
	
	if final_cd < ABILITY_MINIMUM_COOLDOWN:
		final_cd = ABILITY_MINIMUM_COOLDOWN
	
	return final_cd


# time related

func time_decreased(delta : float):
	if is_timebound and _time_current_cooldown > 0:
		if counter_decrease_clauses.is_passed:
			
			_time_current_cooldown -= delta
			emit_signal("current_time_cd_changed", _time_current_cooldown)
			
			if _time_current_cooldown <= 0:
				emit_signal("current_time_cd_reached_zero")
				emit_updated_is_ready_for_activation(0)


func remove_all_time_cooldown():
	if is_timebound and _time_current_cooldown > 0:
		_time_current_cooldown = 0
		emit_signal("current_time_cd_changed", _time_current_cooldown)
		
		if _time_current_cooldown <= 0:
			emit_signal("current_time_cd_reached_zero")
			emit_updated_is_ready_for_activation(0)



# signals related

func emit_updated_is_ready_for_activation(clause):
	emit_signal("updated_is_ready_for_activation", is_ready_for_activation())



###################### 
# REWIND RELATED
#####################

export(bool) var is_rewindable : bool = true
var is_dead_but_reserved_for_rewind : bool

var _rewind_state

func get_rewind_save_state():
	return {
		"is_timebound" : is_timebound,
		"time_max_cooldown" : _time_max_cooldown,
		"time_current_cooldown" : _time_current_cooldown,
		
		"activation_conditional_clauses_save_state" : activation_conditional_clauses.get_rewind_save_state(),
		"counter_decrease_clauses_save_state" : counter_decrease_clauses.get_rewind_save_state()
		
	}
	

func load_into_rewind_save_state(arg_state):
	_rewind_state = arg_state
	
	_time_max_cooldown = arg_state["time_max_cooldown"]
	_time_current_cooldown = arg_state["time_current_cooldown"]
	

func destroy_from_rewind_save_state():
	pass
	

func restore_from_destroyed_from_rewind():
	pass
	


func started_rewind():
	pass

func ended_rewind():
	activation_conditional_clauses.load_into_rewind_save_state(_rewind_state["activation_conditional_clauses_save_state"])
	counter_decrease_clauses.load_into_rewind_save_state(_rewind_state["counter_decrease_clauses_save_state"])
	
	emit_updated_is_ready_for_activation(0)


