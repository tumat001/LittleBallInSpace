extends Node


const LightTextureConstructor = preload("res://MiscRelated/Light2DRelated/LightTextureConstructor.gd")
const BaseTileSet = preload("res://ObjectsRelated/TilesRelated/BaseTileSet.gd")


#

const INSTANT_BREAK_GLASS_TILE__MASS = 12
const FRAGILE_BREAK_GLASS_TILE__MASS = 15
const BREAKABLE_GLASS_TILE__MASS = 30
const STRONG_BREAKABLE_GLASS_TILE__MASS = 40
const SPACESHIP_WALL_BREAKABLE_TILE__MASS = 60

# THESE are not custom defined. THESE are defined by tileset resource.
# if the res changes, so shall these
const BREAKABLE_GLASS_TILE_ID__ATLAS_01 = 2
const BREAKABLE_GLASS_TILE_ID__ATLAS_02 = 3
const BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01 = 4
const BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02 = 5

const INSTANT_BREAK_GLASS_TILE_ID = 16
const INSTANT_BREAK_GLASS_GLOWING_TILE_ID = 15

const FRAGILE_BREAK_GLASS_TILE_ID = 17
const FRAGILE_BREAK_GLASS_GLOWING_TILE_ID = 18

const STRONG_BREAK_GLASS_TILE_ID = 19
const STRONG_BREAK_GLASS_GLOWING_TILE_ID = 20

const SPACESHIP_WALL_BREAKABLE_TILE_ID = 21
const SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID = 22


#

const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01 = 6
const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02 = 7

const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01 = 8
const TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02 = 9

const TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED = 28
const TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__UNFILLED = 29


const SIMPLE_METAL_TILE_01__MASS = 60
const SIMPLE_METAL_TILE_02__MASS = 60
const SPACESHIP_WALL_TILE_01__MASS = 60
const SPACESHIP_WALL_TILE_02__MASS = 60
const DARK_METAL_TILE_01__MASS = 60
const SIMPLE_GLASS_TILE_ID__01__MASS = BREAKABLE_GLASS_TILE_ID__ATLAS_01
const SIMPLE_GLASS_TILE_ID__02__MASS = BREAKABLE_GLASS_TILE_ID__ATLAS_02
const HOSTILE_SHIP_METAL_TILE_01__MASS = 60
const HOSTILE_SHIP_METAL_FRAME_TILE_01__MASS = 60

#

const SIMPLE_METAL_TILE_ID__01 = 0
const SIMPLE_METAL_TILE_ID__02 = 1
const SIMPLE_METAL_TILE_ID__01__V2 = 24
const SIMPLE_GLASS_TILE_ID__01 = 2
const SIMPLE_GLASS_TILE_ID__02 = 3
const SPACESHIP_TILE_ID__01 = 10
const SPACESHIP_TILE_ID__02 = 11
const SPACESHIP_METAL_FRAME_TILE_ID = 12
const SPACESHIP_SPECIAL_GLASS_TILE_ID = 13

const DARK_METAL_TILE_ID = 14

const DARK_METAL_FRAME_TILE_ID = 23
const DARK_METAL_FRAME_02_TILE_ID = 30
#24 is above (SIMPLE_METAL_TILE_ID__01__V2)
const SIMPLE_METAL_FRAME_TILE_ID = 25

const HOSTILE_SHIP_METAL_TILE_ID__01 = 26
const HOSTILE_SHIP_METAL_FRAME_TILE__01 = 27

#

# structure: tile id -> tile auto coord -> segment size -> [[atlased images, top_left_pos], length]
var _atlased_imgs_of_tile_fragments_map : Dictionary = {}

# structure: tile id -> tile auto coord -> img
var _tile_id_to_auto_coord_to_img_map : Dictionary = {}

# structure: tile id -> region -> atlas img
var _tile_id_to_region_to_img_map : Dictionary = {}


####################

const ANY_AUTO_COORD = Vector2(-1, -1)
var _tile_id_to_auto_coord_to_sound_id_map__normal_and_loud : Dictionary
var _breakable_tile_id_to_auto_coord_to_sound_id_map : Dictionary


var _uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map : Dictionary

class LightDetails:
	var light_texture : GradientTexture2D
	var rotation : float = 0.0
	var offset : Vector2 = Vector2.ZERO setget ,get_offset
	
	func get_offset():
		return offset.rotated(rotation)

###########

onready var METAL_FRAGMENT_COLLISION_SOUND_LIST : Array = [
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_01,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_02,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_03,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_04,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_05,
	StoreOfAudio.AudioIds.SFX_TileFragments_Metal_06,
]
onready var GLASS_FRAGMENT_COLLISION_SOUND_LIST : Array = [
	StoreOfAudio.AudioIds.SFX_TileFragments_Glass_01,
	StoreOfAudio.AudioIds.SFX_TileFragments_Glass_02,
	StoreOfAudio.AudioIds.SFX_TileFragments_Glass_03,
	StoreOfAudio.AudioIds.SFX_TileFragments_Glass_04,
	StoreOfAudio.AudioIds.SFX_TileFragments_Glass_05,
	#StoreOfAudio.AudioIds.SFX_TileFragments_Glass_06,
	
]
var NONE__ANY_COLLISION_SOUND_LIST : Array = []

