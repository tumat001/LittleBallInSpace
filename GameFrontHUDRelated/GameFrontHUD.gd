extends CanvasLayer


onready var other_hosters = $OtherHosters
onready var other_hud_non_screen_hosters = $OtherHUDNonScreenHosters

onready var ability_panel = $ControlContainer/AbilityPanel
onready var energy_panel = $ControlContainer/VBoxContainer/MarginContainer/EnergyPanel
onready var rewind_panel = $ControlContainer/RewindPanel
onready var health_panel = $ControlContainer/VBoxContainer/HealthPanel
onready var speed_panel = $ControlContainer/SpeedPanel
onready var trophy_panel = $ControlContainer/TopRightPanel/VBox/TrophyPanel
onready var robot_health_panel = $ControlContainer/VBoxContainer/RobotHealthPanel
onready var enemy_monitor_panel = $ControlContainer/TopRightPanel/VBox/EnemyMonitorPanel

onready var game_dialog_panel = $ControlContainer/GameDialogPanel

onready var tooltip_container = $TooltipContainer

onready var vic_def_anim_container = $VicDefAnimContainer
onready var coins_panel = $ControlContainer/TopRightPanel/VBox/CoinsPanel
onready var pcar_captured_panel = $ControlContainer/TopRightPanel/VBox/PCARCapturedPanel

onready var non_gui_screen_sprite = $NonGUIScreenShaderSprite


onready var in_game_pause_panel_tree = $InGamePausePanelTree

onready var out_of_map_bounds_warning_panel = $OutOfMapBoundsWarningPanel

#

onready var misc_center_container = $MiscCenterContainer

onready var sprite_shader_container = $SpriteShaderContainer

onready var gfh_control_focuser = $GFH_ControlFocuserDrawer

#

onready var control_container = $ControlContainer

####

func add_node_to_other_hosters(arg_node : Node):
	other_hosters.add_child(arg_node)
	

func add_node_to_other_hosters__deferred(arg_node : Node):
	other_hosters.call_deferred("add_child", arg_node)
	

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
	


############

func set_control_container_visibility(arg_val : bool, arg_use_tween : bool = false, arg_duration : float = 1.0):
	#control_container.visible = arg_val
	_set_control_container_vis__internal(arg_val, arg_use_tween, arg_duration)
	
	if arg_val:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

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
		
	

func _on_mod_a_tweener_finished__going_to_0():
	control_container.visible = false

