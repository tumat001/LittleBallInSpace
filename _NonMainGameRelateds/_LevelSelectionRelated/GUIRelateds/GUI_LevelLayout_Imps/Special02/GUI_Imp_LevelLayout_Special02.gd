extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"


#

onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02

onready var layout_spec_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_ToSpec01

#

func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02


func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_SPECIAL_2)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_SPECIAL_2)
	
	layout_spec_01__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_SPECIAL_02)
	layout_spec_01__tile.layout_ele_id_to_put_cursor_to = 24
	

#

func _set_game_background_based_on_states(arg_is_instant_in_transition):
	pass
	#todoimp change this to depending on completion states

