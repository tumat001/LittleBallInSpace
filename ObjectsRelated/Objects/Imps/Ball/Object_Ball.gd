extends "res://ObjectsRelated/Objects/BaseObject.gd"

signal after_ready()


const COLOR_RED := Color(255/255.0, 14/255.0, 10/255.0)  # reserved for enemies
const COLOR_ORANGE := Color(255/255.0, 128/255.0, 0/255.0)
const COLOR_YELLOW := Color(255/255.0, 251/255.0, 0/255.0)
const COLOR_GREEN := Color(101/255.0, 253/255.0, 78/255.0)
const COLOR_BLUE := Color(78/255.0, 123/255.0, 253/255.0)
const COLOR_VIOLET := Color(165/255.0, 78/255.0, 253/255.0)
const COLOR_WHITE := Color(255/255.0, 255/255.0, 255/255.0)

const all_colors_but_red = [
	#COLOR_RED,
	COLOR_ORANGE,
	COLOR_YELLOW,
	COLOR_GREEN,
	COLOR_BLUE,
	COLOR_VIOLET,
	COLOR_WHITE,
]

const all_colors = [
	COLOR_RED,
	
	COLOR_ORANGE,
	COLOR_YELLOW,
	COLOR_GREEN,
	COLOR_BLUE,
	COLOR_VIOLET,
	COLOR_WHITE,
]

#

var is_class_type_obj_ball : bool = true


var _start_tween_rainbow_at_ready : bool

##

func _ready():
	#randomize_color()
	
	if _start_tween_rainbow_at_ready:
		tween_rainbow_color()
	emit_signal("after_ready")

##

func randomize_color_modulate__except_red():
	var rng = StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL)
	var rand_color = StoreOfRNG.randomly_select_one_element(all_colors_but_red, rng)
	
	modulate = rand_color

func tween_rainbow_color():
	randomize_color_modulate__except_red()
	
	if is_inside_tree():
		_tween_rainbow_color__in_tree()
	else:
		_start_tween_rainbow_at_ready = true

func _tween_rainbow_color__in_tree():
	var tweener = create_tween()
	tweener.set_loops()
	for color in all_colors_but_red:
		tweener.tween_property(self, "modulate", color, 1.0)
	


