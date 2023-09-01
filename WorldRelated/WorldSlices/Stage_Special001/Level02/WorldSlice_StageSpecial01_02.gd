# TOO MANY technical difficulties to implement.....
# NO, we can do this. For first time opening this (every new session),
# Play some teaser/loading screen (running animal of your choice)/bloopers/behind the scenes to stall time for the simulation
extends "res://WorldRelated/AbstractWorldSlice.gd"


#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func _on_after_game_start_init():
	._on_after_game_start_init()
	

func _on_before_game_start_init():
	pass



#######
# LOAD
########

const OBJ_IDENTIF__BUTTON = "RewindData_BUTTON"
const OBJ_IDENTIF__BALL = "RewindData_BALL"
const OBJ_IDENTIF__PLAYER = "RewindData_PLAYER"
const OBJ_IDENTIF__TILESET = "RewindData_TILESET"

var _ball
var _player
onready var _button = $ObjectContainer/Object_InteractableButton_Red
onready var _tileset = $TileContainer/BaseTileSet_Red



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
	for object_name_to_rewind_data in arg_datas:
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
		obj_to_rewind_data[_player] = player_data
		
		## TILESET
		var tileset_data = object_name_to_rewind_data[OBJ_IDENTIF__TILESET]
		obj_to_rewind_data[_tileset] = tileset_data
		
		
		
		######
		SingletonsAndConsts.current_rewind_manager.__append_to_rewind_datas__single_frame(obj_to_rewind_data)
	
	print("size: %s" % arg_datas.size())
	#return arg_datas.size() != 0



########################

func _generate_rewindable_data__for_this_level():
	_show_cutscene_for_obstruction()
	call_deferred("_start_simulation_of_events")



## CUTSCENE

func _show_cutscene_for_obstruction():
	pass
	


## SIMULATION OF EVENTS

func _start_simulation_of_events():
	pass
	