onready var _tile_id_to_fragment_collision_sound_list_map : Dictionary = {
	SIMPLE_METAL_TILE_ID__01 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	SIMPLE_METAL_TILE_ID__02 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	SIMPLE_METAL_TILE_ID__01__V2 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	
	SPACESHIP_TILE_ID__01 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	SPACESHIP_TILE_ID__02 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	
	DARK_METAL_TILE_ID : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	
	#
	
	BREAKABLE_GLASS_TILE_ID__ATLAS_01 : GLASS_FRAGMENT_COLLISION_SOUND_LIST,
	BREAKABLE_GLASS_TILE_ID__ATLAS_02 : GLASS_FRAGMENT_COLLISION_SOUND_LIST,
	INSTANT_BREAK_GLASS_TILE_ID : GLASS_FRAGMENT_COLLISION_SOUND_LIST,
	FRAGILE_BREAK_GLASS_TILE_ID : GLASS_FRAGMENT_COLLISION_SOUND_LIST,
	STRONG_BREAK_GLASS_TILE_ID : GLASS_FRAGMENT_COLLISION_SOUND_LIST,
	
	SPACESHIP_WALL_BREAKABLE_TILE_ID : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	
	HOSTILE_SHIP_METAL_TILE_ID__01 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	HOSTILE_SHIP_METAL_FRAME_TILE__01 : METAL_FRAGMENT_COLLISION_SOUND_LIST,
	
}



##

onready var BALL__METAL_TILE_COLLISION_SOUND_LIST : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_Metal_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_Metal_02,
	StoreOfAudio.AudioIds.SFX_BallCollision_Metal_03,
	
]
onready var BALL__TOGGLEABLE_TILE_COLLISION_SOUND_LIST : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_ToggleableTiles_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_ToggleableTiles_02,
	
]
onready var BALL__GLASS_TILE_COLLISION_SOUND_HIT : Array = [
	StoreOfAudio.AudioIds.SFX_BallCollision_Glass_01,
	StoreOfAudio.AudioIds.SFX_BallCollision_Glass_02,
	StoreOfAudio.AudioIds.SFX_BallCollision_Glass_03,
	
]

onready var _tile_id_to_ball_collision_sound_list_map : Dictionary = {
	SIMPLE_METAL_TILE_ID__01 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	SIMPLE_METAL_TILE_ID__02 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	SIMPLE_METAL_TILE_ID__01__V2 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
	SPACESHIP_TILE_ID__01 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	SPACESHIP_TILE_ID__02 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
	DARK_METAL_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
	#
	
	SPACESHIP_METAL_FRAME_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	SPACESHIP_SPECIAL_GLASS_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	
	DARK_METAL_FRAME_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	SIMPLE_METAL_FRAME_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
	#
	
	BREAKABLE_GLASS_TILE_ID__ATLAS_01 : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	BREAKABLE_GLASS_TILE_ID__ATLAS_02 : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01 : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02 : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	
	
	INSTANT_BREAK_GLASS_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	INSTANT_BREAK_GLASS_GLOWING_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	
	FRAGILE_BREAK_GLASS_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	FRAGILE_BREAK_GLASS_GLOWING_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	
	STRONG_BREAK_GLASS_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	STRONG_BREAK_GLASS_GLOWING_TILE_ID : BALL__GLASS_TILE_COLLISION_SOUND_HIT,
	
	#
	
	SPACESHIP_WALL_BREAKABLE_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
	#
	
	TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01 : BALL__TOGGLEABLE_TILE_COLLISION_SOUND_LIST,
	TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02 : BALL__TOGGLEABLE_TILE_COLLISION_SOUND_LIST,
	
	#
	
	HOSTILE_SHIP_METAL_TILE_ID__01 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	HOSTILE_SHIP_METAL_FRAME_TILE__01 : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
	TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED : BALL__TOGGLEABLE_TILE_COLLISION_SOUND_LIST,
	
	#
	
	DARK_METAL_FRAME_02_TILE_ID : BALL__METAL_TILE_COLLISION_SOUND_LIST,
	
}


#const DEFAULT_PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE = Color("#CCCCCC")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_METAL = Color("#282828")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_METAL = Color("#614F82")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__DARK_METAL = Color("#1A1A1A")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_SPECIAL_GLASS = Color("#CFCFCF")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_BREAKABLE = Color("#317BA7")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__INSTANT_BREAKABLE = Color("#D2FDFE")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__FRAGILE_BREAKABLE = Color("#AAFDFE")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__STRONG_BREAKABLE = Color("#317BA7")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_WALL_BREAKABLE = Color("#614F82")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__TOGGLEABLE_COLOR_CODED_BLOCKS = Color("#474747")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__HOSTILE_SHIP_METAL = Color("#1F1F1F")
const PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__TOGGLEABLE_HOSTILE_SHIP_BLOCKS = Color("#970204")


