extends MarginContainer


const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")


onready var stcep_normal = $HBoxContainer/TileColorContainer/VBoxContainer/STCEP_Normal
onready var stcep_energized = $HBoxContainer/TileColorContainer/VBoxContainer/STCEP_Energized
onready var stcep_grounded = $HBoxContainer/TileColorContainer/VBoxContainer/STCEP_Grounded

#

func _ready():
	_init_all_stcep()
	

func _init_all_stcep():
	var adv_param__normal = stcep_normal.AdvParam.new()
	adv_param__normal.title_desc = [
		["|0|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.NORMAL_TILES, "Normal Tiles")]]
	]
	adv_param__normal.var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__NORMAL__DIC_IDENTIFIER"
	adv_param__normal.var_name__get__tile_color_config__tile_modulate__x = "tile_color_config__tile_modulate__normal"
	adv_param__normal.func_name__set__tile_color_config__tile_modulate__x = "set_tile_color_config__tile_modulate__normal"
	adv_param__normal.var_name__get__tile_color_config__tile_modulate__x__default = "tile_color_config__tile_modulate__normal__default"
	
	adv_param__normal.var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER"
	adv_param__normal.var_name__get__shared_commnons__all_color_presets = "shared_commnons__all_color_presets"
	adv_param__normal.func_name__set__shared_commnons__all_color_presets = "set_shared_commnons__all_color_presets"
	
	adv_param__normal.signal_name__tile_color_config__tile_modulate__x_changed = "tile_color_config__tile_modulate__normal_changed"
	adv_param__normal.signal_name__tile_color_config__tile_presets__x_changed = "shared_commons__all_color_presets__changed"
	
	stcep_normal.configure_tile_color_editor(adv_param__normal)
	##
	
	var adv_param__energized = stcep_energized.AdvParam.new()
	adv_param__energized.title_desc = [
		["|0|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.ENERGIZED_TILES, "Energized Tiles")]]
	]
	adv_param__energized.var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__ENERGIZED__DIC_IDENTIFIER"
	adv_param__energized.var_name__get__tile_color_config__tile_modulate__x = "tile_color_config__tile_modulate__energized"
	adv_param__energized.func_name__set__tile_color_config__tile_modulate__x = "set_tile_color_config__tile_modulate__energized"
	adv_param__energized.var_name__get__tile_color_config__tile_modulate__x__default = "tile_color_config__tile_modulate__energized__default"
	
	adv_param__energized.var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER"
	adv_param__energized.var_name__get__shared_commnons__all_color_presets = "shared_commnons__all_color_presets"
	adv_param__energized.func_name__set__shared_commnons__all_color_presets = "set_shared_commnons__all_color_presets"
	
	adv_param__energized.signal_name__tile_color_config__tile_modulate__x_changed = "tile_color_config__tile_modulate__energized_changed"
	adv_param__energized.signal_name__tile_color_config__tile_presets__x_changed = "shared_commons__all_color_presets__changed"
	
	
	stcep_energized.configure_tile_color_editor(adv_param__energized)
	
	##
	
	var adv_param__grounded = stcep_energized.AdvParam.new()
	adv_param__grounded.title_desc = [
		["|0|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES, "Grounded Tiles")]]
	]
	adv_param__grounded.var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__GROUNDED__DIC_IDENTIFIER"
	adv_param__grounded.var_name__get__tile_color_config__tile_modulate__x = "tile_color_config__tile_modulate__grounded"
	adv_param__grounded.func_name__set__tile_color_config__tile_modulate__x = "set_tile_color_config__tile_modulate__grounded"
	adv_param__grounded.var_name__get__tile_color_config__tile_modulate__x__default = "tile_color_config__tile_modulate__grounded__default"
	
	adv_param__grounded.var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER = "TILE_COLOR_CONFIG__TILE_MODULATE__FOR_ALL_TYPES_PRESETS_DIC_IDENTIFIER"
	adv_param__grounded.var_name__get__shared_commnons__all_color_presets = "shared_commnons__all_color_presets"
	adv_param__grounded.func_name__set__shared_commnons__all_color_presets = "set_shared_commnons__all_color_presets"
	
	adv_param__grounded.signal_name__tile_color_config__tile_modulate__x_changed = "tile_color_config__tile_modulate__grounded_changed"
	adv_param__grounded.signal_name__tile_color_config__tile_presets__x_changed = "shared_commons__all_color_presets__changed"
	
	
	stcep_grounded.configure_tile_color_editor(adv_param__grounded)
	


#############################################
# TREE ITEM Specific methods/vars

var control_tree setget set_control_tree

var _old_control_tree_modulate : Color
const COLOR_FOR_CONTROL_TREE = Color("f5ffffff")

func on_control_received_focus():
	_old_control_tree_modulate = control_tree.background_texture_rect_modulate
	control_tree.set_background_texture_rect_modulate(COLOR_FOR_CONTROL_TREE)

func on_control_fully_visible():
	pass

func on_control_lost_focus():
	control_tree.set_background_texture_rect_modulate(_old_control_tree_modulate)

func on_control_fully_invisible():
	pass
	


func set_control_tree(arg_tree):
	control_tree = arg_tree
	

############
# END OF TREE ITEM Specific methods/vars
###########

