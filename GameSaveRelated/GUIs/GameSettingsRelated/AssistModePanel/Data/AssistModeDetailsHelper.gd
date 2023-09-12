extends Reference

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
const PlayerGUI_HOptionSelection = preload("res://MiscRelated/GUIControlsRelated/PlayerGUI_HOptionSelector/PlayerGUI_HOptionSelector.gd")

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")

#

const ADDITIONAL_LAUNCH_BALL_FORMAT_STRING = "%s launch ball%s on level start."

##

var assist_mode_id_to_item_arr_map : Dictionary

var assist_mode__additional_energy_mode_id_item_arr : Array
var assist_mode__energy_reduction_mode_id_item_arr : Array
var assist_mode__additional_launch_ball_mode_id_item_arr : Array
var assist_mode__pause_at_esc_id_item_arr : Array


#var assist_mode__toggle_active_mode_id_to_desc_map : Dictionary = {}
#var assist_mode__additional_energy_mode_id_to_desc_map : Dictionary = {}
#var assist_mode__energy_reduction_mode_id_to_desc_map : Dictionary = {}
#var assist_mode__additional_launch_ball_mode_id_to_desc_map : Dictionary = {}
#var assist_mode__pause_at_esc_id_to_desc_map : Dictionary = {}

#

func _init():
	_init_hoption_standard_select_items__for_all()
	#_init_descriptions()

#

func _init_hoption_standard_select_items__for_all():
	_init_hoption_standard_select_items__for_additional_energy_mode()
	_init_hoption_standard_select_items__for_energy_reduc_mode()
	_init_hoption_standard_select_items__for_additional_launch_ball_mode()
	_init_hoption_standard_select_items__for_pause_at_esc_mode()
	
	_init_assist_mode_id_to_list_map()

func _init_hoption_standard_select_items__for_additional_energy_mode():
	for id in GameSettingsManager.AssistMode_AdditionalEnergyModeId.values():
		var energy_amount = GameSettingsManager.assist_mode__additional_energy_mode_id__details_map[id]
		
		var select_list_item = PlayerGUI_HOptionSelection.SelectorItem.new()
		select_list_item.id = id
		select_list_item.display_value = str(energy_amount)
		assist_mode__additional_energy_mode_id_item_arr.append(select_list_item)

func _init_hoption_standard_select_items__for_energy_reduc_mode():
	_construct_true_false_select_item_for_arr(assist_mode__energy_reduction_mode_id_item_arr, GameSettingsManager.AssistMode_EnergyReductionModeId.INFINITE, GameSettingsManager.AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL, GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE)


func _init_hoption_standard_select_items__for_additional_launch_ball_mode():
	for id in GameSettingsManager.AssistMode_AdditionalLaunchBallModeId.values():
		var modi_details : Array = GameSettingsManager.assist_mode__additional_launch_ball_mode_id__details_map[id]
		var is_infinite = modi_details[1]
		var select_list_item = PlayerGUI_HOptionSelection.SelectorItem.new()
		select_list_item.id = id
		
		if is_infinite:
			select_list_item.display_value = "Infinite"
		else:
			select_list_item.display_value = str(modi_details[0])
		
		assist_mode__additional_launch_ball_mode_id_item_arr.append(select_list_item)


func _init_hoption_standard_select_items__for_pause_at_esc_mode():
	_construct_true_false_select_item_for_arr(assist_mode__pause_at_esc_id_item_arr, GameSettingsManager.AssistMode_PauseAtESCModeId.PAUSE, GameSettingsManager.AssistMode_PauseAtESCModeId.NO_PAUSE, GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE)


func _init_assist_mode_id_to_list_map():
	assist_mode_id_to_item_arr_map[GameSettingsManager.AssistModeId.ADDITIONAL_ENERGY_MODE] = assist_mode__additional_energy_mode_id_item_arr
	assist_mode_id_to_item_arr_map[GameSettingsManager.AssistModeId.ENERGY_REDUC_MODE] = assist_mode__energy_reduction_mode_id_item_arr
	assist_mode_id_to_item_arr_map[GameSettingsManager.AssistModeId.ADDITIONAL_LAUNCH_BALL_MODE] = assist_mode__additional_launch_ball_mode_id_item_arr
	assist_mode_id_to_item_arr_map[GameSettingsManager.AssistModeId.PAUSE_AT_ESC_MODE] = assist_mode__pause_at_esc_id_item_arr
	

