extends ParallaxBackground

#const Shader_RippleBackground = preload("res://MiscRelated/ShadersRelated/Shader_RippleGradient.tres")
#const Shader_EarthboundLikeBackground = preload("res://MiscRelated/ShadersRelated/Shader_EarthboundLikeBackground.tres")
#const Shader_CircularNoiseBackground = preload("res://MiscRelated/ShadersRelated/Shader_CircularNoiseBackground.tres")

#

enum BackgroundTypeIds {
	STANDARD = 0,
	
	LEVEL__SPECIAL_01 = 1,
	
	LAYOUT__CHALLENGE_NORMAL = 2,
	#LAYOUT__CHALLENGE_PRELUDE = 3,
	#LAYOUT__CHALLENGE_COMPLETED = 4,
}
var _current_background_type : int = -1 #= BackgroundTypeIds.STANDARD

#

enum ShaderTypeId {
	RIPPLE = 0,
	
	#EARTHBOUND_LIKE = 1,
	
	CIRCULAR_NOISE_01 = 10,
	
	#CIRCULAR_NOISE_02 = 11,  #for level challenge
}
#var _current_shader_type_id : int = -1
var _shader_type_id_to_shader_material_map : Dictionary = {}

#

var _is_star_collected : bool

#

const BackgroundColor_Normal = Color("#000000")
const BackgroundColor_Normal_02 = Color("#080808")

const BackgroundColor_Brightened = Color("#030016")
const BackgroundColor_Brightened_02 = Color("#110024")

#

const STYPE_STANDARD__SHADER_SPEED__BRIGHTENED = 1.0
const STYPE_STANDARD__SHADER_FREQUENCY__BRIGHTENED = 10.0
const STYPE_STANDARD__SHADER_AMPLITUDE__BRIGHTENED = 0.2

const STYPE_STANDARD__SHADER_SPEED__NORMAL = 0.25
const STYPE_STANDARD__SHADER_FREQUENCY__NORMAL = 10.0
const STYPE_STANDARD__SHADER_AMPLITUDE__NORMAL = 0.2


const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIUS__NORMAL = 0.75
const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_THICKNESS__NORMAL = 0.6
const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_COLOR__NORMAL = Color("#6D0103")
const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_BRIGHTNESS__NORMAL = 2.0
const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ANGULAR_SPEED__NORMAL = -0.2
const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIAL_SPEED__NORMAL = 0.1
const STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ALPHA__NORMAL = 0.2


const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIUS__NORMAL = 0.65
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_THICKNESS__NORMAL = 1.2
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_COLOR__NORMAL = Color("#FFFFFF")
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_BRIGHTNESS__NORMAL = 1.5
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ANGULAR_SPEED__NORMAL = -0.02
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIAL_SPEED__NORMAL = 0.02
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ALPHA__NORMAL = 0.05

const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIUS__BRIGHTENED = 0.6
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_THICKNESS__BRIGHTENED = 1.0
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_COLOR__BRIGHTENED = Color("#9533FF")
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_BRIGHTNESS__BRIGHTENED = 1.75
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ANGULAR_SPEED__BRIGHTENED = -0.07
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIAL_SPEED__BRIGHTENED = 0.07
const STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ALPHA__BRIGHTENED = 0.12


const SVARNAME_CIRCULAR__RADIUS = "radius"
const SVARNAME_CIRCULAR__THICKNESS = "thickness"
const SVARNAME_CIRCULAR__COLOR = "color"
const SVARNAME_CIRCULAR__BRIGHTNESS = "brightness"
const SVARNAME_CIRCULAR__ANGULAR_SPEED = "angular_speed"
const SVARNAME_CIRCULAR__RADIAL_SPEED = "radial_speed"
const SVARNAME_CIRCULAR__ALPHA = "alpha"



#

var small__total_star_count : int
var small__normal_vis_star_count : int

var _color_rect_modulate_tweener : SceneTreeTween
var _shader_tweener : SceneTreeTween

#

export(float) var background_shader_main_colors_tween_duration : float = 5.0
export(float) var background_shader_cycle_switch_tween_duration : float = 3.0  #when using tween/transition, and replacing bg with another bg

#

var prev_cycle_background_shader_control_holder
var current_active_background_shader_holder_control 
var background_shader_mat : ShaderMaterial

#

var _noise_texture : NoiseTexture

#

onready var small_star_grid_background = $StarGridBackground

onready var shader_holder_container = $ShaderHolderContainer

#

func _init():
	_generate_noise_texture()

