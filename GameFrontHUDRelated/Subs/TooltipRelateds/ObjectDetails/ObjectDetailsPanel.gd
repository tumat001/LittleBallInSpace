extends "res://MiscRelated/TooltipRelated/BaseTooltip.gd"


const PlainTextFragment = preload("res://MiscRelated/TextInterpreterRelated/TextFragments/PlainTextFragment.gd")

const StoreOfFonts = preload("res://MiscRelated/FontRelated/StoreOfFonts.gd")


##

var has_dark_background : bool = true


onready var tooltip_body = $MarginContainer2/MarginContainer/TooltipBody

#

func _ready():
	#tooltip_body.font_id_to_use = StoreOfFonts.FontTypes.CONSOLA
	tooltip_body.use_color_for_dark_background = has_dark_background
	
	#tooltip_body.
	
	visible = false

##########

func show_descs(arg_descs):
	if arg_descs.size() != 0:
		tooltip_body.descriptions = arg_descs
		tooltip_body.update_display()
	
	if !visible:
		modulate.a = 0
		visible = true
		var tweener = create_tween()
		tweener.tween_property(self, "modulate:a", 1.0, 0.3)

##

static func generate_descs__for_tileset(arg_base_tileset):
	var final_desc = []
	
	##
	
#	var energy_mode_desc_line
#
#	#if arg_base_tileset.energy_mode == arg_base_tileset.EnergyMode.NORMAL:
#	#	energy_mode_desc_line = ["Energy type: |0|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.NORMAL_TILES, "None")]]
#	#	
#	if arg_base_tileset.energy_mode == arg_base_tileset.EnergyMode.ENERGIZED:
#		energy_mode_desc_line = ["Energy type: |0|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.ENERGIZED_TILES, "Energized")]]
#
#	elif arg_base_tileset.energy_mode == arg_base_tileset.EnergyMode.INSTANT_GROUND:
#		energy_mode_desc_line = ["Energy type: |0|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.INSTANT_GROUNDED_TILES, "Grounded")]]
#
#
#	if energy_mode_desc_line != null:
#		final_desc.append(energy_mode_desc_line)
	
	##
	if arg_base_tileset.is_breakable():
		#var value = stepify(arg_base_tileset.momentum_breaking_point / arg_base_tileset.get_player().last_calculated_object_mass, 0.01)
		var value = ceil(arg_base_tileset.momentum_breaking_point / arg_base_tileset.get_player().last_calculated_object_mass)
		var mov_speed_to_break = ["Mov speed to |0|: |1|", [PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.BREAKABLE_TILES, "break"), PlainTextFragment.new(PlainTextFragment.DESCRIPTION_TYPE.SPEED, "%s" % (value))]]
		
		final_desc.append(mov_speed_to_break)
	
	##
	
	return final_desc



