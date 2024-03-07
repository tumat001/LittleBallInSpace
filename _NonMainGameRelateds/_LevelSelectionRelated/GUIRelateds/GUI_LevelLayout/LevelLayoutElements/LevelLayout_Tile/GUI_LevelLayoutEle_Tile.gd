tool
extends MarginContainer

#

const LevelDetails = preload("res://LevelRelated/Classes/LevelDetails.gd")
const LevelLayoutDetails = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout_Imps/LevelLayoutDetails.gd")

const Tile_White = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_TilePath_White_Standard_46x46.png")

#

const BUTTON_HOVER__MODULATE = Color(1.3, 1.3, 1.3, 1)
const BUTTON_NORMAL__MODULATE = Color(1.0, 1.0, 1.0, 1)


#

signal is_layout_element_invis_changed(arg_val)

signal tile_pressed()

#

var layout_ele_id : int

#

var _can_update_path_texture_status : bool = false

export(NodePath) var layout_element_tile__left__path : NodePath setget set_layout_element_tile__left__path
var layout_element_tile__left setget set_layout_element_tile__left

export(NodePath) var layout_element_tile__right__path : NodePath setget set_layout_element_tile__right__path
var layout_element_tile__right setget set_layout_element_tile__right

export(NodePath) var layout_element_tile__up__path : NodePath setget set_layout_element_tile__up__path
var layout_element_tile__up setget set_layout_element_tile__up

export(NodePath) var layout_element_tile__down__path : NodePath setget set_layout_element_tile__down__path
var layout_element_tile__down setget set_layout_element_tile__down


export(bool) var is_path : bool setget set_is_path


export(Texture) var default_texture_of_tile : Texture = Tile_White setget set_default_texture_of_tile


#

var level_layout_details : LevelLayoutDetails setget set_level_layout_details
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

export(bool) var is_layout_element_invis_by_default : bool = false
# setted by level layout
var is_layout_element_invis : bool = false setget set_is_layout_element_invis

#

var is_a_tile_type : bool = true setget set_is_a_tile_type
var is_hovered_by_hover_icon_in_non_tile_type : bool setget set_is_hovered_by_hover_icon_in_non_tile_type

#

# managed by abstratlevellayout
#var _all_non_path_tiles_connected : Array = []

#


const FOUR_POINT_STAR__MOD_A__MIN = 0.1
const FOUR_POINT_STAR__MOD_A__MAX = 0.9
const FOUR_POINT_STAR__MOD_A_HALF_CYCLE_DURATION = 3.0 
var is_init_four_point_star_sprite_relateds : bool
var four_point_star_mod_a_tweener : SceneTreeTween
var four_point_star_sprite_container : Node2D
var four_point_star_sprite__left : Sprite
var four_point_star_sprite__right : Sprite
var four_point_star_sprite__up : Sprite
var four_point_star_sprite__down : Sprite

#


var _hover_icon : TextureRect


onready var tile_texture_rect = $TileTextureRect

onready var path_texture_container = $PathTextureContainer

onready var path_texture_rect__editor = $PathTextureRect__Editor

onready var label = $Control/Label

onready var level_completed_marker = $Control/CompletedMarker
onready var got_all_coins_marker = $Control/GotAllCoinsMarker

onready var free_form_control = $Control

########

func _ready():
	if !Engine.editor_hint:
		path_texture_rect__editor.visible = false
	
	_can_update_path_texture_status = false
	set_layout_element_tile__left__path(layout_element_tile__left__path)
	set_layout_element_tile__right__path(layout_element_tile__right__path)
	set_layout_element_tile__up__path(layout_element_tile__up__path)
	set_layout_element_tile__down__path(layout_element_tile__down__path)
	set_is_layout_element_invis(is_layout_element_invis)
	_can_update_path_texture_status = true
	
	set_is_path(is_path)
	_update_tile_texture_rect__texture()

#


