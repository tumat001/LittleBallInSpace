extends CanvasLayer


onready var other_hosters = $OtherHosters

onready var ability_panel = $ControlContainer/AbilityPanel
onready var energy_panel = $ControlContainer/EnergyPanel
onready var rewind_panel = $ControlContainer/RewindPanel

###

func add_node_to_other_hosters(arg_node : Node):
	other_hosters.add_child(arg_node)
	

func add_node_to_other_hosters__deferred(arg_node : Node):
	other_hosters.call_deferred("add_child", arg_node)
	

