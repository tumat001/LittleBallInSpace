extends Control


const ENERGY_LABEL_STRING_FORMAT = "%s / %s"

#

var player_modi__energy setget set_player_modi__energy

#

onready var energy_label = $EnergyLabel

onready var texture_progress_current = $TextureProgressCurrent
onready var texture_progress_forcasted = $TextureProgressForcasted

#

func set_player_modi__energy(arg_modi):
	player_modi__energy = arg_modi
	
	player_modi__energy.connect("forecasted_or_current_energy_changed", self, "_on_modi_forecasted_or_current_energy_changed")
	player_modi__energy.connect("max_energy_changed", self, "_on_modi_max_energy_changed")
	
	if is_inside_tree():
		_update_display__for_max()
		_update_display__for_current_and_forecasted()
	
	visible = true


func _on_modi_forecasted_or_current_energy_changed(arg_curr, arg_forcasted):
	_update_display__for_current_and_forecasted()

func _update_display__for_current_and_forecasted():
	texture_progress_current.value = player_modi__energy.get_current_energy()
	texture_progress_forcasted.value = player_modi__energy.get_forcasted_energy()
	
	_update_label()


func _on_modi_max_energy_changed(arg_val):
	_update_display__for_max()
	

func _update_display__for_max():
	texture_progress_current.max_value = player_modi__energy.get_max_energy()
	texture_progress_forcasted.max_value = player_modi__energy.get_max_energy()
	
	_update_label()

#

func _update_label():
	var curr_energy = ceil(player_modi__energy.get_current_energy())
	var max_energy = ceil(player_modi__energy.get_max_energy())
	
	energy_label.text = ENERGY_LABEL_STRING_FORMAT % [curr_energy, max_energy]


#

func _ready():
	if player_modi__energy != null:
		_update_display__for_max()
		_update_display__for_current_and_forecasted()
		visible = true
	else:
		visible = false
