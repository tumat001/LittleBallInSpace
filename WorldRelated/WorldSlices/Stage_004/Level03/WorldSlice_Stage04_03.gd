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

# arr in arr. 
var _mod_x_vbox_container_elements : Array = []

var _is_displayed_fog__as_first_time : bool

#

onready var vision_fog = $MiscContainer/VisionFog

onready var mod_x_screen = $MiscContainer/ModX_Screen
onready var mod_x_all_vbox_container = $MiscContainer/ModX_AllContainer

onready var mod_x_status__stats = $MiscContainer/ModX_AllContainer/ModX_StatsContainer/ModXStatus_Stats
onready var mod_x_status__player_aesth = $MiscContainer/ModX_AllContainer/ModX_PlayerAesthContainer/ModXStatus_PlayerAesth
onready var mod_x_status__tile_colors = $MiscContainer/ModX_AllContainer/ModX_TileColorsContainer/ModXStatus_TileColors

onready var base_tileset_simple_glass_for_mod_x = $TileContainer/BaseTileSet_SimpleGlassForModX

onready var button_for_mod_x_screen = $ObjectContainer/Object_IB_ForModXScreen

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	as_test__override__do_insta_win__template_capture_all_points()
	

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	if GameSaveManager.has_metadata_in_level_id(SingletonsAndConsts.current_base_level_id):
		_init__as_NOT_first_time_viewing_mod_x_statuses()
	else:
		_init__as_first_time_viewing_mod_x_statuses()
	
	##
	
	if CameraManager.is_at_default_zoom():
		CameraManager.start_camera_zoom_change__with_default_player_initialized_vals()


#####

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
	
	#
	
#	#for i in child_count:
#	for list in children_list_of_list:
#
#		for ele in :
#			ele.modulate.a = 0
#		_mod_x_vbox_container_elements.append(container.get_children())



func _config_mod_x_status_icons():
	if GameSaveManager.can_view_game_stats:
		mod_x_status__stats.texture = ModuleX_StatusIcon_Check
	else:
		mod_x_status__stats.texture = ModuleX_StatusIcon_X
	
	if GameSaveManager.can_edit_player_aesth:
		mod_x_status__player_aesth.texture = ModuleX_StatusIcon_Check
	else:
		mod_x_status__player_aesth.texture = ModuleX_StatusIcon_X
	
	if GameSaveManager.can_edit_tile_colors:
		mod_x_status__tile_colors.texture = ModuleX_StatusIcon_Check
	else:
		mod_x_status__tile_colors.texture = ModuleX_StatusIcon_X
	

######

func _init__as_NOT_first_time_viewing_mod_x_statuses():
	_is_displayed_fog__as_first_time = false
	_config_mod_x_status_icons()
	mod_x_screen.modulate = MOD_X_SCREEN_MODULATE__ACTIVE
	
	base_tileset_simple_glass_for_mod_x.remove_tiles_at_all_coords()
	
	button_for_mod_x_screen.can_play_sound = false
	button_for_mod_x_screen.set_is_pressed(true)
	button_for_mod_x_screen.can_play_sound = true
	vision_fog.visible = false

###################

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
	


#

func _on_Object_IB_ForModXScreen_pressed(arg_is_pressed):
	if arg_is_pressed:
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
	

####



