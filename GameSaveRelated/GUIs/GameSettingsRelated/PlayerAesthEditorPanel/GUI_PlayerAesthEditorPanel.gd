extends MarginContainer


onready var body__color_picker_button = $VBoxContainer/HBoxContainer/BodySpecContianer/VBoxContainer/BodyColor/Body_ColorPickerButton
onready var body__texture_option_button = $VBoxContainer/HBoxContainer/BodySpecContianer/VBoxContainer/BodyTexture_OptionButton

onready var face_screen__color_picker_button = $VBoxContainer/HBoxContainer/FaceSpecContainer/VBoxContainer/FaceScreenColor/FaceScreen_ColorPickerButton
onready var face_screen__texture_option_button = $VBoxContainer/HBoxContainer/FaceSpecContainer/VBoxContainer/FaceScreenTexture_OptionButton

#

func _ready():
	## BODY TEXTURE
	_connect_signals_with_GSettingsM__for_body_texture()
	_populate_choices_in_body_texture_option_button__and_configure()
	_update_selected_body_texture_id_index_based_on_GSettingsM()
	
	## BODY MODULATE
	_connect_signals_with_GSettingsM__for_body_modulate()
	_update_body_modulate_based_on_GSettingsM()
	
	## FACE screen TEXTURE
	_connect_signals_with_GSettingsM__for_face_screen_texture()
	_populate_choices_in_face_screen_texture_option_button__and_configure()
	_update_selected_face_screen_texture_id_index_based_on_GSettingsM()
	
	## FACE screen MODULATE
	_connect_signals_with_GSettingsM__for_face_screen_modulate()
	_update_face_screen_modulate_based_on_GSettingsM()
	


######### Body Texture

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
	


######## Body Modulate

func _connect_signals_with_GSettingsM__for_body_modulate():
	GameSettingsManager.connect("player_aesth_config__saved_modulate_for_body_texture_id__changed", self, "_on_GSettingsM_player_aesth_config__saved_modulate_for_body_texture_id__changed")
	GameSettingsManager.connect("player_aesth_config__body_texture_id__changed", self, "_on_GSettingsM__player_aesth_config__body_texture_id__changed__for_body_modulate")

func _on_GSettingsM_player_aesth_config__saved_modulate_for_body_texture_id__changed(arg_modulate, arg_id):
	_update_body_modulate_based_on_GSettingsM()
	

func _update_body_modulate_based_on_GSettingsM():
	var selected_id = body__texture_option_button.get_selected_id()
	if selected_id == GameSettingsManager.player_aesth_config__body_texture_id:
		body__color_picker_button.color = GameSettingsManager.player_aesth_config__body_texture_id_to_saved_modulate_map[selected_id]


func _on_Body_ColorPickerButton_color_changed__by_any_means__input_esc_eat(arg_color):
	GameSettingsManager.set_player_aesth_config__modulate_for_body_texture_id(arg_color, GameSettingsManager.player_aesth_config__body_texture_id)


func _on_GSettingsM__player_aesth_config__body_texture_id__changed__for_body_modulate(arg_id):
	_update_body_modulate_based_on_GSettingsM()


############# Face screen texture

func _connect_signals_with_GSettingsM__for_face_screen_texture():
	GameSettingsManager.connect("player_aesth_config__face_screen_texture_id__changed", self, "_on_GSettingM_player_aesth_config__face_screen_texture_id__changed")

func _populate_choices_in_face_screen_texture_option_button__and_configure():
	for face_screen_texture_id_or_sepa in GameSettingsManager.player_aesth_config__face_screen_texture_ids_with_sepa_arr__as_displayed_in_ui:
		
		if face_screen_texture_id_or_sepa == GameSettingsManager.OPTION_BUTTON__LINE_SEPA:
			face_screen__texture_option_button.add_separator()
			
		else:
			var face_screen_texture_id = face_screen_texture_id_or_sepa
			var details : Dictionary = GameSettingsManager.player_aesth_config__face_screen_texture_id_to_details_map[face_screen_texture_id]
			
			var option_name = details[GameSettingsManager.PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_DETAILS__NAME__DIC_ID]
			var icon = details[GameSettingsManager.PLAYER_AESTH_CONFIG__FACE_SCREEN_TEXTURE_DETAILS__ICON__DIC_ID]
			
			if icon != null:
				face_screen__texture_option_button.add_item(option_name, face_screen_texture_id)
			else:
				face_screen__texture_option_button.add_icon_item(icon, option_name, face_screen_texture_id)
			
	


func _on_GSettingM_player_aesth_config__face_screen_texture_id__changed(arg_id):
	_update_selected_face_screen_texture_id_index_based_on_GSettingsM()
	

func _update_selected_face_screen_texture_id_index_based_on_GSettingsM():
	var index = face_screen__texture_option_button.get_item_index(GameSettingsManager.player_aesth_config__face_screen_texture_id)
	face_screen__texture_option_button.select(index)
	


########## FACE screen MODULATE

func _connect_signals_with_GSettingsM__for_face_screen_modulate():
	GameSettingsManager.connect("player_aesth_config__BTId_to_saved_modulate_for_face_screen_texture_id__changed", self, "_on_GSettingsM_player_aesth_config__BTId_to_saved_modulate_for_face_screen_texture_id__changed")
	GameSettingsManager.connect("player_aesth_config__body_texture_id__changed", self, "_on_GSettingsM_player_aesth_config__body_texture_id__changed__for_face_screen")

func _on_GSettingsM_player_aesth_config__BTId_to_saved_modulate_for_face_screen_texture_id__changed(arg_modulate, arg_id):
	_update_face_screen_modulate_based_on_GSettingsM()

func _on_GSettingsM_player_aesth_config__body_texture_id__changed__for_face_screen(arg_id):
	_update_face_screen_modulate_based_on_GSettingsM()


func _update_face_screen_modulate_based_on_GSettingsM():
	var selected_body_id = body__texture_option_button.get_selected_id()
	#var selected_face_id = face_screen__texture_option_button.get_selected_id()
	if selected_body_id == GameSettingsManager.player_aesth_config__body_texture_id:
		face_screen__color_picker_button.color = GameSettingsManager.player_aesth_config__BTId_to_saved_face_screen_modulate_map[selected_body_id]


func _on_FaceScreen_ColorPickerButton_color_changed__by_any_means__input_esc_eat(arg_color):
	GameSettingsManager.set_player_aesth_config__modulate_for_BTId_saved_face_screen(arg_color, GameSettingsManager.player_aesth_config__body_texture_id)




#############################################
# TREE ITEM Specific methods/vars

var control_tree setget set_control_tree

var _old_control_tree_modulate : Color
const COLOR_FOR_CONTROL_TREE = Color("f5ffffff")

func on_control_received_focus():
	_old_control_tree_modulate = control_tree.background_texture_rect_modulate
	control_tree.set_background_texture_rect_modulate(COLOR_FOR_CONTROL_TREE)

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	control_tree.set_background_texture_rect_modulate(_old_control_tree_modulate)

func on_control_fully_invisible():
	pass
	


func set_control_tree(arg_tree):
	control_tree = arg_tree
	

############
# END OF TREE ITEM Specific methods/vars
###########
