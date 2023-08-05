extends Control

const GUI_LevelLayoutEle_Tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/GUI_LevelLayoutEle_Tile.gd")

#

signal prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)
signal prompt_entered_into_link_to_other_layout(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)

signal currently_hovered_layout_ele_changed(arg_id, arg_currently_hovered_tile)

##

var level_layout_id

#

export(NodePath) var default_node_to_summon_cursor_on__for_first_time__path setget set_default_node_to_summon_cursor_on__for_first_time__path

const NO_CURSOR : int = -2  # if you want to delay the cursor spawn for whatever reason
const UNINITIALIZED_CURSOR : int = -1  # if you want to signal that this level layout has not been traversed yet (new to game, new to layout, etc)
var layout_ele_id_to_summon_cursor_to : int = UNINITIALIZED_CURSOR setget set_layout_ele_id_to_summon_cursor_to

#

# if can accept inputs
var is_layout_enabled : bool setget set_is_layout_enabled

#

var _is_player_cursor_active : bool
var _is_player_cursor_gliding : bool

var _next_available_id : int = 0
var _id_to_layout_ele_map : Dictionary
var _layout_ele_to_id_map : Dictionary


var _currently_hovered_layout_ele_id : int
var _currently_hovered_tile : GUI_LevelLayoutEle_Tile

#

onready var player_cursor = $MiscContainer/Cursor

onready var background_container = $BackgroundContainer
onready var layout_elements_container = $LayoutElesContainer
onready var aesthetics_container = $AestheticsContainer

#

func set_default_node_to_summon_cursor_on__for_first_time__path(arg_path):
	default_node_to_summon_cursor_on__for_first_time__path = arg_path
	

####

func _ready():
	_init_id_to_layout_ele_map()
	_summon_cursor_at_appropriate_loc()
	set_is_layout_enabled(is_layout_enabled)
	

func _init_id_to_layout_ele_map():
	for child in layout_elements_container.get_children():
		_assign_layout_ele_next_available_id(child)
	

func _assign_layout_ele_next_available_id(arg_ele):
	_id_to_layout_ele_map[_next_available_id] = arg_ele
	_layout_ele_to_id_map[arg_ele] = _next_available_id
	
	_next_available_id += 1

#

func _set_is_player_cursor_active(arg_val):
	_is_player_cursor_active = arg_val
	
	if !_is_player_cursor_active:
		player_cursor.visible = false
		
	else:
		player_cursor.visible = true
		

##

func get_currently_hovered_layout_ele_id() -> int:
	return _currently_hovered_layout_ele_id

func get_currently_hovered_tile() -> GUI_LevelLayoutEle_Tile:
	return _currently_hovered_tile

##

func set_layout_ele_id_to_summon_cursor_to(arg_ele_id):
	layout_ele_id_to_summon_cursor_to = arg_ele_id
	
	if is_inside_tree():
		if !is_instance_valid(player_cursor):
			_summon_cursor_at_appropriate_loc()
		else:
			_instant_place_cursor_at_layout_ele_id(arg_ele_id)

func _summon_cursor_at_appropriate_loc():
	if layout_ele_id_to_summon_cursor_to == NO_CURSOR:
		_set_is_player_cursor_active(false)
		return
		
	elif layout_ele_id_to_summon_cursor_to == UNINITIALIZED_CURSOR:
		var node = get_node(default_node_to_summon_cursor_on__for_first_time__path)
		_instant_place_cursor_at_layout_ele(node)
		_set_is_player_cursor_active(true)
		
	else:
		_set_is_player_cursor_active(true)
		


func _instant_place_cursor_at_layout_ele_id(arg_id):
	var ele = _id_to_layout_ele_map[arg_id]
	_instant_place_cursor_at_layout_ele(ele)

func _instant_place_cursor_at_layout_ele(arg_ele : Control):
	player_cursor.rect_global_position = arg_ele.global_position
	
	_assign_layout_ele_as_current_hovered(arg_ele)


func _assign_layout_ele_as_current_hovered(arg_ele):
	_currently_hovered_layout_ele_id = _layout_ele_to_id_map[arg_ele]
	_currently_hovered_tile = arg_ele
	
	GameSaveManager.last_hovered_over_level_layout_element_id = _currently_hovered_layout_ele_id
	
	emit_signal("currently_hovered_layout_ele_changed", _currently_hovered_layout_ele_id, _currently_hovered_tile)


func _glide_place_cursor_at_layout_ele(arg_ele : Control):
	_is_player_cursor_gliding = true
	
	var glide_duration : float = 0.2
	
	var tweener = create_tween()
	tweener.tween_property(player_cursor, "rect_global_position", arg_ele.rect_global_position, glide_duration).set_ease(Tween.EASE_IN_OUT)
	tweener.tween_callback(self, "_on_player_cursor_done_gliding").set_delay(glide_duration)
	
	_assign_layout_ele_as_current_hovered(arg_ele)

func _on_player_cursor_done_gliding():
	_is_player_cursor_gliding = false
	

##

func set_is_layout_enabled(arg_val):
	var old_val = arg_val
	is_layout_enabled = arg_val
	
	if old_val != arg_val:
		if is_layout_enabled:
			if !is_connected("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input"):
				connect("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input")
			
		else:
			if is_connected("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input"):
				disconnect("gui_input", self, "_on_GUI_AbstractLevelLayout_gui_input")
			

##

func _on_GUI_AbstractLevelLayout_gui_input(event):
	if event is InputEventKey:
		if _is_player_cursor_active:
			
			if !_is_player_cursor_gliding:
				if event.is_action("ui_up"):
					_attempt_glide_cursor_from_current__to_up()
					
				elif event.is_action("ui_down"):
					_attempt_glide_cursor_from_current__to_down()
					
				elif event.is_action("ui_left"):
					_attempt_glide_cursor_from_current__to_left()
					
				elif event.is_action("ui_right"):
					_attempt_glide_cursor_from_current__to_right()
					
				
			
			
			if event.is_action_released("ui_accept"):
				_attempt_enter_inside_current_tile()
				
			
			

func _attempt_glide_cursor_from_current__to_up():
	var tile = _currently_hovered_tile.layout_element_tile__up
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _attempt_glide_cursor_from_current__to_down():
	var tile = _currently_hovered_tile.layout_element_tile__down
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _attempt_glide_cursor_from_current__to_left():
	var tile = _currently_hovered_tile.layout_element_tile__left
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _attempt_glide_cursor_from_current__to_right():
	var tile = _currently_hovered_tile.layout_element_tile__right
	if _if_can_hover_over_tile(tile):
		_glide_place_cursor_at_layout_ele(tile)
		
	

func _if_can_hover_over_tile(tile) -> bool:
	return is_instance_valid(tile) and tile.is_hoverable_by_player_cursor()



func _attempt_enter_inside_current_tile():
	if _currently_hovered_tile.level_details != null:
		emit_signal("prompt_entered_into_level", _currently_hovered_tile, _currently_hovered_layout_ele_id)
		
	elif _currently_hovered_tile.is_link_to_another_layout:
		emit_signal("prompt_entered_into_link_to_other_layout", _currently_hovered_tile, _currently_hovered_layout_ele_id)
		
	



