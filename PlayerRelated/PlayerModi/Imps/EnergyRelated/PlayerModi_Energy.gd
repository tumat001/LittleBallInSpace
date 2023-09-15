extends "res://PlayerRelated/PlayerModi/AbstractPlayerModi.gd"

const LightTextureConstructor = preload("res://MiscRelated/Light2DRelated/LightTextureConstructor.gd")

##

signal discarged_to_zero_energy()
signal recharged_from_no_energy()

signal current_energy_changed(arg_val)
signal max_energy_changed(arg_val)

# for use of energy HUD
signal forecasted_or_current_energy_changed(arg_curr_energy, arg_forecasted_energy)


signal battery_visual_type_id_changed(arg_id)

signal is_energy_deductable_changed(arg_val)


signal allow_display_of_energy_hud_changed(arg_val)
signal is_true_instant_drain_and_recharge_changed(arg_val)

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

enum BatteryVisualTypeId {
	STANDARD = 0,
	MEGA = 1,
}
var battery_visual_type_id : int setget set_battery_visual_type_id

#


# NOTE: These are not made to be rewindable...
var is_energy_deductable : bool = true setget set_is_energy_deductable

var allow_display_of_energy_hud : bool = true setget set_allow_display_of_energy_hud
var is_true_instant_drain_and_recharge : bool = false setget set_is_true_instant_drain_and_recharge

#

var _game_front_hud
var _blackout_hud_sprite : Sprite

#

func apply_modification_to_player_and_game_elements(arg_player, arg_game_elements):
	.apply_modification_to_player_and_game_elements(arg_player, arg_game_elements)
	
	_player = arg_player
	
	if arg_game_elements.is_game_front_hud_initialized:
		_init_all_game_hud_relateds()
	else:
		arg_game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)

func _on_game_front_hud_initialized(arg_hud):
	_init_all_game_hud_relateds()



#

func inc_current_energy(arg_amount, arg_source_id = -1):
	set_current_energy(_current_energy + arg_amount, arg_source_id)
	

func dec_current_energy(arg_amount, arg_source_id = -1):
	set_current_energy(_current_energy - arg_amount, arg_source_id)
	

func set_current_energy(arg_val, arg_source_id = -1):
	var old_val = _current_energy
	_current_energy = arg_val
	
	
	if !is_energy_deductable and _current_energy < old_val:
		_current_energy = old_val
	
	
	if _current_energy < 0:
		_current_energy = 0
	if _current_energy > _max_energy:
		_current_energy = _max_energy
	
	#
	
	if is_true_instant_drain_and_recharge:
		if old_val > _current_energy:
			_current_energy = 0
		elif _current_energy > old_val:
			_current_energy = _max_energy
	
	
	var old_has_no_energy_val = _has_no_energy
	_has_no_energy = is_zero_approx(_current_energy)
	if old_has_no_energy_val != _has_no_energy:
		if _has_no_energy:
			
			if !SingletonsAndConsts.current_rewind_manager.is_rewinding and is_instance_valid(_player):
				_energy_down__sound_player = AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_EnergyModi_PowerDown_01, _player.global_position, 1.38, null)
				if _energy_restored__sound_player != null and _energy_restored__sound_player.playing:
					AudioManager.stop_stream_player_and_mark_as_inactive(_energy_restored__sound_player)
			
			_player.can_capture_PCA_regions = false
			
			_tween_mute_background_music__internal()
			emit_signal("discarged_to_zero_energy")
			
		else:
			
			if !SingletonsAndConsts.current_rewind_manager.is_rewinding and is_instance_valid(_player):
				_energy_restored__sound_player = AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_EnergyModi_PowerUp_01, _player.global_position, 1.0, null)
				if _energy_down__sound_player != null and _energy_down__sound_player.playing:
					AudioManager.stop_stream_player_and_mark_as_inactive(_energy_down__sound_player)
			
			_player.can_capture_PCA_regions = true
			
			_tween_unmute_background_music__internal()
			emit_signal("recharged_from_no_energy")
			
	
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding:
		if old_val > _current_energy:
			if (old_val / _max_energy) > ENERGY_RATIO_FOR_WARNING_TRIGGER and (_current_energy / _max_energy) <= ENERGY_RATIO_FOR_WARNING_TRIGGER:
				if is_instance_valid(_player):
					AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_EnergyModi_LowBatteryWarning, _player.global_position, 0.9, null)
				
			
		else:
			if (old_val / _max_energy) < ENERGY_RATIO_FOR_WARNING_TRIGGER and (_current_energy / _max_energy) >= ENERGY_RATIO_FOR_WARNING_TRIGGER:
				if is_instance_valid(_player):
					AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_EnergyModi_RechargeAtLow, _player.global_position, 0.9, null)
				
	
	#
	
	var diff = _current_energy - old_val
	
	if arg_source_id != -1:
		_source_id_to_energy_amount_contributed[arg_source_id] += diff
	
	_update_and_calculate_forecasted_energy_consumption()
	
	emit_signal("current_energy_changed", arg_val)


