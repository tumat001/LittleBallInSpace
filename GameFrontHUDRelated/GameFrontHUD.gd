extends CanvasLayer

#

signal in_game_pause_control_tree_opened()
signal in_game_pause_control_tree_closed()


#

var is_showing_in_game_pause_panel_tree : bool = false

#

var _adjusted_pos_node_container__above_other_hosters : Node2D
var _adjusted_node_to_in_GE_node_map : Dictionary
var _half_screen_size = SingletonsAndConsts.current_master.screen_size / 2

var _control_container_above_control_container : Control

onready var other_hosters = $OtherHosters
onready var above_other_hosters = $AboveOtherHosters
onready var other_hud_non_screen_hosters = $OtherHUDNonScreenHosters

onready var ability_panel = $ControlContainer/HUDCMH_AbilityPanel/AbilityPanel
onready var energy_panel = $ControlContainer/HUDCMH_TopMidPanel/VBoxContainer/MarginContainer/EnergyPanel
onready var rewind_panel = $ControlContainer/RewindPanel
onready var health_panel = $ControlContainer/HUDCMH_TopMidPanel/VBoxContainer/HealthPanel
onready var speed_panel = $ControlContainer/HUDCMH_SpeedPanel/SpeedPanel
onready var trophy_panel = $ControlContainer/TopRightPanel/HUDCMH_TopRightPanel/VBox/TrophyPanel
onready var robot_health_panel = $ControlContainer/HUDCMH_TopMidPanel/VBoxContainer/RobotHealthPanel
#onready var enemy_monitor_panel = $ControlContainer/TopRightPanel/HUDCMH_TopRightPanel/VBox/EnemyMonitorPanel

onready var game_dialog_panel = $ControlContainer/HUDCMH_GameDialogPanel/GameDialogPanel

onready var tooltip_container = $TooltipContainer

onready var vic_def_anim_container = $VicDefAnimContainer
onready var coins_panel = $ControlContainer/TopRightPanel/HUDCMH_TopRightPanel/VBox/CoinsPanel
onready var pcar_captured_panel = $ControlContainer/TopRightPanel/HUDCMH_TopRightPanel/VBox/PCARCapturedPanel

onready var non_gui_screen_sprite = $NonGUIScreenShaderSprite


onready var in_game_pause_panel_tree = $InGamePausePanelTree

onready var out_of_map_bounds_warning_panel = $OutOfMapBoundsWarningPanel

#

onready var HUDCMH_speed_panel = $ControlContainer/HUDCMH_SpeedPanel
onready var HUDCMH_top_right_panel = $ControlContainer/TopRightPanel/HUDCMH_TopRightPanel
onready var HUDCMH_ability_panel = $ControlContainer/HUDCMH_AbilityPanel
onready var HUDCMH_top_mid_panel = $ControlContainer/HUDCMH_TopMidPanel
onready var HUDCMH_game_dialog_panel = $ControlContainer/HUDCMH_GameDialogPanel

onready var all_HUDCMH = [
	HUDCMH_speed_panel,
	HUDCMH_top_right_panel,
	HUDCMH_ability_panel,
	HUDCMH_top_mid_panel,
	HUDCMH_game_dialog_panel,
	
]

#

onready var misc_center_container = $MiscCenterContainer

onready var sprite_shader_container = $SpriteShaderContainer

onready var gfh_control_focuser = $GFH_ControlFocuserDrawer

#

onready var control_container = $ControlContainer

####

func add__is_activated__clause_for_all_HUDCMH(arg_clause_id):
	for hudcmh in all_HUDCMH:
		hudcmh.is_activated_cond_clause.attempt_insert_clause(arg_clause_id)
	

func remove__is_activated__clause_for_all_HUDCMH(arg_clause_id):
	for hudcmh in all_HUDCMH:
		hudcmh.is_activated_cond_clause.remove_clause(arg_clause_id)
	



#

func add_node_to_other_hosters(arg_node : Node):
	other_hosters.add_child(arg_node)

func add_node_to_other_hosters__deferred(arg_node : Node):
	other_hosters.call_deferred("add_child", arg_node)


func add_node_to_above_other_hosters(arg_node : Node):
	above_other_hosters.add_child(arg_node)

func add_node_to_above_other_hosters__deferred(arg_node : Node):
	above_other_hosters.call_deferred("add_child", arg_node)


##

func add_node_to_tooltip_container(arg_node : Node):
	tooltip_container.add_child(arg_node)
	

##

func add_vic_def_anim(arg_anim):
	#vic_def_anim_container.add_child(arg_anim)
	arg_anim.connect("ready_finished", self, "_on_vic_def_anim_ready_finished", [arg_anim])
	vic_def_anim_container.call_deferred("add_child", arg_anim)
	

func _on_vic_def_anim_ready_finished(arg_anim):
	arg_anim.start_show()

#

func _ready():
	coins_panel.configure_self_to_monitor_coin_status_for_curr_level_tentative()
	energy_panel.player_health_panel = health_panel
	
	pcar_captured_panel.configure_self_to_monitor_curr_world_manager()
	
	_config_with_in_game_pause_panel_tree()


