
const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")


signal ability_activated()
signal current_time_cd_changed(current_time_cd)
signal current_time_cd_reached_zero()

signal updated_is_ready_for_activation(is_ready)
signal icon_changed(icon)
signal display_name_changed(display_name)
signal descriptions_changed(descriptions)

signal started_time_cooldown(max_time_cd, current_time_cd)

signal destroying_self()

signal should_be_displaying_changed(bool_value)


# NOT Automated. Emitted by caster
signal on_ability_before_cast_start(cooldown)
signal on_ability_after_cast_end(cooldown)


enum ActivationClauses {
	
}

enum CounterDecreaseClauses {
	
}

enum ShouldBeDisplayingClauses {
	
}


const ON_ABILITY_CAST_NO_COOLDOWN : float = -1.0
const ABILITY_MINIMUM_COOLDOWN : float = 0.1


var is_timebound : bool = false
var _time_max_cooldown : float = 0
var _time_current_cooldown : float = 0 

var activation_conditional_clauses : ConditionalClauses
var counter_decrease_clauses : ConditionalClauses
var should_be_displaying_clauses : ConditionalClauses
var auto_castable_clauses : ConditionalClauses

var icon : Texture setget set_icon

#

var descriptions_source_func_name : String setget set_descriptions_source_func_name
var descriptions_source setget set_descriptions_source
var descriptions : Array = [] setget set_descriptions

#

var display_name : String setget set_display_name

var should_be_displaying : bool setget, _get_should_be_displaying


#######

func _init():
	activation_conditional_clauses = ConditionalClauses.new()
	activation_conditional_clauses.connect("clause_inserted", self, "emit_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	activation_conditional_clauses.connect("clause_removed", self, "emit_updated_is_ready_for_activation", [], CONNECT_PERSIST)
	
	#
	
	counter_decrease_clauses = ConditionalClauses.new()
	#counter_decrease_clauses.blacklisted_clauses.append(CounterDecreaseClauses.ROUND_ONGOING_STATE)
	
	#
	
	should_be_displaying_clauses = ConditionalClauses.new()
	should_be_displaying_clauses.connect("clause_inserted", self, "emit_updated_should_be_displayed", [], CONNECT_PERSIST)
	should_be_displaying_clauses.connect("clause_removed", self, "emit_updated_should_be_displayed", [], CONNECT_PERSIST)
	
	

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


func emit_updated_should_be_displayed(clause):
	emit_signal("should_be_displaying_changed", should_be_displaying_clauses.is_passed)


# setters

func set_icon(arg_icon):
	icon = arg_icon
	call_deferred("emit_signal", "icon_changed", icon)

func set_descriptions(arg_desc : Array):
	descriptions.clear()
	for des in arg_desc:
		descriptions.append(des)
		
	call_deferred("emit_signal", "descriptions_changed", arg_desc)

func set_descriptions_source_func_name(arg_func_name : String):
	descriptions_source_func_name = arg_func_name

func set_descriptions_source(arg_source):
	descriptions_source = arg_source


#

func set_display_name(arg_name : String):
	display_name = arg_name
	call_deferred("emit_signal", "display_name_changed", arg_name)


# getters

func _get_should_be_displaying() -> bool:
	return should_be_displaying_clauses.is_passed


# destroying self

func destroy_self():
	emit_signal("destroying_self")

