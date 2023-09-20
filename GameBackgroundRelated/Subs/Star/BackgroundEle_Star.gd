extends Sprite

const SmallStarPic_0000 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0000.png")
const SmallStarPic_0001 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0001.png")
const SmallStarPic_0002 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0002.png")
const SmallStarPic_0003 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0003.png")
const SmallStarPic_0004 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0004.png")
const SmallStarPic_0005 = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/Particles/Assets/LevelUnlock_BeforeBurst_Stream/LevelUnlock_BeforeBurst_Stream_0005.png")

const all_star_pics = [
	SmallStarPic_0000,
	SmallStarPic_0001,
	SmallStarPic_0002,
	SmallStarPic_0003,
	SmallStarPic_0004,
	SmallStarPic_0005,
	
]

##

var _rng_to_use : RandomNumberGenerator

var _modulate_a__min : float
var _modulate_a__max : float

var _duration_of_mod_a_half_cycle : float

#

var _is_invis : bool = true

#

var _is_in_ready : bool

#

var _mod_a_tweener : SceneTreeTween

#

func _init():
	_rng_to_use = StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL)
	_randomize_star_properties()

func _randomize_star_properties():
	_modulate_a__max = _rng_to_use.randf_range(0.15, 0.3)
	_modulate_a__min = _modulate_a__max - _rng_to_use.randf_range(0.1, 0.05)
	
	_duration_of_mod_a_half_cycle = _rng_to_use.randf_range(5.0, 15.0)

#

func _ready():
	_is_in_ready = true
	_randomize_sprite()
	
	if _is_invis:
		modulate.a = 0
	else:
		modulate.a = _modulate_a__min
		_start_mod_a_tweener__cycle()
	
	_is_in_ready = false

func _randomize_sprite():
	texture = StoreOfRNG.randomly_select_one_element(all_star_pics, _rng_to_use)
	

func _start_mod_a_tweener__cycle():
	_end_mod_a_tweener()
	
	_mod_a_tweener = create_tween()
	
	_mod_a_tweener.set_loops()
	_mod_a_tweener.set_parallel(false)
	_mod_a_tweener.tween_property(self, "modulate:a", _modulate_a__max, _duration_of_mod_a_half_cycle)
	_mod_a_tweener.tween_property(self, "modulate:a", _modulate_a__min, _duration_of_mod_a_half_cycle)

func _start_mod_a_tweener__hide():
	_end_mod_a_tweener()
	
	_mod_a_tweener = create_tween()
	_mod_a_tweener.tween_property(self, "modulate:a", 0.0, 2.0)

func _end_mod_a_tweener():
	if _mod_a_tweener != null:
		_mod_a_tweener.kill()
		_mod_a_tweener = null

#

# no need to call in ready
func set_is_invis(arg_val, arg_use_tweeners : bool):
	var old_val = _is_invis
	_is_invis = arg_val
	
	if old_val != arg_val or _is_in_ready:
		if is_inside_tree():
			
			if _is_invis:
				if arg_use_tweeners:
					_start_mod_a_tweener__hide()
				else:
					modulate.a = 0
			else:
				if arg_use_tweeners:
					_start_mod_a_tweener__cycle()
				else:
					modulate.a = _modulate_a__min
					_start_mod_a_tweener__cycle()

#


