extends "res://MiscRelated/GUIControlsRelated/PlayerGUI_SliderStandard/PlayerGUI_AbstractSliderStandard.gd"


onready var hslider_control = $Control/HSlider
onready var value_label_control = $Control/ValueLabel
onready var name_label_control = $Control/NameLabel


func _ready():
	set_slider(hslider_control)
	set_value_label_control(value_label_control)
	set_name_label_control(name_label_control)
