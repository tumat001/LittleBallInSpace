extends Node



const BREAKABLE_GLASS_TILE__MASS = 30

const BREAKABLE_GLASS_TILE_ID__ATLAS_01 = 2
const BREAKABLE_GLASS_TILE_ID__ATLAS_02 = 3

const BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01 = 4
const BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02 = 5

#

# structure: tile id -> tile auto coord -> segment size -> [[atlased images, top_left_pos], length]
var _atlased_imgs_of_tile_fragments_map : Dictionary = {}

# structure: tile id -> tile auto coord -> img
var _tile_id_to_auto_coord_to_img_map : Dictionary = {}

# structure: tile id -> region -> atlas img
var _tile_id_to_region_to_img_map : Dictionary = {}

#

static func is_tile_id_glowing(arg_id):
	match arg_id:
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01, BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
			return true
	
	return false

#

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