onready var _tile_id_to_player_hit_collision_rect_particle_modulate_map := {
	SIMPLE_METAL_TILE_ID__01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_METAL,
	SIMPLE_METAL_TILE_ID__02 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_METAL,
	SIMPLE_METAL_TILE_ID__01__V2 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_METAL,
	
	SPACESHIP_TILE_ID__01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_METAL,
	SPACESHIP_TILE_ID__02 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_METAL,
	
	DARK_METAL_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__DARK_METAL,
	
	#
	
	SPACESHIP_METAL_FRAME_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_METAL,
	SPACESHIP_SPECIAL_GLASS_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_METAL,
	
	DARK_METAL_FRAME_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__DARK_METAL,
	SIMPLE_METAL_FRAME_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_METAL,
	
	#
	
	BREAKABLE_GLASS_TILE_ID__ATLAS_01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_BREAKABLE,
	BREAKABLE_GLASS_TILE_ID__ATLAS_02 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_BREAKABLE,
	BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_BREAKABLE,
	BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SIMPLE_BREAKABLE,
	
	
	INSTANT_BREAK_GLASS_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__INSTANT_BREAKABLE,
	INSTANT_BREAK_GLASS_GLOWING_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__INSTANT_BREAKABLE,
	
	FRAGILE_BREAK_GLASS_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__FRAGILE_BREAKABLE,
	FRAGILE_BREAK_GLASS_GLOWING_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__FRAGILE_BREAKABLE,
	
	STRONG_BREAK_GLASS_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__STRONG_BREAKABLE,
	STRONG_BREAK_GLASS_GLOWING_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__STRONG_BREAKABLE,
	
	#
	
	SPACESHIP_WALL_BREAKABLE_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_WALL_BREAKABLE,
	SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__SPACESHIP_WALL_BREAKABLE,
	
	#
	
	TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__TOGGLEABLE_COLOR_CODED_BLOCKS,
	TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__TOGGLEABLE_COLOR_CODED_BLOCKS,
	
	#
	
	HOSTILE_SHIP_METAL_TILE_ID__01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__HOSTILE_SHIP_METAL,
	HOSTILE_SHIP_METAL_FRAME_TILE__01 : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__HOSTILE_SHIP_METAL,
	
	TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__TOGGLEABLE_HOSTILE_SHIP_BLOCKS,
	
	#
	
	DARK_METAL_FRAME_02_TILE_ID : PLAYER_HIT_COLLISION_RECT_PARTICLE_MODULATE__DARK_METAL,
	
}

onready var _precalced_tile_id_to_tileset_extr_modulate_to_player_hit_collision_rect_particle_modulate_map_map : Dictionary = {
	
}


#

func _ready():
	_initialize_all_tile_to_sound_id_map()
	_initialize_all_uncol_tile_to_light_tex_rect_size_and_color_gradient_map()
	#_initialize_tile_fragment_to_sound_list()

#

static func is_tile_id_fillable_or_unfillable(arg_id):
	match arg_id:
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01, TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02:
			return true
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01, TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02:
			return true
		TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED, TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__UNFILLED:
			return true
	
	return false


static func is_tile_id_filled(arg_id):
	match arg_id:
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01, TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02:
			return true
		TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED:
			return true
	
	return false

static func convert_unfilled_tile_id__to_filled(arg_id):
	match arg_id:
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01:
			return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02:
			return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02
		TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__UNFILLED:
			return TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED


static func convert_filled_tile_id__to_unfilled(arg_id):
	match arg_id:
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_01:
			return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_01
		TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__FILLED_02:
			return TOGGLEABLE_COLOR_CODED_BLOCKS_TILE_ID__UNFILLED_02
		TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__FILLED:
			return TOGGLEABLE_HOSTILE_SHIP_BLOCKS_TILE_ID__UNFILLED


####

static func is_tile_id_glowing(arg_id):
	match arg_id:
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01, BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
			return true
		INSTANT_BREAK_GLASS_GLOWING_TILE_ID:
			return true
		FRAGILE_BREAK_GLASS_GLOWING_TILE_ID:
			return true
		STRONG_BREAK_GLASS_GLOWING_TILE_ID:
			return true
		SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID:
			return true
	
	return false


static func convert_non_glowing_breakable_tile_id__to_glowing(arg_id):
	if arg_id == BREAKABLE_GLASS_TILE_ID__ATLAS_01:
		return BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01
	elif arg_id == BREAKABLE_GLASS_TILE_ID__ATLAS_02:
		return BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02
	elif arg_id == INSTANT_BREAK_GLASS_TILE_ID:
		return INSTANT_BREAK_GLASS_GLOWING_TILE_ID
	elif arg_id == FRAGILE_BREAK_GLASS_TILE_ID:
		return FRAGILE_BREAK_GLASS_GLOWING_TILE_ID
	elif arg_id == STRONG_BREAK_GLASS_TILE_ID:
		return STRONG_BREAK_GLASS_GLOWING_TILE_ID
	elif arg_id == SPACESHIP_WALL_BREAKABLE_TILE_ID:
		return SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID

static func convert_glowing_breakable_tile_id__to_non_glowing(arg_id):
	if arg_id == BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01:
		return BREAKABLE_GLASS_TILE_ID__ATLAS_01
	elif arg_id == BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
		return BREAKABLE_GLASS_TILE_ID__ATLAS_02
	elif arg_id == INSTANT_BREAK_GLASS_GLOWING_TILE_ID:
		return INSTANT_BREAK_GLASS_TILE_ID
	elif arg_id == FRAGILE_BREAK_GLASS_GLOWING_TILE_ID:
		return FRAGILE_BREAK_GLASS_TILE_ID
	elif arg_id == STRONG_BREAK_GLASS_GLOWING_TILE_ID:
		return STRONG_BREAK_GLASS_TILE_ID
	elif arg_id == SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID:
		return SPACESHIP_WALL_BREAKABLE_TILE_ID

##################