func _generate_noise_texture():
	var simplex_noise = OpenSimplexNoise.new()
	simplex_noise.octaves = 2
	simplex_noise.period = 16.0
	
	_noise_texture = NoiseTexture.new()
	_noise_texture.noise = simplex_noise
	_noise_texture.seamless = true
	_noise_texture.width = 220
	_noise_texture.height = 220
	

#

func config_self_based_on_background_params_and_update(arg_background_type : int, arg_is_star_collected : int, arg_use_tween_and_transition : bool = true):
	set_current_background_type(arg_background_type, arg_use_tween_and_transition)
	_set_is_star_collected(arg_is_star_collected)




#

func _create_background_color_rect_shader__and_set_as_active(arg_deferred_add_child : bool):
	current_active_background_shader_holder_control = _create_background_color_rect_shader(arg_deferred_add_child)

func _create_background_color_rect_shader(arg_deferred_add_child : bool):
	var control : Control
	
	match _current_background_type:
		BackgroundTypeIds.LAYOUT__CHALLENGE_NORMAL, BackgroundTypeIds.LEVEL__SPECIAL_01:
			var texture_rect = TextureRect.new()
			
			texture_rect.rect_size = SingletonsAndConsts.current_master.screen_size
			texture_rect.margin_right = texture_rect.rect_size.x
			texture_rect.margin_bottom = texture_rect.rect_size.y
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			#texture_rect.texture = preload("res://GameBackgroundRelated/Assets/GameBackground_NoiseTexture_FiveSideDice_9x9.png")
			texture_rect.texture = _noise_texture
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_SCALE_ON_EXPAND
			
			#
			control = texture_rect
			
			
		_:
			var color_rect = ColorRect.new()
			
			color_rect.rect_size = SingletonsAndConsts.current_master.screen_size
			color_rect.margin_right = color_rect.rect_size.x
			color_rect.margin_bottom = color_rect.rect_size.y
			color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			color_rect.color = Color(0, 0, 0, 1)
			
			#
			control = color_rect
	
	#
	if arg_deferred_add_child:
		shader_holder_container.call_deferred("add_child", control)
	else:
		shader_holder_container.add_child(control)
	
	
	return control

#

func _ready():
	small__total_star_count = small_star_grid_background.star_count__at_start
	small__normal_vis_star_count = small_star_grid_background.visible_star_count
	
	##
	
#	_create_background_color_rect_shader__and_set_as_active(false)
#	_create_shader_mat_based_on_curr_background_type__and_give_to_curr_color_rect()

##

func _create_shader_mat_based_on_curr_background_type__and_give_to_curr_color_rect(arg_insta_set_properties : bool):
	background_shader_mat = _create_shader_mat_based_on_curr_background_type(arg_insta_set_properties)
	current_active_background_shader_holder_control.material = background_shader_mat
	

func _create_shader_mat_based_on_curr_background_type(arg_insta_set_properties : bool):
	var material_sh : ShaderMaterial
	var details : Array
	
	match _current_background_type:
		BackgroundTypeIds.STANDARD:
			details = _get_or_create_shader_material_with_type_id(ShaderTypeId.RIPPLE)
			material_sh = details[0]
			
			if arg_insta_set_properties or details[1]:
				_insta_set_properties__TYPE_STANDARD(material_sh)
			
		BackgroundTypeIds.LAYOUT__CHALLENGE_NORMAL:
			details = _get_or_create_shader_material_with_type_id(ShaderTypeId.CIRCULAR_NOISE_01)
			material_sh = details[0]
			
			if arg_insta_set_properties or details[1]:
				#arg_radius, arg_thickness, arg_color, arg_brighness, arg_angular_speed, arg_radial_speed, arg_alpha
				_insta_set_properties__TYPE_LAYOUT_CHALL_NORMAL(material_sh)
			
		BackgroundTypeIds.LEVEL__SPECIAL_01:
			details = _get_or_create_shader_material_with_type_id(ShaderTypeId.CIRCULAR_NOISE_01)
			material_sh = details[0]
			
			if arg_insta_set_properties or details[1]:
				#arg_radius, arg_thickness, arg_color, arg_brighness, arg_angular_speed, arg_radial_speed, arg_alpha
				_insta_set_properties__TYPE_LEVEL_SPECIAL_01(material_sh)
			
			
#		BackgroundTypeIds.LEVEL__CHALLENGE:
#			details = _get_or_create_shader_material_with_type_id(ShaderTypeId.EARTHBOUND_LIKE)
#			material_sh = details[0]
#
#			if arg_insta_set_properties or details[1]:
#				#_insta
	
	return material_sh

