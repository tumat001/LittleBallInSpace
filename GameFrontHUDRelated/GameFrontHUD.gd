extends CanvasLayer


onready var other_hosters = $OtherHosters

onready var ability_panel = $ControlContainer/AbilityPanel
onready var energy_panel = $ControlContainer/VBoxContainer/MarginContainer/EnergyPanel
onready var rewind_panel = $ControlContainer/RewindPanel
onready var health_panel = $ControlContainer/VBoxContainer/HealthPanel
onready var speed_panel = $ControlContainer/SpeedPanel
onready var trophy_panel = $ControlContainer/TopRightPanel/VBox/TrophyPanel
onready var robot_health_panel = $ControlContainer/VBoxContainer/RobotHealthPanel
onready var game_dialog_panel = $ControlContainer/GameDialogPanel

onready var tooltip_container = $TooltipContainer

onready var vic_def_anim_container = $VicDefAnimContainer
onready var coins_panel = $ControlContainer/TopRightPanel/VBox/CoinsPanel

onready var non_gui_screen_sprite = $NonGUIScreenShaderSprite


onready var in_game_pause_panel_tree = $InGamePausePanelTree

onready var out_of_map_bounds_warning_panel = $OutOfMapBoundsWarningPanel

#

onready var misc_center_container = $MiscCenterContainer

onready var sprite_shader_container = $SpriteShaderContainer

###

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
	coins_panel.configure_self_to_monitor_coin_status_for_level(SingletonsAndConsts.current_base_level_id)
	energy_panel.player_health_panel = health_panel

##################

func show_in_game_pause_control_tree():
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



