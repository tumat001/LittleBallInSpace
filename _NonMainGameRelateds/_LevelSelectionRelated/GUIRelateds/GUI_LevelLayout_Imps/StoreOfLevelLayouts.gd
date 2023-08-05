extends Node

#

const LevelLayoutDetails = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/LevelLayoutDetails.gd")
const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

enum LevelLayoutIds {
	NONE = -1
	
	LAYOUT_01 = 1
}

const FIRST_LEVEl_LAYOUT = LevelLayoutIds.LAYOUT_01

#

var _layout_id_to_layout_details_map : Dictionary

##

func generate_instance_of_layout(arg_id):
	var scene_ref
	
	if arg_id == LevelLayoutIds.LAYOUT_01:
		#scene_ref = preload()
		pass
	
	
	return scene_ref.instance()


#

func get_or_construct_layout_details(arg_id) -> LevelLayoutDetails:
	var details : LevelLayoutDetails
	
	if arg_id == LevelLayoutIds.LAYOUT_01:
		_set_details_transition_types__to_usual_circle_types(details)
		
	
	return details


# All black
func _set_details_transition_types__to_usual_circle_types(arg_details : LevelLayoutDetails):
	arg_details.transition_id__entering_layout__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__entering_layout__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_layout__in = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK
	arg_details.transition_id__exiting_layout__out = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK


