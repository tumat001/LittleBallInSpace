extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"


onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02
onready var level_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_03
onready var level_04__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_04
onready var level_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_05

onready var level_03_hard__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_03H
onready var level_04_hard__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_04H
onready var level_05_hard__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_05H


onready var layout_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To03
onready var layout_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To05



func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_04
	


func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_4)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_4)
	level_03__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_4)
	level_04__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_04__STAGE_4)
	level_05__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_05__STAGE_4)
	
	level_03_hard__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_4__HARD)
	level_04_hard__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_04__STAGE_4__HARD)
	level_05_hard__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_05__STAGE_4__HARD)
	
	layout_03__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03)
	layout_03__tile.layout_ele_id_to_put_cursor_to = 23
	
	layout_05__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05)
	layout_05__tile.layout_ele_id_to_put_cursor_to = 0
	