static func get_mass_of_tile_id(arg_id, arg_coords : Vector2):
	match arg_id:
		BREAKABLE_GLASS_TILE_ID__ATLAS_01:
			return BREAKABLE_GLASS_TILE__MASS
		BREAKABLE_GLASS_TILE_ID__ATLAS_02:
			return BREAKABLE_GLASS_TILE__MASS
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_01:
			return BREAKABLE_GLASS_TILE__MASS
		BREAKABLE_GLASS_GLOWING_TILE_ID__ATLAS_02:
			return BREAKABLE_GLASS_TILE__MASS
			
		INSTANT_BREAK_GLASS_TILE_ID:
			return INSTANT_BREAK_GLASS_TILE__MASS
		INSTANT_BREAK_GLASS_GLOWING_TILE_ID:
			return INSTANT_BREAK_GLASS_TILE_ID
			
			
		FRAGILE_BREAK_GLASS_TILE_ID:
			return FRAGILE_BREAK_GLASS_TILE__MASS
		FRAGILE_BREAK_GLASS_GLOWING_TILE_ID:
			return FRAGILE_BREAK_GLASS_TILE__MASS
			
			
		STRONG_BREAK_GLASS_TILE_ID:
			return STRONG_BREAKABLE_GLASS_TILE__MASS
		STRONG_BREAK_GLASS_GLOWING_TILE_ID:
			return STRONG_BREAKABLE_GLASS_TILE__MASS
			
			
		SPACESHIP_WALL_BREAKABLE_TILE_ID:
			return SPACESHIP_WALL_BREAKABLE_TILE__MASS
		SPACESHIP_WALL_BREAKABLE_GLOWING_TILE_ID:
			return SPACESHIP_WALL_BREAKABLE_TILE__MASS
			
			
		##
		SIMPLE_METAL_TILE_ID__01:
			return SIMPLE_METAL_TILE_01__MASS
		SIMPLE_METAL_TILE_ID__02:
			return SIMPLE_METAL_TILE_01__MASS
			
		SPACESHIP_TILE_ID__01:
			return SPACESHIP_WALL_TILE_01__MASS
		SPACESHIP_TILE_ID__02:
			return SPACESHIP_WALL_TILE_02__MASS
			
		DARK_METAL_TILE_ID:
			return DARK_METAL_TILE_01__MASS
			
		SIMPLE_GLASS_TILE_ID__01:
			return SIMPLE_GLASS_TILE_ID__01__MASS
		SIMPLE_GLASS_TILE_ID__02:
			return SIMPLE_GLASS_TILE_ID__02__MASS
			
		HOSTILE_SHIP_METAL_TILE_ID__01:
			return HOSTILE_SHIP_METAL_TILE_01__MASS
		HOSTILE_SHIP_METAL_FRAME_TILE__01:
			return HOSTILE_SHIP_METAL_FRAME_TILE_01__MASS


###############################

func generate_object_tile_fragments(arg_global_pos : Vector2,
		arg_img : Texture, arg_segments : int,
		arg_tile_id : int, arg_tile_coords : Vector2):
	
	var fragment_mass = get_mass_of_tile_id(arg_tile_id, arg_tile_coords) / float(arg_segments)
	
	var fragments : Array = []
	
	var atlasted_textures_and_poses__and_length = generate_or_load_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_img, arg_segments, arg_tile_id, arg_tile_coords)
	var length = atlasted_textures_and_poses__and_length[1]
	for texture_and_top_left_pos in atlasted_textures_and_poses__and_length[0]:
		var tile_fragment_obj = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.TILE_FRAGMENT)
		
		tile_fragment_obj.texture_to_use__fragment = texture_and_top_left_pos[0]
		tile_fragment_obj.tileset_id = arg_tile_id
		var mid_mag = (length / 2.0)
		tile_fragment_obj.position = texture_and_top_left_pos[1] + Vector2(mid_mag, mid_mag) + arg_global_pos
		
		tile_fragment_obj.mass = fragment_mass
		
		fragments.append(tile_fragment_obj)
	
	return fragments


# segment of 9 of 9x9 img = 9 3x3 imgs
func generate_or_load_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_img : Texture, arg_segments : int, 
		arg_tile_id : int, arg_tile_coords : Vector2) -> Array:
	
	if has_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_tile_id, arg_tile_coords, arg_segments):
		return _atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords][arg_segments]
	
	########
	
	var img_size = arg_img.get_size()
	
	var rects : Array = generate_rects_for_size(img_size, arg_segments)
	#var atlased_textures : Array = []
	#var top_left_poses : Array = []
	var atlased_textures_and_top_left_poses = []
	var length : float
	
	for rect in rects:
		var atlased_texture = AtlasTexture.new()
		atlased_texture.region = rect
		atlased_texture.atlas = arg_img
		atlased_texture.filter_clip = true
		#atlased_textures.append(atlased_texture)
		
		length = rect.size.x
		
		#top_left_poses.append(rect.position)
		
		atlased_textures_and_top_left_poses.append([atlased_texture, rect.position])
	
	if arg_tile_id != -1:
		if !_atlased_imgs_of_tile_fragments_map.has(arg_tile_id):
			_atlased_imgs_of_tile_fragments_map[arg_tile_id] = {}
		
		if !_atlased_imgs_of_tile_fragments_map[arg_tile_id].has(arg_tile_coords):
			_atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords] = {}  #.append(arg_tile_coords)
		
		if _atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords].has(arg_segments):
			_atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords][arg_segments] = [atlased_textures_and_top_left_poses, length]
	
	return [atlased_textures_and_top_left_poses, length] #atlased_textures

func has_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments(arg_tile_id : int, arg_tile_coords : Vector2, arg_segments):
	if arg_tile_id != -1 and _atlased_imgs_of_tile_fragments_map.has(arg_tile_id):
		if _atlased_imgs_of_tile_fragments_map[arg_tile_id].has(arg_tile_coords):
			if _atlased_imgs_of_tile_fragments_map[arg_tile_id][arg_tile_coords].has(arg_segments):
				return true
	
	return false


