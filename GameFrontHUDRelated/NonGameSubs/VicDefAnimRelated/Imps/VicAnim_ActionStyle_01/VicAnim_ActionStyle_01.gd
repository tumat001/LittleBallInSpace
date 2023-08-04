extends "res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/AbstractVicDefAnim.gd"


const BANNER_EXPAND_DURATION : float = 0.1
const LABEL_FULL_SHOW_DURATION : float = 1.5

const ANIM_DURATION : float = 3.5

#

onready var horizontal_band = $HorizontalBand
onready var vertical_band_left = $VerticalBandLeft
onready var vertical_band_right = $VerticalBandRight

onready var label = $Label


func _ready():
	reset_show()

###

func reset_show():
	.reset_show()
	
	vertical_band_left.rect_scale.y = 0
	vertical_band_right.rect_scale.y = 0
	horizontal_band.rect_scale.x = 0
	label.visible_characters = 0


func start_show():
	.start_show()
	
	label.text = get_win_message()
	
	var tweener = create_tween()
	tweener.tween_property(horizontal_band, "rect_scale:x", 960.0, BANNER_EXPAND_DURATION)
	tweener.tween_property(vertical_band_left, "rect_scale:y", 540.0, BANNER_EXPAND_DURATION).set_delay(BANNER_EXPAND_DURATION / 2)
	tweener.tween_property(vertical_band_right, "rect_scale:y", 540.0, BANNER_EXPAND_DURATION).set_delay(BANNER_EXPAND_DURATION)
	tweener.tween_property(label, "visible_characters", label.text.length(), LABEL_FULL_SHOW_DURATION).set_delay(BANNER_EXPAND_DURATION)
	tweener.tween_callback(self, "_on_end_of_tweener").set_delay(ANIM_DURATION)

func _on_end_of_tweener():
	_end_of_anim()
	

