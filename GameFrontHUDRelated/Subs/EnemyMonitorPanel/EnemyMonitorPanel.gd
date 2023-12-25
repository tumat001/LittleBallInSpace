extends MarginContainer

const EnemyAliveStatusMonitor = preload("res://ObjectsRelated/Objects/ObjectBehaviorCompos/EnemyRelated/EnemyAliveStatusMonitor.gd")

#

signal current_enemy_alive_status_monitor_changed(arg_curr)


#

const MODULATE__GREEN_GLOW__NON_ZERO = Color("#02ED3B")
const MODULATE__GREEN_GLOW__AS_ZERO = Color("#77FE97")

const MODULATE__GREEN_GLOW__NON_ZERO__ZERO_ALPHA = Color("#02ED3B00")
const MODULATE__GREEN_GLOW__AS_ZERO__ZERO_ALPHA = Color("#77FE9700")

const MODULATE__NORMAL_LABEL = Color(1, 1, 1, 1)

const TWEEN_DURATION__IN__AS_ZERO = 0.75
const TWEEN_DURATION__IN__NON_ZERO = 0.3
const TWEEN_DURATION__OUT__AS_ZERO = 3.0
const TWEEN_DURATION__OUT__NON_ZERO = 0.45

#

const VIS_TWEEN_DURATION__LONG = 1.25
const VIS_TWEEN_DURATION__SHORT = 0.25

#

var _current_tween_glow__label : SceneTreeTween
var _current_tween_glow__border : SceneTreeTween

#

const LAST_REGISTERED_COUNT__NOT_YET_ACTIVATED = -1

var current_enemy_alive_status_monitor : EnemyAliveStatusMonitor
var _last_registered_enemy_count : int = LAST_REGISTERED_COUNT__NOT_YET_ACTIVATED

#

onready var glow_border = $GlowBorder
onready var enemy_count_label = $Control/EnemyCountLabel

#

func _ready():
	glow_border.modulate.a = 0
	enemy_count_label.modulate.a = 1
	
	visible = false

#####

func make_self_visible__using_tween(arg_tween_duration = VIS_TWEEN_DURATION__SHORT):
	visible = true
	modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, arg_tween_duration)

func make_self_visible():
	visible = true


func make_self_invisible__using_tween(arg_tween_duration = VIS_TWEEN_DURATION__SHORT):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, arg_tween_duration)
	tween.call("_tween_mod_a_to_zero_finished__for_visibility")

func _tween_mod_a_to_zero_finished__for_visibility():
	visible = false


func make_self_invisible():
	visible = false

#####

func register_enemy_alive_status_monitor(arg_monitor : EnemyAliveStatusMonitor):
	if current_enemy_alive_status_monitor == null:
		current_enemy_alive_status_monitor = arg_monitor
		
		arg_monitor.connect("enemy_alive_count_changed", self, "_on_enemy_alive_count_changed")
		arg_monitor.connect("enemy_total_count_changed", self, "_on_enemy_total_count_changed")
		
		_update_enemy_count_label()
		emit_signal("current_enemy_alive_status_monitor_changed", arg_monitor)


func unregister_enemy_alive_status_monitor():
	_stop_any_tween_glow()
	
	if current_enemy_alive_status_monitor != null:
		current_enemy_alive_status_monitor.disconnect("enemy_alive_count_changed", self, "_on_enemy_alive_count_changed")
		current_enemy_alive_status_monitor.disconnect("enemy_total_count_changed", self, "_on_enemy_total_count_changed")
		
		current_enemy_alive_status_monitor = null
		
		emit_signal("current_enemy_alive_status_monitor_changed", null)


#

