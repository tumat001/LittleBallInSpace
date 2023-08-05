tool
extends MarginContainer

#

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")

const Tile_White = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_TilePath_White_Standard_46x46.png")

#


export(NodePath) var layout_element_tile__left__path : NodePath setget set_layout_element_tile__left__path
var layout_element_tile__left

export(NodePath) var layout_element_tile__right__path : NodePath setget set_layout_element_tile__right__path
var layout_element_tile__right

export(NodePath) var layout_element_tile__up__path : NodePath setget set_layout_element_tile__up__path
var layout_element_tile__up

export(NodePath) var layout_element_tile__down__path : NodePath setget set_layout_element_tile__down__path
var layout_element_tile__down


export(bool) var is_path : bool setget set_is_path


export(Texture) var default_texture_of_tile : Texture = Tile_White setget set_default_texture_of_tile


#

var layout_id_to_link_to = StoreOfLevelLayouts.LevelLayoutIds.NONE setget set_layout_id_to_link_to
var layout_ele_id_to_put_cursor_to : int

#

var level_details : LevelDetails setget set_level_details

#

var _path__to_north : TextureRect
var _path__to_south : TextureRect
var _path__to_west : TextureRect
var _path__to_east : TextureRect
var _all_paths : Array

#

onready var tile_texture_rect = $TileTextureRect

########

func _ready():
	set_is_path(is_path)
	_update_tile_texture_rect__texture()

#


func set_level_details(arg_level):
	level_details = arg_level
	
	level_details.connect("is_level_locked_changed", self, "_is_level_locked_changed")
	
	_update_tile_texture_rect__texture()

func _is_level_locked_changed(arg_val):
	_update_tile_texture_rect__texture()

func set_default_texture_of_tile(arg_texture):
	default_texture_of_tile = arg_texture
	
	_update_tile_texture_rect__texture()


func _update_tile_texture_rect__texture():
	if level_details != null:
		var texture_and_mod_to_use = level_details.get_texture_and_modulate_to_use__based_on_properties()
		var texture_to_use = texture_and_mod_to_use[0]
		
		if texture_to_use != null:
			var mod_to_use = texture_and_mod_to_use[1]
			
			tile_texture_rect.texture = texture_to_use
			tile_texture_rect.modulate = mod_to_use
			return
	
	
	if default_texture_of_tile != null:
		tile_texture_rect.texture = default_texture_of_tile
		tile_texture_rect.modulate = Color(1, 1, 1, 1)
		return
	
	#
	
	tile_texture_rect.texture = null

#

func set_is_path(arg_val):
	var old_val = is_path
	is_path = arg_val
	
	if old_val != is_path:
		if is_path:
			tile_texture_rect.visible = false
			_update_display__as_path()
			
		else:
			tile_texture_rect.visible = true
			for path in _all_paths:
				path.visible = false
			
			


func _update_display__as_path():
	for path in _all_paths:
		path.visible = false
	
	if layout_element_tile__up != null or (Engine.editor_hint and layout_element_tile__up__path != null):
		if !is_instance_valid(_path__to_north):
			_path__to_north = _create_path_texture_rect()
		_path__to_north.visible = true
		
	elif layout_element_tile__down != null or (Engine.editor_hint and layout_element_tile__down__path != null):
		if !is_instance_valid(_path__to_south):
			_path__to_south = _create_path_texture_rect()
			_path__to_south.flip_v = true
		_path__to_south.visible = true
		
	elif layout_element_tile__left != null or (Engine.editor_hint and layout_element_tile__left__path != null):
		if !is_instance_valid(_path__to_west):
			_path__to_west = _create_path_texture_rect()
			_path__to_west.rect_rotation = 270
		_path__to_west.visible = true
		
	elif layout_element_tile__right != null or (Engine.editor_hint and layout_element_tile__right__path != null):
		if !is_instance_valid(_path__to_east):
			_path__to_east = _create_path_texture_rect()
			_path__to_east.rect_rotation = 90
		_path__to_east.visible = true
		
	

func _create_path_texture_rect():
	var path = TextureRect.new()
	path.texture = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_TilePath_White_Standard_46x46.png")
	add_child(path.texture)
	path.rect_pivot_offset = path.texture.get_size() / 2
	path.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_all_paths.append(path)
	return path



#######

func set_layout_element_tile__left__path(arg_path):
	layout_element_tile__left__path = arg_path
	
	if is_inside_tree():
		layout_element_tile__left = get_node_or_null(layout_element_tile__left__path)
		
	
	if is_path:
		_update_display__as_path()

func set_layout_element_tile__right__path(arg_path):
	layout_element_tile__right__path = arg_path
	
	if is_inside_tree():
		layout_element_tile__right = get_node_or_null(layout_element_tile__right__path)
		
	
	if is_path:
		_update_display__as_path()

func set_layout_element_tile__up__path(arg_path):
	layout_element_tile__up__path = arg_path
	
	if is_inside_tree():
		layout_element_tile__up = get_node_or_null(layout_element_tile__up__path)
		
	
	if is_path:
		_update_display__as_path()

func set_layout_element_tile__down__path(arg_path):
	layout_element_tile__down__path = arg_path
	
	if is_inside_tree():
		layout_element_tile__down = get_node_or_null(layout_element_tile__down__path)
		
	
	if is_path:
		_update_display__as_path()


###

func is_hoverable_by_player_cursor() -> bool:
	if is_path:
		return true
	
	if level_details != null:
		if !level_details.is_level_locked:
			return true
	
	if is_link_to_another_layout():
		return true
	
	return false
	

#

func set_layout_id_to_link_to(arg_val):
	layout_id_to_link_to = arg_val
	

func is_link_to_another_layout():
	return layout_id_to_link_to != StoreOfLevelLayouts.LevelLayoutIds.NONE
	