func _config_with_in_game_pause_panel_tree():
	in_game_pause_panel_tree.connect("hierarchy_emptied", self, "_on_control_tree_hierarchy_emptied")
	in_game_pause_panel_tree.connect("hierarchy_advanced_forwards", self, "_on_control_tree_hierarchy_advanced_forwards")


func _on_control_tree_hierarchy_emptied():
	is_showing_in_game_pause_panel_tree = false
	
	emit_signal("in_game_pause_control_tree_closed")

func _on_control_tree_hierarchy_advanced_forwards(arg_control):
	if !is_showing_in_game_pause_panel_tree:
		is_showing_in_game_pause_panel_tree = true
		emit_signal("in_game_pause_control_tree_opened")
	


##################

func show_in_game_pause_control_tree():
	set_control_container_visibility(true)
	in_game_pause_panel_tree.show_in_game_pause_main_page()
	

func hide_in_game_pause_control_tree():
	in_game_pause_panel_tree.hide_current_control__and_traverse_thru_hierarchy(false)
	

#

func show_warning_out_of_map_bounds():
	out_of_map_bounds_warning_panel.show_self()
	

func hide_warning_out_of_map_bounds():
	out_of_map_bounds_warning_panel.hide_self()
	

####

func create_sprite_shader(arg_material) -> Sprite:
	var sprite = Sprite.new()
	sprite.texture = preload("res://GameElements/ScreenShaderSprite/ScreenShaderSprite.png")
	sprite.material = arg_material
	sprite.visible = false
	sprite.position = Vector2(960, 540)
	sprite.scale = Vector2(960, 540)
	
	sprite_shader_container.add_child(sprite)
	
	return sprite

#######

func template__start_focus_on_energy_panel__with_glow_up(arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params):
	var ending_metadata = [arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params]
	
	gfh_control_focuser.modulate.a = 0
	gfh_control_focuser.focus_draw_on_control(energy_panel, 15)
	gfh_control_focuser.start_mod_a_tween(1.0, 0.7, 0.4, self, "_on_ghf_mod_a_to_1_finished__focus_on_energy_panel", ending_metadata)

func _on_ghf_mod_a_to_1_finished__focus_on_energy_panel(arg_ending_metadata):
	energy_panel.template__do_brief_glowup(0.6, self, "_on_energy_panel__done_glowup__focus_on_energy_panel", arg_ending_metadata)

func _on_energy_panel__done_glowup__focus_on_energy_panel(arg_ending_metadata):
	gfh_control_focuser.start_mod_a_tween(0.0, 0.7, 0.4 + arg_ending_metadata[0], self, "_on_ghf_mod_a_to_0_finished__focus_on_energy_panel", arg_ending_metadata)


func _on_ghf_mod_a_to_0_finished__focus_on_energy_panel(arg_ending_metadata):
	var func_source = arg_ending_metadata[1]
	var func_name = arg_ending_metadata[2]
	var func_params = arg_ending_metadata[3]
	
	func_source.call(func_name, func_params)


##

func template__start_focus_on_launch_ball_panel__with_glow_up(arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params):
	var ending_metadata = [arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params]
	
	gfh_control_focuser.modulate.a = 0
	gfh_control_focuser.focus_draw_on_control(ability_panel.launch_ball_ability_panel, 15)
	gfh_control_focuser.start_mod_a_tween(1.0, 0.7, 0.4, self, "_on_ghf_mod_a_to_1_finished__focus_on_launch_ball_panel", ending_metadata)

func _on_ghf_mod_a_to_1_finished__focus_on_launch_ball_panel(arg_ending_metadata):
	ability_panel.launch_ball_ability_panel.template__do_brief_glowup(0.6, self, "_on_launch_ball_panel__done_glowup__focus_on_launch_ball_panel", arg_ending_metadata)

func _on_launch_ball_panel__done_glowup__focus_on_launch_ball_panel(arg_ending_metadata):
	gfh_control_focuser.start_mod_a_tween(0.0, 0.7, 0.4 + arg_ending_metadata[0], self, "_on_ghf_mod_a_to_0_finished__focus_on_launch_ball_panel", arg_ending_metadata)

func _on_ghf_mod_a_to_0_finished__focus_on_launch_ball_panel(arg_ending_metadata):
	var func_source = arg_ending_metadata[1]
	var func_name = arg_ending_metadata[2]
	var func_params = arg_ending_metadata[3]
	
	func_source.call(func_name, func_params)
	

#