func set_level_details(arg_level):
	level_details = arg_level
	
	level_details.connect("is_level_locked_changed", self, "_is_level_locked_changed")
	level_details.connect("volatile__is_show_four_pointed_star_vfx_changed", self, "_on_volatile__is_show_four_pointed_star_vfx")
	
	_update_vfx_based_on_is_show_four_pointed_star_vfx()
	_update_tile_texture_rect__texture()
	_update_label_text()
	_update_all_marker_visibility()

func _is_level_locked_changed(arg_val):
	_update_tile_texture_rect__texture()
	_update_all_marker_visibility()

func set_default_texture_of_tile(arg_texture):
	default_texture_of_tile = arg_texture
	
	if is_inside_tree():
		_update_tile_texture_rect__texture()


func set_level_layout_details(arg_level_layout_det):
	level_layout_details = arg_level_layout_det
	
	level_layout_details.connect("is_level_layout_locked_changed", self, "_is_level_layout_locked_changed")
	
	_update_tile_texture_rect__texture()
	_update_label_text()
	_update_all_marker_visibility()

func _is_level_layout_locked_changed(arg_val):
	_update_tile_texture_rect__texture()
	_update_all_marker_visibility()



func _update_tile_texture_rect__texture():
	if level_details != null:
		var texture_and_mod_to_use = level_details.get_texture_and_modulate_to_use__based_on_properties()
		var texture_to_use = texture_and_mod_to_use[0]
		
		if texture_to_use != null:
			var mod_to_use = texture_and_mod_to_use[1]
			
			tile_texture_rect.texture = texture_to_use
			tile_texture_rect.modulate = mod_to_use
			
			label.modulate = mod_to_use
			return
	
	
	if level_layout_details != null:
		var texture_and_mod_to_use = level_layout_details.get_texture_and_modulate_to_use__based_on_properties()
		var texture_to_use = texture_and_mod_to_use[0]
		
		if texture_to_use != null:
			var mod_to_use = texture_and_mod_to_use[1]
			
			tile_texture_rect.texture = texture_to_use
			tile_texture_rect.modulate = mod_to_use
			
			label.modulate = mod_to_use
			return
	
	
	
	if default_texture_of_tile != null:
		tile_texture_rect.texture = default_texture_of_tile
		tile_texture_rect.modulate = Color(1, 1, 1, 1)
		
		label.modulate = Color(1, 1, 1, 1)
		return
	
	#
	
	tile_texture_rect.texture = null

func _update_label_text():
	if is_path:
		label.visible = false
		return
	else:
		label.visible = true
	
	if level_details != null:
		label.text = level_details.level_label_on_tile
		label.add_color_override("font_color", level_details.level_label_text_color)
		if level_details.has_outline_color:
			label.add_color_override("font_outline_modulate", level_details.level_label_outline_color)
		else:
			label.remove_color_override("font_outline_modulate")
		
	elif level_layout_details != null:
		label.text = level_layout_details.level_layout_label_on_tile
		label.add_color_override("font_color", level_layout_details.level_label_text_color)
		if level_layout_details.has_outline_color:
			label.add_color_override("font_outline_modulate", level_layout_details.level_label_outline_color)
		else:
			label.remove_color_override("font_outline_modulate")
		
	else:
		label.text = ""
		label.add_color_override("font_color", Color("#dddddd"))
		label.remove_color_override("font_outline_modulate")
	

#

func set_is_path(arg_val):
	var old_val = is_path
	is_path = arg_val
	
	if is_inside_tree() or Engine.editor_hint:
		#if old_val != is_path:
		if is_path:
			tile_texture_rect.visible = false
			_update_display__as_path()
			
			
		else:
			tile_texture_rect.visible = true
			#for path in _all_paths:
			#	path.visible = false
			_update_display__as_path()
			
			path_texture_rect__editor.visible = false
		
		_update_label_text()
		_update_all_marker_visibility()