func generate_rects_for_size(arg_size : Vector2, arg_segments : int) -> Array:
	var root_segment_ceil = stepify(sqrt(arg_segments), 0.1)
	
	var full_length_per_segment = arg_size.x / root_segment_ceil
	var lengths : Array = []
	var remaining_length = arg_size.x
	while (remaining_length >= full_length_per_segment):
		remaining_length -= full_length_per_segment
		if remaining_length < 0:
			lengths.append(full_length_per_segment - remaining_length)
		else:
			lengths.append(full_length_per_segment)
	
	##
	
	var rects : Array = []
	var total_x_traversed = 0
	for length in lengths:
		var old_x_total = total_x_traversed
		total_x_traversed += length
		
		var total_y_traversed = 0
		for i in lengths.size():
			var old_y_total = total_y_traversed
			total_y_traversed += length
			
			rects.append(Rect2(old_x_total, old_y_total, length, length))
	
	
	
	return rects


#############

func get_atlas_texture_from_tile_sheet_id(arg_tile_id, arg_auto_coord):
	return _tile_id_to_auto_coord_to_img_map[arg_tile_id][arg_auto_coord]


func generate_atlas_textures_for_tile_sheet(arg_tile_id, arg_tilesheet : Texture, arg_cell_length_and_width : float):
	var tilesheet_size = arg_tilesheet.get_size()
	var x_segment_count = (tilesheet_size.x / arg_cell_length_and_width)
	var y_segment_count = (tilesheet_size.y / arg_cell_length_and_width)
	#print("x: %s, y: %s" % [x_segment_count, y_segment_count])
	#var segment_count = (tilesheet_size.x / arg_cell_length_and_width) * (tilesheet_size.y / arg_cell_length_and_width)
	#segment_count *= segment_count
	
	_tile_id_to_auto_coord_to_img_map[arg_tile_id] = {}
	
	#var rects_and_autocoords = generate_rects_for_size__and_autocoords(tilesheet_size, segment_count)
	var rects_and_autocoords = generate_rects_for_size__and_autocoords(tilesheet_size, x_segment_count, y_segment_count)
	for rect_and_autocoord in rects_and_autocoords:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = arg_tilesheet
		atlas_texture.region = rect_and_autocoord[0]
		
		_tile_id_to_auto_coord_to_img_map[arg_tile_id][rect_and_autocoord[1]] = atlas_texture
	
	#print(_tile_id_to_auto_coord_to_img_map[arg_tile_id].size())
	
	return true

func has_atlas_textures_for_tile_sheet(arg_tile_id):
	return _tile_id_to_auto_coord_to_img_map.has(arg_tile_id)


func generate_rects_for_size__and_autocoords(arg_size : Vector2, arg_x_segments : int, arg_y_segments : int) -> Array:
	#var root_segment_ceil = ceil(sqrt(arg_segments))
	
	var x_full_length = arg_size.x
	var x_lengths : Array = []
	var x_remaining_length = x_full_length
	while (x_remaining_length > 0):
		x_remaining_length -= arg_size.x / float(arg_x_segments)
		x_lengths.append(arg_size.x / float(arg_x_segments))
		#if x_remaining_length > 0:
		#	x_lengths.append(x_full_length - x_remaining_length)
		#else:
		#	x_lengths.append(x_full_length)
	
	
	var y_full_length = arg_size.y
	var y_lengths : Array = []
	var y_remaining_length = y_full_length
	while (y_remaining_length > 0):
		y_remaining_length -= arg_size.y / float(arg_y_segments)
		y_lengths.append(arg_size.y / float(arg_y_segments))
		#if y_remaining_length > 0:
		#	y_lengths.append(y_full_length - y_remaining_length)
		#else:
		#	y_lengths.append(y_full_length)
	
	
	##
	
	var rects_and_auto_coords : Array = []
	#var auto_coords : Array = []
	
	var i_x = 0
	var i_y = 0
	var total_x_traversed = 0
	for x_length in x_lengths:
		var old_x_total = total_x_traversed
		total_x_traversed += x_length
		
		var total_y_traversed = 0
		for y_length in y_lengths:
			var old_y_total = total_y_traversed
			total_y_traversed += y_length
			
			#rects.append(Rect2(old_x_total, old_y_total, length, length))
			#auto_coords.append([i_x + 1, i_y + 1])
			
			var rect = Rect2(old_x_total, old_y_total, x_length, y_length)
			var auto_coords = Vector2(i_x, i_y)
			rects_and_auto_coords.append([rect, auto_coords])
			
			i_y += 1
		
		i_x += 1
		i_y = 0
	
	
	
	return rects_and_auto_coords


###

func generate_atlas_img_for_tilesheet_on_region(arg_tile_id, arg_region : Rect2, arg_tilesheet : Texture):
	var atlas_img = AtlasTexture.new()
	atlas_img.atlas = arg_tilesheet
	atlas_img.region = arg_region
	
	if !_tile_id_to_region_to_img_map.has(arg_tile_id):
		_tile_id_to_region_to_img_map[arg_tile_id] = {}
	
	_tile_id_to_region_to_img_map[arg_tile_id][arg_region] = atlas_img

func has_atlas_img_for_tilesheet_on_region(arg_tile_id, arg_region) -> bool:
	if _tile_id_to_region_to_img_map.has(arg_tile_id):
		if _tile_id_to_region_to_img_map[arg_tile_id].has(arg_region):
			return true
	
	return false

func get_atlas_img_for_tilesheet_on_region(arg_tile_id, arg_region) -> AtlasTexture:
	return _tile_id_to_region_to_img_map[arg_tile_id][arg_region]


###########
# FRAGMENTS, BUT FOR ANY

