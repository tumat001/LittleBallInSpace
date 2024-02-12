extends MarginContainer


const MUTE_BUTTON_HOVER_MODULATE := Color(1.3, 1.3, 1.3, 1)
const MUTE_BUTTON_NOT_HOVER_MODULATE := Color(1, 1, 1, 1)


class AudioProperties:
	
	var audio_bus_display_name
	
	# from audio manager
	var bus_player_type_volume__variable_name
	var bus_player_type_volume_changed__signal
	
	var bus_player_type_mute__variable_name
	var bus_player_type_mute_changed__signal
	
	
	var mute_button_unmuted_texture : Texture
	var mute_button_muted_texture : Texture
	

var _audio_properties : AudioProperties

export(bool) var is_mute_button_enabled : bool = true setget set_is_mute_button_enabled

onready var slider_standard = $VBoxContainer/SliderStandard
onready var mute_button = $VBoxContainer/MuteButton

####

func set_is_mute_button_enabled(arg_val):
	is_mute_button_enabled = arg_val
	
	if is_inside_tree():
		mute_button.visible = is_mute_button_enabled

#

func set_audio_properties(arg_properties : AudioProperties):
	_audio_properties = arg_properties
	
	if is_inside_tree():
		_update_display_based_on_properties()

func _ready():
	if _audio_properties != null:
		_update_display_based_on_properties()
	
	slider_standard.connect("slider_value_changed", self, "_on_slider_value_changed", [], CONNECT_PERSIST)
	
	set_is_mute_button_enabled(is_mute_button_enabled)

func _update_display_based_on_properties():
	slider_standard.set_name_label(_audio_properties.audio_bus_display_name)
	
	AudioManager.connect(_audio_properties.bus_player_type_volume_changed__signal, self, "_on_bus_player_type_volume_changed")
	AudioManager.connect(_audio_properties.bus_player_type_mute_changed__signal, self, "_on_bus_player_type_mute_changed")
	_update_slider_and_mute_button_based_on_volume()
	


func _on_bus_player_type_volume_changed(arg_val):
	_update_slider_and_mute_button_based_on_volume()

func _on_bus_player_type_mute_changed(arg_val):
	_update_slider_and_mute_button_based_on_volume()

func _update_slider_and_mute_button_based_on_volume():
	var volume_db = AudioManager.get(_audio_properties.bus_player_type_volume__variable_name)
	var amount = _convert_volume_db_into_100_to_0_range(volume_db)
	
	#print("voldb: %s, amount: %s" % [volume_db, amount])
	
	if AudioManager.get(_audio_properties.bus_player_type_mute__variable_name):
		amount = 0
	
	slider_standard.set_value(amount)
	
	#
	
	if is_equal_approx(0, amount):
		mute_button.texture_normal = _audio_properties.mute_button_muted_texture
	else:
		mute_button.texture_normal = _audio_properties.mute_button_unmuted_texture


func _convert_volume_db_into_100_to_0_range(arg_db):
	return db2linear(arg_db) * 100
	



func _on_MuteButton_mouse_entered():
	mute_button.modulate = MUTE_BUTTON_HOVER_MODULATE
	

func _on_MuteButton_mouse_exited():
	mute_button.modulate = MUTE_BUTTON_NOT_HOVER_MODULATE
	

func _on_AudioBusVolumePanel_visibility_changed():
	mute_button.modulate = MUTE_BUTTON_NOT_HOVER_MODULATE
	


func _on_MuteButton_pressed():
	if is_mute_button_enabled:
		if slider_standard.get_value() != 0:
			slider_standard.set_value(0, true)
		else:
			slider_standard.set_value(100, true)

#

func _on_slider_value_changed(arg_val):
	var db = linear2db(arg_val / 100)
	if arg_val == 0:
		db = -80
	
	AudioManager.set(_audio_properties.bus_player_type_volume__variable_name, db)
	
	if arg_val == 0:
		AudioManager.set(_audio_properties.bus_player_type_mute__variable_name, true)
	else:
		AudioManager.set(_audio_properties.bus_player_type_mute__variable_name, false)

#

