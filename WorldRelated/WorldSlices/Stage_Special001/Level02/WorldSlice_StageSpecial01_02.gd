# We can do this. For first time opening this (every new session),
# Play some teaser/loading screen (running animal of your choice)/bloopers/behind the scenes to stall time for the simulation
extends "res://WorldRelated/AbstractWorldSlice.gd"

#

const StoreOfCutscenes = preload("res://MiscRelated/CutsceneRelated/Imps/Cutscenes/StoreOfCutscenes.gd")

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	_add_launch_ball_modi()
	
	_init_rewindable_objects__for_this_special()
	if !SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_1):
		#_player._save_rewind_save_state_of_any_nodes = false
		pass
		
	else:
		_ball = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL).create_ball__for_any_use(true)
		_ball.has_finite_lifespan = true
	
	
	call_deferred("_deferred_init")

func _deferred_init():
	_load_or_generate_rewindable_data__for_this_level()



func _add_launch_ball_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	modi.starting_ball_count = 1
	modi.is_infinite_ball_count = false
	modi.show_player_trajectory_line = true
	
	game_elements.player_modi_manager.add_modi_to_player(modi)

func _on_before_game_start_init():
	pass
	


#######
# LOAD OR GENERATE
########

const OBJ_IDENTIF__BUTTON = "RewindData_BUTTON"
const OBJ_IDENTIF__BALL = "RewindData_BALL"
const OBJ_IDENTIF__PLAYER = "RewindData_PLAYER"
const OBJ_IDENTIF__TILESET = "RewindData_TILESET"

var _ball
var _player
onready var _button = $ObjectContainer/Object_InteractableButton_Red
onready var _tileset = $TileContainer/BaseTileSet_Red

var _cutscene

var _relevant_object_name_to_rewind_data_list : Array
var _rewind_marker_data_list : Array

func _init_rewindable_objects__for_this_special():
	_player = SingletonsAndConsts.current_game_elements.get_current_player()
	
	#_ball = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL).create_ball__for_any_use()



func _load_or_generate_rewindable_data__for_this_level():
	if !SingletonsAndConsts.if_level_id_has_single_game_session_persisting_data(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_1):
		_generate_rewindable_data__for_this_level()
		
	else:
		var datas = SingletonsAndConsts.get_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_1)
		_init_rewindable_datas__into_rewind_manager(datas)



func _init_rewindable_datas__into_rewind_manager(arg_datas : Array):
#	_ball = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL).create_ball__for_any_use()
#	_ball.has_finite_lifespan = true
	
	#
	var rewind_datas : Array = arg_datas[0]
	var rewind_marker_datas = arg_datas[1]
	
	for object_name_to_rewind_data in rewind_datas:
		var obj_to_rewind_data : Dictionary = {}
		
		## BUTTON
		var button_data = object_name_to_rewind_data[OBJ_IDENTIF__BUTTON]
		obj_to_rewind_data[_button] = button_data
		
		## BALL
		if object_name_to_rewind_data.has(OBJ_IDENTIF__BALL):
			var ball_data = object_name_to_rewind_data[OBJ_IDENTIF__BALL]
			obj_to_rewind_data[_ball] = ball_data
		
		## PLAYER
		var player_data = object_name_to_rewind_data[OBJ_IDENTIF__PLAYER]
		_player.__map_save_state_map_nodes_with_own_nodes(player_data)
		obj_to_rewind_data[_player] = player_data
		#print(player_data["_all_nodes_to_rotate_with_cam"])
		
		## TILESET
		var tileset_data = object_name_to_rewind_data[OBJ_IDENTIF__TILESET]
		obj_to_rewind_data[_tileset] = tileset_data
		
		
		
		######
		SingletonsAndConsts.current_rewind_manager.__append_to_rewind_datas__single_frame(obj_to_rewind_data)
	
	for marker_data in rewind_marker_datas:
		SingletonsAndConsts.current_rewind_manager.__append_to_rewind_marker_datas__single_frame(marker_data)
	
	
	#############
	
	var last_object_name_to_rewind_data = rewind_datas.back()
	# BUTTON
	var button_data = last_object_name_to_rewind_data[OBJ_IDENTIF__BUTTON]
	_button.load_into_rewind_save_state(button_data)
	_button.ended_rewind()
	
	# BALL
	if last_object_name_to_rewind_data.has(OBJ_IDENTIF__BALL):
		var ball_data = last_object_name_to_rewind_data[OBJ_IDENTIF__BALL]
		_ball.load_into_rewind_save_state(ball_data)
		_ball.ended_rewind()
	
	# PLAYER
	var player_data = last_object_name_to_rewind_data[OBJ_IDENTIF__PLAYER]
	_player.load_into_rewind_save_state(player_data)
	_player.ended_rewind()
	
	# TILESET
	var tileset_data = last_object_name_to_rewind_data[OBJ_IDENTIF__TILESET]
	_tileset.load_into_rewind_save_state(tileset_data)
	_tileset.ended_rewind()
	
	
	#print("size: %s" % arg_datas.size())
	#return arg_datas.size() != 0



