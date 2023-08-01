extends "res://MiscRelated/TextInterpreterRelated/TextFragments/AbstractTextFragment.gd"


var _text_desc : String
var _has_space_between_num_and_text : bool
var _is_percent : bool

var _stat_type : int

func _init(
		arg_stat_type : int,
		arg_text_desc : String = "",
		arg_has_spacing : bool = false).(true):
	
	_text_desc = arg_text_desc
	_has_space_between_num_and_text = arg_has_spacing
	_stat_type = arg_stat_type
	
	has_numerical_value = false

#

func _get_as_text() -> String:
	var base_string = ""
	
	if _has_space_between_num_and_text:
		base_string += " " + _text_desc
	else:
		base_string += _text_desc
	
	if _stat_type != -1:
		base_string += " [img=<%s>]%s[/img]" % [width_img_val_placeholder, _get_img_path_for_type(_stat_type)]
	
	
	return "[color=%s]%s[/color]" % [_get_type_color_map_to_use(_stat_type), base_string]

#

func get_as_text_for_tooltip() -> String:
	return _get_as_text()

#

func get_deep_copy():
	var copy = get_script().new(_text_desc, _stat_type, _has_space_between_num_and_text)
	
	._configure_copy_to_match_self(copy)
	
	return copy

