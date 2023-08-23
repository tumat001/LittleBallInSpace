extends "res://WorldRelated/AbstractWorldSlice.gd"



onready var glass_ins_label = $MiscContainer/GlassInsLabel


func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	

#

func _ready():
	glass_ins_label.modulate.a = 0.0

func _on_PDAR_NearFragileGlassType_player_entered_in_area():
	var tweener = create_tween()
	tweener.tween_property(glass_ins_label, "modulate:a", 1.0, 0.75)

