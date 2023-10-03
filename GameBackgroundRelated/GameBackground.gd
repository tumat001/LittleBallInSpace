extends ParallaxBackground


const BackgroundColor_Normal = Color("#000000")
const BackgroundColor_Brightened = Color("#030011")


#

var small__total_star_count : int
var small__normal_vis_star_count : int

var _color_rect_modulate_tweener : SceneTreeTween

#

export(float) var background_tween_duration : float = 5.0

#

onready var small_star_grid_background = $StarGridBackground
onready var background_color_rect = $ColorRect

#

func _ready():
	pass
	#CameraManager.make_node_rotate_with_camera(self)
	
	####
	
	small__total_star_count = small_star_grid_background.star_count__at_start
	small__normal_vis_star_count = small_star_grid_background.visible_star_count
	

##

func request_show_brightened_star_background__star_collectible_collected():
	#print("all collected")
	small_star_grid_background.visible_star_count = small__total_star_count
	_tween_color_rect__into_color(BackgroundColor_Brightened)

func request_unshow_brightened_star_background__star_collectible_uncollected():
	#print("all not collected")
	small_star_grid_background.visible_star_count = small__normal_vis_star_count
	_tween_color_rect__into_color(BackgroundColor_Normal)

#

func _tween_color_rect__into_color(arg_color):
	_color_rect_modulate_tweener = create_tween()
	_color_rect_modulate_tweener.tween_property(background_color_rect, "color", arg_color, background_tween_duration)
	
