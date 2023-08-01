extends Reference

const AbstractTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/AbstractTextFragment.gd")
const NumericalTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/NumericalTextFragment.gd")
const OutcomeTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/OutcomeTextFragment.gd")
const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

#const BaseAbility = preload("res://GameInfoRelated/AbilityRelated/BaseAbility.gd")


enum STAT_OPERATION {
	ADDITION = 1,
	MULTIPLICATION = 2,
	
	PERCENT_SUBTRACT = 3,
	DIVIDE = 4,
}

enum ESTIMATE_METHOD {
	NONE = 0,
	ROUND = 1,
	CEIL = 2,
	FLOOR = 3,
}

#


const operation_to_text_map : Dictionary = {
	STAT_OPERATION.ADDITION : "+",
	STAT_OPERATION.MULTIPLICATION : "x",
	
	STAT_OPERATION.PERCENT_SUBTRACT : "-",
	STAT_OPERATION.DIVIDE : "/",
}

#

#const ABILITY_MINIMUM_COOLDOWN = BaseAbility.ABILITY_MINIMUM_COOLDOWN

var array_of_instructions : Array
var display_body : bool
var display_header : bool = true
var header_description : String = ""

var use_color_for_dark_background : bool

var estimate_method_for_final_num_val : int = ESTIMATE_METHOD.NONE

#


func get_deep_copy():
	var copy = get_script().new()
	
	copy.array_of_instructions = []
	for ins in array_of_instructions:
		if ins is AbstractTextFragment:
			copy.array_of_instructions.append(ins.get_deep_copy())
		else:
			copy.array_of_instructions.append(ins)
	
	copy.display_body = display_body
	copy.display_header = display_header
	copy.header_description = header_description
	
	copy.use_color_for_dark_background = use_color_for_dark_background
	
	copy.estimate_method_for_final_num_val = estimate_method_for_final_num_val
	
	return copy


func interpret_array_of_instructions_to_final_text():
	return interpret_arr_to_final_text(array_of_instructions, header_description, display_body, use_color_for_dark_background, estimate_method_for_final_num_val, display_header)


#

# the array contains: AbstractTextFragment (ATF), STAT_OPERATION (SO), ATF, SO, ... , ATF
# returns a string with BBCode encoding
#
# Ex: 50 [icon] physical damage (200% [icon] total base damage [phy dmg icon] * 1 [icon] total ability potency)
# [TowerStatTextFragment(x, x, base dmg, total, 2, DamageType.PHYSICAL), STAT_OPERATION_MULTIPLY, TowerStatTextFragment(x, x, ability potency, total)]
#
# -----
# Ex: 75 [mixed dmg icon] mixed damage ((5 [phy dmg icon] + 150% [icon] bonus base damage [phy dmg icon] + 100% [icon] on hit damages [ele dmg icon]) * (2 * [icon] total ability potency))
# [[NumericalTextFragment(5, false, DamageType.PHY), STAT_OPERATION.ADDITION, TowerStatTextFragment(x, x, base dmg, bonus, 1.5, DamageType.ELEMENTAL), STAT_OPERATION.ADDITION, TowerStatTextFragment(x, x, on_hit_dmg, total)], STAT_OPERATION_MULTIPLY, TowerStatTextFragment(x, x, ability potency, total, 2)]
#
# -----
# Ex: 50% of max health [icon] elemental damage (25% [ele dmg icon] * [icon] total ability potency)
# [NumericalTextFragment(25, true, DamageType.PHY), STAT_OPERATION.MULTIPLICATION, TowerStatTextFragment(x, x, ability potency, total)]
# "of max health" comes from header_desc argument
#
static func interpret_arr_to_final_text(arg_arr : Array, arg_header_desc : String = "", 
		arg_display_body : bool = true,
		arg_use_color_for_dark_background = true, arg_estimate_method_for_final_num_val = ESTIMATE_METHOD.NONE, arg_display_header : bool = true) -> String:
	
	var portions = _interpret_arr_to_portions(arg_arr, arg_header_desc, arg_use_color_for_dark_background, arg_estimate_method_for_final_num_val)
	
	if !portions[6]:
		return "%s" % portions[2]
	
	if arg_display_body and arg_display_header:
		if !portions[5]: # no tower or tower_info is provided, but one of the inses is a TowerStatFragment ("incomplete info")
			return "%s" % portions[2]
		else:
			if portions[3]: # if outcome text fragment is not the only ins
				return "%s (%s)" % [portions[1], portions[2]]
				
			else: # outcome text fragment is the only ins 
				if portions[2].length() > 0: # is there is base string
					return "%s %s" % [portions[1], portions[2]]
				else:
					return "%s" % portions[1]
		
	elif arg_display_body:
		return "%s" % portions[2]
		
	if arg_display_header:
		return "%s" % portions[1]
		
	else:
		return "%s" % portions[1]
	


