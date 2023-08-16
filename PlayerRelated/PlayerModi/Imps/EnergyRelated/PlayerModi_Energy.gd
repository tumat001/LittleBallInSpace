extends "res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd"



signal discarged_to_zero_energy()
signal recharged_from_no_energy()

signal current_energy_changed(arg_val)
signal max_energy_changed(arg_val)

# for use of energy HUD
signal forecasted_or_current_energy_changed(arg_curr_energy, arg_forecasted_energy)

#


func _init().(StoreOfPlayerModi.PlayerModiIds.ENERGY):
	pass

#

const ENERGY_RATIO_FOR_WARNING_TRIGGER = 0.25

#

var _player

var _energy_down__sound_player : AudioStreamPlayer2D
var _energy_restored__sound_player : AudioStreamPlayer2D

#

var _max_energy : float
var _current_energy : float

var _source_id_to_energy_amount_contributed : Dictionary


enum ForecastConsumeId {
	LAUNCH_BALL = 0,
	INSTANT_GROUND = 1,
}

var _forecast_energy_consume_id_to_amount_map : Dictionary
var _forecasted_energy : float

#

var _has_no_energy : bool

#

func apply_modification_to_player_and_game_elements(arg_player, arg_game_elements):
	.apply_modification_to_player_and_game_elements(arg_player, arg_game_elements)
	
	_player = arg_player

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
	
	#
	
	var old_has_no_energy_val = _has_no_energy
	_has_no_energy = _current_energy == 0
	if old_has_no_energy_val != _has_no_energy:
		if _has_no_energy:
			
			if !SingletonsAndConsts.current_rewind_manager.is_rewinding and is_instance_valid(_player):
				_energy_down__sound_player = AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_EnergyModi_PowerDown_01, _player.global_position, 1.38, null)
				if _energy_restored__sound_player != null and _energy_restored__sound_player.playing:
					AudioManager.stop_stream_player_and_mark_as_inactive(_energy_restored__sound_player)
			
			emit_signal("discarged_to_zero_energy")
			
		else:
			
			if !SingletonsAndConsts.current_rewind_manager.is_rewinding and is_instance_valid(_player):
				_energy_restored__sound_player = AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_EnergyModi_PowerUp_01, _player.global_position, 1.0, null)
				if _energy_down__sound_player != null and _energy_down__sound_player.playing:
					AudioManager.stop_stream_player_and_mark_as_inactive(_energy_down__sound_player)
			
			emit_signal("recharged_from_no_energy")
			
	
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if old_val > _current_energy:
			if (old_val / _max_energy) > ENERGY_RATIO_FOR_WARNING_TRIGGER and (_current_energy / _max_energy) <= ENERGY_RATIO_FOR_WARNING_TRIGGER:
				if is_instance_valid(_player):
					AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_EnergyModi_LowBatteryWarning, _player.global_position, 0.9, null)
				
			
		else:
			if (old_val / _max_energy) < ENERGY_RATIO_FOR_WARNING_TRIGGER and (_current_energy / _max_energy) >= ENERGY_RATIO_FOR_WARNING_TRIGGER:
				if is_instance_valid(_player):
					AudioManager.helper__play_sound_effect__2d__major(StoreOfAudio.AudioIds.SFX_EnergyModi_RechargeAtLow, _player.global_position, 0.9, null)
				
	
	#
	
	var diff = _current_energy - old_val
	
	if arg_source_id != -1:
		_source_id_to_energy_amount_contributed[arg_source_id] += diff
	
	_update_and_calculate_forecasted_energy_consumption()
	
	emit_signal("current_energy_changed", arg_val)


func get_current_energy():
	return _current_energy


#

func clear_source_id_energy_modified(arg_id):
	_source_id_to_energy_amount_contributed.erase(arg_id)



#

func set_forecasted_energy_consume(arg_id, arg_amount):
	_forecast_energy_consume_id_to_amount_map[arg_id] = arg_amount
	_update_and_calculate_forecasted_energy_consumption()

func remove_forecasted_energy_consume(arg_id):
	_forecast_energy_consume_id_to_amount_map.erase(arg_id)
	_update_and_calculate_forecasted_energy_consumption()


func _update_and_calculate_forecasted_energy_consumption():
	_forecasted_energy = _current_energy
	for amount in _forecast_energy_consume_id_to_amount_map.values():
		_forecasted_energy -= amount
	
	if _forecasted_energy < 0:
		_forecasted_energy = 0
	
	emit_signal("forecasted_or_current_energy_changed", _forecasted_energy, _current_energy)



func get_forecasted_energy() -> float:
	return _forecasted_energy

#


func set_max_energy(arg_val):
	_max_energy = arg_val
	
	emit_signal("max_energy_changed", arg_val)

func get_max_energy():
	return _max_energy
	

#####


func is_no_energy():
	return _has_no_energy


###################### 
# REWIND RELATED
#####################

#export(bool) var is_rewindable : bool = true

func get_rewind_save_state():
	return {
		"max_energy" : _max_energy,
		"current_energy" : _current_energy,
		"source_id_to_energy_amount_contributed" : _source_id_to_energy_amount_contributed.duplicate(true),
		"forecast_energy_consume_id_to_amount_map" : _forecast_energy_consume_id_to_amount_map.duplicate(true),
	}
	
	

func load_into_rewind_save_state(arg_state):
	set_max_energy(arg_state["max_energy"])
	set_current_energy(arg_state["current_energy"])
	
	_source_id_to_energy_amount_contributed = arg_state["source_id_to_energy_amount_contributed"]
	_forecast_energy_consume_id_to_amount_map = arg_state["forecast_energy_consume_id_to_amount_map"]
	_update_and_calculate_forecasted_energy_consumption()
	

func destroy_from_rewind_save_state():
	pass
	


func stared_rewind():
	pass
	

func ended_rewind():
	pass
	






