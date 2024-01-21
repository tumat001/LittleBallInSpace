extends "res://WorldRelated/AbstractWorldSlice.gd"


#

const ModuleX_StatusIcon_Check = preload("res://WorldRelated/WorldSlices/Stage_004/Level03/Assets/ModuleX_StatusIcon_Check.png")
const ModuleX_StatusIcon_X = preload("res://WorldRelated/WorldSlices/Stage_004/Level03/Assets/ModuleX_StatusIcon_X.png")

#

const MOD_X_SCREEN_MODULATE__INACTIVE = Color("#C4C4C4")
const MOD_X_SCREEN_MODULATE__ACTIVE = Color("#C48BFE")
const MOD_X_SCREEN_MODULATE__DURATION_TRANSITION : float = 1.4

const MOD_X_SCREEN_MODULATE__DELAY_SMALL__BETWEEN_ELE = 0.15
const MOD_X_SCREEN_MODULATE__DELAY_SMALL__BETWEEN_CONTAINERS = 0.25
const MOD_X_SCREEN_MODULATE__DELAY_LONG = 0.8

#

var _is_first_time__show_pca_lines : bool

#

var _is_displayed_fog__as_first_time : bool
# arr in arr. 
var _mod_x_vbox_container_elements : Array = []


#

onready var vision_fog = $MiscContainer/VisionFogForModX

onready var mod_x_screen = $MiscContainer/ModX_Screen
onready var mod_x_all_vbox_container = $MiscContainer/ModX_AllContainer

onready var base_tileset_simple_glass_for_mod_x = $TileContainer/BTS_SimpleGlassForModX
onready var button_for_mod_x_screen = $ObjectContainer/Button_ForModuleX

######

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_03__STAGE_3__HARD):
		var is_fast_respawn = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_3__HARD)
		
		if is_fast_respawn:
			_is_first_time__show_pca_lines = false
			
		else:
			_is_first_time__show_pca_lines = true
		
		
	else:
		_is_first_time__show_pca_lines = true
	
	SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_3__HARD, true)
	
	###
	
	_show_lines_to_pca__temporarily()
	
	###
	
	if GameSaveManager.has_metadata_in_level_id(SingletonsAndConsts.current_base_level_id):
		_init__as_NOT_first_time_viewing_mod_x_statuses()
	else:
		_init__as_first_time_viewing_mod_x_statuses()
	


func _show_lines_to_pca__temporarily():
	var player = game_elements.get_current_player()
	player.is_show_lines_to_uncaptured_player_capture_regions = true
	
	var pca_line_drawer = player.pca_line_direction_drawer
	
	var pca_line_shower_tween = create_tween()
	if _is_first_time__show_pca_lines:
		pca_line_shower_tween.tween_interval(12.0)
	else:
		pca_line_shower_tween.tween_interval(4.0)
	pca_line_shower_tween.tween_property(pca_line_drawer, "modulate:a", 0.0, 2.0)
	pca_line_shower_tween.tween_callback(pca_line_drawer, "set_is_show_lines_to_uncaptured_player_capture_regions", [false])
	pca_line_shower_tween.tween_property(pca_line_drawer, "modulate:a", 1.0, 0.0)


##


func _init__as_first_time_viewing_mod_x_statuses():
	_is_displayed_fog__as_first_time = true
	_init_and_config_mod_x_all_container_elements__as_hidden()
	_config_mod_x_status_icons()
	mod_x_screen.modulate = MOD_X_SCREEN_MODULATE__INACTIVE
	vision_fog.visible = true

func _init_and_config_mod_x_all_container_elements__as_hidden():
	#var children_list_of_list : Array = []
	#var child_count : int
	for mod_x_container in mod_x_all_vbox_container.get_children():
		#child_count = mod_x_container.get_child_count()
		#children_list_of_list.append(mod_x_container.get_children())
		
		for child in mod_x_container.get_children():
			child.modulate.a = 0
		_mod_x_vbox_container_elements.append(mod_x_container.get_children())


#todoimp continue the mod x related things to display
func _config_mod_x_status_icons():
	pass
	
#	if GameSaveManager.can_view_game_stats:
#		mod_x_status__stats.texture = ModuleX_StatusIcon_Check
#	else:
#		mod_x_status__stats.texture = ModuleX_StatusIcon_X
#
#	if GameSaveManager.can_edit_player_aesth:
#		mod_x_status__player_aesth.texture = ModuleX_StatusIcon_Check
#	else:
#		mod_x_status__player_aesth.texture = ModuleX_StatusIcon_X
#
#	if GameSaveManager.can_edit_tile_colors:
#		mod_x_status__tile_colors.texture = ModuleX_StatusIcon_Check
#	else:
#		mod_x_status__tile_colors.texture = ModuleX_StatusIcon_X
#

#

func _init__as_NOT_first_time_viewing_mod_x_statuses():
	_is_displayed_fog__as_first_time = false
	_config_mod_x_status_icons()
	mod_x_screen.modulate = MOD_X_SCREEN_MODULATE__ACTIVE
	
	base_tileset_simple_glass_for_mod_x.remove_tiles_at_all_coords()
	
	button_for_mod_x_screen.can_play_sound = false
	button_for_mod_x_screen.set_is_pressed(true)
	button_for_mod_x_screen.can_play_sound = true
	vision_fog.visible = false


##########

func _on_PDAR_FogLift_player_entered_in_area():
	if _is_displayed_fog__as_first_time:
		game_elements.ban_rewind_manager_to_store_and_cast_rewind()
		
		vision_fog.start_hide_fog()
		vision_fog.connect("fog_hide_finished", self, "_on_fog_hide_finished", [], CONNECT_ONESHOT)
		
		##
		
		
		GameSaveManager.set_metadata_of_level_id(SingletonsAndConsts.current_base_level_id, true)
	

func _on_fog_hide_finished():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	





func _on_Button_ForModuleX_pressed(arg_is_pressed):
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding and arg_is_pressed:
		if _is_displayed_fog__as_first_time:
			_is_displayed_fog__as_first_time = false
			game_elements.ban_rewind_manager_to_store_and_cast_rewind()
			
			_start_display_mod_x_statuses()

func _start_display_mod_x_statuses():
	var tweener = create_tween()
	
	# screen
	tweener.tween_property(mod_x_screen, "modulate", MOD_X_SCREEN_MODULATE__ACTIVE, MOD_X_SCREEN_MODULATE__DURATION_TRANSITION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tweener.tween_interval(0.2)
	
	for mod_arr in _mod_x_vbox_container_elements:
		for mod_ele in mod_arr:
			tweener.tween_property(mod_ele, "modulate:a", 1.0, MOD_X_SCREEN_MODULATE__DELAY_SMALL__BETWEEN_ELE)
			tweener.tween_interval(MOD_X_SCREEN_MODULATE__DELAY_SMALL__BETWEEN_CONTAINERS)
		tweener.tween_interval(MOD_X_SCREEN_MODULATE__DELAY_LONG)
	
	tweener.tween_callback(self, "_on_display_mod_x_statuses_finished")


func _on_display_mod_x_statuses_finished():
	SingletonsAndConsts.current_rewind_manager.prevent_rewind_up_to_this_time_point()
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	


