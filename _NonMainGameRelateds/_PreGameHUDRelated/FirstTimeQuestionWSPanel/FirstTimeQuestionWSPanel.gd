extends MarginContainer

signal question_panel_finished()

#

onready var ftq_scene01 = $FreeFormControl/FTQ_Scene01
onready var ftq_scene02 = $FreeFormControl/FTQ_Scene02
onready var ftq_scene03 = $FreeFormControl/FTQ_Scene03
onready var ftq_scene04 = $FreeFormControl/FTQ_Scene04


#

func _ready():
	ftq_scene01.visible = false
	ftq_scene02.visible = false
	ftq_scene03.visible = false
	ftq_scene04.visible = false
	
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
	ftq_scene03.visible = false
	ftq_scene03.queue_free()
	
	##
	
	ftq_scene04.visible = true
	ftq_scene04.start_display()
	ftq_scene04.connect("sequence_finished", self, "_on_sequence_finished__scene_04")

##

func _on_sequence_finished__scene_04():
	#var wait_tweener = create_tween()
	#wait_tweener.tween_callback(self, "_emit_finished").set_delay(2.0)
	
	_emit_finished()

func _emit_finished():
	emit_signal("question_panel_finished")


