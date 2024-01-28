extends "res://WorldRelated/AbstractWorldSlice.gd"

const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

const PlayerCaptureAreaRegion = preload("res://AreaRegionRelated/Subs/PlayerCaptureAreaRegion/PlayerCaptureAreaRegion.gd")
const VisualKeyPress = preload("res://MiscRelated/VisualsRelated/KeyPressVisual/Visual_Keypress.gd")

const WSSS0104_BannedHotkeyPanel = preload("res://WorldRelated/WorldSlices/Stage_Special001/Level04/CustomGameFrontHUDControls/WSSS0104_BannedHotkeyPanel.gd")
const WSSS0104_BannedHotkeyPanel_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special001/Level04/CustomGameFrontHUDControls/WSSS0104_BannedHotkeyPanel.tscn")

#

signal keys_banned_changed(arg_key_affected, arg_is_banned, arg_keys_to_is_banned_map)


###

var banned_key_panel : WSSS0104_BannedHotkeyPanel

var keys_to_is_banned_map : Dictionary = {}

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	
	_init_keys_to_is_banned_map()

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_init_with_GFH()

#

func _init_with_GFH():
	if game_elements.is_game_front_hud_initialized:
		_do_all_GFH_relateds()
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)
		

func _on_game_front_hud_initialized(arg_GFH):
	_do_all_GFH_relateds()


func _do_all_GFH_relateds():
	_add_gui_panels_to_GFH()

func _add_gui_panels_to_GFH():
	banned_key_panel = WSSS0104_BannedHotkeyPanel_Scene.instance()
	
	banned_key_panel.config_to_game_front_hud(game_elements.game_front_hud)
	banned_key_panel.config_with_WSSS0104(self)

###

func _input(event):
	if event is InputEventKey:
		if keys_to_is_banned_map[event.scancode]:
			get_viewport().set_input_as_handled()
	

#

func _init_keys_to_is_banned_map():
	for game_control_action_name in GameSettingsManager.GAME_CONTROLS_TO_NAME_MAP.keys():
		var hotkey = GameSettingsManager.get_game_control_hotkey__as_string(game_control_action_name)
		keys_to_is_banned_map[hotkey] = false
		
	

func ban_key(arg_key):
	keys_to_is_banned_map[arg_key] = true
	
	emit_signal("keys_banned_changed", arg_key, true, keys_to_is_banned_map)

func unban_key(arg_key):
	keys_to_is_banned_map[arg_key] = false
	
	emit_signal("keys_banned_changed", arg_key, false, keys_to_is_banned_map)


##

func _associate_pca_to_vkp(arg_pca : PlayerCaptureAreaRegion, arg_vkp : VisualKeyPress):
	var key = GameSettingsManager.get_game_control_hotkey__as_string(arg_vkp.game_control_action_name)
	arg_pca.connect("region_area_captured", self, "_on_pca_region_area_captured", [key])
	arg_pca.connect("region_area_uncaptured", self, "_on_pca_region_area_uncaptured", [key])


func _on_pca_region_area_captured(arg_key):
	ban_key(arg_key)

func _on_pca_region_area_uncaptured(arg_key):
	unban_key(arg_key)



