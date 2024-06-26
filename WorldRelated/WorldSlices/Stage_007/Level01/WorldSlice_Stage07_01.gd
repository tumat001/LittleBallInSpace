extends "res://WorldRelated/AbstractWorldSlice.gd"

const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


#

onready var cdsu_anchor_hook = $ObjectContainer/CDSU_AnchorHook


#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	start_fade_out()


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CameraManager.set_current_default_zoom_out_vec(Vector2(1, 1))


#######


func _on_CDSU_AnchorHook_player_entered_self__custom_defined():
	_start_item_cutscene()

func _start_item_cutscene():
	var param = PickupImportantItemCutsceneParam.new()
	param.item_texture = cdsu_anchor_hook.sprite.texture
	param.staring_pos = cdsu_anchor_hook.global_position
	param.ending_pos = SingletonsAndConsts.current_game_elements.get_current_player().global_position
	
	helper__start_cutscene_of_pickup_important_item(param, self, "_on_item_cutscene_end", null)
	

func _on_item_cutscene_end(arg_params):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	
	start_fade_out()


func start_fade_out():
	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_FADE__BLACK__LONG)
	transition.queue_free_on_end_of_transition = false
	
	#SingletonsAndConsts.current_master.play_transition__alter_no_states(transition, false)
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(transition)
	transition.start_transition()
	transition.modulate.a = 0.0
	
	transition.connect("transition_finished", self, "_on_transition_finished", [], CONNECT_ONESHOT)
	


func _on_transition_finished():
	_start_dialog__01()

func _start_dialog__01():
	var dialog_desc = [
		["Every journey has its end. New paths may reveal, soon.", []],
		["(Thank you for playing. - bambii)", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 5.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()


func _on_display_of_desc_finished__01(arg):
	#SingletonsAndConsts.switch_to_level_selection_scene__from_game_elements__from_quit()
	#SingletonsAndConsts.switch_to_level_selection_scene__from_game_elements__as_win()
	
	if GameSaveManager.is_level_layout_id_playable(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_01):
		game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()
	else:
		#SingletonsAndConsts.current_game_front_hud.game_dialog_panel.disconnect("display_of_desc_finished", self, "_on_display_of_desc_finished__01")
		_start_dialog__02()
	

func _start_dialog__02():
	var dialog_desc = [
		["But this journey has not ended yet.", []],
		["The galaxy still hides its secrets.", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__02", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 5.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__02(arg):
	game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()

#
