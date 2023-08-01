extends Node

enum FontTypes {
	PIXEL_EMULATOR,
	ATARI_CLASSIC,
	ATARI_CLASSIC_SMOOTH,
}

var _pixel_emulator_font_size_to_font_map : Dictionary = {}
var _atari_classic_font_size_to_font_map : Dictionary = {}
var _atari_classic_smooth_font_size_to_font_map : Dictionary = {}

#

func get_font_with_size(font_type : int, font_size : int) -> DynamicFont:
	if font_type == FontTypes.PIXEL_EMULATOR:
		return get_pixel_emulator_font_with_size(font_size)
	if font_type == FontTypes.ATARI_CLASSIC:
		return get_atari_classic_font_with_size(font_size)
	if font_type == FontTypes.ATARI_CLASSIC_SMOOTH:
		return get_atari_classic_smooth_font_with_size(font_size)
	
	return null

#######

func get_pixel_emulator_font_with_size(font_size : int) -> DynamicFont:
	if _pixel_emulator_font_size_to_font_map.has(font_size):
		return _pixel_emulator_font_size_to_font_map[font_size]
	else:
		return _add_pixel_emulator_font_with_size_to_map(font_size)

func _add_pixel_emulator_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/PixelEmulator/PixelEmulator-xq08.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_pixel_emulator_font_size_to_font_map[font_size] = font
	return font


#

func get_atari_classic_font_with_size(font_size : int) -> DynamicFont:
	if _atari_classic_font_size_to_font_map.has(font_size):
		return _atari_classic_font_size_to_font_map[font_size]
	else:
		return _add_pixel_emulator_font_with_size_to_map(font_size)

func _add_atari_classic_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/AtariClassic/AtariClassic-gry3.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_atari_classic_font_size_to_font_map[font_size] = font
	return font


#

func get_atari_classic_smooth_font_with_size(font_size : int) -> DynamicFont:
	if _atari_classic_font_size_to_font_map.has(font_size):
		return _atari_classic_font_size_to_font_map[font_size]
	else:
		return _add_pixel_emulator_font_with_size_to_map(font_size)

func _add_atari_classic_smooth_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/AtariClassic/AtariClassicSmooth-XzW2.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_atari_classic_font_size_to_font_map[font_size] = font
	return font
