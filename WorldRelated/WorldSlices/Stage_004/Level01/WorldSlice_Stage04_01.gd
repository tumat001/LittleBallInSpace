extends "res://WorldRelated/AbstractWorldSlice.gd"



#onready var glass_ins_label = $MiscContainer/GlassInsLabel
onready var vis_ins_glass_hover_mouse = $MiscContainer/VisIns_GlassHoverMouse

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	

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
