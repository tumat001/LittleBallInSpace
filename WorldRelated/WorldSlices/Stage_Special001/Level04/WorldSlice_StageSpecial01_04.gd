extends "res://WorldRelated/AbstractWorldSlice.gd"

const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

const PlayerCaptureAreaRegion = preload("res://AreaRegionRelated/Subs/PlayerCaptureAreaRegion/PlayerCaptureAreaRegion.gd")
const VisualKeyPress = preload("res://MiscRelated/VisualsRelated/KeyPressVisual/Visual_Keypress.gd")

const WSSS0104_BannedHotkeyPanel = preload("res://WorldRelated/WorldSlices/Stage_Special001/Level04/CustomGameFrontHUDControls/WSSS0104_BannedHotkeyPanel.gd")
const WSSS0104_BannedHotkeyPanel_Scene = preload("res://WorldRelated/WorldSlices/Stage_Special001/Level04/CustomGameFrontHUDControls/WSSS0104_BannedHotkeyPanel.tscn")

#

signal keys_banned_changed(arg_key_affected, arg_is_banned)
signal attempted_key_pressed(arg_key_pressed)
signal attempted_mouse_motion()

###

var banned_key_panel : WSSS0104_BannedHotkeyPanel

const VKP_DETAILS__IS_BANNED = "is_banned"
const VKP_DETAILS__KEY_AT_BAN_TIME_PERIOD = "key_at_ban_time_period"
var vkp_to_details_map_map : Dictionary


var player_modi_launch_ball
var last_mouse_angle : float
var is_mouse_mov_disabled : bool

#

onready var vkp_rewind = $MiscContainer/VKP_Rewind
onready var vkp_ball_launch = $MiscContainer/VKP_BallLaunch
onready var vkp_left = $MiscContainer/VKP_Left
onready var vkp_right = $MiscContainer/VKP_Right
onready var vkp_stop = $MiscContainer/VKP_Stop
onready var vkp_zoom = $MiscContainer/VKP_Zoom
onready var mouse_press_visual_tex_rect = $MiscContainer/MousePressVisualTexRect

onready var all_displaying_controls : Array = [
	vkp_rewind,
	vkp_ball_launch,
	vkp_left,
	vkp_right,
	vkp_stop,
	vkp_zoom,
	mouse_press_visual_tex_rect,
]

onready var pca_rewind = $AreaRegionContainer/PCA_Rewind
onready var pca_ball_launch = $AreaRegionContainer/PCA_BallLaunch
onready var pca_left = $AreaRegionContainer/PCA_Left
onready var pca_right = $AreaRegionContainer/PCA_Right
onready var pca_stop = $AreaRegionContainer/PCA_Stop
onready var pca_zoom = $AreaRegionContainer/PCA_Zoom

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_init_with_GFH()

#

func _init_player_relateds():
	player_modi_launch_ball = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)

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
		#if keys_to_is_banned_map[event.scancode]:
		for details_map in vkp_to_details_map_map.values():
			var key = details_map[VKP_DETAILS__KEY_AT_BAN_TIME_PERIOD]
			if event.scancode == key:
				get_viewport().set_input_as_handled()
				emit_signal("attempted_key_pressed", event.scancode)
				break
		
	
	if is_mouse_mov_disabled and event is InputEventMouseMotion:
		emit_signal("attempted_mouse_motion")

#

func ban_key_associated_with_vkp(arg_vkp):
	make_control_mod_a_fade(arg_vkp)
	
	var key = GameSettingsManager.get_game_control_hotkey__as_string(arg_vkp.game_control_action_name)
	
	var details_map = vkp_to_details_map_map[arg_vkp]
	details_map[VKP_DETAILS__IS_BANNED] = true
	details_map[VKP_DETAILS__KEY_AT_BAN_TIME_PERIOD] = GameSettingsManager.get_game_control_hotkey__as_string(arg_vkp.game_control_action_name)
	
	emit_signal("keys_banned_changed", key, true)

