extends ColorPickerButton


signal color_changed__by_any_means__input_esc_eat(arg_color)

#

var color_picker : ColorPicker

#

var _is_eat_esc_input__popup_open : bool setget _set_is_eat_esc_input__popup_open

export(bool) var configure_to_eat_esc_on_open__at_ready : bool = false

#

var _is_set_own_presets_based_on_GSettingsM : bool

var var_name__get__shared_commnons__all_color_presets
var func_name__set__shared_commnons__all_color_presets

#

func _ready():
	color_picker = get_picker()
	
	color_picker.deferred_mode = true
	
	_set_is_eat_esc_input__popup_open(false)
	
	if configure_to_eat_esc_on_open__at_ready:
		configure_self__eat_escape_input_to_change_color()


#

func set_presets(arg_presets : Array):
	clear_presets()
	for preset_color in arg_presets:
		color_picker.add_preset(preset_color)

func clear_presets():
	#print("cleared presets: %s" % [color_picker.get_presets()])
	for preset in color_picker.get_presets():
		color_picker.erase_preset(preset)

func get_presets():
	#print("presets, of color picker: %s" % [color_picker.get_presets()])
	return color_picker.get_presets()



func attempt_close_color_picker():
	get_popup().hide()


##

func configure_self__eat_escape_input_to_change_color():
	connect("color_changed", self, "_on_color_changed__base")
	connect("pressed", self, "_on_pressed__base")
	connect("popup_closed", self, "_on_popup_closed__base")
	

func _set_is_eat_esc_input__popup_open(arg_val):
	_is_eat_esc_input__popup_open = arg_val
	
	if _is_eat_esc_input__popup_open:
		set_process_input(true)
	else:
		set_process_input(false)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			get_popup().hide()
			_on_popup_closed__base()
			_on_color_changed__base(color)
			
			get_viewport().set_input_as_handled()

func _on_color_changed__base(arg_color):
	emit_signal("color_changed__by_any_means__input_esc_eat", arg_color)
	


func _on_pressed__base():
	_set_presets__of_color_picker__from_GSettingsM()
	
	_set_is_eat_esc_input__popup_open(true)
	

func _on_popup_closed__base():
	_set_is_eat_esc_input__popup_open(false)
	if _is_set_own_presets_based_on_GSettingsM:
		_attempt_update_presets_of_GSettingsM()



func configure_self_to_update_to_GSettingsM_presets(arg_var_name__get__shared_commnons__all_color_presets, arg_func_name__set__shared_commnons__all_color_presets,
		arg_signal_name__tile_color_config__tile_presets__x_changed):
	var_name__get__shared_commnons__all_color_presets = arg_var_name__get__shared_commnons__all_color_presets
	func_name__set__shared_commnons__all_color_presets = arg_func_name__set__shared_commnons__all_color_presets
	
	_is_set_own_presets_based_on_GSettingsM = true
	
	GameSettingsManager.connect(arg_signal_name__tile_color_config__tile_presets__x_changed, self, "_on_GSettingsM_signal_name__color_presets__x_changed")
	
	_set_presets__of_color_picker__from_GSettingsM()

func _on_GSettingsM_signal_name__color_presets__x_changed(arg_presets):
	_set_presets__of_color_picker__from_GSettingsM()
	

func _set_presets__of_color_picker__from_GSettingsM():
	var presets = GameSettingsManager.get(var_name__get__shared_commnons__all_color_presets)
	
	set_presets(presets)

func _attempt_update_presets_of_GSettingsM():
	var presets_of_picker_button = get_presets()
	var bucket = []
	for color_preset in presets_of_picker_button:
		bucket.append(color_preset)
	
	GameSettingsManager.call(func_name__set__shared_commnons__all_color_presets, bucket)