# returns an array with [(num_val in header), (header), (body)]
static func _interpret_arr_to_portions(arg_arr : Array, arg_header_desc : String = "", #arg_tower_or_enemy_to_use_for_stat_fragments = null, 
		arg_use_color_for_dark_background : bool = true, arg_estimate_method_for_final_num_val : int = ESTIMATE_METHOD.NONE) -> Array:
	
	var base_string = ""
	var num_val : float = 0.0
	var is_percent : int = -1 # -1 = unset, 1 = yes, 0 = no
	var previous_operation : int = -1
	
	var curr_outcome_text_fragment = null 
	
	var only_outcome_text_fragment_in_ins : int = -1 # -1 is unset, 1 = yes, 0 = no
	
	var at_least_one_is_tower_or_enemy_stat_fragment : bool = false
	
	#var no_enemy_info_or_tower_provided : bool = arg_enemy_to_use_for_enemy_stat_fragments == null
	
	var has_numerical_val : bool = true
	var plain_text_fragment : PlainTextFragment
	
	
	#
	
	for item in arg_arr:
		if item is PlainTextFragment:
			has_numerical_val = false
			plain_text_fragment = item
		
		if item is OutcomeTextFragment:
			curr_outcome_text_fragment = item
			if only_outcome_text_fragment_in_ins == -1:
				only_outcome_text_fragment_in_ins = 1
			
			continue
		
		only_outcome_text_fragment_in_ins = 0
		
		
		if item is AbstractTextFragment:
			if arg_use_color_for_dark_background:
				item.color_mode = AbstractTextFragment.ColorMode.FOR_DARK_BACKGROUND
			else:
				item.color_mode = AbstractTextFragment.ColorMode.FOR_LIGHT_BACKGROUND
			
			base_string += "%s" % _interpret_AFT_to_text(item)
			
			
			if item is NumericalTextFragment:
				if is_percent == -1:
					if item._is_percent == true:
						is_percent = 1
					else:
						is_percent = 0
			
			
			if item.has_numerical_value:
				if previous_operation == -1 or previous_operation == STAT_OPERATION.ADDITION:
					num_val += _interpret_AFT_to_num(item)
				elif previous_operation == STAT_OPERATION.MULTIPLICATION:
					num_val *= _interpret_AFT_to_num(item)
				elif previous_operation == STAT_OPERATION.PERCENT_SUBTRACT:
					num_val -= (_interpret_AFT_to_num(item) / 100) * num_val
				elif previous_operation == STAT_OPERATION.DIVIDE:
					num_val /= _interpret_AFT_to_num(item)
				
				
			
			
		elif typeof(item) == TYPE_STRING: # just a string
			base_string += " %s" % item
			
		elif typeof(item) == TYPE_ARRAY:
			var portions = _interpret_arr_to_portions(item, "", arg_use_color_for_dark_background, arg_estimate_method_for_final_num_val)
			
			base_string += "(%s)" % portions[2]
			
			var metadata_of_inner = portions[4]
			
			if previous_operation == -1 or previous_operation == STAT_OPERATION.ADDITION:
				num_val += portions[0]
			elif previous_operation == STAT_OPERATION.MULTIPLICATION:
				num_val *= portions[0]
			elif previous_operation == STAT_OPERATION.PERCENT_SUBTRACT:
				num_val -= portions[0]
			elif previous_operation == STAT_OPERATION.DIVIDE:
				num_val /= portions[0]
			
			if is_percent == -1:
				if metadata_of_inner[0] == 1:
					is_percent = 1
				elif metadata_of_inner[0] == 0:
					is_percent = 0
			
			
		elif typeof(item) == TYPE_INT: # Stat operation
			base_string += " %s " % operation_to_text_map[item]
			previous_operation = item
	
	#
	
	if arg_estimate_method_for_final_num_val == ESTIMATE_METHOD.ROUND:
		num_val = round(num_val)
	elif arg_estimate_method_for_final_num_val == ESTIMATE_METHOD.FLOOR:
		num_val = floor(num_val)
	elif arg_estimate_method_for_final_num_val == ESTIMATE_METHOD.CEIL:
		num_val = ceil(num_val)
	
	
	var frag_header
	if curr_outcome_text_fragment == null:
		if plain_text_fragment == null:
			frag_header = NumericalTextFragment.new(num_val, is_percent, arg_header_desc, true)
		else:
			frag_header = plain_text_fragment
	else:
		frag_header = curr_outcome_text_fragment
		
		if only_outcome_text_fragment_in_ins != 1:
			frag_header.is_percent = is_percent
			frag_header.num_val = num_val
			frag_header._text_desc = arg_header_desc
	
	frag_header.color_mode = arg_use_color_for_dark_background
	
	#
	
	return [num_val, _interpret_AFT_to_text(frag_header), base_string, !only_outcome_text_fragment_in_ins, [is_percent], has_numerical_val] #5