func _update_display__as_path():
	for path in _all_paths:
		path.visible = false
	
	if Engine.editor_hint:
		path_texture_rect__editor.texture = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_TilePath_White_All_46x46.png")
		path_texture_rect__editor.visible = true
		return
	
	if !is_a_tile_type:
		return
	
	if is_instance_valid(layout_element_tile__up) and !layout_element_tile__up.is_layout_element_invis:
		if !is_instance_valid(_path__to_north):
			_path__to_north = _create_path_texture_rect()
		_path__to_north.visible = true
		
	
	if is_instance_valid(layout_element_tile__down) and !layout_element_tile__down.is_layout_element_invis:
		if !is_instance_valid(_path__to_south):
			_path__to_south = _create_path_texture_rect()
			_path__to_south.flip_v = true
		_path__to_south.visible = true
		
	
	if is_instance_valid(layout_element_tile__left) and !layout_element_tile__left.is_layout_element_invis:
		if !is_instance_valid(_path__to_west):
			_path__to_west = _create_path_texture_rect()
			_path__to_west.rect_rotation = 270
		_path__to_west.visible = true
		
	
	if is_instance_valid(layout_element_tile__right) and !layout_element_tile__right.is_layout_element_invis:
		if !is_instance_valid(_path__to_east):
			_path__to_east = _create_path_texture_rect()
			_path__to_east.rect_rotation = 90
		_path__to_east.visible = true
		


func _create_path_texture_rect():
	var path = TextureRect.new()
	path.texture = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_TilePath_White_Standard_46x46.png")
	path_texture_container.add_child(path)
	path.rect_pivot_offset = path.texture.get_size() / 2
	path.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_all_paths.append(path)
	return path



#######

func set_layout_element_tile__left__path(arg_path):
	layout_element_tile__left__path = arg_path
	
	if is_inside_tree():
		set_layout_element_tile__left(get_node_or_null(layout_element_tile__left__path))
	

func set_layout_element_tile__right__path(arg_path):
	layout_element_tile__right__path = arg_path
	
	if is_inside_tree():
		set_layout_element_tile__right(get_node_or_null(layout_element_tile__right__path))
	

func set_layout_element_tile__up__path(arg_path):
	layout_element_tile__up__path = arg_path
	
	if is_inside_tree():
		set_layout_element_tile__up(get_node_or_null(layout_element_tile__up__path))
		

func set_layout_element_tile__down__path(arg_path):
	layout_element_tile__down__path = arg_path
	
	if is_inside_tree():
		set_layout_element_tile__down(get_node_or_null(layout_element_tile__down__path))
	



func set_layout_element_tile__left(arg_node):
	layout_element_tile__left = arg_node
	
	if is_instance_valid(layout_element_tile__left):
		layout_element_tile__left.connect("is_layout_element_invis_changed", self, "_on_layout_element_is_invis_changed")
	
	_update_display__as_path()

func set_layout_element_tile__right(arg_node):
	layout_element_tile__right = arg_node
	
	if is_instance_valid(layout_element_tile__right):
		layout_element_tile__right.connect("is_layout_element_invis_changed", self, "_on_layout_element_is_invis_changed")
	
	_update_display__as_path()

func set_layout_element_tile__up(arg_node):
	layout_element_tile__up = arg_node
	
	if is_instance_valid(layout_element_tile__up):
		layout_element_tile__up.connect("is_layout_element_invis_changed", self, "_on_layout_element_is_invis_changed")
	
	_update_display__as_path()

func set_layout_element_tile__down(arg_node):
	layout_element_tile__down = arg_node
	
	if is_instance_valid(layout_element_tile__down):
		layout_element_tile__down.connect("is_layout_element_invis_changed", self, "_on_layout_element_is_invis_changed")
	
	_update_display__as_path()


#

func _on_layout_element_is_invis_changed(arg_val):
	_update_display__as_path()
	

###

