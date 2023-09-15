extends Node

const BasicTrailType_Scene = preload("res://MiscRelated/TrailRelated/TrailTypeRelated/BasicTrailType.tscn")

enum {
	BASIC_TRAIL = 0
}


static func create_trail_type_instance(id : int):
	if id == BASIC_TRAIL:
		return BasicTrailType_Scene.instance()
	
	return null

