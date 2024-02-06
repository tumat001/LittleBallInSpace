extends Node2D

#####################
# DRAW FX PHASE
# 1) star edge beams (starting bot left then clockwise)
# 2) small line-only circle (ease out)
# 3) medium line-only circle (ease out)
# 4) big filling circle (linear)


var shine_delay_per_star_beam : float

onready var line_draw_node = $LineDrawNode


####

func start_draw():
	pass
	

