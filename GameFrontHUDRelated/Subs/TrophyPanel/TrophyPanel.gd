extends MarginContainer


onready var player_dead_tex_rect = $MarginContainer/HBoxContainer/PlayerDeadTextureRect
onready var player_health_invul_tex_rect = $MarginContainer/HBoxContainer/PlayerHealthInvulTexture


func _ready():
	player_dead_tex_rect.visible = false
	player_health_invul_tex_rect.visible = false
	
	_init_player_heart_vis_status__check_for_GE()



func _init_player_heart_vis_status__check_for_GE():
	if !SingletonsAndConsts.current_game_elements.is_player_spawned():
		SingletonsAndConsts.current_game_elements.connect("player_spawned", self, "_on_player_spawned", [], CONNECT_ONESHOT)
	else:
		_init_player_heart_vis_status__player_spawned(SingletonsAndConsts.current_game_elements.get_current_player())
	
	

func _on_player_spawned(arg_player):
	_init_player_heart_vis_status__player_spawned(arg_player)
	

func _init_player_heart_vis_status__player_spawned(arg_player):
	arg_player.connect("health_restored_from_zero", self, "_on_player_health_restored_from_zero")
	arg_player.connect("all_health_lost", self, "_on_player_all_health_lost")
	arg_player.connect("is_player_health_invulnerable_changed", self, "_on_is_player_health_invulnerable_changed")
	
	_update_player_heart_vis_status()


#


func _on_player_health_restored_from_zero():
	_update_player_heart_vis_status()

func _on_player_all_health_lost():
	_update_player_heart_vis_status()

func _on_is_player_health_invulnerable_changed(arg_val):
	_update_player_heart_vis_status()

#

func _update_player_heart_vis_status():
	var player = SingletonsAndConsts.current_game_elements.get_current_player()#.get_current_health()
	var is_dead = player.is_no_health() #is_equal_approx(, 0)
	if is_dead:
		_tween_set_texture_rect_visible(player_dead_tex_rect)
		player_health_invul_tex_rect.visible = false
		
	else:
		player_dead_tex_rect.visible = false
		
		if player.is_player_health_invulnerable:
			_tween_set_texture_rect_visible(player_health_invul_tex_rect)
		else:
			player_health_invul_tex_rect.visible = false

func _tween_set_texture_rect_visible(arg_texture_rect : TextureRect):
	if !arg_texture_rect.visible:
		arg_texture_rect.modulate.a = 0
		arg_texture_rect.visible = true
		
		var tweener = create_tween()
		tweener.tween_property(arg_texture_rect, "modulate:a", 1.0, 0.5)




#

func get_player_dead_tex_rect_pos__and_center_pos__and_texture__and_is_vis():
	var center_pos = player_dead_tex_rect.rect_global_position + player_dead_tex_rect.texture.get_size() / 2.0
	return [player_dead_tex_rect.rect_global_position, center_pos, player_dead_tex_rect.texture, player_dead_tex_rect.visible]


