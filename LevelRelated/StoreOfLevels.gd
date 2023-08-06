extends Node

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")


#####

enum LevelIds {
	TEST = -10,
	
	LEVEL_01 = 1
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
		level_details.level_name = [
			["TestName Desc", []]
		]
		level_details.level_desc = [
			["Testing Desc Lorem ipsum", []]
		]
		
		#level_details.texture_of_level_tile
		level_details.modulate_of_level_tile = Color(1, 1, 0, 1)
		
		#level_details.texture_of_level_tile__locked
		level_details.modulate_of_level_tile__locked = Color(1, 0, 0, 1)
		
		_set_details__to_usual_circle_types(level_details)
		
		
		
	elif arg_id == LevelIds.LEVEL_01:
		level_details.level_name = [
			["Beginnings", []]
		]
		level_details.level_desc = [
			["A step in a thousand mile journey... Well, you can't really make a step here but you know what I mean..."]
		]
		
		
	
	_level_id_to_level_details_map[arg_id] = level_details
	
	return level_details



# All black
static func _set_details__to_usual_circle_types(arg_details : LevelDetails):
	arg_details.transition_id__entering_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__entering_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_level__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK


#####

static func generate_base_level_imp_new(arg_id):
	if arg_id == LevelIds.TEST:
		return load("res://LevelRelated/BaseLevelImps/Test/Level_Test01.gd").new()
	elif arg_id == LevelIds.LEVEL_01:
		#todo
		return load("res://LevelRelated/BaseLevelImps/Test/Level_Test01.gd").new()
		
	