#

static func _interpret_AFT_to_text(arg_aft : AbstractTextFragment) -> String:
	return arg_aft._get_as_text()

static func _interpret_AFT_to_num(arg_aft : AbstractTextFragment) -> float:
	return arg_aft._get_as_numerical_value()


#


static func get_bbc_modified_description_as_string(arg_desc : String, arg_text_fragment_interpreters : Array, arg_tower, arg_tower_info,
		arg_font_size : int, arg_color_for_common_text : Color, arg_use_color_for_dark_background : bool, arg_enemy = null, arg_enemy_info = null) -> String:
	
	var index = 0
	
	for interpreter in arg_text_fragment_interpreters:
		
		if interpreter is PlainTextFragment:
			# in this case, interpreter is an item/fragment
			if arg_use_color_for_dark_background:
				interpreter.color_mode = AbstractTextFragment.ColorMode.FOR_DARK_BACKGROUND
			else:
				interpreter.color_mode = AbstractTextFragment.ColorMode.FOR_LIGHT_BACKGROUND
			
			var text = interpreter.get_as_text_for_tooltip()
			
			arg_desc = arg_desc.replace("|%s|" % str(index), text)
			
		else:
			# if you see "invalid set index 'use_color...'... on base array, with value type 'bool', then you've inserted an array of ins instead of the interpreter.
			interpreter.use_color_for_dark_background = arg_use_color_for_dark_background
			
			if !is_instance_valid(interpreter.tower_to_use_for_tower_stat_fragments):
				interpreter.tower_to_use_for_tower_stat_fragments = arg_tower
			if interpreter.get_tower_info_to_use_for_tower_stat_fragments() == null:
				interpreter.set_tower_info_to_use_for_tower_stat_fragments(arg_tower_info)
			
			#
			
			if !is_instance_valid(interpreter.enemy_to_use_for_enemy_stat_fragments):
				interpreter.enemy_to_use_for_enemy_stat_fragments = arg_enemy
			if interpreter.get_enemy_info_to_use_for_enemy_stat_fragments() == null:
				interpreter.set_enemy_info_to_use_for_enemy_stat_fragments(arg_enemy_info)
			
			#
			
			var interpreted_text = interpreter.interpret_array_of_instructions_to_final_text()
			arg_desc = arg_desc.replace("|%s|" % str(index), interpreted_text)
		
		index += 1
	
	arg_desc = arg_desc.replace(AbstractTextFragment.width_img_val_placeholder, str((arg_font_size / 2) + 2))
	
	
	return "[color=#%s]%s[/color]" % [arg_color_for_common_text.to_html(false), arg_desc]