func _insta_set_properties__TYPE_STANDARD(material_sh):
	TYPE_RIPPLE__set_color_rect_shader_colors(material_sh, BackgroundColor_Normal, BackgroundColor_Normal_02)
	TYPE_RIPPLE__set_shader_properties(material_sh, STYPE_STANDARD__SHADER_SPEED__NORMAL, STYPE_STANDARD__SHADER_FREQUENCY__NORMAL, STYPE_STANDARD__SHADER_AMPLITUDE__NORMAL)

func _insta_set_properties__TYPE_LAYOUT_CHALL_NORMAL(material_sh):
	_TYPE_CIRCULAR_NOISE__set_shader_properties(material_sh, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIUS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_THICKNESS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_COLOR__NORMAL,
			STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_BRIGHTNESS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ANGULAR_SPEED__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIAL_SPEED__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ALPHA__NORMAL)

func _insta_set_properties__TYPE_LEVEL_SPECIAL_01(material_sh):
	_TYPE_CIRCULAR_NOISE__set_shader_properties(material_sh, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIUS__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_THICKNESS__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_COLOR__NORMAL,
			STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_BRIGHTNESS__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ANGULAR_SPEED__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIAL_SPEED__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ALPHA__NORMAL)


#func _insta_set_properties__TYPE_EARTHBOUND(material_sh)


## shader bg type related

func set_current_background_type(arg_type, arg_use_tween_and_transition : bool):
	#var old_bg_type = _current_background_type
	_current_background_type = arg_type
	#if old_bg_type != _current_background_type:
	_update_current_background_based_on_curr_type(arg_use_tween_and_transition)
	
	

func _update_current_background_based_on_curr_type(arg_use_tween_and_transition):
	_attempt_queue_free_prev_cycle_background_shader_control_holder()
	prev_cycle_background_shader_control_holder = current_active_background_shader_holder_control
	_create_background_color_rect_shader__and_set_as_active(true)
	
	_create_shader_mat_based_on_curr_background_type__and_give_to_curr_color_rect(!arg_use_tween_and_transition)
	
	if arg_use_tween_and_transition:
		_set_control_as_zero_mod__then_tween_until_full_mod(current_active_background_shader_holder_control)
		if is_instance_valid(prev_cycle_background_shader_control_holder):
			_tween_control_until_zero_mod(prev_cycle_background_shader_control_holder)
		
	else:
		if is_instance_valid(prev_cycle_background_shader_control_holder) and !prev_cycle_background_shader_control_holder.is_queued_for_deletion():
			prev_cycle_background_shader_control_holder.call_deferred("queue_free")
		
	
	_update_shader_based_on_is_star_collected()

func _attempt_queue_free_prev_cycle_background_shader_control_holder():
	if is_instance_valid(prev_cycle_background_shader_control_holder) and !prev_cycle_background_shader_control_holder.is_queued_for_deletion():
		prev_cycle_background_shader_control_holder.queue_free()
	
	prev_cycle_background_shader_control_holder = null


func _set_control_as_zero_mod__then_tween_until_full_mod(arg_control : Control):
	arg_control.modulate.a = 0
	var tweener = create_tween()
	tweener.tween_property(arg_control, "modulate:a", 1.0, background_shader_cycle_switch_tween_duration)

func _tween_control_until_zero_mod(arg_control : Control):
	var tweener = create_tween()
	tweener.tween_property(arg_control, "modulate:a", 0.0, background_shader_cycle_switch_tween_duration)



### star related

func request_show_brightened_star_background__star_collectible_collected():
	_set_is_star_collected(true)

func request_unshow_brightened_star_background__star_collectible_uncollected():
	_set_is_star_collected(false)


func _set_is_star_collected(arg_val):
	var old_val = _is_star_collected
	_is_star_collected = arg_val
	
	if old_val != arg_val:
		_update_shader_based_on_is_star_collected()

