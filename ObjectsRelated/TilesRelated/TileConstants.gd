extends Node


const LightTextureConstructor = preload("res://MiscRelated/Light2DRelated/LightTextureConstructor.gd")



const BREAKABLE_GLASS_TILE__MASS = 30


# THESE are not custom defined. THESE are defined by tileset resource
const BREAKABLE_GLASS_TILE_ID__ATLAS_01 = 2
const BREAKABLE_GLASS_TILE_ID__ATLAS_02 = 3

const BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01 = 4
const BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02 = 5


const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01 = 6
const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02 = 7

const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01 = 8
const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02 = 9


#

# structure: tile id -> tile auto coord -> segment size -> [[atlased images, top_left_pos], length]
var _atlased_imgs_of_tile_fragments_map : Dictionary = {}

# structure: tile id -> tile auto coord -> img
var _tile_id_to_auto_coord_to_img_map : Dictionary = {}

# structure: tile id -> region -> atlas img
var _tile_id_to_region_to_img_map : Dictionary = {}


####################

const ANY_AUTO_COORD = Vector2(-1, -1)
var _tile_id_to_auto_coord_to_sound_id_map__normal_and_loud : Dictionary
var _breakable_tile_id_to_auto_coord_to_sound_id_map : Dictionary


var _uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map : Dictionary

class LightDetails:
	var light_texture : GradientTexture2D
	var rotation : float = 0.0
	var offset : Vector2 = Vector2.ZERO setget ,get_offset
	
	func get_offset():
		return offset.rotated(rotation)

#

func _ready():
	_initialize_all_tile_to_sound_id_map()
	_initialize_all_uncol_tile_to_light_tex_rect_size_and_color_gradient_map()

#

static func is_tile_id_fillable_or_unfillable(arg_id):
	match arg_id:
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01, TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02:
			return true
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01, TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02:
			return true
	
	return false


static func is_tile_id_filled(arg_id):
	match arg_id:
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01, TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02:
			return true
	
	return false

static func convert_unfilled_tile_id__to_filled(arg_id):
	if arg_id == TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01:
		return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01
	elif arg_id == TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02:
		return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02


static func convert_filled_tile_id__to_unfilled(arg_id):
	if arg_id == TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01:
		return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01
	elif arg_id == TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02:
		return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02


#

static func is_tile_id_glowing(arg_id):
	match arg_id:
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01, BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
			return true
	
	return false


static func convert_non_glowing_breakable_tile_id__to_glowing(arg_id):
	if arg_id == BREAKABLE_GLASS_TILE_ID__ATLAS_01:
		return BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01
	elif arg_id == BREAKABLE_GLASS_TILE_ID__ATLAS_02:
		return BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02
		

static func convert_glowing_breakable_tile_id__to_non_glowing(arg_id):
	if arg_id == BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01:
		return BREAKABLE_GLASS_TILE_ID__ATLAS_01
	elif arg_id == BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
		return BREAKABLE_GLASS_TILE_ID__ATLAS_02
		


##################

static func get_mass_of_tile_id(arg_id, arg_coords : Vector2):
	match arg_id:
		BREAKABLE_GLASS_TILE_ID__ATLAS_01:
			return BREAKABLE_GLASS_TILE__MASS
		BREAKABLE_GLASS_TILE_ID__ATLAS_02:
			return BREAKABLE_GLASS_TILE__MASS
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01:
			return BREAKABLE_GLASS_TILE__MASS
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
			return BREAKABLE_GLASS_TILE__MASS
			



###############################