func generate_object_tile_fragments__for_any_no_save(arg_global_pos : Vector2,
		atlasted_textures_and_poses__and_length : Array,
		arg_fragment_mass : float):
	
	var fragments : Array = []
	
	#var atlasted_textures_and_poses__and_length = generate_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments__for_any_no_save(arg_img, arg_segments)
	var length = atlasted_textures_and_poses__and_length[1]
	for texture_and_top_left_pos in atlasted_textures_and_poses__and_length[0]:
		var fragment_obj = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.TILE_FRAGMENT)
		
		fragment_obj.texture_to_use__fragment = texture_and_top_left_pos[0]
		#fragment_obj.tileset_id = arg_tile_id
		var mid_mag = (length / 2.0)
		fragment_obj.position = texture_and_top_left_pos[1] + Vector2(mid_mag, mid_mag) + arg_global_pos
		
		fragment_obj.mass = arg_fragment_mass
		
		fragments.append(fragment_obj)
	
	return fragments

# segment of 9 of 9x9 img = 9 3x3 imgs
func generate_atlased_textures_and_top_left_pos__and_length_of_img__for_fragments__for_any_no_save(arg_img : Texture, arg_segments : int) -> Array:
	var img_size = arg_img.get_size()
	
	var rects : Array = generate_rects_for_size(img_size, arg_segments)
	var atlased_textures_and_top_left_poses = []
	var length : float
	
	for rect in rects:
		var atlased_texture = AtlasTexture.new()
		atlased_texture.region = rect
		atlased_texture.atlas = arg_img
		atlased_texture.filter_clip = true
		
		length = rect.size.x
		
		atlased_textures_and_top_left_poses.append([atlased_texture, rect.position])
	
	
	return [atlased_textures_and_top_left_poses, length] #atlased_textures


#func generate_atlas_textures_for__for_any_no_save(arg_texture : Texture, arg_fragment_length_and_width : float):
#	var texture_size = arg_texture.get_size()
#	var x_segment_count = (texture_size.x / arg_fragment_length_and_width)
#	var y_segment_count = (texture_size.y / arg_fragment_length_and_width)
#
#	var rects_and_autocoords = generate_rects_for_size__and_autocoords(texture_size, x_segment_count, y_segment_count)
#	for rect_and_autocoord in rects_and_autocoords:
#		var atlas_texture = AtlasTexture.new()
#		atlas_texture.atlas = arg_texture
#		atlas_texture.region = rect_and_autocoord[0]
#
#
#	return true


##################
# SOUND related
#################

func _initialize_all_tile_to_sound_id_map():
	#used by common/most surfaces
	var _standard_tile_metal_hit__ping = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_Ping_HighPitchShortFull, StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion]
	}
	#used by glass
	var _standard_tile_glass_hit = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalHitGlass, StoreOfAudio.AudioIds.SFX_TileHit_MetalHitGlass]
	}
	#used by toggleable
	var _standard_tile_metal_hit__tin = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_SoftFull_LowPitchTinPlate, StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion]
	}
	#not used yet
	var _standard_tile_metal_hit__hollow = {
		ANY_AUTO_COORD : [StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_SoftHollow, StoreOfAudio.AudioIds.SFX_TileHit_MetalBang_LoudFullBangExplosion]
	}
	
	_tile_id_to_auto_coord_to_sound_id_map__normal_and_loud = {
		0 : _standard_tile_metal_hit__ping,
		1 : _standard_tile_metal_hit__ping,
		2 : _standard_tile_glass_hit,
		3 : _standard_tile_glass_hit,
		4 : _standard_tile_glass_hit,
		5 : _standard_tile_glass_hit,
		6 : _standard_tile_metal_hit__tin,
		7 : _standard_tile_metal_hit__tin,
		#8
		#9
		10 : _standard_tile_metal_hit__ping,
		11 : _standard_tile_metal_hit__ping,
		12 : _standard_tile_metal_hit__ping,
		#13
		14 : _standard_tile_metal_hit__ping,
		15 : _standard_tile_glass_hit,
		16 : _standard_tile_glass_hit,
		17 : _standard_tile_glass_hit,
		18 : _standard_tile_glass_hit,
		19 : _standard_tile_glass_hit,
		20 : _standard_tile_glass_hit,
		
		
		23 : _standard_tile_metal_hit__ping,
		24 : _standard_tile_metal_hit__ping,
		25 : _standard_tile_metal_hit__ping,
		
		HOSTILE_SHIP_METAL_TILE_ID__01 : _standard_tile_metal_hit__ping,
		HOSTILE_SHIP_METAL_FRAME_TILE__01 : _standard_tile_metal_hit__ping
		
	}
	
	###########
	var _standard_tile_glass_break = {
		ANY_AUTO_COORD : StoreOfAudio.AudioIds.SFX_Misc_GlassBreak_Hard
	}
	var _spaceship_wall_breakable_break = {
		ANY_AUTO_COORD : StoreOfAudio.AudioIds.SFX_SpaceshipWall_Tile_Break
	}
	
	_breakable_tile_id_to_auto_coord_to_sound_id_map = {
		2 : _standard_tile_glass_break,
		3 : _standard_tile_glass_break,
		4 : _standard_tile_glass_break,
		5 : _standard_tile_glass_break,
		
		15 : _standard_tile_glass_break,
		16 : _standard_tile_glass_break,
		
		17 : _standard_tile_glass_break,
		18 : _standard_tile_glass_break,
		
		19 : _standard_tile_glass_break,
		20 : _standard_tile_glass_break,
		
		21 : _spaceship_wall_breakable_break,
		22 : _spaceship_wall_breakable_break,
		
	}
	

