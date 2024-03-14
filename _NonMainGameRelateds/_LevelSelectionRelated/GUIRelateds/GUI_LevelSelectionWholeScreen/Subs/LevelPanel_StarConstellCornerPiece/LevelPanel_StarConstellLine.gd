tool
extends MarginContainer


const BASE_MODULATE = Color("#ECD58D")

const MARGIN_NAME__LEFT = "margin_left"
const MARGIN_NAME__RIGHT = "margin_right"
const MARGIN_NAME__TOP = "margin_top"
const MARGIN_NAME__BOTTOM = "margin_bottom"
const ALL_MARGIN_NAMES = [
	MARGIN_NAME__LEFT,
	MARGIN_NAME__RIGHT,
	MARGIN_NAME__TOP,
	MARGIN_NAME__BOTTOM,
	
]

const POS_MARGIN_AMOUNT : int = 4
enum PositionTypeId {
	TOP = 0,
	BOT = 1,
	LEFT = 2,
	RIGHT = 3,
}
export(PositionTypeId) var position_type_id : int setget set_position_type_id

#

func set_position_type_id(arg_position_type_id):
	position_type_id = arg_position_type_id
	
	if is_inside_tree() or Engine.editor_hint:
		_update_properties_based_on_position_type_id()

func _update_properties_based_on_position_type_id():
	match position_type_id:
		PositionTypeId.TOP:
			size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
			size_flags_vertical = SIZE_EXPAND
			_set_margin_constant_override__and_reset_others(MARGIN_NAME__TOP)
		PositionTypeId.BOT:
			size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
			size_flags_vertical = SIZE_EXPAND | SIZE_SHRINK_END
			_set_margin_constant_override__and_reset_others(MARGIN_NAME__BOTTOM)
		PositionTypeId.LEFT:
			size_flags_horizontal = SIZE_EXPAND
			size_flags_vertical = SIZE_FILL | SIZE_EXPAND
			_set_margin_constant_override__and_reset_others(MARGIN_NAME__LEFT)
		PositionTypeId.RIGHT:
			size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END
			size_flags_vertical = SIZE_FILL | SIZE_EXPAND
			_set_margin_constant_override__and_reset_others(MARGIN_NAME__RIGHT)
		

func _set_margin_constant_override__and_reset_others(arg_margin_name):
	for margin_name in ALL_MARGIN_NAMES:
		add_constant_override(margin_name, 0)
	
	add_constant_override(arg_margin_name, POS_MARGIN_AMOUNT)


###

func _ready() -> void:
	_update_properties_based_on_position_type_id()
	modulate = BASE_MODULATE