func generate_object_tile_fragments(arg_global_pos : Vector2, arg_top_left_local_pos : Vector2,
		arg_img : Texture, arg_segments : int,
		arg_tile_id : int, arg_tile_coords : Vector2):
	
	var fragment_mass = get_mass_of_tile_id(arg_tile_id, arg_tile_coords) / arg_segments
	
	var fragments : Array = []
	
	var atlasted_textures_and_poses__and_length = generate_or_load_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_img, arg_segments, arg_tile_id, arg_tile_coords)
	var length = atlasted_textures_and_poses__and_length[1]
	for texture_and_top_left_pos in atlasted_textures_and_poses__and_length[0]:
		var tile_fragment_obj = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.TILE_FRAGMENT)
		
		tile_fragment_obj.texture_to_use__fragment = texture_and_top_left_pos[0]
		var mid_mag = (length / 2.0)
		tile_fragment_obj.position = texture_and_top_left_pos[1] + Vector2(mid_mag, mid_mag) + arg_global_pos
		
		tile_fragment_obj.mass = fragment_mass
		
		fragments.append(tile_fragment_obj)
	
	return fragments


# segment of 9 of 9x9 img = 9 3x3 imgs
func generate_or_load_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_img : Texture, arg_segments : int, 
		arg_tile_id : int, arg_tile_coords : Vector2) -> Array:
	
	if has_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_tile_id, arg_tile_coords, arg_segments):
		return _atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords][arg_segments]
	
	########
	
	var img_size = arg_img.get_size()
	
	var rects : Array = generate_rects_for_size(img_size, arg_segments)
	#var atlased_textures : Array = []
	#var top_left_poses : Array = []
	var atlased_textures_and_top_left_poses = []
	var length : float
	
	for rect in rects:
		var atlased_texture = AtlasTexture.new()
		atlased_texture.region = rect
		atlased_texture.atlas = arg_img
		atlased_texture.filter_clip = true
		#atlased_textures.append(atlased_texture)
		
		length = rect.size.x
		
		#top_left_poses.append(rect.position)
		
		atlased_textures_and_top_left_poses.append([atlased_texture, rect.position])
	
	if arg_tile_id != -1:
		if !_atlased_imgs_of_tile_fragments_map.has(arg_tile_id):
			_atlased_imgs_of_tile_fragments_map[arg_tile_id] = {}
		
		if !_atlased_imgs_of_tile_fragments_map[arg_tile_id].has(arg_tile_coords):
			_atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords] = {}  #.append(arg_tile_coords)
		
		if _atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords].has(arg_segments):
			_atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords][arg_segments] = [atlased_textures_and_top_left_poses, length]
	
	return [atlased_textures_and_top_left_poses, length] #atlased_textures

func has_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_tile_id : int, arg_tile_coords : Vector2, arg_segments):
	if arg_tile_id != -1 and _atlased_imgs_of_tile_fragments_map.has(arg_tile_id):
		if _atlased_imgs_of_tile_fragments_map[arg_tile_id].has(arg_tile_coords):
			if _atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords].has(arg_segments):
				return true
	
	return false


func generate_rects_for_size(arg_size : Vector2, arg_segments : int) -> Array:
	var root_segment_ceil = stepify(sqrt(arg_segments), 0.1)
	
	var full_length_per_segment = arg_size.x / root_segment_ceil
	var lengths : Array = []
	var remaining_length = arg_size.x
	while (remaining_length >= full_length_per_segment):
		remaining_length -= full_length_per_segment
		if remaining_length < 0:
			lengths.append(full_length_per_segment - remaining_length)
		else:
			lengths.append(full_length_per_segment)
	
	##
	
	var rects : Array = []
	var total_x_traversed = 0
	for length in lengths:
		var old_x_total = total_x_traversed
		total_x_traversed += length
		
		var total_y_traversed = 0
		for i in lengths.size():
			var old_y_total = total_y_traversed
			total_y_traversed += length
			
			rects.append(Rect2(old_x_total, old_y_total, length, length))
	
	
	
	return rects


#############

func get_atlas_texture_from_tile_sheet_id(arg_tile_id, arg_auto_coord):
	return _tile_id_to_auto_coord_to_img_map[arg_tile_id][arg_auto_coord]


