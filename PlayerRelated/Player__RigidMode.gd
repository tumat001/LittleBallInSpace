extends RigidBody2D

const ConditionalClauses = preload("res://MiscRelated/ClauseRelated/ConditionalClauses.gd")

const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")



signal request_rotate(arg_data)

#

var _player_prev_global_position : Vector2
var _player_pos_change_from_last_frame : Vector2

#

onready var sprite_layer = $SpriteLayer

onready var floor_area_2d = $FloorArea2D
onready var floor_area_2d_coll_shape = $FloorArea2D/CollisionShape2D

#onready var remote_transform_2d = $RemoteTransform2D

#

func _init():
	pass


#


#######

func _on_FloorArea2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass

func _on_FloorArea2D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	pass


#############

func _ready():
	_player_prev_global_position = global_position


func receive_cam_focus__as_child(arg_cam : Camera2D):
	add_child(arg_cam)
	


