extends ColorPickerButton


var color_picker : ColorPicker

func _ready():
	color_picker = get_picker()
	
	color_picker.deferred_mode = true
	

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

