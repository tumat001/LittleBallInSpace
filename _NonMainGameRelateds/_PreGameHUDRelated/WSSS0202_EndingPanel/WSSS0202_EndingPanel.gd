extends Control

signal ending_panel_finished()


var show_bonus_blind_panel : bool = false

onready var ep_scene01 = $WSSS0202_EP_Scene01
onready var ep_scene_bonus_blind = $WSSS0202_EP_SceneBonusBlind


func _ready():
	ep_scene01.visible = false
	ep_scene_bonus_blind.visible = false


func start_display():
	_start_show_ep_scene_01()


func _start_show_ep_scene_01():
	ep_scene01.connect("sequence_finished", self, "_on_ep_scene01_sequence_finished", [], CONNECT_ONESHOT)
	ep_scene01.visible = true
	ep_scene01.start_display()

func _on_ep_scene01_sequence_finished():
	var tweener = create_tween()
	tweener.tween_property(ep_scene01, "modulate:a", 0.0, 1.0)
	tweener.tween_interval(0.25)
	if show_bonus_blind_panel:
		tweener.tween_callback(self, "_start_show_ep_scene_bonus_blind")
	else:
		_config_tweener_to_callback_end_panel(tweener)
	

func _start_show_ep_scene_bonus_blind():
	ep_scene_bonus_blind.connect("sequence_finished", self, "_on_ep_scene_bonus_blind_sequence_finished", [], CONNECT_ONESHOT)
	ep_scene_bonus_blind.visible = true
	ep_scene_bonus_blind.start_display()

func _on_ep_scene_bonus_blind_sequence_finished():
	var tweener = create_tween()
	tweener.tween_property(ep_scene_bonus_blind, "modulate:a", 0.0, 1.0)
	tweener.tween_interval(0.25)
	_config_tweener_to_callback_end_panel(tweener)


func _config_tweener_to_callback_end_panel(tweener : SceneTreeTween):
	tweener.tween_callback(self, "_on_end_panel")

func _on_end_panel():
	emit_signal("ending_panel_finished")

###