func generate_atlas_textures_for_tile_sheet(arg_tile_id, arg_tilesheet : Texture, arg_cell_length_and_width : float):
	var tilesheet_size = arg_tilesheet.get_size()
	var segment_count = (tilesheet_size.x / arg_cell_length_and_width)
	segment_count *= segment_count
	
	_tile_id_to_auto_coord_to_img_map[arg_tile_id] = {}
	
	var rects_and_autocoords = generate_rects_for_size__and_autocoords(tilesheet_size, segment_count)
	for rect_and_autocoord in rects_and_autocoords:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = arg_tilesheet
		atlas_texture.region = rect_and_autocoord[0]
		
		_tile_id_to_auto_coord_to_img_map[arg_tile_id][rect_and_autocoord[1]] = atlas_texture
	
	return true

func has_atlas_textures_for_tile_sheet(arg_tile_id):
	return _tile_id_to_auto_coord_to_img_map.has(arg_tile_id)


func generate_rects_for_size__and_autocoords(arg_size : Vector2, arg_segments : int) -> Array:
	var root_segment_ceil = ceil(sqrt(arg_segments))
	
	var full_length_per_segment = arg_size.x / root_segment_ceil
	var lengths : Array = []
	var remaining_length = arg_size.x
	while (remaining_length > 0):
		remaining_length -= full_length_per_segment
		if remaining_length < 0:
			lengths.append(full_length_per_segment - remaining_length)
		else:
			lengths.append(full_length_per_segment)
	
	##
	
	var rects_and_auto_coords : Array = []
	#var auto_coords : Array = []
	
	var i_x = 0
	var total_x_traversed = 0
	for length in lengths:
		var old_x_total = total_x_traversed
		total_x_traversed += length
		
		var total_y_traversed = 0
		for i_y in lengths.size():
			var old_y_total = total_y_traversed
			total_y_traversed += length
			
			#rects.append(Rect2(old_x_total, old_y_total, length, length))
			#auto_coords.append([i_x + 1, i_y + 1])
			
			var rect = Rect2(old_x_total, old_y_total, length, length)
			var auto_coords = Vector2(i_x, i_y)
			rects_and_auto_coords.append([rect, auto_coords])
		
		i_x += 1
	
	return rects_and_auto_coords


############

func generate_atlas_img_for_tilesheet_on_region(arg_tile_id, arg_region : Rect2, arg_tilesheet : Texture):
	var atlas_img = AtlasTexture.new()
	atlas_img.atlas = arg_tilesheet
	atlas_img.region = arg_region
	
	if !_tile_id_to_region_to_img_map.has(arg_tile_id):
		_tile_id_to_region_to_img_map[arg_tile_id] = {}
	
	_tile_id_to_region_to_img_map[arg_tile_id][arg_region] = atlas_img

func has_atlas_img_for_tilesheet_on_region(arg_tile_id, arg_region) -> bool:
	if _tile_id_to_region_to_img_map.has(arg_tile_id):
		if _tile_id_to_region_to_img_map[arg_tile_id].has(arg_region):
			return true
	
	return false

func get_atlas_img_for_tilesheet_on_region(arg_tile_id, arg_region) -> AtlasTexture:
	return _tile_id_to_region_to_img_map[arg_tile_id][arg_region]



##################
# SOUND related
#################