func is_hoverable_by_player_cursor() -> bool:
	if is_layout_element_invis:
		return false
	
	if is_path:
		return true
	
	if level_details != null:
		if !level_details.is_level_locked:
			return true
	
	if is_link_to_layout():
		return true
	
	return false
	

#

#func set_layout_id_to_link_to(arg_val):
#	layout_id_to_link_to = arg_val
#

func is_link_to_layout():
	if level_layout_details != null:
		#return level_layout_details.level_layout_id != StoreOfLevelLayouts.LevelLayoutIds.NONE
		return true
	else:
		return false

func is_link_to_level():
	if level_details != null:
		return true
	else:
		return false

##################

func _update_all_marker_visibility():
	if level_details != null:
		var is_completed = GameSaveManager.is_level_id_finished(level_details.level_id)
		level_completed_marker.visible = is_completed
		
		var all_coins_collected = GameSaveManager.is_all_coins_collected_in_level(level_details.level_id)
		got_all_coins_marker.visible = all_coins_collected
		
	elif level_layout_details != null:
		var status_arr = StoreOfLevels.get_level_layout_completion_status__for_all(level_layout_details.level_layout_id)
		
		var all_coins_collected = status_arr[0]
		got_all_coins_marker.visible = all_coins_collected
		
		var is_all_levels_completed = status_arr[1]
		level_completed_marker.visible = is_all_levels_completed
		
	else:
		level_completed_marker.visible = false
		got_all_coins_marker.visible = false
	


#########

#func add_non_path_tiles_as_connected(arg_tile):
#	_all_non_path_tiles_connected.append(arg_tile)
#
#

#

func set_is_layout_element_invis(arg_val):
	is_layout_element_invis = arg_val
	
	if is_inside_tree():
		visible = !arg_val
		emit_signal("is_layout_element_invis_changed", arg_val)

#

func get_center_position() -> Vector2:
	return rect_global_position + (rect_size / 2)

##############################

func set_is_a_tile_type(arg_val):
	is_a_tile_type = arg_val
	
	if is_a_tile_type:
		if is_instance_valid(_hover_icon):
			_hover_icon.visible = false
		
	else:
		
		if is_inside_tree():
			if !is_instance_valid(_hover_icon):
				_hover_icon = TextureRect.new()
				_hover_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
				_hover_icon.texture = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_LayoutShortcutPanel_HoverIndicator.png")
				_hover_icon.visible = false
				
				free_form_control.add_child(_hover_icon)
		
	
	_update_display__as_path()


func set_is_hovered_by_hover_icon_in_non_tile_type(arg_val):
	is_hovered_by_hover_icon_in_non_tile_type = arg_val
	
	if is_hovered_by_hover_icon_in_non_tile_type:
		if is_instance_valid(_hover_icon):
			_hover_icon.visible = true
		
	else:
		if is_instance_valid(_hover_icon):
			_hover_icon.visible = false
		
		
	

#

func play_four_pointed_star_vfx():
	if !is_init_four_point_star_sprite_relateds:
		_init_all_related_four_pointed_star()
	else:
		_set_four_point_sprite_visiblity(true)
		_construct_and_play_mod_a_tweener_for_four_pointed_stars()

func _init_all_related_four_pointed_star():
	_construct_four_pointed_star_container()
	_construct_and_config_four_pointed_star_sprites()
	_construct_and_play_mod_a_tweener_for_four_pointed_stars()

func _construct_four_pointed_star_container():
	four_point_star_sprite_container = Node2D.new()
	
	add_child(four_point_star_sprite_container)
	move_child(four_point_star_sprite_container, 0)

