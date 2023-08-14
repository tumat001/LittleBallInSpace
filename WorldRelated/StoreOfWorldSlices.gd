extends Node


enum WorldSliceIds {
	STAGE_TEST_01 = -10
	
	STAGE_01_01 = 1
	STAGE_01_02 = 2
	STAGE_01_03 = 3
	STAGE_01_04 = 4
	STAGE_01_05 = 5
	
	STAGE_02_01 = 10
	
}



func load_world_slice_from_id(arg_id):
	var world_packed_scene
	var world
	
	if arg_id == WorldSliceIds.STAGE_TEST_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Test/WorldSlice_Stage_Test01.tscn")
	elif arg_id == WorldSliceIds.STAGE_01_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level01/WorldSlice_Stage01_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_01_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level02/WorldSlice_Stage01_02.tscn")
	elif arg_id == WorldSliceIds.STAGE_01_03:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level03/WorldSlice_Stage01_03.tscn")
	elif arg_id == WorldSliceIds.STAGE_01_04:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level04/WorldSlice_Stage01_04.tscn")
	elif arg_id == WorldSliceIds.STAGE_01_05:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_001/Level05/WorldSlice_Stage01_05.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_02_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level01/WorldSlice_Stage02_01.tscn")
	
	
	####
	
	world = world_packed_scene.instance()
	
	world.world_id = arg_id
	
	return world

##




