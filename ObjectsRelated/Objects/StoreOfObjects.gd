extends Node

enum ObjectTypeIds {
	BALL = 0,
	TILE_FRAGMENT = 1,
	INTERACTABLE_BUTTON = 2,
}

var _object_type_id_to_file_path_map : Dictionary

#

onready var PLAYER_COLLISION_SOUND_HIT : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_Player_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_Player_02,
	
]
onready var BALL_COLLISION_SOUND_HIT : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_Ball_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_Ball_02,
	
]

#onready var NONE_COLLISION_SOUND_HIT : Array = []

##

func _init():
	_object_type_id_to_file_path_map[ObjectTypeIds.BALL] = "res://ObjectsRelated/Objects/Imps/Ball/Object_Ball.tscn"
	_object_type_id_to_file_path_map[ObjectTypeIds.TILE_FRAGMENT] = "res://ObjectsRelated/Objects/Imps/TileFragment/Object_TileFragment.tscn"
	_object_type_id_to_file_path_map[ObjectTypeIds.INTERACTABLE_BUTTON] = "res://ObjectsRelated/Objects/Imps/InteractableButton/Object_ButtonInteractable.tscn"
	

func construct_object(arg_id):
	var object = load(_object_type_id_to_file_path_map[arg_id]).instance()
	
	if arg_id == ObjectTypeIds.BALL:
		if is_instance_valid(SingletonsAndConsts.current_game_elements):
			var lifespan = SingletonsAndConsts.current_game_elements.object_lifespan__ball
			if lifespan != -1:
				object.has_finite_lifespan = true
				object.current_lifespan = lifespan
	
	
	return object


####################
# COLLISION SOUND

func get_ball_collision__with_player__sound_list():
	return PLAYER_COLLISION_SOUND_HIT

func get_ball_collision__with_ball__sound_list():
	return BALL_COLLISION_SOUND_HIT



