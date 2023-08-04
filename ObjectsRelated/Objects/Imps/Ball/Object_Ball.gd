extends "res://ObjectsRelated/Objects/BaseObject.gd"

signal after_ready()


#const COLOR_RED := Color(255/255.0, 14/255.0, 10/255.0)  # reserved for enemies
const COLOR_ORANGE := Color(255/255.0, 128/255.0, 0/255.0)
const COLOR_YELLOW := Color(255/255.0, 251/255.0, 0/255.0)
const COLOR_GREEN := Color(101/255.0, 253/255.0, 78/255.0)
const COLOR_BLUE := Color(78/255.0, 123/255.0, 253/255.0)
const COLOR_VIOLET := Color(165/255.0, 78/255.0, 253/255.0)
const COLOR_WHITE := Color(255/255.0, 255/255.0, 255/255.0)

const all_colors = [
	#COLOR_RED,
	COLOR_ORANGE,
	COLOR_YELLOW,
	COLOR_GREEN,
	COLOR_BLUE,
	COLOR_VIOLET,
	COLOR_WHITE,
]

##

func _ready():
	randomize_color()
	
	emit_signal("after_ready")

##

func randomize_color():
	var rng = StoreOfRng.get_rng(StoreOfRng.RNGSource.NON_ESSENTIAL)
	var rand_color = StoreOfRng.randomly_select_one_element(all_colors, rng)
	
	modulate = rand_color


