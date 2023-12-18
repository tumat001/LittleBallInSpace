extends "res://WorldRelated/AbstractWorldSlice.gd"


onready var vis_transition_fog_circ = $MiscContainer/VisTransitionFog_Circ

var _lifted_fog : bool = false

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CameraManager.set_current_default_zoom_out_vec(Vector2(1, 1))



#####


func _on_Button_AntiFog_pressed(arg_is_pressed):
	if !_lifted_fog and arg_is_pressed:
		_lifted_fog = true
		
		vis_transition_fog_circ.lift_and_end_fog(2.0)
		vis_transition_fog_circ.deactivate_monitor_for_player()
		
		SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
		
		CameraManager.set_current_default_zoom_out_vec(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL)


#func _on_Button_AntiFog_pressed(arg_is_pressed):
#	if !_lifted_fog and arg_is_pressed:
#		_lifted_fog = true
#
#		SingletonsAndConsts.current_rewind_manager.can_cast_rewind_cond_clause.attempt_insert_clause(SingletonsAndConsts.current_rewind_manager.CanCastRewindClauseIds.CUSTOM_FROM_WORLD_SLICE)
#
#		call_deferred("_deferred_lift_fog_and_do_relateds")
#
#func _deferred_lift_fog_and_do_relateds():
#	vis_transition_fog_circ.lift_and_end_fog(2.0)
#	vis_transition_fog_circ.deactivate_monitor_for_player()
#
#	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
#
#	CameraManager.set_current_default_zoom_out_vec(CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL)
#
#
#	SingletonsAndConsts.current_rewind_manager.can_cast_rewind_cond_clause.remove_clause(SingletonsAndConsts.current_rewind_manager.CanCastRewindClauseIds.CUSTOM_FROM_WORLD_SLICE)
#