func _initialize_all_tile_to_sound_id_map():
	var _standard_tile_metal_hit__ping = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_Ping_HighPitchShortFull, StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion]
	}
	var _standard_tile_glass_hit = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalHitGlass, StoreOfAudio.AudioIds.SFX_TileHit_MetalHitGlass]
	}
	var _standard_tile_metal_hit__tin = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_SoftFull_LowPitchTinPlate, StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion]
	}
	var _standard_tile_metal_hit__hollow = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_SoftHollow, StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion]
	}
	
	_tile_id_to_auto_coord_to_sound_id_map__normal_and_loud = {
		0 : _standard_tile_metal_hit__ping,
		1 : _standard_tile_metal_hit__ping,
		2 : _standard_tile_glass_hit,
		3 : _standard_tile_glass_hit,
		4 : _standard_tile_glass_hit,
		5 : _standard_tile_glass_hit,
		6 : _standard_tile_metal_hit__tin,
		7 : _standard_tile_metal_hit__tin,
		#8
		#9
		10 : _standard_tile_metal_hit__ping,
		11 : _standard_tile_metal_hit__ping,
		12 : _standard_tile_metal_hit__ping,
		#13
		14 : _standard_tile_metal_hit__ping,
		
	}
	
	###########
	var _standard_tile_glass_break = {
		ANY_AUTO_COORD : StoreOfAudio.AudioIds.SFX_Misc_GlassBreak_Hard
	}
	
	_breakable_tile_id_to_auto_coord_to_sound_id_map = {
		4 : _standard_tile_glass_break,
		5 : _standard_tile_glass_break,
		
	}
	


func get_sound_id_to_play_for_tile_hit(arg_tile_id, arg_auto_coords, arg_is_loud : bool):
	if _tile_id_to_auto_coord_to_sound_id_map__normal_and_loud.has(arg_tile_id):
		var auto_coord_to_id_map = _tile_id_to_auto_coord_to_sound_id_map__normal_and_loud[arg_tile_id]
		if auto_coord_to_id_map.has(arg_auto_coords):
			var ids_of_normal_or_loud = auto_coord_to_id_map[arg_auto_coords]
			if arg_is_loud:
				return ids_of_normal_or_loud[1]
			else:
				return ids_of_normal_or_loud[0]
			
		elif auto_coord_to_id_map.has(ANY_AUTO_COORD):
			var ids_of_normal_or_loud = auto_coord_to_id_map[ANY_AUTO_COORD]
			if arg_is_loud:
				return ids_of_normal_or_loud[1]
			else:
				return ids_of_normal_or_loud[0]
			
	
	
	return -1

func get_sound_id_to_play_for_tile_break(arg_tile_id, arg_auto_coords):
	if _breakable_tile_id_to_auto_coord_to_sound_id_map.has(arg_tile_id):
		var auto_coord_to_id_map = _breakable_tile_id_to_auto_coord_to_sound_id_map[arg_tile_id]
		if auto_coord_to_id_map.has(arg_auto_coords):
			return auto_coord_to_id_map[arg_auto_coords]
			
		elif auto_coord_to_id_map.has(ANY_AUTO_COORD):
			return auto_coord_to_id_map[ANY_AUTO_COORD]
			
	
	
	return -1


############################
## LIGHT RELATED
#############################


func _initialize_all_uncol_tile_to_light_tex_rect_size_and_color_gradient_map():
	_uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map = {
		14 : {
			Vector2(0, 0) : _construct_light_details__for_14__dark_metal_lamp__vert(),
			Vector2(1, 0) : _construct_light_details__for_14__dark_metal_lamp__horiz(),
			
		}
	}
	

func _construct_light_details__for_14__dark_metal_lamp__vert():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(120, 240))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(253/255.0, 215/255.0, 98/255.0, 0.6), Color(0, 0, 0, 0))
	
	return light_details

func _construct_light_details__for_14__dark_metal_lamp__horiz():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(120, 240))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(253/255.0, 215/255.0, 98/255.0, 0.6), Color(0, 0, 0, 0))
	light_details.rotation = 90
	
	return light_details


func get_light_details_of_tile_id(arg_tile_id, arg_auto_coords) -> LightDetails:
	if _uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map.has(arg_tile_id):
		var map = _uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map[arg_tile_id]
		
		if map.has(arg_auto_coords):
			return map[arg_auto_coords]
			
		elif map.has(ANY_AUTO_COORD):
			return map[ANY_AUTO_COORD]
			
	
	
	return null
