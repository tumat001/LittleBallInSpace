extends Reference


enum AnimTypes {
	NONE = -1
	ACTION = 0,
	CALM = 1,
	SUPER_ACTION = 2,  # foreground becomes white instead of black
}

#

enum VicDefAnimIds {
	NONE = -1
	
	Vic_ActionStyle_Normal_01 = 0
	Def_ActionStyle_Normal_01 = 1
}


#

const all_anim__vic__action_style__ids = [
	VicDefAnimIds.Vic_ActionStyle_Normal_01
]

const all_anim__def__action_style__ids = [
	VicDefAnimIds.Def_ActionStyle_Normal_01
]


const all_anim__vic__calm_style__ids = [
	
]

const all_anim__def__calm_style__ids = [
	
]



const all_anim__vic__super_action_style__ids = [
	
]

const all_anim__def__super_action_style__ids = [
	
]


####

static func get_instance_of_anim_id(arg_id):
	if arg_id == VicDefAnimIds.NONE or arg_id == null:
		return null
	
	
	var anim_class_file
	
	if arg_id == VicDefAnimIds.Vic_ActionStyle_Normal_01:
		anim_class_file = load("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/Imps/VicAnim_ActionStyle_01/VicAnim_ActionStyle_01.tscn")
	elif arg_id == VicDefAnimIds.Def_ActionStyle_Normal_01:
		anim_class_file = load("res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/Imps/DefAnim_ActionStyle_01/DefAnim_ActionStyle_01.tscn")
	
	return anim_class_file.instance()


static func get_random_anim_id(arg_is_vic, arg_type : int):
	if arg_type == AnimTypes.NONE:
		return null
	
	
	var rng = StoreOfRng.get_rng(StoreOfRng.RNGSource.NON_ESSENTIAL)
	
	if arg_is_vic:
		if arg_type == AnimTypes.ACTION:
			return StoreOfRng.randomly_select_one_element(all_anim__vic__action_style__ids, rng)
			
		elif arg_type == AnimTypes.CALM:
			pass
			
		elif arg_type == AnimTypes.SUPER_ACTION:
			pass
			
		
	else:
		if arg_type == AnimTypes.ACTION:
			return StoreOfRng.randomly_select_one_element(all_anim__def__action_style__ids, rng)
			
		elif arg_type == AnimTypes.CALM:
			pass
			
		elif arg_type == AnimTypes.SUPER_ACTION:
			pass
			
		
		


