extends "res://GameFrontHUDRelated/NonGameSubs/VicDefAnimRelated/AbstractVicDefAnim.gd"


#

const SHADER_PARAM_NAME__PROGRESS = "progress"
const SHADER_PARAM_NAME__TOP_LEFT = "topleft"
const SHADER_PARAM_NAME__TOP_RIGHT = "topright"
const SHADER_PARAM_NAME__BOT_LEFT = "bottomleft"
const SHADER_PARAM_NAME__BOT_RIGHT = "bottomright"


const HORIZONTAL_BAND_EDGE_MODULATE__NORMAL = Color("#DDBBBBBB")
const HORIZONTAL_BAND_EDGE_MODULATE__STAR = Color("#DD130070")

const HORIZONTAL_BAND_FILL_COLOR__TOP_LEFT__NORMAL := Color("#EE070707")
const HORIZONTAL_BAND_FILL_COLOR__TOP_RIGHT__NORMAL := Color("#EE070707")
const HORIZONTAL_BAND_FILL_COLOR__BOT_LEFT__NORMAL := Color("#EE070707")
const HORIZONTAL_BAND_FILL_COLOR__BOT_RIGHT__NORMAL := Color("#EE070707")

const HORIZONTAL_BAND_FILL_COLOR__TOP_LEFT__STAR := Color("#EE0e001d")
const HORIZONTAL_BAND_FILL_COLOR__TOP_RIGHT__STAR := Color("#EE070707")
const HORIZONTAL_BAND_FILL_COLOR__BOT_LEFT__STAR := Color("#EE070707")
const HORIZONTAL_BAND_FILL_COLOR__BOT_RIGHT__STAR := Color("#EE000321")


#

const BANNER_EXPAND_DURATION : float = 0.1
const LABEL_FULL_SHOW_DURATION : float = 1.5

const ANIM_DURATION : float = 3.5

#

onready var horizontal_band_edge = $HorizontalBandEdge
onready var horizontal_band_fill_color_rect = $HorizontalBandFillColorRect
onready var horizontal_band_edge_mat = horizontal_band_edge.material
onready var horizontal_band_fill_color_rect_mat = horizontal_band_fill_color_rect.material


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
	#horizontal_band_edge.rect_scale.x = 0
	label.visible_characters = 0
	
	set_horizontal_band_edge_mat__progress(0.0)
	set_horizontal_band_fill_color_rect_mat__progress(0.0)


func start_show():
	.start_show()
	
	label.text = get_win_message()
	
	#
	
	update_horiz_bands_colors_based_on_states()
	
	#
	
	var tweener = create_tween()
	#tweener.tween_property(horizontal_band_edge, "rect_scale:x", 960.0, BANNER_EXPAND_DURATION)
	tweener.tween_method(self, "set_all_horizontals__progress", 0.0, 1.0, BANNER_EXPAND_DURATION)
	tweener.tween_property(vertical_band_left, "rect_scale:y", 540.0, BANNER_EXPAND_DURATION).set_delay(BANNER_EXPAND_DURATION / 2)
	tweener.tween_property(vertical_band_right, "rect_scale:y", 540.0, BANNER_EXPAND_DURATION).set_delay(BANNER_EXPAND_DURATION)
	tweener.tween_property(label, "visible_characters", label.text.length(), LABEL_FULL_SHOW_DURATION).set_delay(BANNER_EXPAND_DURATION)
	tweener.tween_callback(self, "_on_end_of_tweener").set_delay(ANIM_DURATION)

func _on_end_of_tweener():
	_end_of_anim()
	


##

func update_horiz_bands_colors_based_on_states():
	if GameSaveManager.is_all_coins_collected_in_curr_level__tentative():
		set_horizontal_band_fill_color_rect_mat__dir_colors(HORIZONTAL_BAND_FILL_COLOR__TOP_LEFT__STAR, HORIZONTAL_BAND_FILL_COLOR__TOP_RIGHT__STAR, HORIZONTAL_BAND_FILL_COLOR__BOT_LEFT__STAR, HORIZONTAL_BAND_FILL_COLOR__BOT_RIGHT__STAR)
		horizontal_band_edge.modulate = HORIZONTAL_BAND_EDGE_MODULATE__STAR
		
	else:
		set_horizontal_band_fill_color_rect_mat__dir_colors(HORIZONTAL_BAND_FILL_COLOR__TOP_LEFT__NORMAL, HORIZONTAL_BAND_FILL_COLOR__TOP_RIGHT__NORMAL, HORIZONTAL_BAND_FILL_COLOR__BOT_LEFT__NORMAL, HORIZONTAL_BAND_FILL_COLOR__BOT_RIGHT__NORMAL)
		horizontal_band_edge.modulate = HORIZONTAL_BAND_EDGE_MODULATE__NORMAL
		


func set_horizontal_band_fill_color_rect_mat__dir_colors(arg_top_left : Color, arg_top_right : Color, arg_bot_left : Color, arg_bot_right : Color):
	horizontal_band_fill_color_rect_mat.set_shader_param(SHADER_PARAM_NAME__TOP_LEFT, arg_top_left)
	horizontal_band_fill_color_rect_mat.set_shader_param(SHADER_PARAM_NAME__TOP_RIGHT, arg_top_right)
	horizontal_band_fill_color_rect_mat.set_shader_param(SHADER_PARAM_NAME__BOT_LEFT, arg_bot_left)
	horizontal_band_fill_color_rect_mat.set_shader_param(SHADER_PARAM_NAME__BOT_RIGHT, arg_bot_right)

#

func set_horizontal_band_edge_mat__progress(arg_progress : float):
	horizontal_band_edge_mat.set_shader_param(SHADER_PARAM_NAME__PROGRESS, arg_progress)

func set_horizontal_band_fill_color_rect_mat__progress(arg_progress : float):
	horizontal_band_fill_color_rect_mat.set_shader_param(SHADER_PARAM_NAME__PROGRESS, arg_progress)

func set_all_horizontals__progress(arg_progress : float):
	set_horizontal_band_edge_mat__progress(arg_progress)
	set_horizontal_band_fill_color_rect_mat__progress(arg_progress)