#func template__start_focus_on_launch_ball_panel__with_glow_up(arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params):
#	var ending_metadata = [arg_delay_for_func_call, arg_func_source, arg_func_name, arg_func_params]
#
#	gfh_control_focuser.modulate.a = 0
#	gfh_control_focuser.focus_draw_on_control(ability_panel.launch_ball_ability_panel, 15)
#	gfh_control_focuser.start_mod_a_tween(1.0, 0.7, 0.4, self, "_on_ghf_mod_a_to_1_finished__focus_on_launch_ball_panel", ending_metadata)
#
#func _on_ghf_mod_a_to_1_finished__focus_on_launch_ball_panel(arg_ending_metadata):
#	ability_panel.launch_ball_ability_panel.template__do_brief_glowup(0.6, self, "_on_launch_ball_panel__done_glowup__focus_on_launch_ball_panel", arg_ending_metadata)
#
#func _on_launch_ball_panel__done_glowup__focus_on_launch_ball_panel(arg_ending_metadata):
#	gfh_control_focuser.start_mod_a_tween(0.0, 0.7, 0.4 + arg_ending_metadata[0], self, "_on_ghf_mod_a_to_0_finished__focus_on_launch_ball_panel", arg_ending_metadata)
#
#func _on_ghf_mod_a_to_0_finished__focus_on_launch_ball_panel(arg_ending_metadata):
#	var func_source = arg_ending_metadata[1]
#	var func_name = arg_ending_metadata[2]
#	var func_params = arg_ending_metadata[3]
#
#	func_source.call(func_name, func_params)
#

############

func set_control_container_visibility(arg_val : bool, arg_use_tween : bool = false, arg_duration : float = 1.0, arg_hide_mouse_if_appropriate : bool = true):
	_set_control_container_vis__internal(arg_val, arg_use_tween, arg_duration)
	
	if arg_val:
		MouseManager.remove_input_mouse_reservation_id(MouseManager.InputMouseModeReserveId.GAME_FRONT_HUD)
	else:
		if arg_hide_mouse_if_appropriate:
			MouseManager.set_input_mouse_mode__via_reservation(MouseManager.InputMouseModeReserveId.GAME_FRONT_HUD, Input.MOUSE_MODE_HIDDEN)
		else:
			MouseManager.remove_input_mouse_reservation_id(MouseManager.InputMouseModeReserveId.GAME_FRONT_HUD)
	

func toggle_control_container_visibility__not_hides_mouse(arg_use_tween : bool = false, arg_duration : float = 1.0):
	set_control_container_visibility(!control_container.visible, arg_use_tween, arg_duration, false)


func toggle_control_container_visibility(arg_use_tween : bool = false, arg_duration : float = 1.0):
	set_control_container_visibility(!control_container.visible, arg_use_tween, arg_duration)



func _set_control_container_vis__internal(arg_val, arg_use_tween, arg_duration):
	if arg_use_tween:
		_set_control_container_vis__via_tween(arg_val, arg_duration)
		
	else:
		control_container.visible = arg_val
		control_container.modulate.a = 1
	

func _set_control_container_vis__via_tween(arg_vis, arg_duration):
	if arg_vis:
		if !control_container.visible:
			control_container.modulate.a = 0
		control_container.visible = arg_vis
		
		var tweener = create_tween()
		tweener.tween_property(control_container, "modulate:a", 1.0, arg_duration)
		###
		
	else: # going invis
		var tweener = create_tween()
		tweener.connect("finished", self, "_on_mod_a_tweener_finished__going_to_0", [], CONNECT_ONESHOT)
		tweener.tween_property(control_container, "modulate:a", 0.0, arg_duration)
		


func external__set_control_container_mod_a(arg_mod_a):
	control_container.modulate.a = arg_mod_a


func _on_mod_a_tweener_finished__going_to_0():
	control_container.visible = false



func add_custom_control_in_container(arg_control, arg_index = 0):
	control_container.add_child(arg_control)
	control_container.move_child(arg_control, arg_index)


#############

############################################
#_adjusted_pos_node_container__above_other_hosters relateds

func init_adjusted_pos_node_container__above_other_hosters():
	_adjusted_pos_node_container__above_other_hosters = Node2D.new()
	add_child(_adjusted_pos_node_container__above_other_hosters)
	move_child(_adjusted_pos_node_container__above_other_hosters, above_other_hosters.get_index())

func add_node_to_adjusted_pos_node_container(arg_node, arg_node_to_follow_in_GE):
	_adjusted_node_to_in_GE_node_map[arg_node] = arg_node_to_follow_in_GE
	_adjusted_pos_node_container__above_other_hosters.add_child(arg_node)
	set_process(true)

func _process(delta):
	var cam_screen_center = CameraManager.camera.get_camera_screen_center()
	for adjusted_node in _adjusted_node_to_in_GE_node_map.keys():
		var in_GE_node = _adjusted_node_to_in_GE_node_map[adjusted_node]
		
		var pos_in_hud = in_GE_node.global_position - cam_screen_center + _half_screen_size
		adjusted_node.global_position = pos_in_hud


#func get_adjusted_pos_in_hud__of_pos(arg_in_GE_node_pos : Vector2):
#	return arg_in_GE_node_pos - cam_screen_center + _half_screen_size
#

#########################
# control above other controls

func init_control_container_above_control_container():
	_control_container_above_control_container = Control.new()
	add_child(_control_container_above_control_container)
	move_child(_control_container_above_control_container, control_container.get_index())
	
	_control_container_above_control_container.rect_size = SingletonsAndConsts.current_master.screen_size
	_control_container_above_control_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

func add_node_to_control_container_above_control_container(arg_node):
	_control_container_above_control_container.add_child(arg_node)


