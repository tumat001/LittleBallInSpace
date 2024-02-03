extends "res://WorldRelated/AbstractWorldSlice.gd"

const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


const STAR_COUNT_BUFFER = 3
var STARS_NEEDED : int


#

var _transition_sprite


###

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	
	# init stars needed --> the -2 is from this and the trophy level (next)


func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _ready():
	STARS_NEEDED = StoreOfLevels.get_total_coin_count() - (2) - STAR_COUNT_BUFFER


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided", [], CONNECT_ONESHOT)
	
	if STARS_NEEDED > GameSaveManager.get_total_coin_collected_count():
		#todoimp TEST 02_01
		pass
		#_do_actions_from_lack_of_stars()


#

func _do_actions_from_lack_of_stars():
	if game_elements.is_game_front_hud_initialized:
		_do_actions_from_lack_of_stars__all_GFH_relateds()
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized", [], CONNECT_ONESHOT)

func _on_game_front_hud_initialized(arg_GFH):
	_do_actions_from_lack_of_stars__all_GFH_relateds()


func _do_actions_from_lack_of_stars__all_GFH_relateds():
	_construct_fog_transition_sprite()
	_start_dialog__01()


func _construct_fog_transition_sprite():
	_transition_sprite = SingletonsAndConsts.current_master.construct_transition__using_id(StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK)
	
	_transition_sprite.is_custom_controlled__avoid_auto_tweens = true
	
	_transition_sprite.initial_ratio = 0.1
	_transition_sprite.target_ratio = 0.1
	_transition_sprite.wait_at_start = 0.0
	_transition_sprite.duration = 1
	_transition_sprite.trans_type = Tween.TRANS_LINEAR
	#SingletonsAndConsts.current_master.play_transition__alter_no_states(_transition_sprite)
	
	_transition_sprite.queue_free_on_end_of_transition = false
	#SingletonsAndConsts.add_child_to_game_elements__other_node_hoster(_transition_sprite)
	
	
	SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(_transition_sprite)
	_transition_sprite.start_transition()
	_transition_sprite.modulate.a = 1.0


func _start_dialog__01():
	var plain_fragment__x_stars_needed = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.STAR, "%s stars" % STARS_NEEDED)
	var plain_fragment__x_curr_stars = PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.STAR, "%s stars" % GameSaveManager.get_total_coin_collected_count())
	
	
	var dialog_desc = [
		["It's too dark here! You'll need at least |0| to lift the darkness.", [plain_fragment__x_stars_needed]],
		["Right now, you have |0|.", [plain_fragment__x_curr_stars]],
	]
	
	#
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 7.5, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__01(arg_data):
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()


###########

func _on_game_result_decided(arg_result):
	if game_elements.game_result_manager.is_game_result_win():
		StoreOfLevels.attempt_do_unlock_actions_on_finish_level_01_of_stage_special_02()
		


