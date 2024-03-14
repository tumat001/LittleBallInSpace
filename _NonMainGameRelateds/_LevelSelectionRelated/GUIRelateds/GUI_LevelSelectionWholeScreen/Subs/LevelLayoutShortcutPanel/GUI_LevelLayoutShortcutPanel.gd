extends MarginContainer

#const Background_NoBar = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_LayoutShortcutPanel_NoBarSize.png")
#const Background_Normal = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/GUI_LevelSelectionWholeScreen_LayoutShortcutPanel.png")


const GUI_LevelLayoutEle_Tile = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/GUI_LevelLayoutEle_Tile.gd")
const GUI_LevelLayoutEle_Tile_Scene = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/GUI_LevelLayoutEle_Tile.tscn")

#

signal layout_tile_pressed(arg_tile, arg_id)

#

var _level_selection_whole_screen_panel

var _level_layout_id_to_tile_map : Dictionary

#

var _frame_count_wait_for__update_shortcut_panel__button_status : int

#

onready var background_texture_rect = $MainBackground
onready var grid_container = $MarginContainer/ScrollContainer/GridContainer

###

func _ready():
	if is_instance_valid(_level_selection_whole_screen_panel):
		_update_shortcut_panel__visible_buttons()
		
		#call_deferred("_update_shortcut_panel__button_status")
		_update_shortcut_panel__button_status__after_x_frames()

func _update_shortcut_panel__button_status__after_x_frames():
	_frame_count_wait_for__update_shortcut_panel__button_status = 3
	set_process(true)

func _process(delta):
	_dec__frame_count_wait_for__update_shortcut_panel__button_status()


func _dec__frame_count_wait_for__update_shortcut_panel__button_status():
	_frame_count_wait_for__update_shortcut_panel__button_status -= 1
	if _frame_count_wait_for__update_shortcut_panel__button_status <= 0:
		_frame_count_wait_for__update_shortcut_panel__button_status = 0
		set_process(false)
		_update_shortcut_panel__button_status()


#

func set_level_selection_whole_screen__and_init(arg_whole_screen):
	_level_selection_whole_screen_panel = arg_whole_screen
	
	_level_selection_whole_screen_panel.connect("current_level_layout_changed", self, "_on_current_level_layout_changed")
	GameSaveManager.connect("level_layout_id_completion_status_changed", self, "_on_level_layout_id_completion_status_changed")
	
	if is_inside_tree():
		_update_shortcut_panel__visible_buttons()
		_update_shortcut_panel__button_status()


func _on_current_level_layout_changed(arg_layout, arg_layout_id):
	_update_shortcut_panel__button_status()

func _on_level_layout_id_completion_status_changed():
	_update_shortcut_panel__visible_buttons()



func _update_shortcut_panel__visible_buttons():
	var vis_count : int = 0
	for level_layout_id in StoreOfLevelLayouts.LevelLayoutIds.values():
		if GameSaveManager.is_level_layout_id_playable(level_layout_id):
			vis_count += 1
			
			if !_level_layout_id_to_tile_map.has(level_layout_id):
				_create_level_layout_tile_for_id(level_layout_id)
			else:
				var tile = _level_layout_id_to_tile_map[level_layout_id]
				tile.visible = true
			
		else:
			if _level_layout_id_to_tile_map.has(level_layout_id):
				var tile = _level_layout_id_to_tile_map[level_layout_id]
				tile.visible = false
	
	if vis_count <= 2:
		visible = false
	else:
		visible = true


func _create_level_layout_tile_for_id(arg_id):
	var tile = GUI_LevelLayoutEle_Tile_Scene.instance()
	_level_layout_id_to_tile_map[arg_id] = tile
	tile.visible = false
	tile.connect("tile_pressed", self, "_on_tile_pressed", [tile, arg_id])
	
	tile.connect("tree_entered", self, "_on_tile_tree_entered", [tile, arg_id], CONNECT_DEFERRED)
	grid_container.call_deferred("add_child", tile)

func _on_tile_tree_entered(arg_tile : GUI_LevelLayoutEle_Tile, arg_layout_id):
	arg_tile.is_a_tile_type = false
	
	arg_tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(arg_layout_id)
	arg_tile.layout_ele_id_to_put_cursor_to = 0
	


func _update_shortcut_panel__button_status():
	var layout_scene = _level_selection_whole_screen_panel.get_current_active_level_layout()
	if is_instance_valid(layout_scene):
		var curr_level_layout_id = layout_scene.level_layout_id
		
		for layout_id in _level_layout_id_to_tile_map.keys():
			var tile = _level_layout_id_to_tile_map[layout_id]
			if curr_level_layout_id != layout_id:
				tile.set_is_hovered_by_hover_icon_in_non_tile_type(false)
			else:
				tile.set_is_hovered_by_hover_icon_in_non_tile_type(true)


#########

func _on_tile_pressed(arg_tile, arg_id):
	emit_signal("layout_tile_pressed", arg_tile, arg_id)
	
