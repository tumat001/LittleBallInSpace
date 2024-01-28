extends "res://LevelRelated/Classes/BaseLevel.gd"



var _black_sprite_cover : Sprite

func _init():
	anim_type_to_use_on_vic = StoreOfVicDefAnim.AnimTypes.ACTION
	anim_type_to_use_on_def = StoreOfVicDefAnim.AnimTypes.ACTION
	
	win_message_type = AbstractVicDefAnim.WinMessageType.CONGRATULATIONS
	lose_messege_type = AbstractVicDefAnim.LoseMessageType.DEFEAT
	
	

#

func apply_modification_to_game_elements(arg_elements):
	.apply_modification_to_game_elements(arg_elements)
	
	arg_elements.world_manager.add_world_slice(StoreOfWorldSlices.WorldSliceIds.STAGE_SPECIAL01_01, Vector2(0, 0))
	
	##
	arg_elements.game_result_manager.connect("game_result_decided", self, "_on_game_result_decided")
	call_deferred("_add_black_sprite_covering_all")


######

func after_game_init():
	.after_game_init()
	
	_add_energy_modi()
	_add_launch_ball_modi()
	_make_all_base_tilesets_not_generate_tooltip()


func _add_launch_ball_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	modi.starting_ball_count = 0
	modi.is_infinite_ball_count = false
	modi.show_player_trajectory_line = true
	
	game_elements.player_modi_manager.add_modi_to_player(modi)



func _add_energy_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.ENERGY)
	modi.set_max_energy(15)
	modi.set_current_energy(15)
	
	game_elements.player_modi_manager.add_modi_to_player(modi)



func _make_all_base_tilesets_not_generate_tooltip():
	game_elements.world_manager.set_enable_base_tileset_generate_tooltips__for_all_current_slices(false)

######################

func _add_black_sprite_covering_all():
	_black_sprite_cover = Sprite.new()
	_black_sprite_cover.texture = preload("res://LevelRelated/BaseLevelImps/LayoutSpecial01/LayoutAssetsAndSpecials/SpecialLevel01_BlackPixelForCover.png")
	_black_sprite_cover.scale = Vector2(1000, 1000)
	_black_sprite_cover.position = Vector2(960, 540)
	
	if is_instance_valid(SingletonsAndConsts.current_game_front_hud):
		_on_hud_initialized()
	else:
		SingletonsAndConsts.current_game_elements.connect("game_front_hud_initialized", self, "_on_game_front_hud_initialized")

func _on_game_front_hud_initialized(arg_game_front_hud):
	_on_hud_initialized()


func _on_hud_initialized():
	#SingletonsAndConsts.current_game_front_hud.add_node_to_other_hosters(_black_sprite_cover) 
	var gfh = SingletonsAndConsts.current_game_front_hud
	gfh.add_custom_control_in_container(_black_sprite_cover)

#

func _on_game_result_decided(arg_result):
	if game_elements.game_result_manager.is_game_result_win():
		_tween_remove_black_sprite_covering_all()

func _tween_remove_black_sprite_covering_all():
	var tweener : SceneTreeTween = game_elements.create_tween()
	tweener.tween_property(_black_sprite_cover, "modulate:a", 0.0, 0.65)

