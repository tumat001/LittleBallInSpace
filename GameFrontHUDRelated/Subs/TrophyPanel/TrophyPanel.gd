extends MarginContainer


onready var player_dead_tex_rect = $MarginContainer/HBoxContainer/PlayerDeadTextureRect

#

#func _ready():
#	_init_player_dead_vis_status()
#
#
#
#
#func _init_player_dead_vis_status():
#	GameSaveManager.connect("is_player_health_on_start_zero_changed", self, "_on_is_player_health_on_start_zero_changed")
#	_update_player_dead_vis_status()
#
#
#func _on_is_player_health_on_start_zero_changed(arg_val):
#	_update_player_dead_vis_status()
#
#
#func _update_player_dead_vis_status():
#	var is_dead = is_equal_approx(GameSaveManager.player_health_on_start, 0)
#	if is_dead:
#		if !player_dead_tex_rect.visible:
#			player_dead_tex_rect.modulate.a = 0
#			player_dead_tex_rect.visible = true
#
#			var tweener = create_tween()
#			tweener.tween_property(player_dead_tex_rect, "modulate:a", 1.0, 0.5)
#
#	else:
#		player_dead_tex_rect.visible = false
#


func _ready():
	_init_player_dead_vis_status__check_for_GE()
	
	player_dead_tex_rect.visible = false



func _init_player_dead_vis_status__check_for_GE():
	if !SingletonsAndConsts.current_game_elements.is_player_spawned():
		SingletonsAndConsts.current_game_elements.connect("player_spawned", self, "_on_player_spawned", [], CONNECT_ONESHOT)
	else:
		_init_player_dead_vis_status__player_spawned()
	
	

func _on_player_spawned(arg_player):
	arg_player.connect("health_restored_from_zero", self, "_on_player_health_restored_from_zero")
	arg_player.connect("all_health_lost", self, "_on_player_all_health_lost")
	
	_init_player_dead_vis_status__player_spawned()
	

func _init_player_dead_vis_status__player_spawned():
	_update_player_dead_vis_status()
	
	

#


func _on_player_health_restored_from_zero():
	_update_player_dead_vis_status()

func _on_player_all_health_lost():
	_update_player_dead_vis_status()


#

func _update_player_dead_vis_status():
	var is_dead = is_equal_approx(SingletonsAndConsts.current_game_elements.get_current_player().get_current_health(), 0)
	if is_dead:
		if !player_dead_tex_rect.visible:
			player_dead_tex_rect.modulate.a = 0
			player_dead_tex_rect.visible = true
			
			var tweener = create_tween()
			tweener.tween_property(player_dead_tex_rect, "modulate:a", 1.0, 0.5)
		
	else:
		player_dead_tex_rect.visible = false
		


#

func get_player_dead_tex_rect_pos__and_center_pos__and_texture__and_is_vis():
	var center_pos = player_dead_tex_rect.rect_global_position + player_dead_tex_rect.texture.get_size() / 2.0
	return [player_dead_tex_rect.rect_global_position, center_pos, player_dead_tex_rect.texture, player_dead_tex_rect.visible]


