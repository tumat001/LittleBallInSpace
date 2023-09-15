extends Reference

#const CenterBasedAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.gd")
#const CenterBasedAttackSprite_Scene = preload("res://MiscRelated/AttackSpriteRelated/CenterBasedAttackSprite.tscn")



#static func generate_center_based_attk_sprite_to_pos_modi_map__from_atlas_textures_and_pos_modifier_map(arg_texture_to_center_pos_modifier_map : Dictionary, arg_top_left_pos : Vector2, arg_scene) -> Dictionary:
#	var node_map : Dictionary = {}
#
#	for texture in arg_texture_to_center_pos_modifier_map:
#		var pos_modi = arg_texture_to_center_pos_modifier_map[texture]
#
#		var center_based_attk_sprite = arg_scene.instance()
#		center_based_attk_sprite.texture_to_use = texture
#		#center_based_attk_sprite.center_pos_of_basis = arg_top_left_pos + pos_modi
#
#		node_map[center_based_attk_sprite] = arg_top_left_pos + pos_modi
#
#	return node_map


#static func generate_texture_rects__from_atlas_textures_and_pos_modifier_map(arg_texture_to_center_pos_modifier_map : Dictionary, arg_top_left_pos : Vector2) -> Array:
#	var texture_rects_list = []
#
#	for texture in arg_texture_to_center_pos_modifier_map:
#		var pos_modi = arg_texture_to_center_pos_modifier_map[texture]
#
#		var texture_rect = TextureRect.new()
#		texture_rect.texture = texture
#		texture_rect.rect_position = arg_top_left_pos + pos_modi
#
#		texture_rects_list.append(texture_rect)
#
#	return texture_rects_list


#

static func convert_pos_modi_top_left_based__into_center_based(arg_image_size : Vector2, arg_pos_modi_top_left : Vector2):
	var half_size = arg_image_size / 2
	return arg_pos_modi_top_left - half_size



static func generate_atlas_textures_and_pos_modifier_map__for_texture(arg_texture : Texture, arg_piece_width : float, arg_piece_height : float) -> Dictionary:
	var tilesheet_size = arg_texture.get_size()
	var x_segment_count = (tilesheet_size.x / arg_piece_width)
	var y_segment_count = (tilesheet_size.y / arg_piece_height)
	
	var rects_and_autocoords = generate_rects_for_size__and_autocoords(tilesheet_size, x_segment_count, y_segment_count)
	
	var texture_to_center_pos_modifier_map : Dictionary
	for rect_and_autocoord in rects_and_autocoords:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = arg_texture
		atlas_texture.region = rect_and_autocoord[0]
		
		var autocoord : Vector2 = rect_and_autocoord[1]
		texture_to_center_pos_modifier_map[atlas_texture] = Vector2(arg_piece_width / 2 + (autocoord.x * arg_piece_width), arg_piece_height / 2 + (autocoord.y * arg_piece_height))
	
	return texture_to_center_pos_modifier_map


static func generate_rects_for_size__and_autocoords(arg_size : Vector2, arg_x_segments : int, arg_y_segments : int) -> Array:
	#var root_segment_ceil = ceil(sqrt(arg_segments))
	
	var x_full_length = arg_size.x
	var x_lengths : Array = []
	var x_remaining_length = x_full_length
	while (x_remaining_length > 0):
		x_remaining_length -= arg_size.x / float(arg_x_segments)
		x_lengths.append(arg_size.x / float(arg_x_segments))
		#if x_remaining_length > 0:
		#	x_lengths.append(x_full_length - x_remaining_length)
		#else:
		#	x_lengths.append(x_full_length)
	
	
	var y_full_length = arg_size.y
	var y_lengths : Array = []
	var y_remaining_length = y_full_length
	while (y_remaining_length > 0):
		y_remaining_length -= arg_size.y / float(arg_y_segments)
		y_lengths.append(arg_size.y / float(arg_y_segments))
		#if y_remaining_length > 0:
		#	y_lengths.append(y_full_length - y_remaining_length)
		#else:
		#	y_lengths.append(y_full_length)
	
	
	##
	
	var rects_and_auto_coords : Array = []
	#var auto_coords : Array = []
	
	var i_x = 0
	var i_y = 0
	var total_x_traversed = 0
	for x_length in x_lengths:
		var old_x_total = total_x_traversed
		total_x_traversed += x_length
		
		var total_y_traversed = 0
		for y_length in y_lengths:
			var old_y_total = total_y_traversed
			total_y_traversed += y_length
			
			#rects.append(Rect2(old_x_total, old_y_total, length, length))
			#auto_coords.append([i_x + 1, i_y + 1])
			
			var rect = Rect2(old_x_total, old_y_total, x_length, y_length)
			var auto_coords = Vector2(i_x, i_y)
			rects_and_auto_coords.append([rect, auto_coords])
			
			i_y += 1
		
		i_x += 1
		i_y = 0
	
	
	return rects_and_auto_coords