func get_current_energy():
	return _current_energy

#

func _tween_mute_background_music__internal():
	var background_music_playlist = StoreOfAudio.BGM_playlist__calm_01  ## does not matter since they affect the same bus
	background_music_playlist.set_volume_db__bus_internal__tween(AudioManager.DECIBEL_VAL__INAUDIABLE, 1.5, self, "_on_finish_tweening_background_music", null)

func _tween_unmute_background_music__internal():
	var background_music_playlist = StoreOfAudio.BGM_playlist__calm_01  ## does not matter since they affect the same bus
	background_music_playlist.set_volume_db__bus_internal__tween(AudioManager.DECIBEL_VAL__STANDARD, 1.5, self, "_on_finish_tweening_background_music", null)




func _on_finish_tweening_background_music(arg_params):
	pass
	


##

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

##

func set_battery_visual_type_id(arg_id):
	var old_val = battery_visual_type_id
	battery_visual_type_id = arg_id
	
	if old_val != battery_visual_type_id:
		emit_signal("battery_visual_type_id_changed", battery_visual_type_id)

#

func set_properties__as_mega_battery(arg_start_with_full_battery : bool = true):
	set_battery_visual_type_id(BatteryVisualTypeId.MEGA)
	set_max_energy(150)
	
	if arg_start_with_full_battery:
		set_current_energy(150)
	

#

func set_is_energy_deductable(arg_val):
	var old_val = is_energy_deductable
	is_energy_deductable = arg_val
	
	if old_val != arg_val:
		emit_signal("is_energy_deductable_changed", is_energy_deductable)

########

func make_assist_mode_modification__additional_energy():
	var extra_energy_amount = GameSettingsManager.get_assist_mode__additional_energy_amount_from_current_id()
	set_max_energy(_max_energy + extra_energy_amount)
	set_current_energy(_current_energy + extra_energy_amount)

func make_assist_mode_modification__energy_reduction_mode():
	var reduc_id = GameSettingsManager.assist_mode__energy_reduction_mode_id
	if reduc_id == GameSettingsManager.AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL:
		set_is_energy_deductable(true)
	elif reduc_id == GameSettingsManager.AssistMode_EnergyReductionModeId.INFINITE:
		set_is_energy_deductable(false)


#

func set_allow_display_of_energy_hud(arg_val):
	var old_val = allow_display_of_energy_hud
	allow_display_of_energy_hud = arg_val
	
	if old_val != arg_val:
		emit_signal("allow_display_of_energy_hud_changed", arg_val)


func set_is_true_instant_drain_and_recharge(arg_val):
	var old_val = is_true_instant_drain_and_recharge
	is_true_instant_drain_and_recharge = arg_val
	
	if old_val != arg_val:
		emit_signal("is_true_instant_drain_and_recharge_changed", arg_val)


#####


func _init_all_game_hud_relateds():
	_game_front_hud = SingletonsAndConsts.current_game_front_hud
	_create_blackout_no_energy_sprite()
	
	_player.connect("light_2d_mod_a_changed", self, "_on_light_2d_mod_a_changed")

func _create_blackout_no_energy_sprite():
	_blackout_hud_sprite = _game_front_hud.create_sprite_shader(null)
	var gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(0, 0, 0, 0), Color(0, 0, 0, 0.8), false)
	var grad_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(960, 540), false)
	grad_texture.gradient = gradient
	_blackout_hud_sprite.visible = true
	_blackout_hud_sprite.global_position = Vector2(0, 0)
	_blackout_hud_sprite.centered = false
	_blackout_hud_sprite.scale = Vector2(1, 1)
	
	_blackout_hud_sprite.texture = grad_texture
	_blackout_hud_sprite.modulate.a = 0


func _on_light_2d_mod_a_changed(arg_val):
	var reverse_val = 1 - arg_val
	_blackout_hud_sprite.modulate.a = reverse_val

#

func custom_event__tween_blackout_hud_sprite(arg_val, arg_duration):
	var tween : SceneTreeTween = _player.create_tween()
	tween.tween_property(_blackout_hud_sprite, "modulate:a", arg_val, arg_duration)
	

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
	


func started_rewind():
	pass
	

func ended_rewind():
	pass
	