func get_sound_id_to_play_for_tile_hit(arg_tile_id, arg_auto_coords, arg_is_loud : bool):
	if _tile_id_to_auto_coord_to_sound_id_map__normal_and_loud.has(arg_tile_id):
		var auto_coord_to_id_map = _tile_id_to_auto_coord_to_sound_id_map__normal_and_loud[arg_tile_id]
		if auto_coord_to_id_map.has(arg_auto_coords):
			var ids_of_normal_or_loud = auto_coord_to_id_map[arg_auto_coords]
			if arg_is_loud:
				return ids_of_normal_or_loud[1]
			else:
				return ids_of_normal_or_loud[0]
			
		elif auto_coord_to_id_map.has(ANY_AUTO_COORD):
			var ids_of_normal_or_loud = auto_coord_to_id_map[ANY_AUTO_COORD]
			if arg_is_loud:
				return ids_of_normal_or_loud[1]
			else:
				return ids_of_normal_or_loud[0]
			
	
	
	return -1

func get_sound_id_to_play_for_tile_break(arg_tile_id, arg_auto_coords):
	if _breakable_tile_id_to_auto_coord_to_sound_id_map.has(arg_tile_id):
		var auto_coord_to_id_map = _breakable_tile_id_to_auto_coord_to_sound_id_map[arg_tile_id]
		if auto_coord_to_id_map.has(arg_auto_coords):
			return auto_coord_to_id_map[arg_auto_coords]
			
		elif auto_coord_to_id_map.has(ANY_AUTO_COORD):
			return auto_coord_to_id_map[ANY_AUTO_COORD]
			
	
	
	return -1


############################
## LIGHT RELATED
#############################


func _initialize_all_uncol_tile_to_light_tex_rect_size_and_color_gradient_map():
	_uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map = {
		14 : {
			Vector2(0, 0) : _construct_light_details__for_14__dark_metal_lamp__vert(),
			Vector2(1, 0) : _construct_light_details__for_14__dark_metal_lamp__horiz(),
		},
		
		23 : {
			Vector2(0, 0) : _construct_light_details__for_23__V00_00(),
			Vector2(1, 0) : _construct_light_details__for_23__V01_00(),
			
			Vector2(0, 1) : _construct_light_details__for_23__Vxx_01(),
			Vector2(1, 1) : _construct_light_details__for_23__Vxx_01(),
			Vector2(2, 1) : _construct_light_details__for_23__Vxx_01(),
			Vector2(3, 1) : _construct_light_details__for_23__Vxx_01(),
			
		},
		
		43: {
			Vector2(0, 0) : _construct_light_details__for_43__V00_00(),
			Vector2(1, 0) : _construct_light_details__for_43__V01_00(),
			Vector2(2, 0) : _construct_light_details__for_43__V02_00(),
			Vector2(3, 0) : _construct_light_details__for_43__V03_00(),
			
		},
		
		# purple spaceship
		55 : {
			Vector2(0, 0) : _construct_light_details__for_55__V00_00(),
			Vector2(1, 0) : _construct_light_details__for_55__V01_00(),
			
			Vector2(0, 1) : _construct_light_details__for_55__V00_01(),
			Vector2(1, 1) : _construct_light_details__for_55__V01_01(),
			Vector2(2, 1) : _construct_light_details__for_55__V02_01(),
			Vector2(3, 1) : _construct_light_details__for_55__V03_01(),
			
		},
		
		# dark metal
		63 : {
			Vector2(0, 0) : _construct_light_details__for_63__V00_00(),
			Vector2(1, 0) : _construct_light_details__for_63__V01_00(),
			Vector2(2, 0) : _construct_light_details__for_63__V02_00(),
			Vector2(3, 0) : _construct_light_details__for_63__V03_00(),
			
			Vector2(0, 1) : _construct_light_details__for_63__V00_01(),
			Vector2(1, 1) : _construct_light_details__for_63__V01_01(),
			Vector2(2, 1) : _construct_light_details__for_63__V02_01(),
			Vector2(3, 1) : _construct_light_details__for_63__V03_01(),
			
		}
		
	}
	

func _construct_light_details__for_14__dark_metal_lamp__vert():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(120, 240))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(253/255.0, 215/255.0, 98/255.0, 0.6), Color(0, 0, 0, 0))
	
	return light_details

func _construct_light_details__for_14__dark_metal_lamp__horiz():
	var light_details = _construct_light_details__for_14__dark_metal_lamp__vert()
	light_details.rotation = 90
	
	return light_details
#	var light_details = LightDetails.new()
#	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(120, 240))
#	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(253/255.0, 215/255.0, 98/255.0, 0.6), Color(0, 0, 0, 0))
#	light_details.rotation = 90
#
#	return light_details


func _construct_light_details__for_23__V00_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(255, 195))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(129/255.0, 209/255.0, 254/255.0, 0.6), Color(0, 0, 0, 0))
	
	return light_details

func _construct_light_details__for_23__V01_00():
	var light_details = _construct_light_details__for_23__V00_00()
	light_details.rotation = 90
	
	return light_details


func _construct_light_details__for_23__Vxx_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(180, 180))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(255/255.0, 145/255.0, 41/255.0, 0.6), Color(0, 0, 0, 0))
	
	return light_details
	


func _construct_light_details__for_43__V00_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(256, 196))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99E8FD00"), Color(0, 0, 0, 0))
	
	return light_details

func _construct_light_details__for_43__V01_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(196, 256))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99E8FD00"), Color(0, 0, 0, 0))
	
	return light_details



func _construct_light_details__for_43__V02_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(257, 197))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99FF8F1F"), Color(0, 0, 0, 0))
	
	return light_details

func _construct_light_details__for_43__V03_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(197, 257))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99FF8F1F"), Color(0, 0, 0, 0))
	
	return light_details



