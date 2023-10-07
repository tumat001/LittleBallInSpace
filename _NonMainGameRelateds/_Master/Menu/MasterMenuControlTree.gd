extends "res://MiscRelated/ControlTreeRelated/ControlTree.gd"


const MasterMenu_AboutPage = preload("res://_NonMainGameRelateds/_Master/Menu/Subs/MasterMenu_About/MasterMenu_AboutPage.gd")
const MasterMenu_AboutPage_Scene = preload("res://_NonMainGameRelateds/_Master/Menu/Subs/MasterMenu_About/MasterMenu_AboutPage.tscn")

const GUI_TileColorEditPanel = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/TileColorEditPanel/GUI_TileColorEditPanel.gd")
const GUI_TileColorEditPanel_Scene = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/TileColorEditPanel/GUI_TileColorEditPanel.tscn")

##

var about_page : MasterMenu_AboutPage

#

var _gui_tile_color_edit_panel : GUI_TileColorEditPanel
var _gui_edit_tile_color_panel_button : TextureButton

#

onready var main_page = $ControlContainer/MasterMenu_MainPage


func _ready():
	pause_tree_on_show = false
	use_mod_a_tweeners_for_traversing_hierarchy = false
	can_show_settings_button_on_first_hierarchy = true
	
	connect("hierarchy_advanced_forwards", self, "_on_hierarchy_advanced_forwards__MMCT")
	
	_config_init_gui_tile_color_editor_relateds()


func show_main_page():
	show_control__and_add_if_unadded(main_page, use_mod_a_tweeners_for_traversing_hierarchy)
	


########

func _on_hierarchy_advanced_forwards__MMCT(arg_control):
	if arg_control == main_page:
		set_show_info_button(true)
		
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_GUI_InGamePauseMenu_OrMainMenu_Open, 1.0, null)
	else:
		set_show_info_button(false)
	
	_update_visibility_of_gui_edit_tile_color_button()

#

func _on_MasterMenuControlTree_info_button_pressed():
	show_about_page__construct_if_unconstructed()


func show_about_page__construct_if_unconstructed():
	if !is_instance_valid(about_page):
		about_page = MasterMenu_AboutPage_Scene.instance()
	
	show_control__and_add_if_unadded(about_page, use_mod_a_tweeners_for_traversing_hierarchy)

#

func _config_init_gui_tile_color_editor_relateds():
	GameSaveManager.connect("can_edit_tile_colors_changed", self, "_on_can_edit_tile_colors_changed")
	_update_visibility_of_gui_edit_tile_color_button()

func _on_can_edit_tile_colors_changed(arg_val):
	_update_visibility_of_gui_edit_tile_color_button()


func _update_visibility_of_gui_edit_tile_color_button():
	if GameSaveManager.can_edit_tile_colors and _current_control_showing == main_page:
		
		if !is_instance_valid(_gui_edit_tile_color_panel_button):
			_gui_tile_color_edit_panel = GUI_TileColorEditPanel_Scene.instance()
			add_control__but_dont_show(_gui_tile_color_edit_panel)
			
			_gui_edit_tile_color_panel_button = create_texture_button__with_info_textures()
			_gui_edit_tile_color_panel_button.texture_normal = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/TileColorEditPanel/Assets/GUI_TileColorEditPanel_Button_Normal.png")
			_gui_edit_tile_color_panel_button.texture_hover = preload("res://GameSaveRelated/GUIs/GameSettingsRelated/TileColorEditPanel/Assets/GUI_TileColorEditPanel_Button_Highlighted.png")
			_gui_edit_tile_color_panel_button.connect("pressed", self, "_on_gui_edit_tile_color_panel_button_pressed")
			add_custom_top_right_button__and_associate_with_control(_gui_edit_tile_color_panel_button, _gui_tile_color_edit_panel)
		
		_gui_edit_tile_color_panel_button.visible = true
		
	else:
		
		if is_instance_valid(_gui_edit_tile_color_panel_button):
			_gui_edit_tile_color_panel_button.visible = false
		
	

func _on_gui_edit_tile_color_panel_button_pressed():
	show_control__and_add_if_unadded(_gui_tile_color_edit_panel)
