extends MarginContainer

signal slider_value_changed(arg_val)


onready var v_slider = $Control/SliderMarginer/VSlider
onready var value_label = $Control/ValueMarginer/ValueLabel
onready var name_label = $Control/NameMarginer/NameLabel

#

func _ready():
	v_slider.connect("value_changed", self, "_on_vslider_value_changed")
	


func _on_vslider_value_changed(arg_val : float):
	value_label.text = str(arg_val)
	
	emit_signal("slider_value_changed", arg_val)


##

func set_value(arg_val, arg_emit_signal : bool = false):
	v_slider.value = arg_val
	value_label.text = str(v_slider.value)
	
	if arg_emit_signal:
		emit_signal("slider_value_changed", arg_val)

func set_name_label(arg_label):
	name_label.text = arg_label
	


func get_value():
	return v_slider.value
