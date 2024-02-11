extends MarginContainer



var trophy_id_to_texture_rect_node_map : Dictionary

export(bool) var can_show_healths_related_trophies : bool = true setget set_can_show_healths_related_trophies

onready var player_dead_tex_rect = $MarginContainer/HBoxContainer/PlayerDeadTextureRect
onready var player_health_invul_tex_rect = $MarginContainer/HBoxContainer/PlayerHealthInvulTexture

onready var trophy_non_volatile_container = $MarginContainer/HBoxContainer/TrophyNonVolatileContainer


#

func _ready():
	player_dead_tex_rect.visible = false
	player_health_invul_tex_rect.visible = false
	
	_init_player_heart_vis_status__check_for_GE()
	_init_trophy_non_volatile__from_GSM()


func _init_player_heart_vis_status__check_for_GE():
	if !can_show_healths_related_trophies:
		return
	
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
	if !can_show_healths_related_trophies:
		player_health_invul_tex_rect.visible = false
		player_dead_tex_rect.visible = false
		return
	
	
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


####

func _init_trophy_non_volatile__from_GSM():
	_update_trophy_non_volatile_container__based_on_GSM()
	GameSaveManager.connect("trophies_collected_changed", self, "_on_trophies_collected_changed")

func _on_trophies_collected_changed():
	_update_trophy_non_volatile_container__based_on_GSM()

func _update_trophy_non_volatile_container__based_on_GSM():
	var make_trophy_container_vis : bool = false
	for trophy_id in GameSaveManager.collected_trophy_id_to_metadata_map.keys():
		if !trophy_id_to_texture_rect_node_map.has(trophy_id):
			_construct_texture_rect_from_trophy_id(trophy_id)
		else:
			var tex_rec = trophy_id_to_texture_rect_node_map[trophy_id]
			tex_rec.visible = true
		
		make_trophy_container_vis = true
	
	for trophy_id in trophy_id_to_texture_rect_node_map.keys():
		if !GameSaveManager.is_trophy_collected(trophy_id):
			var tex_rec = trophy_id_to_texture_rect_node_map[trophy_id]
			tex_rec.visible = false
	
	trophy_non_volatile_container.visible = make_trophy_container_vis

func _construct_texture_rect_from_trophy_id(arg_id):
	var trophy_details = GameSaveManager.get_or_generate_trophy_details(arg_id)
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = trophy_details.trophy_mini_image
	trophy_non_volatile_container.add_child(texture_rect)
	
	trophy_id_to_texture_rect_node_map[arg_id] = texture_rect

#

func set_can_show_healths_related_trophies(arg_val):
	can_show_healths_related_trophies = arg_val
	
	if is_inside_tree():
		_update_player_heart_vis_status()


