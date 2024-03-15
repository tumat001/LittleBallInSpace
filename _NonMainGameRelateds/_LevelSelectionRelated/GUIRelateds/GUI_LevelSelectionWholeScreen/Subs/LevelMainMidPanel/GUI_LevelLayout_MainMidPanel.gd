extends MarginContainer


enum MainMidPanelColorTemplateType {
	NONE = -1,
	
	NORMAL = 0,
	CHALLENGE = 1,
	BRANCHING_NORMAL = 2,
	BRANCHING_CHALLENGE = 3,
	
	SPEC_CHALLENGE = 4,
	MAGNUM_OPUS = 5,
	LVL_01_05 = 6,
	STAGE_05 = 7,
	CONSTELLATION = 8,
}

const MODULATES_FOR_RECT_PARTICLE__NONE = []
const MODULATES_FOR_RECT_PARTICLE__NORMAL = [Color("#D6CBA8")]
const MODULATES_FOR_RECT_PARTICLE__CHALLENGE = [Color("#DA6262")]
const MODULATES_FOR_RECT_PARTICLE__BRANCHING_NORMAL = [Color("#A34DFD")]
const MODULATES_FOR_RECT_PARTICLE__BRANCHING_CHALLENGE = [Color("#A34DFD"), Color("#DA6262")]

const MODULATES_FOR_RECT_PARTICLE__SPEC_CHALLENGE = [Color("#DA6262"), Color("#F34949")]
const MODULATES_FOR_RECT_PARTICLE__MAGNUM_OPUS = [Color("#DA6262"), Color("#FCD140")]

const MODULATES_FOR_RECT_PARTICLE__LVL_01_05 = [Color("#8917FD")]
const MODULATES_FOR_RECT_PARTICLE__STAGE_05 = [Color("#3017FD")]
const MODULATES_FOR_RECT_PARTICLE__CONSTELLATION = [Color("#FCD140"), Color("#FCD140"), Color("#FCD140"), Color("#96E8E7")]


var is_rect_particle_show_enabled : bool

var modulates_for_rect_particle : Array
var rect_particle_modulate_rand_variation_magnitude : float  #1 + x, 1 - x

var rect_particle_mod_a_starting : float
var rect_particle_mod_a_middle : float
var rect_particle_mod_a_ending : float
var rect_particle_mod_a_rand_variration_magnitude : float  # 1+, 1-

var rect_particle_frequency_min : float #trigger per sec
var rect_particle_frequency_max : float #trigger per sec
var rect_particle_count_per_pulse_min : int
var rect_particle_count_per_pulse_max : int

var rect_particle_xy_starting : float
var rect_particle_xy_middle : float
var rect_particle_xy_ending : float
var rect_particle_xy_rand_variation_magnitude : float   #1 + x, 1 - x

var rect_particle_lifetime_min : float
var rect_particle_lifetime_max : float
var rect_particle_lifetime_ratio_trigger : float

var rect_particle_float_dist_min : float
var rect_particle_float_dist_max : float

##

var _delta_before_next_rect_particle : float

#

var non_essential_rng : RandomNumberGenerator

#

onready var rect_float_draw_node = $RectFloatDrawNode

onready var background_panel = $BackgroundPanel

onready var top_star_constell_line_margin_container = $BackgroundPanel/Top_StarConstellLine

#

func _ready() -> void:
	non_essential_rng = SingletonsAndConsts.non_essential_rng

# can be null
func set_level_details(arg_lvl_details):
	_attempt_config_rect_particles_based_on_lvl_det(arg_lvl_details)
	
	_delta_before_next_rect_particle = rect_particle_lifetime_min / 2

func _attempt_config_rect_particles_based_on_lvl_det(arg_lvl_details):
	if arg_lvl_details != null:
		_config_settings_based_on_rect_particle_type(arg_lvl_details.rect_particle_type_id_for_level_layout_main_mid_panel)
	else:
		_config_settings_based_on_rect_particle_type(MainMidPanelColorTemplateType.NONE)
		
	


func _config_settings_based_on_rect_particle_type(arg_particle_type):
	is_rect_particle_show_enabled = arg_particle_type != MainMidPanelColorTemplateType.NONE
	
	#
	
	match arg_particle_type:
		MainMidPanelColorTemplateType.NONE:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__NONE
			
		MainMidPanelColorTemplateType.NORMAL:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__NORMAL
			rect_particle_modulate_rand_variation_magnitude = 0.2
			
			rect_particle_mod_a_starting = 0.3
			rect_particle_mod_a_middle = 0.7
			rect_particle_mod_a_ending = 0.0
			rect_particle_mod_a_rand_variration_magnitude = 0.1
			
			rect_particle_frequency_min = 0.75
			rect_particle_frequency_max = 1.5
			rect_particle_count_per_pulse_min = 0
			rect_particle_count_per_pulse_min = 2
			
			rect_particle_xy_starting = 1.0
			rect_particle_xy_middle = 2.5
			rect_particle_xy_ending = 0.0
			rect_particle_xy_rand_variation_magnitude = 0.2
			
			rect_particle_lifetime_min = 2.0
			rect_particle_lifetime_max = 4.0
			rect_particle_lifetime_ratio_trigger = 0.5
			
			rect_particle_float_dist_min = 30.0
			rect_particle_float_dist_max = 50.0
			
		MainMidPanelColorTemplateType.CHALLENGE:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__CHALLENGE
			
		MainMidPanelColorTemplateType.BRANCHING_NORMAL:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__BRANCHING_NORMAL
			
		MainMidPanelColorTemplateType.BRANCHING_CHALLENGE:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__BRANCHING_CHALLENGE
			
		MainMidPanelColorTemplateType.SPEC_CHALLENGE:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__SPEC_CHALLENGE
			
		MainMidPanelColorTemplateType.MAGNUM_OPUS:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__MAGNUM_OPUS
			
		MainMidPanelColorTemplateType.LVL_01_05:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__LVL_01_05
			
		MainMidPanelColorTemplateType.STAGE_05:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__STAGE_05
			
		MainMidPanelColorTemplateType.CONSTELLATION:
			modulates_for_rect_particle = MODULATES_FOR_RECT_PARTICLE__CONSTELLATION
			
		
		
	

