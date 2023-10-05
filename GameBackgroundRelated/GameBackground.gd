extends ParallaxBackground



const Shader_RippleBackground = preload("res://MiscRelated/ShadersRelated/Shader_RippleGradient.tres")


const BackgroundColor_Normal = Color("#000000")
const BackgroundColor_Normal_02 = Color("#080808")

const BackgroundColor_Brightened = Color("#030016")
const BackgroundColor_Brightened_02 = Color("#110024")


const SHADER_SPEED__BRIGHTENED = 1.0
const SHADER_FREQUENCY__BRIGHTENED = 10.0
const SHADER_AMPLITUDE__BRIGHTENED = 0.2

const SHADER_SPEED__NORMAL = 0.25
const SHADER_FREQUENCY__NORMAL = 10.0
const SHADER_AMPLITUDE__NORMAL = 0.2

#

var small__total_star_count : int
var small__normal_vis_star_count : int

var _color_rect_modulate_tweener : SceneTreeTween
var _color_rect_shader_tweener : SceneTreeTween

#

export(float) var background_tween_duration : float = 5.0

#

var background_color_rect_shader : ShaderMaterial

#

onready var small_star_grid_background = $StarGridBackground
onready var background_color_rect = $ColorRect

#

func _ready():
	small__total_star_count = small_star_grid_background.star_count__at_start
	small__normal_vis_star_count = small_star_grid_background.visible_star_count
	
	##
	
	_init_color_rect_shader()

##

func request_show_brightened_star_background__star_collectible_collected():
	#print("all collected")
	small_star_grid_background.visible_star_count = small__total_star_count
	#_tween_color_rect__into_color(BackgroundColor_Brightened)
	_tween_color_rect_shader__into_colors(BackgroundColor_Brightened, BackgroundColor_Brightened_02)
	_tween_method__set_shader_properties(SHADER_SPEED__BRIGHTENED, SHADER_FREQUENCY__BRIGHTENED,SHADER_AMPLITUDE__BRIGHTENED)

func request_unshow_brightened_star_background__star_collectible_uncollected():
	#print("all not collected")
	small_star_grid_background.visible_star_count = small__normal_vis_star_count
	#_tween_color_rect__into_color(BackgroundColor_Normal)
	_tween_color_rect_shader__into_colors(BackgroundColor_Normal, BackgroundColor_Normal_02)
	_tween_method__set_shader_properties(SHADER_SPEED__NORMAL, SHADER_FREQUENCY__NORMAL, SHADER_AMPLITUDE__NORMAL)

#

func _tween_color_rect__into_color(arg_color):
	_color_rect_modulate_tweener = create_tween()
	_color_rect_modulate_tweener.tween_property(background_color_rect, "color", arg_color, background_tween_duration)
	



##

func _init_color_rect_shader():
	var material_sh = ShaderMaterial.new()
	material_sh.shader = Shader_RippleBackground
	
	background_color_rect.material = material_sh
	background_color_rect_shader = material_sh
	
	set_color_rect_shader_colors(BackgroundColor_Normal, BackgroundColor_Normal_02)
	set_shader_properties(SHADER_SPEED__NORMAL, SHADER_FREQUENCY__NORMAL, SHADER_AMPLITUDE__NORMAL)



func _tween_color_rect_shader__into_colors(arg_color_01, arg_color_02):
	var plane_01 = background_color_rect_shader.get_shader_param("color1")
	var plane_02 = background_color_rect_shader.get_shader_param("color2")
	
	_color_rect_shader_tweener = create_tween()
	_color_rect_shader_tweener.set_parallel(true)
	_color_rect_shader_tweener.tween_method(self, "_tween_method__set_color_rect_shader_color_1", _convert_plane_to_color(plane_01), (arg_color_01), background_tween_duration)
	_color_rect_shader_tweener.tween_method(self, "_tween_method__set_color_rect_shader_color_2", _convert_plane_to_color(plane_02), (arg_color_02), background_tween_duration)

func _convert_color_to_plane(arg_color : Color) -> Plane:
	var plane = Plane(arg_color.r, arg_color.g, arg_color.b, arg_color.a)
	
	return plane

func _convert_plane_to_color(arg_plane : Plane) -> Color:
	var color = Color(arg_plane.x, arg_plane.y, arg_plane.z, arg_plane.d)
	
	return color



func _tween_method__set_color_rect_shader_color_1(arg_color):
	background_color_rect_shader.set_shader_param("color1", _convert_color_to_plane(arg_color))

func _tween_method__set_color_rect_shader_color_2(arg_color):
	background_color_rect_shader.set_shader_param("color2", _convert_color_to_plane(arg_color))
	


func set_color_rect_shader_colors(arg_color_01, arg_color_02):
	background_color_rect_shader.set_shader_param("color1", _convert_color_to_plane(arg_color_01))
	background_color_rect_shader.set_shader_param("color2", _convert_color_to_plane(arg_color_02))
	


#

func _tween_shader_property__speed(arg_speed):
	var orig_speed = background_color_rect_shader.get_shader_param("speed")
	
	var tweener = create_tween()
	tweener.tween_method(self, "_tween_method__set_shader_speed", orig_speed, arg_speed, background_tween_duration)

func _tween_method__set_shader_speed(arg_speed):
	background_color_rect_shader.set_shader_param("speed", arg_speed)

#
func _tween_shader_property__frequency(arg_frequency):
	var orig_frequency = background_color_rect_shader.get_shader_param("frequency")
	
	var tweener = create_tween()
	tweener.tween_method(self, "_tween_method__set_shader_frequency", orig_frequency, arg_frequency, background_tween_duration)

func _tween_method__set_shader_frequency(arg_frequency):
	background_color_rect_shader.set_shader_param("frequency", arg_frequency)

#
func _tween_shader_property__amplitude(arg_amplitude):
	var orig_amplitude = background_color_rect_shader.get_shader_param("amplitude")
	
	var tweener = create_tween()
	tweener.tween_method(self, "_tween_method__set_shader_amplitude", orig_amplitude, arg_amplitude, background_tween_duration)

func _tween_method__set_shader_amplitude(arg_amplitude):
	background_color_rect_shader.set_shader_param("amplitude", arg_amplitude)



func _tween_method__set_shader_properties(arg_speed : float, arg_frequency : float, arg_amplitude : float):
	_tween_method__set_shader_speed(arg_speed)
	_tween_method__set_shader_frequency(arg_frequency)
	_tween_method__set_shader_amplitude(arg_amplitude)

func set_shader_properties(arg_speed : float, arg_frequency : float, arg_amplitude : float):
	background_color_rect_shader.set_shader_param("speed", arg_speed)
	background_color_rect_shader.set_shader_param("frequency", arg_frequency)
	background_color_rect_shader.set_shader_param("amplitude", arg_amplitude)
	


