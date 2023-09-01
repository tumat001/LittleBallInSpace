extends "res://WorldRelated/AbstractWorldSlice.gd"

const StoreOfVicDefAnim = preload("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/StoreOfVicDefAnim.gd")


#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	



#####

func _on_Portal_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_base_level.anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.NONE
	
	StoreOfLevels.unlock_stage_special_01__and_unhide_eles_to_layout_special_01()
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	


