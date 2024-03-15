extends MarginContainer


enum CircParticleType {
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

const MODULATES_FOR_CIRC_PARTICLE__NONE = []
const MODULATES_FOR_CIRC_PARTICLE__NORMAL = [Color("#D6CBA8")]
const MODULATES_FOR_CIRC_PARTICLE__CHALLENGE = [Color("#DA6262")]
const MODULATES_FOR_CIRC_PARTICLE__BRANCHING_NORMAL = [Color("#A34DFD")]
const MODULATES_FOR_CIRC_PARTICLE__BRANCHING_CHALLENGE = [Color("#A34DFD"), Color("#DA6262")]

const MODULATES_FOR_CIRC_PARTICLE__SPEC_CHALLENGE = [Color("#DA6262"), Color("#F34949")]
const MODULATES_FOR_CIRC_PARTICLE__MAGNUM_OPUS = [Color("#DA6262"), Color("#FCD140")]

const MODULATES_FOR_CIRC_PARTICLE__LVL_01_05 = [Color("#8917FD")]
const MODULATES_FOR_CIRC_PARTICLE__STAGE_05 = [Color("#3017FD")]
const MODULATES_FOR_CIRC_PARTICLE__CONSTELLATION = [Color("#FCD140"), Color("#FCD140"), Color("#FCD140"), Color("#96E8E7")]



var modulates_for_circ_particle : Array
var circ_particle_frequency_min : float #trigger per sec
var circ_particle_frequency_max : float #trigger per sec
var circ_particle_count_per_pulse_min : int
var circ_particle_count_per_pulse_max : int

var circ_particle_radius_starting : float
var circ_particle_radius_middle : float
var circ_particle_radius_ending : float
var circ_particle_radius_rand_variation_magnitude : float = 1.4

var circ_particle_lifetime_min : float
var circ_particle_lifetime_max : float
var circ_particle_lifetime_ratio_trigger_to_mid_phase : float

var circ_particle_modulate_rand_variation_magnitude : float = 1.2

##

onready var circle_float_draw_node = $CircleFloatDrawNode

#


#

# can be null
func set_level_details(arg_lvl_details):
	_attempt_emit_circ_particles_based_on_lvl_det(arg_lvl_details)

func _attempt_emit_circ_particles_based_on_lvl_det(arg_lvl_details):
	if arg_lvl_details != null:
		_config_settings_based_on_circ_particle_type(arg_lvl_details.circ_particle_type_id_for_level_layout_main_mid_panel)
	else:
		_config_settings_based_on_circ_particle_type(CircParticleType.NONE)
		
	


func _config_settings_based_on_circ_particle_type(arg_particle_type):
	match arg_particle_type:
		CircParticleType.NONE:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__NONE
			
		CircParticleType.NORMAL:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__NORMAL
			
		CircParticleType.CHALLENGE:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__CHALLENGE
			
		CircParticleType.BRANCHING_NORMAL:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__BRANCHING_NORMAL
			
		CircParticleType.BRANCHING_CHALLENGE:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__BRANCHING_CHALLENGE
			
		CircParticleType.SPEC_CHALLENGE:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__SPEC_CHALLENGE
			
		CircParticleType.MAGNUM_OPUS:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__MAGNUM_OPUS
			
		CircParticleType.LVL_01_05:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__LVL_01_05
			
		CircParticleType.STAGE_05:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__STAGE_05
			
		CircParticleType.CONSTELLATION:
			modulates_for_circ_particle = MODULATES_FOR_CIRC_PARTICLE__CONSTELLATION
			
		
		
	


