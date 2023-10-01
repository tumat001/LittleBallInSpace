extends Node2D

const CircleDrawNode = preload("res://MiscRelated/DrawRelated/CircleDrawNode/CircleDrawNode.gd")

#

signal draw_of_capture_finished()

#

const DRAWER_FIRST__MAX_RADIUS = 75.0
const DRAWER_FIRST__DURATION = 1.50

const DRAWER_SECOND__MAX_RADIUS = 150.0
const DRAWER_SECOND__INITIAL_DELAY = 0.75
const DRAWER_SECOND__DURATION = 2.5


#

onready var drawer_first = $Drawer_First
onready var drawer_second = $Drawer_Second

#

var _is_in_playing : bool
var _current_pca

var _tweener__sequence_of_events : SceneTreeTween
var _tweener__drawer_first : SceneTreeTween
var _tweener__drawer_second : SceneTreeTween

var _current_draw_param__first : CircleDrawNode.DrawParams
var _current_draw_param__second : CircleDrawNode.DrawParams


#

func play_captured_anim__for_PCA(arg_pca):
	_current_pca = arg_pca
	_is_in_playing = true
	
	if !_current_pca.is_connected("region_area_uncaptured", self, "_on_curr_pca__region_area_uncaptured"):
		_current_pca.connect("region_area_uncaptured", self, "_on_curr_pca__region_area_uncaptured")
	
	_start_drawer__first()
	_kill_tweener__with_name("_tweener__sequence_of_events")
	_tweener__sequence_of_events = create_tween()
	_tweener__sequence_of_events.tween_interval(DRAWER_SECOND__INITIAL_DELAY)
	_tweener__sequence_of_events.tween_callback(self, "_start_drawer__second")


func _start_drawer__first():
	_instant_end_draw__first()
	
	var draw_param = CircleDrawNode.DrawParams.new()
	
	draw_param.center_pos = global_position
	draw_param.current_radius = 0
	draw_param.max_radius = DRAWER_FIRST__MAX_RADIUS
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(30/255.0, 217/255.0, 2/255.0, 0.2)
	
	draw_param.outline_color = Color(30/255.0, 217/255.0, 2/255.0, 0.2)
	draw_param.outline_width = 0
	
	draw_param.lifetime_of_draw = DRAWER_FIRST__DURATION
	draw_param.has_lifetime = true
	
	drawer_first.add_draw_param(draw_param)
	_current_draw_param__first = draw_param
	
	##
	
	_tweener__drawer_first = create_tween()
	_tweener__drawer_first.tween_property(draw_param, "current_radius", draw_param.max_radius, DRAWER_FIRST__DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	

func _instant_end_draw__first():
	if _current_draw_param__first != null:
		drawer_first.remove_draw_param(_current_draw_param__first)
	
	_kill_tweener__with_name("_tweener__drawer_first")


func _start_drawer__second():
	_instant_end_draw__second()
	
	var draw_param = CircleDrawNode.DrawParams.new()
	
	draw_param.center_pos = global_position
	draw_param.current_radius = 0
	draw_param.max_radius = DRAWER_SECOND__MAX_RADIUS
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color("#42A6FD4D")
	
	draw_param.outline_color = Color("#42A6FD4D")
	draw_param.outline_width = 0
	
	draw_param.lifetime_of_draw = DRAWER_SECOND__DURATION
	draw_param.has_lifetime = true
	
	drawer_first.add_draw_param(draw_param)
	_current_draw_param__second = draw_param
	
	##
	
	_tweener__drawer_second = create_tween()
	_tweener__drawer_second.tween_property(draw_param, "current_radius", draw_param.max_radius, DRAWER_SECOND__DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tweener__drawer_second.tween_callback(self, "_on_last_drawer_finished")

func _instant_end_draw__second():
	if _current_draw_param__second != null:
		drawer_second.remove_draw_param(_current_draw_param__second)
	
	_kill_tweener__with_name("_tweener__drawer_second")

#

func _kill_tweener__with_name(arg_tweener_name : String):
	var tweener : SceneTreeTween = get(arg_tweener_name)
	
	if tweener != null and tweener.is_valid():
		tweener.kill()
	
	set(arg_tweener_name, null)

#

func _on_curr_pca__region_area_uncaptured():
	instant_end_captured_anim_for_curr_pca()


func instant_end_captured_anim_for_curr_pca():
	_kill_tweener__with_name("_tweener__sequence_of_events")
	_instant_end_draw__first()
	_instant_end_draw__second()
	
	if _current_pca.is_connected("region_area_uncaptured", self, "_on_curr_pca__region_area_uncaptured"):
		_current_pca.disconnect("region_area_uncaptured", self, "_on_curr_pca__region_area_uncaptured")
	
	_is_in_playing = false
	_current_pca = null

func _on_last_drawer_finished():
	instant_end_captured_anim_for_curr_pca()
	emit_signal("draw_of_capture_finished")