func _update_shader_based_on_is_star_collected():
	if _is_star_collected:
		small_star_grid_background.visible_star_count = small__total_star_count
		
		
		if background_shader_mat == null:
			return
		match _current_background_type:
			BackgroundTypeIds.STANDARD:
				_TYPE_STANDARD__tween_color_rect_shader__into_colors(BackgroundColor_Brightened, BackgroundColor_Brightened_02)
				_TYPE_STANDARD__tween_method__set_shader_properties(STYPE_STANDARD__SHADER_SPEED__BRIGHTENED, STYPE_STANDARD__SHADER_FREQUENCY__BRIGHTENED,STYPE_STANDARD__SHADER_AMPLITUDE__BRIGHTENED)
				
			BackgroundTypeIds.LAYOUT__CHALLENGE_NORMAL:
				_TYPE_CIRCULAR_NOISE__tween_rect_shader(STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIUS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_THICKNESS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_COLOR__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_BRIGHTNESS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ANGULAR_SPEED__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIAL_SPEED__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ALPHA__NORMAL)
				
			BackgroundTypeIds.LEVEL__SPECIAL_01:
				_TYPE_CIRCULAR_NOISE__tween_rect_shader(STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIUS__BRIGHTENED, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_THICKNESS__BRIGHTENED, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_COLOR__BRIGHTENED, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_BRIGHTNESS__BRIGHTENED, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ANGULAR_SPEED__BRIGHTENED, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIAL_SPEED__BRIGHTENED, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ALPHA__BRIGHTENED)
		
	else:
		small_star_grid_background.visible_star_count = small__normal_vis_star_count
		
		
		if background_shader_mat == null:
			return
		match _current_background_type:
			BackgroundTypeIds.STANDARD:
				_TYPE_STANDARD__tween_color_rect_shader__into_colors(BackgroundColor_Normal, BackgroundColor_Normal_02)
				_TYPE_STANDARD__tween_method__set_shader_properties(STYPE_STANDARD__SHADER_SPEED__NORMAL, STYPE_STANDARD__SHADER_FREQUENCY__NORMAL, STYPE_STANDARD__SHADER_AMPLITUDE__NORMAL)
				
			BackgroundTypeIds.LAYOUT__CHALLENGE_NORMAL:
				_TYPE_CIRCULAR_NOISE__tween_rect_shader(STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIUS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_THICKNESS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_COLOR__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_BRIGHTNESS__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ANGULAR_SPEED__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_RADIAL_SPEED__NORMAL, STYPE_CIRCULAR_01__LAYOUT_CHALL_NORMAL__SHADER_ALPHA__NORMAL)
				
			BackgroundTypeIds.LEVEL__SPECIAL_01:
				_TYPE_CIRCULAR_NOISE__tween_rect_shader(STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIUS__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_THICKNESS__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_COLOR__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_BRIGHTNESS__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ANGULAR_SPEED__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_RADIAL_SPEED__NORMAL, STYPE_CIRCULAR_01__LEVEL_SPECIAL_01__SHADER_ALPHA__NORMAL)
		

#

# returns arr. [shader_mat, is_first_time]
func _get_or_create_shader_material_with_type_id(arg_id) -> Array:
	
	if _shader_type_id_to_shader_material_map.has(arg_id):
		return [_shader_type_id_to_shader_material_map[arg_id], false]
	
	var shader
	var shader_mat = ShaderMaterial.new()
	
	match arg_id:
		ShaderTypeId.RIPPLE:
			shader = load("res://MiscRelated/ShadersRelated/Shader_RippleGradient.tres")
			
		#ShaderTypeId.EARTHBOUND_LIKE:
		#	shader = load("res://MiscRelated/ShadersRelated/Shader_EarthboundLikeBackground.tres")
		#	
		ShaderTypeId.CIRCULAR_NOISE_01:
			shader = load("res://MiscRelated/ShadersRelated/Shader_CircularNoiseBackground.tres")
			shader_mat.shader = shader
			shader_mat.set_shader_param("noise", _noise_texture)
		
	
	shader_mat.shader = shader
	
	
	_shader_type_id_to_shader_material_map[arg_id] = shader_mat
	return [shader_mat, true]

#########
# TYPE: STANDARD

func _TYPE_STANDARD__tween_color_rect_shader__into_colors(arg_color_01, arg_color_02):
	var plane_01 = background_shader_mat.get_shader_param("color1")
	var plane_02 = background_shader_mat.get_shader_param("color2")
	
	_shader_tweener = create_tween()
	_shader_tweener.set_parallel(true)
	_shader_tweener.tween_method(self, "_TYPE_STANDARD__tween_method__set_color_rect_shader_color_1", _convert_plane_to_color(plane_01), (arg_color_01), background_shader_main_colors_tween_duration)
	_shader_tweener.tween_method(self, "_TYPE_STANDARD__tween_method__set_color_rect_shader_color_2", _convert_plane_to_color(plane_02), (arg_color_02), background_shader_main_colors_tween_duration)


func _TYPE_STANDARD__tween_method__set_color_rect_shader_color_1(arg_color):
	background_shader_mat.set_shader_param("color1", _convert_color_to_plane(arg_color))

func _TYPE_STANDARD__tween_method__set_color_rect_shader_color_2(arg_color):
	background_shader_mat.set_shader_param("color2", _convert_color_to_plane(arg_color))

