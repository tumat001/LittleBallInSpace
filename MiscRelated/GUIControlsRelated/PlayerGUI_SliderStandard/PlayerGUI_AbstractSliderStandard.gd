extends MarginContainer

signal slider_value_changed(arg_val)


var slider setget set_slider
var name_label setget set_name_label_control
var value_label setget set_value_label_control


###

func set_slider(arg_slider):
	slider = arg_slider
	
	slider.connect("value_changed", self, "_on_slider_value_changed")

func _on_slider_value_changed(arg_val):
	value_label.text = str(arg_val)
	
	emit_signal("slider_value_changed", arg_val)


func set_name_label_control(arg_label):
	name_label = arg_label

func set_value_label_control(arg_label):
	value_label = arg_label

##

func set_value(arg_val, arg_emit_signal : bool = false):
	slider.value = arg_val
	value_label.text = str(slider.value)
	
	if arg_emit_signal:
		emit_signal("slider_value_changed", arg_val)

func set_name_label(arg_label):
	name_label.text = arg_label
	

#

func get_value():
	return slider.value

func get_max_value():
	return slider.max_value

