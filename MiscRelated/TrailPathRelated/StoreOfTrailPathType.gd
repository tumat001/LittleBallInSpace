extends Node

const BasicTrailPathType_Scene = preload("res://MiscRelated/TrailPathRelated/TrailTypeRelated/BasicTrailPathType.tscn")

enum {
	BASIC_TRAIL = 0
}


static func create_trail_type_instance(id : int):
	if id == BASIC_TRAIL:
		return BasicTrailPathType_Scene.instance()
	
	return null



