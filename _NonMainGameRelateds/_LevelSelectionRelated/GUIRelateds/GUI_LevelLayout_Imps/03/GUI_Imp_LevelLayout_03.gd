extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"



onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01


onready var layout_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To02

#

func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_03



func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_3)
	
	layout_02__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_02)
	layout_02__tile.layout_ele_id_to_put_cursor_to = 15
	

