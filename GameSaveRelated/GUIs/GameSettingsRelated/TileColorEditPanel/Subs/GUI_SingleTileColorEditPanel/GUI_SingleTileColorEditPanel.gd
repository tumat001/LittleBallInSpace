extends MarginContainer

const BaseTileset = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")

#signal color_pick_finalized(arg_color)

#


class AdvParam:
	var title_desc : Array
	
	var var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER : String
	var var_name__get__tile_color_config__tile_modulate__x : String
	var func_name__set__tile_color_config__tile_modulate__x : String
	var var_name__get__tile_color_config__tile_modulate__x__default : String
	
	var var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER : String
	var var_name__get__shared_commnons__all_color_presets : String
	var func_name__set__shared_commnons__all_color_presets : String
	
	var signal_name__tile_color_config__tile_modulate__x_changed : String
	var signal_name__tile_color_config__tile_presets__x_changed : String


var var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER : String
var var_name__get__tile_color_config__tile_modulate__x : String
var func_name__set__tile_color_config__tile_modulate__x : String
var var_name__get__tile_color_config__tile_modulate__x__default : String

var var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER : String
var var_name__get__shared_commnons__all_color_presets : String
var func_name__set__shared_commnons__all_color_presets : String

var signal_name__tile_color_config__tile_modulate__x_changed : String
var signal_name__tile_color_config__tile_presets__x_changed : String

#

# use methods to set this
var _is_color_picker_open : bool setget _set_is_color_picker_open

#

onready var title_tooltip_body = $VBoxContainer/TitleTooltipBody
onready var color_picker_button = $VBoxContainer/HBoxContainer/ColorPickerButton
onready var test_texture_rect = $VBoxContainer/TestTextureRect

#

func _set_is_color_picker_open(arg_val):
	_is_color_picker_open = arg_val
	
	set_process_input(_is_color_picker_open)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			color_picker_button.attempt_close_color_picker()
			_on_close_of_color_picker_button_popup__any_means()
			get_viewport().set_input_as_handled()

#

func _ready():
	_set_is_color_picker_open(false)
	

#

func configure_tile_color_editor(arg_param : AdvParam):
	var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER = arg_param.var_name__TILE_COLOR_CONFIG__TILE_MODULATE__X__DIC_IDENTIFIER
	var_name__get__tile_color_config__tile_modulate__x = arg_param.var_name__get__tile_color_config__tile_modulate__x
	func_name__set__tile_color_config__tile_modulate__x = arg_param.func_name__set__tile_color_config__tile_modulate__x
	var_name__get__tile_color_config__tile_modulate__x__default = arg_param.var_name__get__tile_color_config__tile_modulate__x__default
	
	var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER = arg_param.var_name__SHARED_COMMONS__ALL_COLOR_PRESETS__DIC_IDENTIFIER
	var_name__get__shared_commnons__all_color_presets = arg_param.var_name__get__shared_commnons__all_color_presets
	func_name__set__shared_commnons__all_color_presets = arg_param.func_name__set__shared_commnons__all_color_presets
	
	signal_name__tile_color_config__tile_modulate__x_changed = arg_param.signal_name__tile_color_config__tile_modulate__x_changed
	signal_name__tile_color_config__tile_presets__x_changed = arg_param.signal_name__tile_color_config__tile_presets__x_changed
	
	#
	
	title_tooltip_body.descriptions = arg_param.title_desc
	title_tooltip_body.update_display()
	
	_update_curr_colors_based_on_configs()
	_attempt__set_presets__from_GSettingsM()
	_connect_signals_with_GSettingsM()

func _connect_signals_with_GSettingsM():
	GameSettingsManager.connect(signal_name__tile_color_config__tile_modulate__x_changed, self, "_on_GSettingsM_signal_name__tile_color_config__tile_modulate__x_changed")
	GameSettingsManager.connect(signal_name__tile_color_config__tile_presets__x_changed, self, "_on_GSettingsM_signal_name__tile_color_config__tile_presets__x_changed")


func _on_GSettingsM_signal_name__tile_color_config__tile_modulate__x_changed(arg_val):
	#if !is_visible_in_tree():
	_update_curr_colors_based_on_configs()

func _on_GSettingsM_signal_name__tile_color_config__tile_presets__x_changed(arg_val):
	#if !is_visible_in_tree():
	_attempt__set_presets__from_GSettingsM()
	


##

func _on_ColorPickerButton_color_changed(color):
	test_texture_rect.modulate = BaseTileset.calculate_final_modulate_to_use([color])
	
	_finalize_color_pick__make_changes_to_GSettingsM(color_picker_button.color_picker.color)
	
	#_attempt_update_presets_of_GSettingsM()

func _on_ColorPickerButton_popup_closed():
	#_finalize_color_pick__make_changes_to_GSettingsM(color_picker_button.color_picker.color)
	
	_on_close_of_color_picker_button_popup__any_means()

func _on_close_of_color_picker_button_popup__any_means():
	_set_is_color_picker_open(false)
	_attempt_update_presets_of_GSettingsM()

#

func _on_ResetToDefaultButton_pressed():
	var color = GameSettingsManager.get(var_name__get__tile_color_config__tile_modulate__x__default)
	
	_finalize_color_pick__make_changes_to_GSettingsM(color)

func _finalize_color_pick__make_changes_to_GSettingsM(arg_color):
	#emit_signal("color_pick_finalized", arg_color)
	GameSettingsManager.call(func_name__set__tile_color_config__tile_modulate__x, arg_color)

##

func _update_curr_colors_based_on_configs():
	if is_inside_tree():
		var curr_color = GameSettingsManager.get(var_name__get__tile_color_config__tile_modulate__x) 
		
		test_texture_rect.modulate = BaseTileset.calculate_final_modulate_to_use([curr_color])
		color_picker_button.color = curr_color


##

func _attempt__set_presets__from_GSettingsM():
	if is_inside_tree():
		var picker : ColorPicker = color_picker_button.color_picker
		if is_instance_valid(picker):
			_set_presets__of_color_picker__from_GSettingsM()
			


#

func _on_ColorPickerButton_picker_created():
	pass
	#_set_presets__of_color_picker__from_GSettingsM()

func _on_ColorPickerButton_pressed():
	_set_presets__of_color_picker__from_GSettingsM()
	
	_set_is_color_picker_open(true)


func _set_presets__of_color_picker__from_GSettingsM():
	var presets = GameSettingsManager.get(var_name__get__shared_commnons__all_color_presets)
	
	color_picker_button.set_presets(presets)


func _attempt_update_presets_of_GSettingsM():
	var presets_of_picker_button = color_picker_button.get_presets()
	var bucket = []
	for color_preset in presets_of_picker_button:
		bucket.append(color_preset)
	
	GameSettingsManager.call(func_name__set__shared_commnons__all_color_presets, bucket)


######
