tool
extends "res://MiscRelated/EnvironmentEventPlayerRelated/BaseEnvEventPlayer/BaseEnvEventPlayer_Looping.gd"


enum AmbientAudioTemplate {
	NONE = -1,
	ELECTRIC_GENERATOR = 0,
	
	COMPUTER_SOUNDS_FUTURISTIC_01 = 10,
	
}
export(AmbientAudioTemplate) var export__audio_template_id : int = AmbientAudioTemplate.NONE setget set_export__audio_template_id

#

enum AmbientAudioListTypeId {
	NONE = -1,
	ELECTRIC_GENERATOR = 0,
	
	COMPUTER_SOUNDS_FUTURISTIC_01 = 10,
}
export(AmbientAudioListTypeId) var export__audio_list_type_id : int = AmbientAudioListTypeId.NONE

#

var audio_id_rand_pool_to_play_from : Array

###

func set_export__audio_template_id(arg_id):
	export__audio_template_id = arg_id
	_config_all_properties__based_on_audio_template()


#

func _ready() -> void:
	_config_all_properties__based_on_audio_template()
	_config_audio_id_rand_pool_to_play_from__based_on_list_type_id()

# check using is_inside_tree()
func _config_all_properties__based_on_audio_template():
	match (export__audio_template_id):
		AmbientAudioListTypeId.ELECTRIC_GENERATOR:
			loop_wait_min = 4
			loop_wait_max = 7
			export__audio_list_type_id = AmbientAudioListTypeId.ELECTRIC_GENERATOR
			
		AmbientAudioListTypeId.COMPUTER_SOUNDS_FUTURISTIC_01:
			loop_wait_min = 10
			loop_wait_max = 30
			export__audio_list_type_id = AmbientAudioListTypeId.COMPUTER_SOUNDS_FUTURISTIC_01
			
		

func _config_audio_id_rand_pool_to_play_from__based_on_list_type_id():
	match (export__audio_list_type_id):
		AmbientAudioListTypeId.ELECTRIC_GENERATOR:
			audio_id_rand_pool_to_play_from = [
				StoreOfAudio.AudioIds.SFX_Ambient_ElectricGenerator
			]
			
		AmbientAudioListTypeId.COMPUTER_SOUNDS_FUTURISTIC_01:
			audio_id_rand_pool_to_play_from = [
				StoreOfAudio.AudioIds.SFX_Ambient_ComputerSoundFuturistic01_01,
				StoreOfAudio.AudioIds.SFX_Ambient_ComputerSoundFuturistic01_02,
				
			]
		


func _execute_environment_action__loop_wait_finished():
	var rand_id = StoreOfRNG.randomly_select_one_element(audio_id_rand_pool_to_play_from, SingletonsAndConsts.non_essential_rng)
	var audio_player : AudioStreamPlayer2D = AudioManager.helper__play_sound_effect__2d(rand_id, global_position, 1.0, null)
	
	is_paused = true
	
	audio_player.connect("finished", self, "_on_audio_player_finished", [], CONNECT_ONESHOT)

func _on_audio_player_finished():
	is_paused = false