########################

func _generate_rewindable_data__for_this_level():
	_configue_states_for_data_generation()
	_show_cutscene_for_obstruction()
	#call_deferred("_start_simulation_of_events")
	_start_simulation_of_events()


##

func _configue_states_for_data_generation():
	#_player._save_rewind_save_state_of_any_nodes = false
	
	StoreOfAudio.mute_all_game_sfx_unaffecting_volume_settings = true
	game_elements.connect("quiting_game_by_queue_free__on_game_quit", self, "_on_quiting_game_by_queue_free__on_game_quit")

func _on_quiting_game_by_queue_free__on_game_quit():
	StoreOfAudio.mute_all_game_sfx_unaffecting_volume_settings = false
	

## CUTSCENE

func _show_cutscene_for_obstruction():
	_cutscene = StoreOfCutscenes.generate_cutscene_from_id(StoreOfCutscenes.CutsceneId.LSpecial01_Lvl02)
	_cutscene.display_loading_panel_on_end_of_cutscene = true
	SingletonsAndConsts.current_master.add_cutscene_to_container(_cutscene)
	
	_cutscene.start_display()


## SIMULATION OF EVENTS

func _start_simulation_of_events():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_interval(1.0)
	tweener.tween_callback(self, "_launch_ball_to_button_pos")
	
	#
	
	SingletonsAndConsts.current_rewind_manager.connect("rewindable_datas_saved", self, "_on_rewindable_datas_saved")


func _launch_ball_to_button_pos():
	var launch_ball_modi = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	var button_pos = _button.global_position
	
	var ball = launch_ball_modi.force_launch_ball_at_pos__min_speed(button_pos)
	ball.connect("destroyed_self_caused_by_destroying_area_region", self, "_on_destroyed_self_caused_by_destroying_area_region", [], CONNECT_ONESHOT)

func _on_destroyed_self_caused_by_destroying_area_region(arg_area_region):
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_interval(1.0)
	tweener.tween_callback(self, "_end_simulation_of_events")


##

func _end_simulation_of_events():
	#_player._save_rewind_save_state_of_any_nodes = true
	_cutscene.display_loading_panel_on_end_of_cutscene = false
	
	StoreOfAudio.mute_all_game_sfx_unaffecting_volume_settings = false
	
	SingletonsAndConsts.current_rewind_manager.disconnect("rewindable_datas_saved", self, "_on_rewindable_datas_saved")
	SingletonsAndConsts.set_single_game_session_persisting_data_of_level_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_1, [_relevant_object_name_to_rewind_data_list, _rewind_marker_data_list])
	
	if !_cutscene.is_currently_displaying_loading_panel():
		SingletonsAndConsts.current_master.set_pause_game(true)
		_cutscene.connect("cutscene_ended", self, "_on_cutscene_ended__from_paused")

func _on_cutscene_ended__from_paused():
	SingletonsAndConsts.current_master.set_pause_game(false)
	



#

func _on_rewindable_datas_saved(arg_rewindable_obj_to_save_state_map, arg_rewindable_marker_data_at_next_frame):
	var relevant_object_name_to_rewind_data : Dictionary = {}
	for obj in arg_rewindable_obj_to_save_state_map.keys():
		if obj.get("is_class_type_object_interactable_button"):
			relevant_object_name_to_rewind_data[OBJ_IDENTIF__BUTTON] = arg_rewindable_obj_to_save_state_map[obj]
			
		elif obj.get("is_class_type_obj_ball"):
			relevant_object_name_to_rewind_data[OBJ_IDENTIF__BALL] = arg_rewindable_obj_to_save_state_map[obj]
			
		elif obj.get("is_player"):
			var save_state = arg_rewindable_obj_to_save_state_map[obj]
			_player.__remove_nodes_from_save_state(save_state)
			#print(save_state["_all_nodes_to_rotate_with_cam"])
			relevant_object_name_to_rewind_data[OBJ_IDENTIF__PLAYER] = arg_rewindable_obj_to_save_state_map[obj]
			
		elif obj.get("is_class_type_base_tileset"):
			relevant_object_name_to_rewind_data[OBJ_IDENTIF__TILESET] = arg_rewindable_obj_to_save_state_map[obj]
			
	
	_relevant_object_name_to_rewind_data_list.append(relevant_object_name_to_rewind_data)
	_rewind_marker_data_list.append(arg_rewindable_marker_data_at_next_frame)

