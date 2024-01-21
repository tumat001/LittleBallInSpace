extends MarginContainer

const PlayTestButtonArt__Play_Normal = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PlayButton_Normal.png")
const PlayTestButtonArt__Play_Highlighted = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PlayButton_Highlighted.png")

const PlayTestButtonArt__Pause_Normal = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PauseButton_Normal.png")
const PlayTestButtonArt__Pause_Highlighted = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PauseButton_Highlighted.png")


const CustomAudioDetailsHelperClass = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Subs/CustomAudioDetailsHelperClass.gd")
const CADHC = CustomAudioDetailsHelperClass

###

var _custom_audio_id


var _current_audio_full_path : String

var _is_audio_playing : bool
var _current_audio_stream_player

#

onready var category_texture_rect = $HBoxContainer/CategoryContainer/BoxContainer/CategoryImage
onready var category_label = $HBoxContainer/CategoryContainer/BoxContainer/CategoryLabel

onready var description_tooltip_body = $HBoxContainer/DescriptionContainer/DescriptionTooltipBody

onready var uploaded_files_label = $HBoxContainer/UploadedFilesContainer/UploadedFilesLabel

onready var play_test_button = $HBoxContainer/PlayTestContainer/PlayTestButton

onready var volume_slider = $HBoxContainer/VolumeContainer/VolumeSlider


######

func _ready():
	pass
	

######

func configure_self_details_using_map(arg_audio_id, arg_audio_spec_map_from_CADHC : Dictionary):
	if !GameSettingsManager.is_custom_audio_unlocked(arg_audio_id):
		visible = false
		return
	
	##
	
	_custom_audio_id = arg_audio_id
	
	visible = true
	
	var category_id = arg_audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__CATEGORY_ID]
	var descriptions = arg_audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__DESCRIPTIONS]
	var folder_name = arg_audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__FOLDER_NAME]
	
	_configure_self_based_on__category_id(category_id)
	_configure_self_based_on__descriptions(descriptions)
	_configure_self_based_on__folder_name(folder_name)


func _configure_self_based_on__category_id(category_id : int):
	var details_map = CADHC.get_map_details_for_category_id(category_id)
	category_texture_rect.texture = details_map[CADHC.CAIdCATEGORY__DETAILS_KEY__IMAGE]
	category_label.text = details_map[CADHC.CAIdCATEGORY__DETAILS_KEY__TEXT]


func _configure_self_based_on__descriptions(arg_descriptions : Array):
	description_tooltip_body.descriptions = arg_descriptions
	description_tooltip_body.update_display()
	

func _configure_self_based_on__folder_name(arg_folder_name : String):
	_current_audio_full_path = GameSettingsManager.get_full_dir_of_custom_audio_file_name__incl_GSM_user_path(arg_folder_name)
	refresh_display_files_found_in_folder__based_on_precalcs()


func refresh_display_files_found_in_folder__based_on_precalcs():
	var all_custom_file_names = GameSettingsManager.get_all_precalced_custom_audio_file_names(_custom_audio_id)
	var all_files_to_display_as_str = ""
	var all_custom_file_name_count : int = all_custom_file_names.size()
	
	for i in all_custom_file_name_count:
		var file_names = all_custom_file_names[i]
		all_files_to_display_as_str += "%s"
		if i != all_custom_file_name_count - 1:
			all_files_to_display_as_str += "/n"
	
	uploaded_files_label.text = all_files_to_display_as_str % all_custom_file_names

#####

func _on_FolderButton_button_pressed():
	var converted_full_path = ProjectSettings.globalize_path(_current_audio_full_path)
	OS.shell_open(converted_full_path)

#

func _on_PlayTestButton_button_pressed():
	if _is_audio_playing:
		_attempt_stop_current_player_if_appropriate()
	else:
		_start_new_player()
	

func _attempt_stop_current_player_if_appropriate():
	pass
	

func _stop_current_player():
	pass
	

func _start_new_player():
	_current_audio_stream_player = AudioManager.helper__play_sound_effect__plain()
	



func _on_VolumeSlider_slider_value_changed(arg_val):
	pass # Replace with function body.
	


