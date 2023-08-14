extends Reference

#

const StoreOfTransitionSprites = preload("res://_NonMainGameRelateds/_Master/TransitionsRelated/StoreOfTransitionSprites.gd")

#

signal is_level_locked_changed(arg_val)

#

const DEFAULT_LEVEL_TILE_LOCKED_TEXTURE = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_Tile_Dark_32x32.png")
const DEFAULT_LEVEL_TILE_LOCKED_MODULATE = Color(0.3, 0.3, 0.3, 1.0)

#

enum LevelTypeId {
	CAMPAIGN = 0,
	FOR_FUN = 1,
	CHALLENGE = 2,
}
var level_type : int = LevelTypeId.CAMPAIGN


#

var level_label_on_tile : String

var level_label_text_color : Color = Color("#dddddd")
var level_label_outline_color : Color = Color("#222222")
var has_outline_color : bool = false

##

var level_full_name : Array
var level_name : Array setget set_level_name
var level_desc

var level_id : int


var texture_of_level_tile : Texture
var modulate_of_level_tile : Color

var texture_of_level_tile__locked : Texture
var modulate_of_level_tile__locked : Color

# managed by gamesavemanager and storeoflevels
var is_level_locked setget set_is_level_locked


var transition_id__entering_level__out  # from selection to blank
var transition_id__entering_level__in   # from blank to game

# for win
var transition_id__exiting_level__out  # from game to blank
var transition_id__exiting_level__in  # from blank to selection

# for lose
var transition_id__exiting_level__out__for_lose = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK  # from game to blank
var transition_id__exiting_level__in__for_lose = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK  # from blank to selection

# for quit
var transition_id__exiting_level__out__for_quit = StoreOfTransitionSprites.TransitionSpriteIds.OUT__STANDARD_CIRCLE__BLACK  # from game to blank
var transition_id__exiting_level__in__for_quit = StoreOfTransitionSprites.TransitionSpriteIds.IN__STANDARD_CIRCLE__BLACK  # from blank to selection



var BGM_playlist_id_to_use__on_level_start : int = StoreOfAudio.BGMPlaylistId.CALM_01


##

var zoom_normal_vec = CameraManager.DEFAULT_ZOOM_LEVEL
var zoom_out_vec = CameraManager.ZOOM_OUT__DEFAULT__ZOOM_LEVEL

##########

func set_level_name(arg_val):
	level_name = arg_val
	
	if level_full_name.size() == 0:
		level_full_name = level_name

#

func set_is_level_locked(arg_val):
	var old_val = is_level_locked
	is_level_locked = arg_val
	
	if old_val != is_level_locked:
		if is_level_locked:
			pass
			
		else:
			pass
			
		
		emit_signal("is_level_locked_changed", is_level_locked)


func get_texture_and_modulate_to_use__based_on_properties() -> Array:
	var bucket = []
	
	if is_level_locked:
		if texture_of_level_tile__locked != null:
			bucket.append(texture_of_level_tile__locked)
			bucket.append(modulate_of_level_tile__locked)
			
		else:
			bucket.append(DEFAULT_LEVEL_TILE_LOCKED_TEXTURE)
			bucket.append(DEFAULT_LEVEL_TILE_LOCKED_MODULATE)
		
	else:
		bucket.append(texture_of_level_tile)
		bucket.append(modulate_of_level_tile)
	
	return bucket