func unban_key_associated_with_vkp(arg_vkp):
	make_control_mod_a_unfade(arg_vkp)
	
	var details_map = vkp_to_details_map_map[arg_vkp]
	details_map[VKP_DETAILS__IS_BANNED] = false
	
	emit_signal("keys_banned_changed", details_map[VKP_DETAILS__KEY_AT_BAN_TIME_PERIOD], false)


##

func _ready():
	_make_all_relevant_controls_respond_rotate_with_cam_manager()
	_init_associate_pca_to_vkp__at_ready()

func _init_associate_pca_to_vkp__at_ready():
	_associate_pca_to_vkp__and_config_with_vkp(pca_rewind, vkp_rewind)
	_associate_pca_to_vkp__and_config_with_vkp(pca_ball_launch, vkp_ball_launch)
	_associate_pca_to_vkp__and_config_with_vkp(pca_left, vkp_left)
	_associate_pca_to_vkp__and_config_with_vkp(pca_right, vkp_right)
	_associate_pca_to_vkp__and_config_with_vkp(pca_stop, vkp_stop)
	_associate_pca_to_vkp__and_config_with_vkp(pca_zoom, vkp_zoom)

func _make_all_relevant_controls_respond_rotate_with_cam_manager():
	for control in all_displaying_controls:
		CameraManager.make_control_node_rotate_with_camera(control)


func _associate_pca_to_vkp__and_config_with_vkp(arg_pca : PlayerCaptureAreaRegion, arg_vkp : VisualKeyPress):
	arg_pca.connect("region_area_captured", self, "_on_pca_region_area_captured", [arg_vkp])
	arg_pca.connect("region_area_uncaptured", self, "_on_pca_region_area_uncaptured", [arg_vkp])
	
	vkp_to_details_map_map[arg_vkp] = {
		VKP_DETAILS__IS_BANNED : false,
		VKP_DETAILS__KEY_AT_BAN_TIME_PERIOD : 0,
	}

func _on_pca_region_area_captured(arg_vkp):
	ban_key_associated_with_vkp(arg_vkp)

func _on_pca_region_area_uncaptured(arg_vkp):
	unban_key_associated_with_vkp(arg_vkp)



#########


func _on_Pickupables_Coin_collected_by_player():
	_disable_mouse_movement_by_custom_rule()

func _on_Pickupables_Coin_uncollected_by_player():
	_reenable_mouse_movement_by_custom_rule()


func _disable_mouse_movement_by_custom_rule():
	is_mouse_mov_disabled = true
	last_mouse_angle = player_modi_launch_ball.get_angle_to_use_for_ball_launch()
	player_modi_launch_ball.custom_mouse_angle = last_mouse_angle
	
	player_modi_launch_ball.is_override_mouse_angle = true
	MouseManager.set_input_mouse_mode__via_reservation(MouseManager.InputMouseModeReserveId.CUSTOM_FROM_WORLD_SLICE, Input.MOUSE_MODE_CAPTURED)
	
	make_control_mod_a_fade(mouse_press_visual_tex_rect)

func _reenable_mouse_movement_by_custom_rule():
	is_mouse_mov_disabled = false
	
	player_modi_launch_ball.is_override_mouse_angle = false
	MouseManager.remove_input_mouse_reservation_id(MouseManager.InputMouseModeReserveId.CUSTOM_FROM_WORLD_SLICE)
	
	make_control_mod_a_unfade(mouse_press_visual_tex_rect)


##

func make_control_mod_a_fade(arg_control):
	var tweener = create_tween()
	tweener.tween_property(arg_control, "modulate:a", 0.3, 1.0)

func make_control_mod_a_unfade(arg_control):
	var tweener = create_tween()
	tweener.tween_property(arg_control, "modulate:a", 1.0, 1.0)
	