func TYPE_RIPPLE__set_color_rect_shader_colors(material_sh, arg_color_01, arg_color_02):
	material_sh.set_shader_param("color1", _convert_color_to_plane(arg_color_01))
	material_sh.set_shader_param("color2", _convert_color_to_plane(arg_color_02))
	

#

func _TYPE_STANDARD__tween_method__set_shader_properties(arg_speed : float, arg_frequency : float, arg_amplitude : float):
	_TYPE_RIPPLE__tween_method__set_shader_speed(arg_speed)
	_TYPE_RIPPLE__tween_method__set_shader_frequency(arg_frequency)
	_TYPE_RIPPLE__tween_method__set_shader_amplitude(arg_amplitude)

func TYPE_RIPPLE__set_shader_properties(material_sh, arg_speed : float, arg_frequency : float, arg_amplitude : float):
	material_sh.set_shader_param("speed", arg_speed)
	material_sh.set_shader_param("frequency", arg_frequency)
	material_sh.set_shader_param("amplitude", arg_amplitude)
	

func _TYPE_RIPPLE__tween_method__set_shader_speed(arg_speed):
	background_shader_mat.set_shader_param("speed", arg_speed)

func _TYPE_RIPPLE__tween_method__set_shader_frequency(arg_frequency):
	background_shader_mat.set_shader_param("frequency", arg_frequency)

func _TYPE_RIPPLE__tween_method__set_shader_amplitude(arg_amplitude):
	background_shader_mat.set_shader_param("amplitude", arg_amplitude)


############
# TYPE: CIRCULAR NOISE

func _TYPE_CIRCULAR_NOISE__tween_rect_shader(arg_radius, arg_thickness, arg_color, arg_brighness, arg_angular_speed, arg_radial_speed, arg_alpha):
	var radius = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__RADIUS)
	var thickness = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__THICKNESS)
	var color_01 = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__COLOR)
	var brightness = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__BRIGHTNESS)
	var angular_speed = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__ANGULAR_SPEED)
	var radial_speed = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__RADIAL_SPEED)
	var alpha = background_shader_mat.get_shader_param(SVARNAME_CIRCULAR__ALPHA)
	
	var tweener = create_tween()
	tweener.set_parallel(true)
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", radius, arg_radius, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__RADIUS])
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", thickness, arg_thickness, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__THICKNESS])
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", color_01, arg_color, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__COLOR])
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", brightness, arg_brighness, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__BRIGHTNESS])
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", angular_speed, arg_angular_speed, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__ANGULAR_SPEED])
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", radial_speed, arg_radial_speed, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__RADIAL_SPEED])
	tweener.tween_method(self, "_TYPE_ANY__tweener_method__set_shader_param_x", alpha, arg_alpha, background_shader_cycle_switch_tween_duration, [SVARNAME_CIRCULAR__ALPHA])


func _TYPE_CIRCULAR_NOISE__set_shader_properties(material_sh, arg_radius, arg_thickness, arg_color, arg_brighness, arg_angular_speed, arg_radial_speed, arg_alpha):
	material_sh.set_shader_param(SVARNAME_CIRCULAR__RADIUS, arg_radius)
	material_sh.set_shader_param(SVARNAME_CIRCULAR__THICKNESS, arg_thickness)
	material_sh.set_shader_param(SVARNAME_CIRCULAR__COLOR, arg_color)
	material_sh.set_shader_param(SVARNAME_CIRCULAR__BRIGHTNESS, arg_brighness)
	material_sh.set_shader_param(SVARNAME_CIRCULAR__ANGULAR_SPEED, arg_angular_speed)
	material_sh.set_shader_param(SVARNAME_CIRCULAR__RADIAL_SPEED, arg_radial_speed)
	material_sh.set_shader_param(SVARNAME_CIRCULAR__ALPHA, arg_alpha)
	

############
# HELPERS

func _convert_color_to_plane(arg_color : Color) -> Plane:
	var plane = Plane(arg_color.r, arg_color.g, arg_color.b, arg_color.a)
	
	return plane

func _convert_plane_to_color(arg_plane : Plane) -> Color:
	var color = Color(arg_plane.x, arg_plane.y, arg_plane.z, arg_plane.d)
	
	return color


func _TYPE_ANY__shader_param_set_x(arg_shader_param_name : String, arg_val):
	background_shader_mat.set_shader_param(arg_shader_param_name, arg_val)

func _TYPE_ANY__tweener_method__set_shader_param_x(arg_val, arg_shader_param_name):
	background_shader_mat.set_shader_param(arg_shader_param_name, arg_val)