func _construct_and_config_four_pointed_star_sprites():
	four_point_star_sprite__left = _construct_four_pointed_star_sprite__vanilla_template()
	four_point_star_sprite__right = _construct_four_pointed_star_sprite__vanilla_template()
	four_point_star_sprite__up = _construct_four_pointed_star_sprite__vanilla_template()
	four_point_star_sprite__down = _construct_four_pointed_star_sprite__vanilla_template()
	
	##
	
	four_point_star_sprite__left.rotation = PI
	four_point_star_sprite__up.rotation = -PI/2
	#four_point_star_sprite__right.rotation = 0.0
	four_point_star_sprite__down.rotation = PI/2
	
	##
	
	# assumes x and y of texture are the same
	var sprite_half_len_width = four_point_star_sprite__up.texture.get_size().x / 2
	var glob_center_pos = get_center_position()
	var tile_texture_half_len_width = tile_texture_rect.texture.get_size().x / 2
	
	four_point_star_sprite__left.global_position = glob_center_pos - Vector2(tile_texture_half_len_width + sprite_half_len_width, 0)
	four_point_star_sprite__right.global_position = glob_center_pos + Vector2(tile_texture_half_len_width + sprite_half_len_width, 0)
	four_point_star_sprite__up.global_position = glob_center_pos - Vector2(0, tile_texture_half_len_width + sprite_half_len_width)
	four_point_star_sprite__down.global_position = glob_center_pos + Vector2(0, tile_texture_half_len_width + sprite_half_len_width)
	

func _construct_four_pointed_star_sprite__vanilla_template() -> Sprite:
	var four_point_star_sprite = Sprite.new()
	four_point_star_sprite.texture = load("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_Tile_4PointStarShine_Right.png")
	four_point_star_sprite.modulate.a = 0.4
	
	four_point_star_sprite_container.add_child(four_point_star_sprite)
	
	return four_point_star_sprite

#

func _construct_and_play_mod_a_tweener_for_four_pointed_stars():
	if four_point_star_mod_a_tweener != null and four_point_star_mod_a_tweener.is_running():
		return
	
	four_point_star_mod_a_tweener = create_tween()
	four_point_star_mod_a_tweener.set_loops()
	four_point_star_mod_a_tweener.set_parallel(true)
	for sprite in four_point_star_sprite_container.get_children():
		four_point_star_mod_a_tweener.tween_property(sprite, "modulate:a", FOUR_POINT_STAR__MOD_A__MAX, FOUR_POINT_STAR__MOD_A_HALF_CYCLE_DURATION)
	four_point_star_mod_a_tweener.set_parallel(false)
	four_point_star_mod_a_tweener.tween_interval(FOUR_POINT_STAR__MOD_A_HALF_CYCLE_DURATION)
	four_point_star_mod_a_tweener.set_parallel(true)
	for sprite in four_point_star_sprite_container.get_children():
		four_point_star_mod_a_tweener.tween_property(sprite, "modulate:a", FOUR_POINT_STAR__MOD_A__MIN, FOUR_POINT_STAR__MOD_A_HALF_CYCLE_DURATION)
	

#

func _set_four_point_sprite_visiblity(arg_vis):
	for sprite in four_point_star_sprite_container.get_children():
		sprite.visible = arg_vis
	

#

func unplay_four_pointed_star_vfx():
	if is_init_four_point_star_sprite_relateds:
		_set_four_point_sprite_visiblity(false)
		

##

func _on_volatile__is_show_four_pointed_star_vfx(arg_val):
	_update_vfx_based_on_is_show_four_pointed_star_vfx()

func _update_vfx_based_on_is_show_four_pointed_star_vfx():
	if level_details.volatile__is_show_four_pointed_star_vfx:
		play_four_pointed_star_vfx()
		
	else:
		unplay_four_pointed_star_vfx()
		
	


#############

func _on_Button_pressed():
	emit_signal("tile_pressed")


###

func _on_Button_mouse_entered():
	modulate = BUTTON_HOVER__MODULATE

func _on_Button_mouse_exited():
	modulate = BUTTON_NORMAL__MODULATE

func _on_Button_visibility_changed():
	modulate = BUTTON_NORMAL__MODULATE

