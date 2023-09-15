extends Control

const LightTextureConstructor = preload("res://MiscRelated/Light2DRelated/LightTextureConstructor.gd")

#

var _show_tweener : SceneTreeTween
var _hide_tweener : SceneTreeTween

#

var original_warning_text : String

#

onready var gradient_background = $GradientBackground

onready var warning_label = $WarningPanel/DialogTemplate_Body_CBM/GridContainer/MidContainer/ContentContainer/Label

#

func _ready():
	visible = false
	_initialize_gradient_background()
	_initialize_warning_label()
	_initialize_game_settings_signal()

func _initialize_gradient_background():
	var gradient = LightTextureConstructor.construct_or_get_gradient_two_color(Color(0, 0, 0, 0), Color(255/255.0, 128/255.0, 0/255.0, 0.2))
	var gradient_texture_2d = LightTextureConstructor.construct_or_get_rect_gradient_texture(Vector2(960, 540), false) 
	
	gradient_texture_2d.gradient = gradient
	gradient_background.texture = gradient_texture_2d

func _initialize_warning_label():
	#var orig_text = warning_label.text
	original_warning_text = warning_label.text
	#warning_label.text = orig_text % [InputMap.get_action_list("rewind")[0].as_text()]
	_update_warning_label_text()

func _update_warning_label_text():
	warning_label.text = original_warning_text % GameSettingsManager.get_game_control_hotkey__as_string("rewind")


func _initialize_game_settings_signal():
	GameSettingsManager.connect("game_control_hotkey_changed", self, "_on_game_control_hotkey_changed")

func _on_game_control_hotkey_changed(arg_action_name, arg_old, arg_new):
	if arg_action_name == "rewind":
		_update_warning_label_text()

##

func show_self():
	if !visible and _show_tweener == null:
		if _hide_tweener != null:
			_hide_tweener.kill()
			_hide_tweener = null
		
		modulate.a = 0
		visible = true
		_show_tweener = create_tween()
		_show_tweener.tween_property(self, "modulate:a", 1.0, 0.5)
		_show_tweener.connect("finished", self, "_on_show_tweener_finished")
		
		AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_PDAR_PlayerReachedOutOfBoundsOfMap, 1.0, null)

func _on_show_tweener_finished():
	_show_tweener = null



func hide_self():
	if visible and _hide_tweener == null:
		if _show_tweener != null:
			_show_tweener.kill()
			_show_tweener = null
		
		_hide_tweener = create_tween()
		_hide_tweener.tween_property(self, "modulate:a", 0.0, 0.5)
		_hide_tweener.connect("finished", self, "_on_hide_tweener_finished")

func _on_hide_tweener_finished():
	_hide_tweener = null
	
	visible = false


