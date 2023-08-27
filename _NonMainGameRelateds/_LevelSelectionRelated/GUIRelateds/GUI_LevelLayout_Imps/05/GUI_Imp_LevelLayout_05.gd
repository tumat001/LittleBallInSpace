extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"



onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02


onready var layout_04__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To04
onready var layout_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To01


func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05



func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_5)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_5)
	
	layout_04__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04)
	layout_04__tile.layout_ele_id_to_put_cursor_to = 22
	
	layout_01__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01)
	layout_01__tile.layout_ele_id_to_put_cursor_to = 14
	

