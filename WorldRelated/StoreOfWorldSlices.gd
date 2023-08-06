extends Node


enum WorldSliceIds {
	STAGE_TEST_01 = -10
	
	STAGE_01_01 = 1
	STAGE_01_02 = 2
	
}



func load_world_slice_from_id(arg_id):
	var world_packed_scene
	var world
	
	if arg_id == WorldSliceIds.STAGE_TEST_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Test/WorldSlice_Stage_Test01.tscn")
	if arg_id == WorldSliceIds.STAGE_01_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level01/WorldSlice_Stage01_01.tscn")
	if arg_id == WorldSliceIds.STAGE_01_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level01/WorldSlice_Stage01_02.tscn")
	
	####
	
	world = world_packed_scene.instance()
	
	world.world_id = arg_id
	
	return world

##




