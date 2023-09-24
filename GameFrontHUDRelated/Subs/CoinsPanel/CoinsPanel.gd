extends MarginContainer


var curr_coin_count : int setget set_curr_coin_count
var max_coin_count : int setget set_max_coin_count

enum DisplayType {
	IS_FOUND = 0,
	NUMERICAL = 1,
}
var display_type : int = DisplayType.IS_FOUND setget set_display_type

var instant_change_tweener_transition : bool

#

var _is_found : bool

var _star_texture_rect_mod_tweener : SceneTreeTween
var _rainbow_rect_mod_a_tweener : SceneTreeTween


#

const DEFAULT_DURATION_OF_TWEENERS : float = 1.25

const MODULATE_FOUND__STAR = Color(1,1,1,1)
const MODULATE_NOT_FOUND__STAR = Color(0.3, 0.3, 0.3, 0.8)


const MOD_A__RAINBOW_RECT__COMPLETE : float = 0.39
const MOD_A__RAINBOW_RECT__NOT_COMPLETE : float = 0.0

#

onready var coin_label = $Control/CoinLabel
onready var found_label = $Control/FoundLabel

onready var star_texture_rect = $Control/StarTextureRect

onready var rainbow_color_rect = $Control/RainbowColorRect

#

func _ready():
	rainbow_color_rect.modulate.a = 0
	
	_update_display(true)


func set_curr_coin_count(arg_val):
	curr_coin_count = arg_val
	
	if is_inside_tree():
		_update_display()

func set_max_coin_count(arg_val):
	max_coin_count = arg_val
	
	if is_inside_tree():
		_update_display()

func set_display_type(arg_val):
	display_type = arg_val
	
	if is_inside_tree():
		_update_display()


func _update_display(arg_force_update = false):
	if display_type == DisplayType.IS_FOUND:
		_update_display__is_found_type(arg_force_update)
	elif display_type == DisplayType.NUMERICAL:
		_update_display__numerical()
	
	



func _update_display__is_found_type(arg_force_update):
	coin_label.visible = false
	
	var old_val = _is_found
	if (curr_coin_count == 1 and max_coin_count == 1) or max_coin_count == 0:
		_is_found = true
	else:
		_is_found = false
	
	
	if old_val != _is_found or arg_force_update:
		if _is_found:
			found_label.visible = true
			_tween_star_texture_rect_modulate(MODULATE_FOUND__STAR)
			_tween_rainbow_color_rect_mod_a(MOD_A__RAINBOW_RECT__COMPLETE)
		else:
			found_label.visible = false
			_tween_star_texture_rect_modulate(MODULATE_NOT_FOUND__STAR)
			_tween_rainbow_color_rect_mod_a(MOD_A__RAINBOW_RECT__NOT_COMPLETE)

func _tween_star_texture_rect_modulate(arg_new_val : Color):
	_kill_existing_star_texture_rect_mod_tweener()
	
	var duration = DEFAULT_DURATION_OF_TWEENERS
	if instant_change_tweener_transition:
		duration = 0
	_star_texture_rect_mod_tweener = create_tween()
	_star_texture_rect_mod_tweener.tween_property(star_texture_rect, "modulate", arg_new_val, duration)

func _kill_existing_star_texture_rect_mod_tweener():
	if _star_texture_rect_mod_tweener != null and _star_texture_rect_mod_tweener.is_valid():
		_star_texture_rect_mod_tweener.kill()


func _tween_rainbow_color_rect_mod_a(arg_new_val : float, arg_always_instant : bool = false):
	_kill_existing_rainbow_color_rect_mod_a_tweener()
	
	var duration = DEFAULT_DURATION_OF_TWEENERS
	if instant_change_tweener_transition or arg_always_instant:
		duration = 0
	_rainbow_rect_mod_a_tweener = create_tween()
	_rainbow_rect_mod_a_tweener.tween_property(rainbow_color_rect, "modulate:a", arg_new_val, duration)

func _kill_existing_rainbow_color_rect_mod_a_tweener():
	if _rainbow_rect_mod_a_tweener != null and _rainbow_rect_mod_a_tweener.is_valid():
		_rainbow_rect_mod_a_tweener.kill()



func _update_display__numerical():
	found_label.visible = false
	coin_label.visible = true
	
	if curr_coin_count >= 100 or max_coin_count >= 100:
		coin_label.text = "%s/%s" % [curr_coin_count, max_coin_count]
		
	else:
		coin_label.text = "%s / %s" % [curr_coin_count, max_coin_count]
	
	_kill_existing_star_texture_rect_mod_tweener()
	star_texture_rect.modulate = MODULATE_FOUND__STAR
	
	
	if curr_coin_count == max_coin_count:
		_tween_rainbow_color_rect_mod_a(MOD_A__RAINBOW_RECT__COMPLETE)
	else:
		_tween_rainbow_color_rect_mod_a(MOD_A__RAINBOW_RECT__NOT_COMPLETE)


#######

func configure_self_to_monitor_coin_status_for_curr_level_tentative(arg_connect_with_signals : bool = true):
	var coin_count_collected_in_level = GameSaveManager.get_tentative_coin_ids_collected_in_curr_level_id__count()
	var total_coins_in_level = StoreOfLevels.get_coin_count_for_level(SingletonsAndConsts.current_base_level_id)
	
	set_curr_coin_count(coin_count_collected_in_level)
	set_max_coin_count(total_coins_in_level)
	
	if !GameSaveManager.is_connected("tentative_coin_ids_collected_changed__for_curr_level", self, "_on_coin_collected_for_level_changed__tentative"):
		GameSaveManager.connect("tentative_coin_ids_collected_changed__for_curr_level", self, "_on_coin_collected_for_level_changed__tentative")

func _on_coin_collected_for_level_changed__tentative(arg_tentative_coin_ids_collected_in_curr_level_id, arg_is_collected, arg_is_all_collected):
	set_curr_coin_count(arg_tentative_coin_ids_collected_in_curr_level_id.size())


##

func configure_self_to_monitor_coin_status_for_level(arg_level_id, arg_connect_with_signals : bool = true):
	var coins_collected_in_level = GameSaveManager.get_coin_ids_collected_in_level(arg_level_id)
	var total_coins_in_level = StoreOfLevels.get_coin_count_for_level(arg_level_id)
	
	set_curr_coin_count(coins_collected_in_level.size())
	set_max_coin_count(total_coins_in_level)
	
	if !GameSaveManager.is_connected("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed"):
		GameSaveManager.connect("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed")

func _on_coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id):
	set_curr_coin_count(arg_coin_ids_collected_for_level.size())


###

func configure_self_to_monitor_coin_status_for_whole_game():
	var curr_coin_total = GameSaveManager.get_total_coin_collected_count()
	var total_coins = StoreOfLevels.get_total_coin_count__unhidden()
	
	set_curr_coin_count(curr_coin_total)
	set_max_coin_count(total_coins)
	
	if !GameSaveManager.is_connected("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed__total"):
		GameSaveManager.connect("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed__total")
	
	if !StoreOfLevels.is_connected("hidden_levels_state_changed", self, "_on_hidden_levels_state_changed"):
		StoreOfLevels.connect("hidden_levels_state_changed", self, "_on_hidden_levels_state_changed", [], CONNECT_DEFERRED)

func _on_coin_collected_for_level_changed__total(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id):
	set_curr_coin_count(GameSaveManager.get_total_coin_collected_count())
	

func _on_hidden_levels_state_changed():
	set_max_coin_count(StoreOfLevels.get_total_coin_count__unhidden())

