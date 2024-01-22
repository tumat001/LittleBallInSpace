extends MarginContainer

const PlayTestButtonArt__Play_Normal = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PlayButton_Normal.png")
const PlayTestButtonArt__Play_Highlighted = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PlayButton_Highlighted.png")

const PlayTestButtonArt__Pause_Normal = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PauseButton_Normal.png")
const PlayTestButtonArt__Pause_Highlighted = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Assets/GUI_CustomAudioPanel_PauseButton_Highlighted.png")


const CustomAudioDetailsHelperClass = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/CustomAudioPanel/Subs/CustomAudioDetailsHelperClass.gd")
const CADHC = CustomAudioDetailsHelperClass

###

var _mapped_audio_id_from_SoA
var _custom_audio_id = -1


var _current_audio_full_path : String

var _is_audio_playing : bool setget _set_is_audio_playing
var _current_audio_stream_player

var _is_enabled : bool = false

var is_configured : bool = false

#

onready var category_texture_rect = $VBoxContainer/HBoxContainer/CategoryContainer/BoxContainer/CategoryImage
onready var category_label = $VBoxContainer/HBoxContainer/CategoryContainer/BoxContainer/CategoryLabel

onready var image_type_tex_rect = $VBoxContainer/HBoxContainer/ImageTypeContainer/ImageTypeTexRect

onready var description_tooltip_body = $VBoxContainer/HBoxContainer/DescriptionContainer/DescriptionTooltipBody

onready var uploaded_files_label = $VBoxContainer/HBoxContainer/UploadedFilesContainer/UploadedFilesLabel

onready var folder_button = $VBoxContainer/HBoxContainer/FolderButtonContainer/FolderButton
onready var play_test_button = $VBoxContainer/HBoxContainer/PlayTestContainer/PlayTestButton
onready var volume_slider = $VBoxContainer/HBoxContainer/VolumeContainer/VolumeSlider


######

func _ready():
	pass
	

######

func attempt_configure_self_details_using_custom_audio_id(arg_audio_id):
	if is_configured:
		return
	
	_custom_audio_id = arg_audio_id
	
	if !GameSettingsManager.is_custom_audio_unlocked(arg_audio_id):
		visible = false
		return
	
	##
	
	is_configured = true
	
	_mapped_audio_id_from_SoA = GameSettingsManager.get_store_of_audio_id_map_associated_with_custom_audio(_custom_audio_id)
	
	visible = true
	
	##
	
	var audio_spec_map_from_CADHC = CADHC.custom_audio_id_to_desc_details_map_map[arg_audio_id]
	
	var category_id = audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__CATEGORY_ID]
	var image_for_type = audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__DET_IMAGE]
	var descriptions = audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__DESCRIPTIONS]
	var folder_name = audio_spec_map_from_CADHC[CADHC.CAIdDETAILS__DIC_KEY__FOLDER_NAME]
	var volume_ratio = GameSettingsManager.get_custom_audio_id__volume_ratio(_custom_audio_id)
	
	_configure_self_based_on__category_id(category_id)
	_configure_self_based_on__image_for_type(image_for_type)
	_configure_self_based_on__descriptions(descriptions)
	_configure_self_based_on__folder_name(folder_name)
	_configure_self_based_on__volume_ratio(volume_ratio)
	

func _configure_self_based_on__category_id(category_id : int):
	var details_map = CADHC.get_map_details_for_category_id(category_id)
	category_texture_rect.texture = details_map[CADHC.CAIdCATEGORY__DETAILS_KEY__IMAGE]
	category_label.text = details_map[CADHC.CAIdCATEGORY__DETAILS_KEY__TEXT]

func _configure_self_based_on__image_for_type(arg_image : Texture):
	image_type_tex_rect.texture = arg_image

func _configure_self_based_on__descriptions(arg_descriptions : Array):
	description_tooltip_body.descriptions = arg_descriptions
	description_tooltip_body.update_display()
	

func _configure_self_based_on__folder_name(arg_folder_name : String):
	_current_audio_full_path = GameSettingsManager.get_full_dir_of_custom_audio_file_name__incl_GSM_user_path(arg_folder_name)
	refresh_display_of_all__based_on_precalcs()


func _configure_self_based_on__volume_ratio(arg_vol_ratio):
	volume_slider.set_value(arg_vol_ratio * volume_slider.get_max_value())
	


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
	if _current_audio_stream_player != null and AudioManager.is_stream_player_active(_current_audio_stream_player):
		_stop_current_player()

func _stop_current_player():
	AudioManager.stop_stream_player_and_mark_as_inactive(_current_audio_stream_player)
	
	_set_is_audio_playing(false)

func _start_new_player():
	_current_audio_stream_player = AudioManager.helper__play_sound_effect__plain(_mapped_audio_id_from_SoA, 1.0)
	_current_audio_stream_player.connect("finished", self, "_on_curr_stream_player_finished", [], CONNECT_ONESHOT)
	
	_set_is_audio_playing(true)

func _on_curr_stream_player_finished():
	_set_is_audio_playing(false)

#

func _set_is_audio_playing(arg_val):
	_is_audio_playing = arg_val
	
	if _is_audio_playing:
		play_test_button.texture_button.texture_normal = PlayTestButtonArt__Pause_Normal
		play_test_button.texture_button.texture_hover = PlayTestButtonArt__Pause_Highlighted
		
	else:
		play_test_button.texture_button.texture_normal = PlayTestButtonArt__Play_Normal
		play_test_button.texture_button.texture_hover = PlayTestButtonArt__Play_Highlighted
		
	

#

func _on_VolumeSlider_slider_value_changed(arg_val):
	var ratio = arg_val / volume_slider.get_max_value()
	
	GameSettingsManager.set_custom_audio_id__volume_ratio(_custom_audio_id, ratio)


########

func disable():
	if _is_enabled:
		folder_button.disconnect("button_pressed", self, "_on_FolderButton_button_pressed")
		play_test_button.disconnect("button_pressed", self, "_on_PlayTestButton_button_pressed")
		volume_slider.disconnect("slider_value_changed", self, "_on_VolumeSlider_slider_value_changed")
	
	_is_enabled = false
	

func enable():
	if !_is_enabled:
		folder_button.connect("button_pressed", self, "_on_FolderButton_button_pressed")
		play_test_button.connect("button_pressed", self, "_on_PlayTestButton_button_pressed")
		volume_slider.connect("slider_value_changed", self, "_on_VolumeSlider_slider_value_changed")
	
	_is_enabled = true


func terminate_all_actions():
	_attempt_stop_current_player_if_appropriate()
	

func refresh_display_of_all__based_on_precalcs():
	if _custom_audio_id == -1:
		return
	
	var all_custom_file_names = GameSettingsManager.get_all_precalced_custom_audio_file_names(_custom_audio_id)
	var all_files_to_display_as_str = ""
	var all_custom_file_name_count : int = all_custom_file_names.size()
	
	for i in all_custom_file_name_count:
		var file_names = all_custom_file_names[i]
		all_files_to_display_as_str += "%s"
		if i != all_custom_file_name_count - 1:
			all_files_to_display_as_str += "\n"
	
	uploaded_files_label.text = all_files_to_display_as_str % all_custom_file_names
	
	##
	
	_refresh_audio_disp()

func _refresh_audio_disp():
	var volume_ratio = GameSettingsManager.get_custom_audio_id__volume_ratio(_custom_audio_id)
	volume_slider.set_value(volume_ratio * volume_slider.get_max_value())
	


func get_custom_audio_id():
	return _custom_audio_id