func _construct_light_details__for_55__V00_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(257, 257))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99933AA1"), Color(0, 0, 0, 0))
	
	return light_details

func _construct_light_details__for_55__V01_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(160, 167))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99933AA1"), Color(0, 0, 0, 0))
	
	return light_details


func _construct_light_details__for_55__V00_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(50, 50))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99933AA1"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(0, 9)
	
	return light_details

func _construct_light_details__for_55__V01_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(50.5, 50.5))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99933AA1"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(-9, 0)
	
	return light_details

func _construct_light_details__for_55__V02_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(51, 51))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99933AA1"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(0, -9)
	
	return light_details

func _construct_light_details__for_55__V03_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(49.5, 49.5))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99933AA1"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(9, 0)
	
	return light_details




func _construct_light_details__for_63__V00_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(90, 60))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#9933FFB2"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(0, 7)
	
	return light_details

func _construct_light_details__for_63__V01_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(90.5, 60))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#9933FFB2"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(-7, 0)
	
	return light_details

func _construct_light_details__for_63__V02_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(91, 60))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#9933FFB2"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(0, -7)
	
	return light_details

func _construct_light_details__for_63__V03_00():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(91.5, 60))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#9933FFB2"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(7, 0)
	
	return light_details



func _construct_light_details__for_63__V00_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(90, 61))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99FF8842"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(0, 8)
	
	return light_details

func _construct_light_details__for_63__V01_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(90.5, 61))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99FF8842"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(-8, 0)
	
	return light_details

func _construct_light_details__for_63__V02_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(91, 61))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99FF8842"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(0, -8)
	
	return light_details

func _construct_light_details__for_63__V03_01():
	var light_details = LightDetails.new()
	light_details.light_texture = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(91.5, 61))
	light_details.light_texture.gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color("#99FF8842"), Color(0, 0, 0, 0))
	light_details.offset = Vector2(8, 0)
	
	return light_details

#

func get_light_details_of_tile_id(arg_tile_id, arg_auto_coords) -> LightDetails:
	if _uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map.has(arg_tile_id):
		var map = _uncollidable_tile_id_to_auto_coord_to_light_details_to_use_map[arg_tile_id]
		
		if map.has(arg_auto_coords):
			return map[arg_auto_coords]
			
		elif map.has(ANY_AUTO_COORD):
			return map[ANY_AUTO_COORD]
			
	
	
	return null

#############################
# FRAGMENT SOUNDS RELATED


#func _initialize_tile_fragment_to_sound_list():
#


func get_tile_id_to_fragment_collision_sound_list(arg_tile_id):
	if _tile_id_to_fragment_collision_sound_list_map.has(arg_tile_id):
		return _tile_id_to_fragment_collision_sound_list_map[arg_tile_id]
	else:
		return NONE__ANY_COLLISION_SOUND_LIST

func get_tile_id_to_ball_collision_sound_list(arg_tile_id):
	if _tile_id_to_ball_collision_sound_list_map.has(arg_tile_id):
		return _tile_id_to_ball_collision_sound_list_map[arg_tile_id]
	else:
		return NONE__ANY_COLLISION_SOUND_LIST




func get_or_calc_modulate_for_player_hit_tile_rect_draw_particles_on_tile_id(arg_tile_id, arg_tileset_curr_modulate : Color):
	if !_precalced_tile_id_to_tileset_extr_modulate_to_player_hit_collision_rect_particle_modulate_map_map.has(arg_tile_id):
		return _populate_precalc_player_hit_collision_rect_particle_modulate_map_map__first_key__and_get_calced_modulate(arg_tile_id, arg_tileset_curr_modulate)
		
	
	if !_precalced_tile_id_to_tileset_extr_modulate_to_player_hit_collision_rect_particle_modulate_map_map[arg_tile_id].has(arg_tileset_curr_modulate):
		return _populate_precalc_player_hit_collision_rect_particle_modulate_map_map__sec_key__and_get_calced_modulate(arg_tile_id, arg_tileset_curr_modulate)
		
	
	return _precalced_tile_id_to_tileset_extr_modulate_to_player_hit_collision_rect_particle_modulate_map_map[arg_tile_id][arg_tileset_curr_modulate]



func _populate_precalc_player_hit_collision_rect_particle_modulate_map_map__first_key__and_get_calced_modulate(arg_tile_id, arg_tileset_curr_modulate : Color):
	var modulate_of_tileset = _tile_id_to_player_hit_collision_rect_particle_modulate_map[arg_tile_id]
	var calced_modulate = BaseTileSet.calculate_final_modulate_to_use([modulate_of_tileset, arg_tileset_curr_modulate])
	
	_precalced_tile_id_to_tileset_extr_modulate_to_player_hit_collision_rect_particle_modulate_map_map[arg_tile_id] = {
		arg_tileset_curr_modulate : calced_modulate
	}
	
	return calced_modulate

func _populate_precalc_player_hit_collision_rect_particle_modulate_map_map__sec_key__and_get_calced_modulate(arg_tile_id, arg_tileset_curr_modulate : Color):
	var modulate_of_tileset = _tile_id_to_player_hit_collision_rect_particle_modulate_map[arg_tile_id]
	var calced_modulate = BaseTileSet.calculate_final_modulate_to_use([modulate_of_tileset, arg_tileset_curr_modulate])
	
	_precalced_tile_id_to_tileset_extr_modulate_to_player_hit_collision_rect_particle_modulate_map_map[arg_tile_id][arg_tileset_curr_modulate] = calced_modulate
	
	return calced_modulate


