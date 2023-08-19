extends Reference

signal is_level_layout_locked_changed(arg_is_level_layout_locked)

#

const DEFAULT_LEVEL_TILE_LOCKED_TEXTURE = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/LevelLayoutElements/LevelLayout_Tile/Assets/LevelLayout_Tile_Dark_32x32.png")
const DEFAULT_LEVEL_TILE_LOCKED_MODULATE = Color(0.5, 0.5, 0.5, 1.0)


#

var level_layout_id

var level_layout_label_on_tile : String
var level_label_text_color : Color = Color("#dddddd")
var level_label_outline_color : Color = Color("#222222")
var has_outline_color : bool = false

#

var texture_of_level_tile : Texture
var modulate_of_level_tile : Color

var texture_of_level_tile__locked : Texture
var modulate_of_level_tile__locked : Color


# managed by gamesavemanager and storeoflevelslayout
var is_level_layout_locked setget set_is_level_layout_locked


#var transition_id__entering_layout__out  # from selection to blank
var transition_id__entering_layout__in   # from blank to (this) selection

#var transition_id__exiting_layout__out  # from (this) selection to blank
var transition_id__exiting_layout__in  # from blank to selection

#



func set_is_level_layout_locked(arg_val):
	var old_val = is_level_layout_locked
	is_level_layout_locked = arg_val
	
	if old_val != is_level_layout_locked:
		if is_level_layout_locked:
			pass
			
		else:
			pass
			
		
		emit_signal("is_level_layout_locked_changed", is_level_layout_locked)


func get_texture_and_modulate_to_use__based_on_properties() -> Array:
	var bucket = []
	
	if is_level_layout_locked:
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

