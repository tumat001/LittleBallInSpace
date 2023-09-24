extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")
const StoreOfVicDefAnim = preload("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/StoreOfVicDefAnim.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")



var _is_first_time_playing_this_lvl : bool

var _spaceship_tile_broken : bool
var _started_dialog_for_spaceship_tile_break : bool

var _triggered_warning_for_next_energy_being_far_away : bool

#

onready var spaceship_breakable_tileset = $TileContainer/BaseTileSet_SpaceshipBreakable

###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	is_player_capture_area_style_one_at_a_time__in_node_order = true


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	
	if !GameSaveManager.is_level_id_finished(StoreOfLevels.LevelIds.LEVEL_02__STAGE_5):
		_is_first_time_playing_this_lvl = true
		SingletonsAndConsts.current_base_level.anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.NONE
		SingletonsAndConsts.current_level_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_FADE__BLACK__LONG
		#SingletonsAndConsts.interrupt_return_to_screen_layout_panel__go_directly_to_level = true
		
	else:
		_is_first_time_playing_this_lvl = false
		SingletonsAndConsts.current_base_level.anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
		SingletonsAndConsts.current_level_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	
	
	game_elements.get_current_player().is_show_lines_to_uncaptured_player_capture_regions = true

#########

func _on_PDAR_Dialog01_player_entered_in_area():
	_start_dialog__01()

func _start_dialog__01():
	var dialog_desc = [
		["This outpost has gotten even more damaged!", []],
		["Follow the capture points to navigate this spaceship.", []]
	]
	
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__01(arg_metadata):
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	
	make_first_pca_region_visible()


func _on_PDAR_Dialog01Ender_player_entered_in_area():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	

####


func _on_PCA_02_region_area_captured():
	if !_triggered_warning_for_next_energy_being_far_away:
		_triggered_warning_for_next_energy_being_far_away = true
		
		var plain_fragment__energized_tiles = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.ENERGIZED_TILES, "energized tiles")
		
		var dialog_desc = [
			["The next |0| are pretty far away! Proceed with haste.", [plain_fragment__energized_tiles]]
		]
		
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__haste_warning_01", [], CONNECT_ONESHOT)
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 4.0, null)
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__haste_warning_01(arg_metadata):
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	


#########

func _on_BaseTileSet_SpaceshipBreakable_tile_broken_via_player_and_speed():
	_spaceship_tile_broken = true
	
	if _started_dialog_for_spaceship_tile_break:
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
		


func _on_PCA_06_region_area_captured():
	if !_spaceship_tile_broken:
		_start_spaceship_tile_break_dialog__01()


func _start_spaceship_tile_break_dialog__01():
	if !_started_dialog_for_spaceship_tile_break:
		_started_dialog_for_spaceship_tile_break = true
		
		
		var plain_fragment__wall = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.BREAKABLE_TILES, "break the weakened wall")
		
		var speed_for_break = ceil(spaceship_breakable_tileset.momentum_breaking_point / spaceship_breakable_tileset.get_player().last_calculated_object_mass)
		var plain_fragment__speed_to_break = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.SPEED, "%s speed" % (speed_for_break))
		
		
		var dialog_desc = [
			["You need to |0|.", [plain_fragment__wall]],
			["You'll need |0| to break it.", [plain_fragment__speed_to_break]]
		]
		
		#game_elements.ban_rewind_manager_to_store_and_cast_rewind()
		
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 2.0, 0, null)
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()


##########

func _on_PCA_Last_region_area_captured():
	if _is_first_time_playing_this_lvl:
		StoreOfLevels.unlock_relateds_after_winning_stage_05_level_02()
		
		SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
		
		game_elements.ban_rewind_manager_to_store_and_cast_rewind()
		
		SingletonsAndConsts.show_end_game_result_pre_hud = true
		
		call_deferred("_deferred_last_region_captured")

func _deferred_last_region_captured():
	SingletonsAndConsts.current_master.show_ending_summary_wsp()
	
	game_elements.game_result_manager.end_game__as_win()
	


#

func _on_PDAR_Breakthru_player_entered_in_area():
	var plain_fragment__energized_tiles = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.ENERGIZED_TILES, "energized tiles")
	
	var dialog_desc = [
		["Nice work!", []],
		["The next |0| are in the escape pod, so preserve your energy!", [plain_fragment__energized_tiles]]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 4.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()



