extends "res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd"


signal current_energy_changed(arg_val)
signal max_energy_changed(arg_val)

# for use of energy HUD
signal forecasted_or_current_energy_changed(arg_curr_energy, arg_forcasted_energy)

#


func _init().(StoreOfPlayerModi.PlayerModiIds.ENERGY):
	pass

#

var _max_energy : float
var _current_energy : float

var _source_id_to_energy_amount_contributed : Dictionary


enum ForecastConsumeId {
	LAUNCH_BALL = 0
}

var _forecast_energy_consume_id_to_amount_map : Dictionary
var _forcasted_energy : float

#

func inc_current_energy(arg_amount, arg_source_id = -1):
	set_current_energy(_current_energy + arg_amount, arg_source_id)
	

func dec_current_energy(arg_amount, arg_source_id = -1):
	set_current_energy(_current_energy - arg_amount, arg_source_id)
	

func set_current_energy(arg_val, arg_source_id = -1):
	var old_val = _current_energy
	_current_energy = arg_val
	
	if _current_energy < 0:
		_current_energy = 0
	if _current_energy > _max_energy:
		_current_energy = _max_energy
	
	var diff = _current_energy - old_val
	
	if arg_source_id != -1:
		_source_id_to_energy_amount_contributed[arg_source_id] += diff
	
	_update_and_calculate_forcasted_energy_consumption()
	emit_signal("current_energy_changed", arg_val)

func get_current_energy():
	return _current_energy


#

func clear_source_id_energy_modified(arg_id):
	_source_id_to_energy_amount_contributed.erase(arg_id)



#

func set_forcasted_energy_consume(arg_id, arg_amount):
	_forecast_energy_consume_id_to_amount_map[arg_id] = arg_amount
	_update_and_calculate_forcasted_energy_consumption()

func remove_forcasted_energy_consume(arg_id):
	_forecast_energy_consume_id_to_amount_map.erase(arg_id)
	_update_and_calculate_forcasted_energy_consumption()


func _update_and_calculate_forcasted_energy_consumption():
	_forcasted_energy = _current_energy
	for amount in _forecast_energy_consume_id_to_amount_map.values():
		_forcasted_energy -= amount
	
	if _forcasted_energy < 0:
		_forcasted_energy = 0
	
	emit_signal("forecasted_or_current_energy_changed", _forcasted_energy, _current_energy)



func get_forcasted_energy() -> float:
	return _forcasted_energy

#


func set_max_energy(arg_val):
	_max_energy = arg_val
	
	emit_signal("max_energy_changed", arg_val)

func get_max_energy():
	return _max_energy
	


