extends "res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd"



onready var level_01__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_01
onready var level_02__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_02
onready var level_03__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_03
onready var level_04__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_04
onready var level_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Tile_05

onready var layout_05__tile = $LayoutElesContainer/GUI_LevelLayoutEle_Layout_To05

#

onready var vkp_ui_up = $OthersContainer/ToMoveContainer/MarginContainer/HBoxContainer/VBoxContainer/VKP_Up
onready var vkp_ui_down = $OthersContainer/ToMoveContainer/MarginContainer/HBoxContainer/VBoxContainer/VKP_Down
onready var vkp_ui_left = $OthersContainer/ToMoveContainer/MarginContainer/HBoxContainer/VKP_Left
onready var vkp_ui_right = $OthersContainer/ToMoveContainer/MarginContainer/HBoxContainer/VKP_Right

onready var vkp_ui_enter = $OthersContainer/EnterContainer/VKP_EnterLevel


#

func _init():
	level_layout_id = StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_01

func _ready():
	level_01__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_1)
	level_02__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_02__STAGE_1)
	level_03__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_03__STAGE_1)
	level_04__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_04__STAGE_1)
	level_05__tile.level_details = StoreOfLevels.generate_or_get_level_details_of_id(StoreOfLevels.LevelIds.LEVEL_05__STAGE_1)
	
	layout_05__tile.level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(StoreOfLevelLayouts.LevelLayoutIds.LAYOUT_05)
	layout_05__tile.layout_ele_id_to_put_cursor_to = 15
	
	###########
	
	vkp_ui_up.use_image_display_instead_of_text = true
	vkp_ui_down.use_image_display_instead_of_text = true
	vkp_ui_left.use_image_display_instead_of_text = true
	vkp_ui_right.use_image_display_instead_of_text = true
	
	vkp_ui_up.any_control_action_name = "ui_up"
	vkp_ui_down.any_control_action_name = "ui_down"
	vkp_ui_left.any_control_action_name = "ui_left"
	vkp_ui_right.any_control_action_name = "ui_right"
	vkp_ui_enter.any_control_action_name = "ui_accept"
	


