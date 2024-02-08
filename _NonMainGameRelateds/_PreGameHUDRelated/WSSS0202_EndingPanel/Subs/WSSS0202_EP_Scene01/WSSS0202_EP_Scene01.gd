extends "res://_NonMainGameRelateds/_PreGameHUDRelated/WSSS0202_EndingPanel/Subs/WSSS0202_EP_BaseScene.gd"



var desc__line_01 = [
	["In the vast [color=#ABABAB]darkness[/color] of space", []]
]
var desc__line_02 = [
	["Even the smallest of [color=#FDC621]stars[/color]", []]
]
var desc__line_03 = [
	["Can leave their [color=#FE8B8D]mark[/color]", []]
]


onready var ftq_line_01 = $FTQ_Line01
onready var ftq_line_02 = $FTQ_Line02
onready var ftq_line_03 = $FTQ_Line03


func _ready():
	ftq_line_01.set_desc__and_hide_tooltip(desc__line_01)
	ftq_line_02.set_desc__and_hide_tooltip(desc__line_02)
	ftq_line_03.set_desc__and_hide_tooltip(desc__line_03)
	

func start_display():
	.start_display()
	
	#_display_ftq_line_01()
	call_deferred("_display_ftq_line_01")

func _display_ftq_line_01():
	ftq_line_01.visible = true
	ftq_line_01.start_display_of_descs__all_chars(1.5, 0.5, null)
	ftq_line_01.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_01", [], CONNECT_ONESHOT)


func _on_display_of_desc_finished__ftq_line_01(custom_char_count_to_show_upto, arg_metadata):
	_display_ftq_line_02()
	


func _display_ftq_line_02():
	ftq_line_02.start_display_of_descs__all_chars(1.5, 0.5, null)
	ftq_line_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_02", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__ftq_line_02(custom_char_count_to_show_upto, arg_metadata):
	_display_ftq_line_03()



func _display_ftq_line_03():
	ftq_line_03.start_display_of_descs__all_chars(1.5, 0.5, null)
	ftq_line_03.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_03", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__ftq_line_03(custom_char_count_to_show_upto, arg_metadata):
	emit_sequence_finished()
	
