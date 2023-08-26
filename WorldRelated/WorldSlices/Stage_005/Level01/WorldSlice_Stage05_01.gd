extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")


#

var _speed_for_break

onready var toughened_glass_tileset = $TileContainer/BaseTileSet_StrongGlass

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	

#########

func _on_PDAR_TriggerDialog_01_player_entered_in_area():
	_start_dialog__01()

func _start_dialog__01():
	var dialog_desc = [
		["You're near one of our outposts!", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()


func _on_PDAR_TriggerDialog_02_player_entered_in_area():
	_start_dialog__02()

func _start_dialog__02():
	var plain_fragment__toughened_glass = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.BREAKABLE_TILES, "toughened glass")
	
	_speed_for_break = ceil(toughened_glass_tileset.momentum_breaking_point / toughened_glass_tileset.get_player().last_calculated_object_mass)
	var plain_fragment__speed_to_break = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.SPEED, "%s speed" % (_speed_for_break))
	
	var dialog_desc = [
		["You have to break through the |0|!", [plain_fragment__toughened_glass]],
		["You'll need |0| to break through.", [plain_fragment__speed_to_break]]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()



func _on_PDAT_EndDialog02_player_entered_in_area():
	_end_dialog__02()

func _end_dialog__02():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	
	



#####

func _on_PDAR_TriggerDialog03_player_entered_in_area():
	_start_dialog__03()
	


func _start_dialog__03():
	#var plain_fragment__speed_to_break = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.SPEED, "%s speed" % (_speed_for_break))
	
	var dialog_desc = [
		["Use balls and portals to build up speed!", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__03", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__03(arg_metadata):
	_end_dialog__03()

func _end_dialog__03():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	

##############

func _on_PDAR_TriggerDialog04_player_entered_in_area():
	_start_dialog__04()

func _start_dialog__04():
	var dialog_desc = [
		["Congratulations! You've made it in!", []],
		["Through a portal, you'll be able to go back to the escape pod.", []]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__04", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 3.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__04():
	_end_dialog__04()

func _end_dialog__04():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	

#


func _on_CDSU_MegaBattery_player_entered_self__custom_defined():
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Pickupable_RemoteControl, 1.0, null)
	
	_on_pickup_mega_battery()
	_start_battery_pickup_dialog__01()

func _start_battery_pickup_dialog__01():
	var dialog_desc = [
		["With the MEGA battery, you can store LOTS of energy!", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_battery_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_battery_desc_finished__01(arg_metadata):
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	call_deferred("_deferred_finish_battery_desc_display_01")

func _deferred_finish_battery_desc_display_01():
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()


func _on_pickup_mega_battery():
	var energy_modi = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	energy_modi.set_properties__as_mega_battery()
	


#####

func _on_Portal_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	StoreOfLevels.unlock_and_goto_stage_05_level_02_on_win()
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	
	






