extends "res://WorldRelated/AbstractWorldSlice.gd"



#onready var glass_ins_label = $MiscContainer/GlassInsLabel
onready var vis_ins_glass_hover_mouse = $MiscContainer/VisIns_GlassHoverMouse

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if GameSaveManager.is_last_playthru_from_demo__and_curr_is_non_demo():
		if game_elements.is_game_front_hud_initialized:
			_show_thanks_for_purchasing_full_version()
		else:
			game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized__for_showing_thanks", [], CONNECT_ONESHOT)

func _on_game_front_hud_initialized__for_showing_thanks(arg_GFH):
	_show_thanks_for_purchasing_full_version()


func _show_thanks_for_purchasing_full_version():
	var dialog_desc = [
		["(Thank you for purchasing the full version!!! - bambii)", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 4.0, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()

func _on_display_of_desc_finished__01(arg):
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()

#


#

func _ready():
	#glass_ins_label.modulate.a = 0.0
	pass

func _on_PDAR_NearFragileGlassType_player_entered_in_area():
	vis_ins_glass_hover_mouse.start_display()
	
	#var tweener = create_tween()
	#tweener.tween_property(glass_ins_label, "modulate:a", 1.0, 0.75)
	

#func _on_PDAR_HideIns_player_entered_in_area():
#	var tweener = create_tween()
#	tweener.tween_property(glass_ins_label, "modulate:a", 0.0, 0.75)
#