# helpers

func _construct_true_false_select_item_for_arr(arg_arr, arg_id_for_true, arg_id_for_false, arg_id_of_assist_mode):
	var select_item__true = PlayerGUI_HOptionSelection.SelectorItem.new()
	select_item__true.id = arg_id_for_true
	select_item__true.display_value = "On"
	arg_arr.append(select_item__true)
	
	var select_item__false = PlayerGUI_HOptionSelection.SelectorItem.new()
	select_item__false.id = arg_id_for_false
	select_item__false.display_value = "Off"
	arg_arr.append(select_item__false)
	
	assist_mode_id_to_item_arr_map[arg_id_of_assist_mode] = arg_arr


# accessors

func get_select_item_list_of_assist_mode_id(arg_id):
	return assist_mode_id_to_item_arr_map[arg_id]

#####################
# DESCS
#####################
#
#func _init_descriptions():
#	assist_mode__toggle_active_mode_id_to_desc_map[GameSettingsManager.AssistMode_ToggleActiveModeId.FOR_THIS_LEVEL_ONLY] = [
#		"Assist Mode will turn off after this level."
#	]
#	assist_mode__toggle_active_mode_id_to_desc_map[GameSettingsManager.AssistMode_ToggleActiveModeId.FOR_ALL_LEVELS] = [
#		"Assist Mode will stay turned on unless manually turned off."
#	]
#
#	##
#	for id in GameSettingsManager.AssistMode_AdditionalEnergyModeId.values():
#		_add_entry_for_additional_energy_mode_id_in_desc_map(id)
#
#	##
#
#	assist_mode__energy_reduction_mode_id_to_desc_map[GameSettingsManager.AssistMode_EnergyReductionModeId.REDUCABLE__NORMAL] = [
#		"Energy can be reduced."
#	]
#	assist_mode__energy_reduction_mode_id_to_desc_map[GameSettingsManager.AssistMode_EnergyReductionModeId.INFINITE] = [
#		"Energy is infinite and cannot be reduced."
#	]
#
#	##
#
#	for id in GameSettingsManager.AssistMode_AdditionalLaunchBallModeId.values():
#		_add_entry_for_additional_launch_ball_mode_id_in_desc_map(id)
#
#	##
#
#	assist_mode__pause_at_esc_id_to_desc_map[GameSettingsManager.AssistMode_PauseAtESCModeId.NO_PAUSE] = [
#		"Game is NOT paused when on the game menu screen."
#	]
#	assist_mode__pause_at_esc_id_to_desc_map[GameSettingsManager.AssistMode_PauseAtESCModeId.PAUSE] = [
#		"Game is paused when on the game menu screen."
#	]
#
#
#func _add_entry_for_additional_energy_mode_id_in_desc_map(arg_id):
#	assist_mode__additional_energy_mode_id_to_desc_map[arg_id] = [
#		"+%s Energy" % GameSettingsManager.get_assist_mode__additional_energy_amount_from_id(arg_id)
#	]
#
#func _add_entry_for_additional_launch_ball_mode_id_in_desc_map(arg_id):
#	var modi_details = GameSettingsManager.assist_mode__additional_launch_ball_mode_id__details_map[arg_id]
#	var is_infinite = modi_details[1]
#
#	if is_infinite:
#		assist_mode__additional_launch_ball_mode_id_to_desc_map[arg_id] = ADDITIONAL_LAUNCH_BALL_FORMAT_STRING % ["Infinite", "s"]
#
#	else:
#		var ball_count = modi_details[0]
#
#		var plural_s_str
#		if ball_count == 1:
#			plural_s_str = ""
#		else:
#			plural_s_str = str(ball_count)
#
#		assist_mode__additional_launch_ball_mode_id_to_desc_map[arg_id] = ADDITIONAL_LAUNCH_BALL_FORMAT_STRING % [str(ball_count), plural_s_str]

