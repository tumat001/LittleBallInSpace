extends Node

enum FontTypes {
	PIXEL_EMULATOR,
	ATARI_CLASSIC,
	ATARI_CLASSIC_SMOOTH,
	CONSOLA,
	CAROLYN_HANDWRITTEN,
}

const _pixel_emulator_font_size_to_font_map : Dictionary = {}
const _atari_classic_font_size_to_font_map : Dictionary = {}
const _atari_classic_smooth_font_size_to_font_map : Dictionary = {}
const _consola_font_size_to_font_map : Dictionary = {}
const _carolyn_handwritten_font_size_to_font_map : Dictionary = {}


#

static func get_font_with_size(font_type : int, font_size : int) -> DynamicFont:
	if font_type == FontTypes.PIXEL_EMULATOR:
		return get_pixel_emulator_font_with_size(font_size)
	if font_type == FontTypes.ATARI_CLASSIC:
		return get_atari_classic_font_with_size(font_size)
	if font_type == FontTypes.ATARI_CLASSIC_SMOOTH:
		return get_atari_classic_smooth_font_with_size(font_size)
	if font_size == FontTypes.CONSOLA:
		return get_consola_font_with_size(font_size)
	if font_size == FontTypes.CAROLYN_HANDWRITTEN:
		return get_carolyn_handwritten_font_with_size(font_size)
	
	return null

#######

static func get_pixel_emulator_font_with_size(font_size : int) -> DynamicFont:
	if _pixel_emulator_font_size_to_font_map.has(font_size):
		return _pixel_emulator_font_size_to_font_map[font_size]
	else:
		return _add_pixel_emulator_font_with_size_to_map(font_size)

static func _add_pixel_emulator_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/PixelEmulator/PixelEmulator-xq08.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_pixel_emulator_font_size_to_font_map[font_size] = font
	return font


#

static func get_atari_classic_font_with_size(font_size : int) -> DynamicFont:
	if _atari_classic_font_size_to_font_map.has(font_size):
		return _atari_classic_font_size_to_font_map[font_size]
	else:
		return _add_atari_classic_font_with_size_to_map(font_size)

static func _add_atari_classic_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/AtariClassic/AtariClassic-gry3.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_atari_classic_font_size_to_font_map[font_size] = font
	return font


#

static func get_atari_classic_smooth_font_with_size(font_size : int) -> DynamicFont:
	if _atari_classic_font_size_to_font_map.has(font_size):
		return _atari_classic_font_size_to_font_map[font_size]
	else:
		return _add_atari_classic_smooth_font_with_size_to_map(font_size)

static func _add_atari_classic_smooth_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/AtariClassic/AtariClassicSmooth-XzW2.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_atari_classic_font_size_to_font_map[font_size] = font
	return font


#

static func get_consola_font_with_size(font_size : int) -> DynamicFont:
	if _consola_font_size_to_font_map.has(font_size):
		return _consola_font_size_to_font_map[font_size]
	else:
		return _add_consola_font_with_size_to_map(font_size)

static func _add_consola_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/Consola/CONSOLA.ttf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_consola_font_size_to_font_map[font_size] = font
	return font

#

static func get_carolyn_handwritten_font_with_size(font_size : int) -> DynamicFont:
	if _carolyn_handwritten_font_size_to_font_map.has(font_size):
		return _carolyn_handwritten_font_size_to_font_map[font_size]
	else:
		return _add_carolyn_handwritten_font_with_size_to_map(font_size)

static func _add_carolyn_handwritten_font_with_size_to_map(font_size : int) -> DynamicFont:
	var font_data = DynamicFontData.new()
	font_data.font_path = "res://MiscRelated/FontRelated/Fonts/CarolynHandwritten/CarolynHandwrittenMedium-lqry.otf"
	
	var font = DynamicFont.new()
	font.font_data = font_data
	font.size = font_size
	
	_carolyn_handwritten_font_size_to_font_map[font_size] = font
	return font