func _update_enemy_count_label():
	_enemy_count_label__glow_based_on_number_changes()
	
	##
	
	var text_to_use
	if current_enemy_alive_status_monitor.enemy_alive_count >= 100 or current_enemy_alive_status_monitor.enemy_total_count >= 100:
		text_to_use = "%s/%s" % [current_enemy_alive_status_monitor.enemy_alive_count, current_enemy_alive_status_monitor.enemy_total_count]
	else:
		text_to_use = "%s / %s" % [current_enemy_alive_status_monitor.enemy_alive_count, current_enemy_alive_status_monitor.enemy_total_count]
	
	enemy_count_label.text = text_to_use

func _enemy_count_label__glow_based_on_number_changes():
	if _last_registered_enemy_count == LAST_REGISTERED_COUNT__NOT_YET_ACTIVATED:
		_last_registered_enemy_count = current_enemy_alive_status_monitor.enemy_alive_count
		return
	
	if current_enemy_alive_status_monitor.enemy_alive_count < _last_registered_enemy_count:
		if current_enemy_alive_status_monitor.enemy_alive_count == 0:
			_tween_green_glow__as_reached_to_zero()
			
		else:
			_tween_green_glow__count_decreased()
			
		
	else:
		_stop_any_tween_glow()
	
	_last_registered_enemy_count = current_enemy_alive_status_monitor.enemy_alive_count



func _tween_green_glow__as_reached_to_zero():
	glow_border.modulate = MODULATE__GREEN_GLOW__AS_ZERO__ZERO_ALPHA
	_current_tween_glow__border = create_tween()
	_current_tween_glow__border.tween_property(glow_border, "modulate", MODULATE__GREEN_GLOW__AS_ZERO, TWEEN_DURATION__IN__AS_ZERO)
	_current_tween_glow__border.tween_property(glow_border, "modulate", MODULATE__GREEN_GLOW__AS_ZERO__ZERO_ALPHA, TWEEN_DURATION__OUT__AS_ZERO)
	
	#
	enemy_count_label.modulate = MODULATE__NORMAL_LABEL
	_current_tween_glow__label = create_tween()
	_current_tween_glow__label.tween_property(enemy_count_label, "modulate", MODULATE__GREEN_GLOW__AS_ZERO, TWEEN_DURATION__IN__AS_ZERO)
	_current_tween_glow__label.tween_property(enemy_count_label, "modulate", MODULATE__NORMAL_LABEL, TWEEN_DURATION__OUT__AS_ZERO)
	

func _tween_green_glow__count_decreased():
	glow_border.modulate = MODULATE__GREEN_GLOW__NON_ZERO__ZERO_ALPHA
	_current_tween_glow__border = create_tween()
	_current_tween_glow__border.tween_property(glow_border, "modulate", MODULATE__GREEN_GLOW__NON_ZERO, TWEEN_DURATION__IN__NON_ZERO)
	_current_tween_glow__border.tween_property(glow_border, "modulate", MODULATE__GREEN_GLOW__NON_ZERO__ZERO_ALPHA, TWEEN_DURATION__OUT__NON_ZERO)
	
	#
	enemy_count_label.modulate = MODULATE__NORMAL_LABEL
	_current_tween_glow__label = create_tween()
	_current_tween_glow__label.tween_property(enemy_count_label, "modulate", MODULATE__GREEN_GLOW__NON_ZERO, TWEEN_DURATION__IN__NON_ZERO)
	_current_tween_glow__label.tween_property(enemy_count_label, "modulate", MODULATE__NORMAL_LABEL, TWEEN_DURATION__OUT__NON_ZERO)
	


func _stop_any_tween_glow():
	if _current_tween_glow__border != null and _current_tween_glow__border.is_valid():
		_current_tween_glow__border.custom_step(999999)
	
	if _current_tween_glow__label != null and _current_tween_glow__label.is_valid():
		_current_tween_glow__label.custom_step(999999)
	

####

func _on_enemy_alive_count_changed(arg_val):
	_update_enemy_count_label()

func _on_enemy_total_count_changed(arg_val):
	_update_enemy_count_label()



#####

