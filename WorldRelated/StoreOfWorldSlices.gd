extends Node


enum WorldSliceIds {
	STAGE_TEST_01 = -10
	
	STAGE_01_01 = 1
	STAGE_01_02 = 2
	STAGE_01_03 = 3
	STAGE_01_04 = 4
	STAGE_01_05 = 5
	
	STAGE_02_01 = 10
	STAGE_02_02 = 11
	STAGE_02_03 = 12
	STAGE_02_04 = 13
	STAGE_02_05 = 14
	STAGE_02_06 = 15
	
	STAGE_03_01 = 20
	STAGE_03_02 = 21
	STAGE_03_03 = 22
	STAGE_03_04 = 23
	STAGE_03_05 = 24
	
	STAGE_04_01 = 30
	STAGE_04_02 = 31
	STAGE_04_03 = 32
	STAGE_04_04 = 33
	STAGE_04_05 = 34
	
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
	elif arg_id == WorldSliceIds.STAGE_02_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level02/WorldSlice_Stage02_02.tscn")
	elif arg_id == WorldSliceIds.STAGE_02_03:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level03/WorldSlice_Stage02_03.tscn")
	elif arg_id == WorldSliceIds.STAGE_02_04:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level04/WorldSlice_Stage02_04.tscn")
	elif arg_id == WorldSliceIds.STAGE_02_05:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level05/WorldSlice_Stage02_05.tscn")
	elif arg_id == WorldSliceIds.STAGE_02_06:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level06/WorldSlice_Stage02_06.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_03_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level01/WorldSlice_Stage03_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_03_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level02/WorldSlice_Stage03_02.tscn")
	elif arg_id == WorldSliceIds.STAGE_03_03:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level03/WorldSlice_Stage03_03.tscn")
	elif arg_id == WorldSliceIds.STAGE_03_04:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level04/WorldSlice_Stage03_04.tscn")
	elif arg_id == WorldSliceIds.STAGE_03_05:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level05/WorldSlice_Stage03_05.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_04_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level01/WorldSlice_Stage04_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_04_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level02/WorldSlice_Stage04_02.tscn")
	elif arg_id == WorldSliceIds.STAGE_04_03:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level03/WorldSlice_Stage04_03.tscn")
	elif arg_id == WorldSliceIds.STAGE_04_04:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level04/WorldSlice_Stage04_04.tscn")
	elif arg_id == WorldSliceIds.STAGE_04_05:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level05/WorldSlice_Stage04_05.tscn")
	
	
	####
	
	world = world_packed_scene.instance()
	
	world.world_id = arg_id
	
	return world

##




