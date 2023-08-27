extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"


onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02
onready var level_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_03
onready var level_04__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_04
onready var level_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_05
onready var level_06__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_06

onready var level_02_hard__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02H
onready var level_06_hard__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_06H


onready var layout_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To03


func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02

func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_2)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_2)
	level_03__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_2)
	level_04__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_04__STAGE_2)
	level_05__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_05__STAGE_2)
	level_06__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2)
	
	level_02_hard__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_2__HARD)
	level_06_hard__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_06__STAGE_2__HARD)
	
	
	layout_03__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03)
	layout_03__tile.layout_ele_id_to_put_cursor_to = 3
	


