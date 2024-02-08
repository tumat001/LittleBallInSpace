extends "res://_NonMainGameRelateds/_PreGameHUDRelated/WSSS0202_EndingPanel/Subs/WSSS0202_EP_BaseScene.gd"


var desc__line_01 = [
	["Even crazier", []]
]
var desc__line_02 = [
	["Are the stars", []]
]
var desc__line_03 = [
	["That shine", []]
]
var desc__line_04 = [
	["In their darkness", []]
]
#var desc__line_05 = [
#	["And Lonesome", []]
#]


onready var ftq_line_01 = $FTQ_Line01
onready var ftq_line_02 = $FTQ_Line02
onready var ftq_line_03 = $FTQ_Line03
onready var ftq_line_04 = $FTQ_Line04
#onready var ftq_line_05 = $FTQ_Line05


#####

func _ready():
	ftq_line_01.set_desc__and_hide_tooltip(desc__line_01)
	ftq_line_02.set_desc__and_hide_tooltip(desc__line_02)
	ftq_line_03.set_desc__and_hide_tooltip(desc__line_03)
	ftq_line_04.set_desc__and_hide_tooltip(desc__line_04)
	#ftq_line_05.set_desc__and_hide_tooltip(desc__line_05)
	


func start_display():
	.start_display()
	
	_display_ftq_line_01()


func _display_ftq_line_01():
	ftq_line_01.start_display_of_descs__all_chars(0.8, 0.3, null)
	ftq_line_01.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_01", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__ftq_line_01(custom_char_count_to_show_upto, arg_metadata):
	_display_ftq_line_02()
	



func _display_ftq_line_02():
	ftq_line_02.start_display_of_descs__all_chars(0.8, 0.3, null)
	ftq_line_02.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_02", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__ftq_line_02(custom_char_count_to_show_upto, arg_metadata):
	_display_ftq_line_03()



func _display_ftq_line_03():
	ftq_line_03.start_display_of_descs__all_chars(0.8, 0.3, null)
	ftq_line_03.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_03", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__ftq_line_03(custom_char_count_to_show_upto, arg_metadata):
	_display_ftq_line_04()



func _display_ftq_line_04():
	ftq_line_04.start_display_of_descs__all_chars(0.8, 0.3, null)
	ftq_line_04.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_04", [], CONNECT_ONESHOT)

func _on_display_of_desc_finished__ftq_line_04(custom_char_count_to_show_upto, arg_metadata):
	#_display_ftq_line_05()
	emit_sequence_finished()


#func _display_ftq_line_05():
#	ftq_line_04.start_display_of_descs__all_chars(0.8, 0.3, null)
#	ftq_line_04.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__ftq_line_05", [], CONNECT_ONESHOT)
#
#func _on_display_of_desc_finished__ftq_line_05(custom_char_count_to_show_upto, arg_metadata):
#	emit_sequence_finished()

