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

###

func add_node_to_other_hosters(arg_node : Node):
	other_hosters.add_child(arg_node)
	

func add_node_to_other_hosters__deferred(arg_node : Node):
	other_hosters.call_deferred("add_child", arg_node)
	

#

func add_node_to_tooltip_container(arg_node : Node):
	tooltip_container.add_child(arg_node)
	

#

func add_vic_def_anim(arg_anim):
	#vic_def_anim_container.add_child(arg_anim)
	arg_anim.connect("ready_finished", self, "_on_vic_def_anim_ready_finished", [arg_anim])
	vic_def_anim_container.call_deferred("add_child", arg_anim)
	

func _on_vic_def_anim_ready_finished(arg_anim):
	arg_anim.start_show()

#

func _ready():
	coins_panel.configure_self_to_monitor_coin_status_for_level(SingletonsAndConsts.current_base_level_id)
	


