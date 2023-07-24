extends Node


enum WorldSliceIds {
	STAGE_01_01 = 1
}



func load_world_slice_from_id(arg_id):
	var world_packed_scene
	var world
	
	if arg_id == WorldSliceIds.STAGE_01_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/WorldSlice_Stage01_01.tscn")
	
	
	####
	
	world = world_packed_scene.instance()
	
	world.world_id = arg_id
	
	return world

