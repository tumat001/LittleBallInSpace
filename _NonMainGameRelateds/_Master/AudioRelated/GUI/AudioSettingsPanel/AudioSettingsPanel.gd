extends MarginContainer

const AudioBusVolumePanel = preload("res://_NonMainGameRelateds/_Master/AudioRelated/GUI/AudioSettingsPanel/Subs/AudioBusVolumePanel/AudioBusVolumePanel.gd")


onready var audio_bus_volume_panel__background = $HBoxContainer/AudioBusVolumePanel_BGM
onready var audio_bus_volume_panel__sound_fx = $HBoxContainer/AudioBusVolumePanel_SoundFX


func _ready():
	var audio_properties__sound_fx = AudioBusVolumePanel.AudioProperties.new()
	audio_properties__sound_fx.audio_bus_display_name = "Sound Effects"
	audio_properties__sound_fx.bus_player_type_volume__variable_name = "bus__sound_fx_volume"
	audio_properties__sound_fx.bus_player_type_volume_changed__signal = "bus__sound_fx_volume_changed"
	audio_properties__sound_fx.bus_player_type_mute__variable_name = "bus__sound_fx_bus_mute"
	audio_properties__sound_fx.bus_player_type_mute_changed__signal = "bus__sound_fx_mute_changed"
	audio_properties__sound_fx.mute_button_muted_texture = preload("res://_NonMainGameRelateds/_Master/AudioRelated/GUI/Assets/AudioSettingsPanel_SoundFXButton_Muted.png")
	audio_properties__sound_fx.mute_button_unmuted_texture = preload("res://_NonMainGameRelateds/_Master/AudioRelated/GUI/Assets/AudioSettingsPanel_SoundFXButton_Normal.png")
	
	
	var audio_properties__background = AudioBusVolumePanel.AudioProperties.new()
	audio_properties__background.audio_bus_display_name = "Background\nMusic"
	audio_properties__background.bus_player_type_volume__variable_name = "bus__background_music_volume"
	audio_properties__background.bus_player_type_volume_changed__signal = "bus__background_music_volume_changed"
	audio_properties__background.bus_player_type_mute__variable_name = "bus__background_music_bus_mute"
	audio_properties__background.bus_player_type_mute_changed__signal = "bus__background_music_mute_changed"
	audio_properties__background.mute_button_muted_texture = preload("res://_NonMainGameRelateds/_Master/AudioRelated/GUI/Assets/AudioSettingsPanel_BGMButton_Muted.png")
	audio_properties__background.mute_button_unmuted_texture = preload("res://_NonMainGameRelateds/_Master/AudioRelated/GUI/Assets/AudioSettingsPanel_BGMButton_Normal.png")
	
	###
	
	audio_bus_volume_panel__sound_fx.set_audio_properties(audio_properties__sound_fx)
	audio_bus_volume_panel__background.set_audio_properties(audio_properties__background)
	

