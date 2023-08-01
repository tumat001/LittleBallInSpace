extends MarginContainer

const TextFragmentInterpreter = preload("res://MiscRelated/TextInterpreterRelated/TextFragmentInterpreter.gd")
const AbstractTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/AbstractTextFragment.gd")


var description : String
var indicator : String
var color : Color = Color(0, 0, 0, 1)
var uses_bbcode : bool

var font_size : int = 8

#

var _tower
var _tower_info

var _text_fragment_interpreters : Array

var _use_color_for_dark_background : bool

#

onready var label = $ColumnContainer/Label

func _init(arg_indicator : String = "", arg_description : String = ""):
	description = arg_description
	indicator = arg_indicator


func _ready():
	$ColumnContainer/Indicator.text = indicator
	
	label.add_font_override("normal_font", StoreOfFonts.get_font_with_size(StoreOfFonts.FontTypes.CONSOLA, font_size))
	label.add_font_override("bold_font", StoreOfFonts.get_font_with_size(StoreOfFonts.FontTypes.CONSOLA_BOLD, font_size))
	#label.add_font_override("bold_italics_font", StoreOfFonts.get_font_with_size(StoreOfFonts.FontTypes.CONSOLA, font_size))
	#label.add_font_override("italics_font", StoreOfFonts.get_font_with_size(StoreOfFonts.FontTypes.CONSOLA, font_size))
	#label.add_font_override("mono_font", StoreOfFonts.get_font_with_size(StoreOfFonts.FontTypes.CONSOLA, font_size))
	
	
	label.bbcode_enabled = uses_bbcode
	
	if (!uses_bbcode):
		label.set("custom_colors/font_color", color)
		label.text = description
		
	else:
		
		label.bbcode_text = _get_bbc_modified_description(description)#description
	
	
	$ColumnContainer/Indicator.set("custom_colors/font_color", color)
	$ColumnContainer/Label.set("custom_colors/font_color", color)

func get_info_from_self_class(self_class):
	description = self_class.description
	indicator = self_class.indicator

#

func _get_bbc_modified_description(arg_desc : String) -> String:
	return TextFragmentInterpreter.get_bbc_modified_description_as_string(arg_desc, _text_fragment_interpreters, _tower, _tower_info, font_size, color, _use_color_for_dark_background)

#

func get_visible_character_count():
	return label.visible_characters

func set_visible_character_count(arg_count):
	label.visible_characters = arg_count

func get_percent_visible_character_count():
	return label.percent_visible

func get_total_char_count():
	return label.bbcode_text.length()
