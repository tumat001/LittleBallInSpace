extends MarginContainer


var curr_coin_count : int setget set_curr_coin_count
var max_coin_count : int setget set_max_coin_count

#

onready var coin_label = $Control/CoinLabel

#

func _ready():
	_update_label_display()


func set_curr_coin_count(arg_val):
	curr_coin_count = arg_val
	
	if is_inside_tree():
		_update_label_display()

func set_max_coin_count(arg_val):
	max_coin_count = arg_val
	
	if is_inside_tree():
		_update_label_display()


func _update_label_display():
	if curr_coin_count >= 100 or max_coin_count >= 100:
		coin_label.text = "%s/%s" % [curr_coin_count, max_coin_count]
		
	else:
		coin_label.text = "%s / %s" % [curr_coin_count, max_coin_count]
		
	

#######

func configure_self_to_monitor_coin_status_for_level(arg_level_id):
	var coins_collected_in_level = GameSaveManager.get_coin_ids_collected_in_level(arg_level_id)
	var total_coins_in_level = StoreOfLevels.get_coin_count_for_level(arg_level_id)
	
	set_curr_coin_count(coins_collected_in_level)
	set_max_coin_count(total_coins_in_level)
	
	GameSaveManager.connect("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed")

func _on_coin_collected_for_level_changed(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id):
	set_curr_coin_count(arg_coin_ids_collected_for_level.size())


#

func configure_self_to_monitor_coin_status_for_whole_game():
	var curr_coin_total = GameSaveManager.get_total_coin_collected_count()
	var total_coins = StoreOfLevels.get_total_coin_count()
	
	set_curr_coin_count(curr_coin_total)
	set_max_coin_count(total_coins)
	
	GameSaveManager.connect("coin_collected_for_level_changed", self, "_on_coin_collected_for_level_changed__total")

func _on_coin_collected_for_level_changed__total(arg_coin_ids_collected_for_level, arg_coin_id_collected, arg_level_id):
	set_curr_coin_count(GameSaveManager.get_total_coin_collected_count())
	

