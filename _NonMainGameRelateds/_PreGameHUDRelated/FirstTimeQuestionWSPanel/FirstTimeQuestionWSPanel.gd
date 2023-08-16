extends MarginContainer

signal question_panel_finished()

#

onready var ftq_scene01 = $FreeFormControl/FTQ_Scene01
onready var ftq_scene02 = $FreeFormControl/FTQ_Scene02
onready var ftq_scene03 = $FreeFormControl/FTQ_Scene03


#

func _ready():
	ftq_scene01.visible = false
	ftq_scene02.visible = false
	ftq_scene03.visible = false
	
	_start_scene_sequence__01()

func _start_scene_sequence__01():
	ftq_scene01.visible = true
	ftq_scene01.start_display()
	ftq_scene01.connect("sequence_finished", self, "_on_sequence_finished__scene_01")


func _on_sequence_finished__scene_01():
	ftq_scene01.visible = false
	ftq_scene01.queue_free()
	
	##
	
	ftq_scene02.visible = true
	ftq_scene02.start_display()
	ftq_scene02.connect("sequence_finished", self, "_on_sequence_finished__scene_02")

func _on_sequence_finished__scene_02():
	ftq_scene02.visible = false
	ftq_scene02.queue_free()
	
	##
	
	ftq_scene03.visible = true
	ftq_scene03.start_display()
	ftq_scene03.connect("sequence_finished", self, "_on_sequence_finished__scene_03")


func _on_sequence_finished__scene_03():
	emit_signal("question_panel_finished")

