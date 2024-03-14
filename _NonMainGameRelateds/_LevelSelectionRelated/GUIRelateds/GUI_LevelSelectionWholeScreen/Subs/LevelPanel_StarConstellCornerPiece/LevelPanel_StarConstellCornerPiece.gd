tool
extends TextureRect


const BASE_MODULATE = Color("#ECD58D")

const GUI_LevelSelectionWS_TopCornerDecor_01 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_01.png")
const GUI_LevelSelectionWS_TopCornerDecor_02 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_02.png")
const GUI_LevelSelectionWS_TopCornerDecor_03 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_03.png")
const GUI_LevelSelectionWS_TopCornerDecor_04 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_04.png")
const GUI_LevelSelectionWS_TopCornerDecor_05 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_05.png")
const GUI_LevelSelectionWS_TopCornerDecor_06 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_06.png")
const GUI_LevelSelectionWS_TopCornerDecor_07 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_07.png")
const GUI_LevelSelectionWS_TopCornerDecor_08 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_08.png")
const GUI_LevelSelectionWS_TopCornerDecor_09 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelSelectionWholeScreen/Assets/LevelSelectionWhoeScreen_MidPanel_Assets/GUI_LevelSelectionWS_TopCornerDecor_09.png")
const ALL_CORNER_DECOR_TEXTURES__5x3_MAX : Array = [
	GUI_LevelSelectionWS_TopCornerDecor_01,
	GUI_LevelSelectionWS_TopCornerDecor_02,
	GUI_LevelSelectionWS_TopCornerDecor_03,
	GUI_LevelSelectionWS_TopCornerDecor_04,
	GUI_LevelSelectionWS_TopCornerDecor_05,
	GUI_LevelSelectionWS_TopCornerDecor_06,
	GUI_LevelSelectionWS_TopCornerDecor_07,
	GUI_LevelSelectionWS_TopCornerDecor_08,
	GUI_LevelSelectionWS_TopCornerDecor_09,
]

const ALL_CORNER_DECOR_TEXTURES__3x3_EDGE_ONLY_MAX : Array = [
	GUI_LevelSelectionWS_TopCornerDecor_06,
	GUI_LevelSelectionWS_TopCornerDecor_07,
	GUI_LevelSelectionWS_TopCornerDecor_08,
	GUI_LevelSelectionWS_TopCornerDecor_09,
]

#


enum CornerTypeId {
	TOP_LEFT = 0,
	TOP_RIGHT = 1,
	BOT_LEFT = 2,
	BOT_RIGHT = 3,
}
export(CornerTypeId) var corner_type_id : int setget set_corner_type_id

enum TextureTypeId {
	DIM_5X3__FILL = 0,
	DIM_3X3__NO_FILL = 1,
}
export(TextureTypeId) var texture_type_id : int setget set_texture_type_id

#

func set_corner_type_id(arg_id):
	corner_type_id = arg_id
	
	if is_inside_tree() or Engine.editor_hint:
		_update_properties_based_on_corner_type_id()

func _update_properties_based_on_corner_type_id():
	match corner_type_id:
		CornerTypeId.TOP_LEFT:
			size_flags_horizontal = SIZE_FILL
			size_flags_vertical = SIZE_FILL
			flip_h = false
			flip_v = false
			
			#add_constant_override("margin_left", CORNER_MARGIN_AMOUNT)
		CornerTypeId.TOP_RIGHT:
			size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END
			size_flags_vertical = SIZE_FILL
			flip_h = true
			flip_v = false
			
			#add_constant_override("margin_right", CORNER_MARGIN_AMOUNT)
		CornerTypeId.BOT_LEFT:
			size_flags_horizontal = SIZE_FILL
			size_flags_vertical = SIZE_EXPAND | SIZE_SHRINK_END
			flip_h = false
			flip_v = true
			
			#add_constant_override("margin_left", CORNER_MARGIN_AMOUNT)
		CornerTypeId.BOT_RIGHT:
			size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END
			size_flags_vertical = SIZE_EXPAND | SIZE_SHRINK_END
			flip_h = true
			flip_v = true
			
			#add_constant_override("margin_left", CORNER_MARGIN_AMOUNT)
		
	



func set_texture_type_id(arg_type_id):
	texture_type_id = arg_type_id
	
	if is_inside_tree() or Engine.editor_hint:
		_update_texture_based_on_texture_type_id()

func _update_texture_based_on_texture_type_id():
	
	if Engine.editor_hint:
		match texture_type_id:
			TextureTypeId.DIM_5X3__FILL:
				texture = GUI_LevelSelectionWS_TopCornerDecor_01
			TextureTypeId.DIM_3X3__NO_FILL:
				texture = GUI_LevelSelectionWS_TopCornerDecor_06
		
		return
	
	#####
	
	var arr_of_textures : Array
	match texture_type_id:
		TextureTypeId.DIM_5X3__FILL:
			arr_of_textures = ALL_CORNER_DECOR_TEXTURES__5x3_MAX
		TextureTypeId.DIM_3X3__NO_FILL:
			arr_of_textures = ALL_CORNER_DECOR_TEXTURES__3x3_EDGE_ONLY_MAX
	
	var rand_texture = StoreOfRNG.randomly_select_one_element(arr_of_textures, SingletonsAndConsts.non_essential_rng)
	texture = rand_texture

#

func _ready() -> void:
	_update_properties_based_on_corner_type_id()
	_update_texture_based_on_texture_type_id()
	modulate = BASE_MODULATE
