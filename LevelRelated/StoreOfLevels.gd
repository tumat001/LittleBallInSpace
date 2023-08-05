extends Node

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")


enum LevelIds {
	TEST = -10,
	
}

const _level_id_to_level_details_map : Dictionary = {}


# should never happen normally...
const DEFAULT_LEVEL_ID_FOR_EMPTY = LevelIds.TEST

#

static func is_level_id_exists(arg_id):
	return LevelIds.values().has(arg_id)


#

static func generate_or_get_level_details_of_id(arg_id) -> LevelDetails:
	if _level_id_to_level_details_map.has(arg_id):
		return _level_id_to_level_details_map[arg_id]
	
	#######
	
	var level_details : LevelDetails = LevelDetails.new()
	level_details.level_id = arg_id
	
	if arg_id == LevelIds.TEST:
		level_details.level_name = ["TestName Desc", []]
		level_details.level_desc = ["Testing Desc Lorem ipsum", []]
	
	
	_level_id_to_level_details_map[arg_id] = level_details
	
	return level_details

#####

static func generate_base_level_imp_new(arg_id):
	if arg_id == LevelIds.TEST:
		return preload("res://LevelRelated/BaseLevelImps/Test/Level_Test01.gd").new()
		



