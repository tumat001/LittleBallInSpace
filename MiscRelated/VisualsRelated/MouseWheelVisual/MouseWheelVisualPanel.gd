extends MarginContainer


func _ready():
	visible = GameSettingsManager.last_calc__unlocked_status__mouse_scroll_launch_ball
	GameSettingsManager.connect("secondary_game_control_is_unlocked_changed", self, "_on_secondary_game_control_is_unlocked_changed") 

func _on_secondary_game_control_is_unlocked_changed(arg_control_id, arg_unlocked_val):
	if arg_control_id == GameSettingsManager.SecondaryControlId.MOUSE_SCROLL__LAUNCH_BALL:
		visible = GameSettingsManager.last_calc__unlocked_status__mouse_scroll_launch_ball
	
