extends Node


enum WorldSliceIds {
	STAGE_TEST_01 = -10
	
	STAGE_01_01 = 1
	STAGE_01_02 = 2
	STAGE_01_03 = 3
	STAGE_01_04 = 4
	STAGE_01_05 = 5
	
	STAGE_02_01 = 100
	STAGE_02_02 = 101
	STAGE_02_03 = 102
	STAGE_02_04 = 103
	STAGE_02_05 = 104
	STAGE_02_06 = 105
	
	STAGE_02_02__HARD = 150
	STAGE_02_06__HARD = 151
	
	STAGE_03_01 = 200
	STAGE_03_02 = 201
	STAGE_03_03 = 202
	STAGE_03_04 = 203
	STAGE_03_05 = 204
	
	STAGE_03_03__HARD = 250
	STAGE_03_04__HARD = 251
	STAGE_03_05__HARD = 252
	
	STAGE_04_01 = 300
	STAGE_04_02 = 301
	STAGE_04_03 = 302
	STAGE_04_04 = 303
	STAGE_04_05 = 304
	
	STAGE_04_03__HARD = 350
	STAGE_04_04__HARD = 351
	STAGE_04_05__HARD = 352
	
	STAGE_05_01 = 400
	STAGE_05_02 = 401
	
	#
	
	STAGE_SPECIAL01_01 = 10000
	STAGE_SPECIAL01_02 = 10001
	STAGE_SPECIAL01_03 = 10002
	STAGE_SPECIAL01_04 = 10003
	
	#
	
	STAGE_06_01 = 500
	STAGE_06_02 = 501
	STAGE_06_03 = 502
	STAGE_06_04 = 503
	STAGE_06_05 = 504
	STAGE_06_06 = 505
	STAGE_06_07 = 506
	
	STAGE_06_04__HARD = 550
	STAGE_06_04__HARD_V02 = 551
	STAGE_06_06__HARD = 552
	STAGE_06_06__HARD_V02 = 553
	STAGE_06_07__HARD = 554
	
	STAGE_07_01 = 600
	
	#
	
	STAGE_SPECIAL02_01 = 10100
	STAGE_SPECIAL02_02 = 10101
	
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
		
	elif arg_id == WorldSliceIds.STAGE_02_02__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level02_Hard/WorldSlice_Stage02_02_Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_02_06__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_002/Level06_Hard/WorldSlice_Stage02_06_Hard.tscn")
		
		
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
		
	elif arg_id == WorldSliceIds.STAGE_03_03__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level03_Hard/WorldSlice_Stage03_03_Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_03_04__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level04_Hard/WorldSlice_Stage03_04_Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_03_05__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_003/Level05_Hard/WorldSlice_Stage03_05_Hard.tscn")
		
		
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
		
		
	elif arg_id == WorldSliceIds.STAGE_04_03__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level03_Hard/WorldSlice_Stage04_03_Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_04_04__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level04_Hard/WorldSlice_Stage04_04__Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_04_05__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_004/Level05_Hard/WorldSlice_Stage04_05_Hard.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_05_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_005/Level01/WorldSlice_Stage05_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_05_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_005/Level02/WorldSlice_Stage05_02.tscn")
		
		
		
	elif arg_id == WorldSliceIds.STAGE_SPECIAL01_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Special001/Level01/WorldSlice_StageSpecial01_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_SPECIAL01_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Special001/Level02/WorldSlice_StageSpecial01_02.tscn")
	elif arg_id == WorldSliceIds.STAGE_SPECIAL01_03:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Special001/Level03/WorldSlice_StageSpecial01_03.tscn")
	elif arg_id == WorldSliceIds.STAGE_SPECIAL01_04:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Special001/Level04/WorldSlice_StageSpecial01_04.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_06_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level01/WorldSlice_Stage06_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level02/WorldSlice_Stage06_02.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_03:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level03/WorldSlice_Stage06_03.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_04:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level04/WorldSlice_Stage06_04.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_05:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level05/WorldSlice_Stage06_05.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_06:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level06/WorldSlice_Stage06_06.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_07:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level07/WorldSlice_Stage06_07.tscn")
		
	elif arg_id == WorldSliceIds.STAGE_06_04__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level04_Hard/WorldSlice_Stage06_04_Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_04__HARD_V02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level04_Hard_V02/WorldSlice_Stage06_04_Hard_V02.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_06__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level06_Hard/WorldSlice_Stage06_06_Hard.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_06__HARD_V02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level06_Hard_V02/WorldSlice_Stage06_06_Hard_V02.tscn")
	elif arg_id == WorldSliceIds.STAGE_06_07__HARD:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_006/Level07_Hard/WorldSlice_Stage06_07_Hard.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_07_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_007/Level01/WorldSlice_Stage07_01.tscn")
		
		
	elif arg_id == WorldSliceIds.STAGE_SPECIAL02_01:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Special002/Level01/WorldSlice_StageSpecial02_01.tscn")
	elif arg_id == WorldSliceIds.STAGE_SPECIAL02_02:
		world_packed_scene = load("res://WorldRelated/WorldSlices/Stage_Special002/Level02/WorldSlice_StageSpecial02_02.tscn")
	
	
	####
	
	world = world_packed_scene.instance()
	
	world.world_id = arg_id
	
	return world

##




