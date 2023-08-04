extends MarginContainer


onready var player_dead_tex_rect = $MarginContainer/HBoxContainer/PlayerDeadTextureRect

#

func _ready():
	_init_player_dead_vis_status()
	



func _init_player_dead_vis_status():
	GameSaveManager.connect("is_player_health_on_start_zero_changed", self, "_on_is_player_health_on_start_zero_changed")
	_update_player_dead_vis_status()


func _on_is_player_health_on_start_zero_changed(arg_val):
	_update_player_dead_vis_status()
	

func _update_player_dead_vis_status():
	var is_dead = is_equal_approx(GameSaveManager.player_health_on_start, 0)
	if is_dead:
		if !player_dead_tex_rect.visible:
			player_dead_tex_rect.modulate.a = 0
			player_dead_tex_rect.visible = true
			
			var tweener = create_tween()
			tweener.tween_property(player_dead_tex_rect, "modulate:a", 1.0, 0.5)
		
	else:
		player_dead_tex_rect.visible = false
		

