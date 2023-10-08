extends MarginContainer


onready var body__color_picker_button = $VBoxContainer/HBoxContainer/BodySpecContianer/VBoxContainer/BodyColor/Body_ColorPickerButton
onready var body__texture_option_button = $VBoxContainer/HBoxContainer/BodySpecContianer/VBoxContainer/BodyTexture_OptionButton

#

func _ready():
	## BODY TEXTURE
	_connect_signals_with_GSettingsM__for_body_texture()
	_populate_choices_in_body_texture_option_button__and_configure()
	_update_selected_body_texture_id_index_based_on_GSettingsM()
	
	## BODY MODULATE
	_connect_signals_with_GSettingsM__for_body_modulate()
	_update_body_modulate_based_on_GSettingsM()

#

func _connect_signals_with_GSettingsM__for_body_modulate():
	GameSettingsManager.connect("player_aesth_config__saved_modulate_for_body_texture_id__changed", self, "_on_GSettingsM_player_aesth_config__saved_modulate_for_body_texture_id__changed")

func _on_GSettingsM_player_aesth_config__saved_modulate_for_body_texture_id__changed(arg_modulate, arg_id):
	_update_body_modulate_based_on_GSettingsM()
	

func _update_body_modulate_based_on_GSettingsM():
	var selected_id = body__texture_option_button.get_selected_id()
	if selected_id == GameSettingsManager.player_aesth_config__body_texture_id:
		body__color_picker_button.color = GameSettingsManager.player_aesth_config__body_texture_id_to_saved_modulate_map[selected_id]


#

func _connect_signals_with_GSettingsM__for_body_texture():
	GameSettingsManager.connect("player_aesth_config__body_texture_id__changed", self, "_on_GSettingsM_player_aesth_config__body_texture_id__changed")
	

func _populate_choices_in_body_texture_option_button__and_configure():
	for body_texture_id_or_sepa in GameSettingsManager.player_aesth_config__body_texture_ids_with_sepa_arr__as_displayed_in_ui:
		
		if body_texture_id_or_sepa == GameSettingsManager.OPTION_BUTTON__LINE_SEPA:
			body__texture_option_button.add_separator()
			
		else:
			var body_texture_id = body_texture_id_or_sepa
			var details : Dictionary = GameSettingsManager.player_aesth_config__body_texture_id_to_details_map[body_texture_id]
			
			var option_name = details[GameSettingsManager.PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__NAME__DIC_ID]
			var icon = details[GameSettingsManager.PLAYER_AESTH_CONFIG__BODY_TEXTURE_DETAILS__ICON__DIC_ID]
			
			if icon != null:
				body__texture_option_button.add_item(option_name, body_texture_id)
			else:
				body__texture_option_button.add_icon_item(icon, option_name, body_texture_id)
				
	

func _on_BodyTexture_OptionButton_item_selected(index):
	var id = body__texture_option_button.get_item_id(index)
	
	GameSettingsManager.set_player_aesth_config__body_texture_id(id)



func _on_GSettingsM_player_aesth_config__body_texture_id__changed(arg_id):
	_update_selected_body_texture_id_index_based_on_GSettingsM()

func _update_selected_body_texture_id_index_based_on_GSettingsM():
	var index = body__texture_option_button.get_item_index(GameSettingsManager.player_aesth_config__body_texture_id)
	body__texture_option_button.select(index)
	

