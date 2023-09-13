extends Control


const EnergyPanel_BatteryFillForeground_Normal = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground.png")
const EnergyPanel_BatteryFillForeground_Normal_Forecasted = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground_Forecasted.png")
const EnergyPanel_BatteryFillForeground_Mega = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground__MegaBattery.png")
const EnergyPanel_BatteryFillForeground_Mega_Forecasted = preload("res://GameFrontHUDRelated/Subs/EnergyPanel/Assets/EnegyPanel_BatteryFillForeground_Forecasted__MegaBattery.png")

#

const ENERGY_LABEL_STRING_FORMAT = "%s / %s"

#

var player_modi__energy setget set_player_modi__energy

#

var original_rewind_reminder_text : String


var player_health_panel

#

onready var energy_label = $EnergyLabel

onready var texture_progress_current = $TextureProgressCurrent
onready var texture_progress_forcasted = $TextureProgressForcasted


onready var rewind_reminder_label = $RewindReminder

#

func set_player_modi__energy(arg_modi):
	player_modi__energy = arg_modi
	
	player_modi__energy.connect("forecasted_or_current_energy_changed", self, "_on_modi_forecasted_or_current_energy_changed")
	player_modi__energy.connect("max_energy_changed", self, "_on_modi_max_energy_changed")
	
	player_modi__energy.connect("discarged_to_zero_energy", self, "_on_discarged_to_zero_energy")
	player_modi__energy.connect("recharged_from_no_energy", self, "_on_recharged_from_no_energy")
	
	player_modi__energy.connect("battery_visual_type_id_changed", self, "_on_battery_visual_type_id_changed")
	
	GameSettingsManager.connect("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed")
	
	if is_inside_tree():
		_update_display__for_max()
		_update_display__for_current_and_forecasted()
		_update_bar_visual_based_on_type_id()
	
	
	_update_vis_based_on_modi()
	player_modi__energy.connect("allow_display_of_energy_hud_changed", self, "_on_allow_display_of_energy_hud_changed")
	
	_update_display_based_on_is_true_instant_drain()
	player_modi__energy.connect("is_true_instant_drain_and_recharge_changed", self, "_on_is_true_instant_drain_and_recharge_changed")




func _on_modi_forecasted_or_current_energy_changed(arg_curr, arg_forcasted):
	_update_display__for_current_and_forecasted()

func _update_display__for_current_and_forecasted():
	texture_progress_current.value = player_modi__energy.get_current_energy()
	texture_progress_forcasted.value = player_modi__energy.get_forecasted_energy()
	
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
	
	_initialize_rewind_reminder_label()

func _initialize_rewind_reminder_label():
	rewind_reminder_label.visible = false
	original_rewind_reminder_text = rewind_reminder_label.text
	#var corrected_text = orig_text % InputMap.get_action_list("rewind")[0].as_text()
	#rewind_reminder_label.text = corrected_text
	_update_rewind_reminder_label()

func _update_rewind_reminder_label():
	var text = original_rewind_reminder_text % GameSettingsManager.get_game_control_hotkey__as_string("rewind")
	rewind_reminder_label.text = text

func _on_game_control_hotkey_changed(arg_action_name, arg_old, arg_new):
	if arg_action_name == "rewind":
		_update_rewind_reminder_label()



func _on_discarged_to_zero_energy():
	rewind_reminder_label.visible = true
	

func _on_recharged_from_no_energy():
	rewind_reminder_label.visible = false
	


###

func _on_battery_visual_type_id_changed(arg_id):
	_update_bar_visual_based_on_type_id()
	

func _update_bar_visual_based_on_type_id():
	var id = player_modi__energy.battery_visual_type_id
	if id == player_modi__energy.BatteryVisualTypeId.STANDARD:
		texture_progress_current.texture_progress = EnergyPanel_BatteryFillForeground_Normal_Forecasted
		texture_progress_forcasted.texture_progress = EnergyPanel_BatteryFillForeground_Normal
		
	elif id == player_modi__energy.BatteryVisualTypeId.MEGA:
		texture_progress_current.texture_progress = EnergyPanel_BatteryFillForeground_Mega_Forecasted
		texture_progress_forcasted.texture_progress = EnergyPanel_BatteryFillForeground_Mega
		
	
	


#############

func _on_allow_display_of_energy_hud_changed(arg_val):
	_update_vis_based_on_modi()

func _update_vis_based_on_modi():
	visible = player_modi__energy.allow_display_of_energy_hud
	
	player_health_panel.can_display__by_energy_panel = player_modi__energy.allow_display_of_energy_hud

#

func _on_is_true_instant_drain_and_recharge_changed(arg_val):
	_update_display_based_on_is_true_instant_drain()

func _update_display_based_on_is_true_instant_drain():
	if player_modi__energy.is_true_instant_drain_and_recharge:
		energy_label.visible = false
		
	else:
		energy_label.visible = true
		
	

