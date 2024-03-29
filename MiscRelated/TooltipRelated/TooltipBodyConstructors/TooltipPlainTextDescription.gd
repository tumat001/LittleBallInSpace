extends MarginContainer

const TextFragmentInterpreter = preload("res://MiscRelated/TextInterpreterRelated/TextFragmentInterpreter.gd")
const AbstractTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/AbstractTextFragment.gd")

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")


#

#const font_name : String = "TooltipLabelFont"

var description : String
var color : Color = Color(0, 0, 0, 1)
var font_size : int = 24 setget set_font_size
var uses_bbcode : bool
var font_id_to_use : int = StoreOfFonts.FontTypes.MONOGRAM setget set_font_id_to_use

onready var label = $Label

#

var _can_update_label_font : bool = false

#

var _tower = null
var _tower_info = null

var _text_fragment_interpreters : Array

var _use_color_for_dark_background : bool

#

func set_font_size(arg_size):
	font_size = arg_size
	
	if is_inside_tree() and _can_update_label_font:
		label.add_font_override("normal_font", StoreOfFonts.get_font_with_size(font_id_to_use, font_size))
		label.add_font_override("bold_font", StoreOfFonts.get_font_with_size(font_id_to_use, font_size))

func set_font_id_to_use(arg_id):
	font_id_to_use = arg_id
	
	if is_inside_tree() and _can_update_label_font:
		label.add_font_override("normal_font", StoreOfFonts.get_font_with_size(font_id_to_use, font_size))
		label.add_font_override("bold_font", StoreOfFonts.get_font_with_size(font_id_to_use, font_size))


#

func _init(arg_description : String = ""):
	description = arg_description

func _ready():
	_can_update_label_font = false
	
	
	set_font_size(font_size)
	
	_can_update_label_font = true
	set_font_id_to_use(font_id_to_use)
	
	
	##############
	
	label.bbcode_enabled = uses_bbcode
	
	if (!uses_bbcode):
		label.set("custom_colors/font_color", color)
		label.text = description
		
	else:
		
		label.bbcode_text = _get_bbc_modified_description(description)
	

func get_info_from_self_class(self_class):
	description = self_class.description

#

func _get_bbc_modified_description(arg_desc : String) -> String:
	return TextFragmentInterpreter.get_bbc_modified_description_as_string(arg_desc, _text_fragment_interpreters, _tower, _tower_info, font_size, color, _use_color_for_dark_background)
#	var index = 0
#
#	for interpreter in _text_fragment_interpreters:
#		interpreter.use_color_for_dark_background = _use_color_for_dark_background
#
#		if interpreter.tower_to_use_for_tower_stat_fragments == null:
#			interpreter.tower_to_use_for_tower_stat_fragments = _tower
#
#		if interpreter.tower_info_to_use_for_tower_stat_fragments == null:
#			interpreter.tower_info_to_use_for_tower_stat_fragments = _tower_info
#
#
#		var interpreted_text = interpreter.interpret_array_of_instructions_to_final_text()
#		arg_desc = arg_desc.replace("|%s|" % str(index), interpreted_text)
#
#		index += 1
#
#	arg_desc = arg_desc.replace(AbstractTextFragment.width_img_val_placeholder, str(font_size / 2))
#
#
#	return "[color=#%s]%s[/color]" % [color.to_html(false), arg_desc]

#

func get_visible_character_count():
	return label.visible_characters

func set_visible_character_count(arg_count):
	var total_char = get_total_char_count()
	if total_char < arg_count:
		arg_count = total_char
	
	label.visible_characters = arg_count

func get_percent_visible_character_count():
	return label.percent_visible


func get_total_char_count():
	return label.get_total_character_count()