####

func play_rect_float_particles_based_on_states():
	var rand_count = non_essential_rng.randi_range(rect_particle_count_per_pulse_min, rect_particle_count_per_pulse_max)
	for i in rand_count:
		var rand_modulate = StoreOfRNG.randomly_select_one_element(modulates_for_rect_particle, non_essential_rng)
		var rand_mod_intensity = non_essential_rng.randf_range(1 - rect_particle_modulate_rand_variation_magnitude, 1 + rect_particle_modulate_rand_variation_magnitude)
		rand_modulate *= rand_mod_intensity
		var rand_mod_a = non_essential_rng.randf_range(1 + rect_particle_mod_a_rand_variration_magnitude, 1 - rect_particle_mod_a_rand_variration_magnitude)
		rand_modulate.a = rand_mod_a
		
		var rand_xy_magnitude = non_essential_rng.randf_range(1 + rect_particle_xy_rand_variation_magnitude, 1 - rect_particle_xy_rand_variation_magnitude)
		var rand_xy_starging = rect_particle_xy_starting * rand_xy_magnitude
		var rand_xy_mid = rect_particle_xy_middle * rand_xy_magnitude
		var rand_xy_end = rect_particle_xy_ending * rand_xy_magnitude
		
		var rand_lifetime = non_essential_rng.randf_range(rect_particle_lifetime_min, rect_particle_lifetime_max)
		
		var rand_float_dist = non_essential_rng.randf_range(rect_particle_float_dist_min, rect_particle_float_dist_max)
		var rand_starting_x = _generate_rand_x_for_rect_float_particle()
		
		var starting_y = _get_starting_y_level_for_rect_float_particle()
		var starting_pos = Vector2(rand_starting_x, starting_y)
		
		#todoimp continue this
		_construct_rect_draw_param_and_tweener_for_float_particle()


func _generate_rand_x_for_rect_float_particle() -> float:
	var starting_x = background_panel.rect_position.x
	var ending_x = starting_x + background_panel.rect_size.x
	
	return non_essential_rng.randf_range(starting_x, ending_x)

func _get_starting_y_level_for_rect_float_particle() -> float:
	return background_panel.rect_position.y + _get_background_panel_top_line_margin()

func _get_background_panel_top_line_margin() -> float:
	return top_star_constell_line_margin_container.POS_MARGIN_AMOUNT

func _construct_rect_draw_param_and_tweener_for_float_particle(arg_modulate : Color,
		arg_mod_a_start : float, arg_mod_a_mid : float, arg_mod_a_end : float,
		arg_xy_start : float, arg_xy_mid : float, arg_xy_end : float,
		arg_lifetime : float, arg_lifetime_ratio_of_mid_to_end : float,
		arg_center_pos_initial : Vector2, arg_center_pos_final : Vector2):
	
	arg_modulate.a = arg_mod_a_start
	
	var draw_param = rect_float_draw_node.DrawParams.new()
	draw_param.fill_color = arg_modulate
	draw_param.outline_color = arg_modulate
	draw_param.outline_width = 0
	
	draw_param.lifetime_to_start_transparency = -1
	draw_param.angle_rad = 0
	draw_param.lifetime_of_draw = arg_lifetime + 0.3
	draw_param.has_lifetime = true
	draw_param.pivot_point = Vector2(0, 0)
	
	var size = Vector2(arg_xy_start, arg_xy_start)
	var initial_rect = Rect2(arg_center_pos_initial - (size/2), size)
	draw_param.initial_rect = initial_rect
	
	rect_float_draw_node.add_draw_param(draw_param)
	
	########
	
	var lifetime_to_mid = arg_lifetime * arg_lifetime_ratio_of_mid_to_end
	var lifetime_to_end = arg_lifetime - lifetime_to_mid
	
	var tweener = create_tween()
	tweener.set_parallel(true)
	tweener.tween_property(draw_param, "current_rect:position", arg_center_pos_final, arg_lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tweener.tween_property(draw_param, "current_rect:size", Vector2(arg_xy_mid, arg_xy_mid), lifetime_to_mid)
	tweener.tween_property(draw_param, "fill_color:a", arg_mod_a_mid, lifetime_to_mid)
	tweener.set_parallel(false)
	
	tweener.tween_interval(lifetime_to_mid)
	tweener.set_parallel(true)
	tweener.tween_property(draw_param, "current_rect:size", Vector2(arg_xy_end, arg_xy_end), lifetime_to_end)
	tweener.tween_property(draw_param, "fill_color:a", arg_mod_a_end, lifetime_to_end)
	


