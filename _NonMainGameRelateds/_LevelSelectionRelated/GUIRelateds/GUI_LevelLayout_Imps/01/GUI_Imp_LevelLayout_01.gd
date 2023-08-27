extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"



onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02
onready var level_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_03
onready var level_04__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_04
onready var level_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_05

onready var layout_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To05



func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01

func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02)
	level_03__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03)
	level_04__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_04)
	level_05__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_05)
	
	layout_05__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05)
	layout_05__tile.layout_ele_id_to_put_cursor_to = 15
	

