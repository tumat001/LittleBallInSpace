extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var star_you_earned_it_label = $MiscContainer/YouveEarnedItLabel


var _is_first_time__do_cutscenes : bool

var _star_label_mod_a_tweener : SceneTreeTween
var _triggered_star_label_already : bool = false

##

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

#

func _ready():
	star_you_earned_it_label.visible = false

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_07__STAGE_6__HARD):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_07__STAGE_6__HARD)
		
		if is_fast_respawn:
			_is_first_time__do_cutscenes = false
			
		else:
			_is_first_time__do_cutscenes = true
		
		
	else:
		_is_first_time__do_cutscenes = true
	
	SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_07__STAGE_6__HARD, true)
	
	###
	
	_show_lines_to_pca()
	
	###
	
	game_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided", [], CONNECT_ONESHOT)


func _on_game_result_decided(arg_result):
	if arg_result == game_elements.game_result_manager.GameResult.WIN:
		StoreOfLevels.unlock_stage_07__and_unhide_eles_to_layout_07()
	

#

func _show_lines_to_pca():
	var player = game_elements.get_current_player()
	player.is_show_lines_to_uncaptured_player_capture_regions = true
	
	var pca_line_drawer = player.pca_line_direction_drawer
	
	var pca_line_shower_tween = create_tween()
	if _is_first_time__do_cutscenes:
		pca_line_shower_tween.tween_interval(12.0)
	else:
		pca_line_shower_tween.tween_interval(4.0)
	pca_line_shower_tween.tween_property(pca_line_drawer, "modulate:a", 0.0, 2.0)
	pca_line_shower_tween.tween_callback(pca_line_drawer, "set_is_show_lines_to_uncaptured_player_capture_regions", [false])
	pca_line_shower_tween.tween_property(pca_line_drawer, "modulate:a", 1.0, 0.0)


####

func _on_Pickupables_Coin_collected_by_player():
	if _is_first_time__do_cutscenes and !_triggered_star_label_already:
		star_you_earned_it_label.modulate.a = 0
		star_you_earned_it_label.visible = true
		
		_star_label_mod_a_tweener = create_tween()
		_star_label_mod_a_tweener.tween_property(star_you_earned_it_label, "modulate:a", 1.0, 0.75)
		_star_label_mod_a_tweener.tween_interval(3.0)
		_star_label_mod_a_tweener.tween_property(star_you_earned_it_label, "modulate:a", 0.0, 2.0)
		
		
		_triggered_star_label_already = true


func _on_Pickupables_Coin_uncollected_by_player():
	if _star_label_mod_a_tweener != null and _star_label_mod_a_tweener.is_valid():
		_star_label_mod_a_tweener.kill()
	
	star_you_earned_it_label.visible = false


