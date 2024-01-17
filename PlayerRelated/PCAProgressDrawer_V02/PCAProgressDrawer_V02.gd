extends TextureProgress


var ratio_filled : float = 0 setget set_ratio_filled


func _ready():
	max_value = 1
	visible = false

func set_ratio_filled(arg_val):
	ratio_filled = arg_val
	
	value = ratio_filled

