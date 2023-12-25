extends Reference


signal enemy_alive_count_changed(arg_alive_count)
signal enemy_total_count_changed(arg_total_count)

signal all_enemies_defeated()
signal all_enemies_undefeated()

# this can change even if the alive count has not. ex: one got alived while the other dies at the same frame (maybe?)
signal enemies_alive_changed(arg_enemies)

signal last_standing_enemy_changed(arg_enemy)

##

var enemies_to_monitor : Array
var enemy_count_queued_free : int

var enemy_alive_count : int
var enemy_total_count : int

var all_alive_enemies : Array


var last_standing_enemy

#

var audio_id_for_last_enemy_death : int = StoreOfAudio.AudioIds.SFX_Enemy_Last_DeathExplode


###

func add_enemy_to_monitor(arg_enemy):
	enemies_to_monitor.append(arg_enemy)
	
	arg_enemy.connect("alive_status_changed", self, "_on_enemy_alive_status_changed", [arg_enemy])
	arg_enemy.connect("tree_exiting", self, "_on_enemy_queue_free", [arg_enemy])
	
	update_based_on_enemy_alive_and_count()
	update_enemy_total_count()

#

func _on_enemy_alive_status_changed(arg_is_alive, arg_enemy):
	update_based_on_enemy_alive_and_count()

func _on_enemy_queue_free(arg_enemy):
	enemy_count_queued_free += 1
	update_based_on_enemy_alive_and_count()



func update_based_on_enemy_alive_and_count():
	var old_alive_enemies_arr = all_alive_enemies.duplicate()
	all_alive_enemies.clear()
	
	var calced_alive_counter : int = 0
	for enemy in enemies_to_monitor:
		if enemy.is_robot_alive():
			calced_alive_counter += 1
			all_alive_enemies.append(enemy)
	
	if all_alive_enemies.size() == 1:
		_set_last_standing_enemy(all_alive_enemies[0])
	else:
		_set_last_standing_enemy(null)
	
	var old_val = enemy_alive_count
	enemy_alive_count = calced_alive_counter
	if old_val != enemy_alive_count:
		emit_signal("enemy_alive_count_changed", enemy_alive_count)
	
	if old_alive_enemies_arr != all_alive_enemies:
		emit_signal("enemies_alive_changed", all_alive_enemies)

func update_enemy_total_count():
	var calced_enemy_total : int = 0
	calced_enemy_total += enemies_to_monitor.size()
	calced_enemy_total += enemy_count_queued_free
	
	var old_val = enemy_total_count
	enemy_total_count = calced_enemy_total
	if old_val != enemy_total_count:
		emit_signal("enemy_total_count_changed", enemy_total_count)
	

###############

func get_alive_enemies():
	return all_alive_enemies

#

func _set_last_standing_enemy(arg_enemy):
	var old_enemy = last_standing_enemy
	if is_instance_valid(old_enemy) and old_enemy != arg_enemy:
		_unconfig_enemy_as_last_standing(old_enemy)
	
	if old_enemy != arg_enemy:
		if is_instance_valid(arg_enemy):
			_config_enemy_as_last_standing(arg_enemy)
		
		emit_signal("last_standing_enemy_changed", arg_enemy)
	
	last_standing_enemy = arg_enemy


func _config_enemy_as_last_standing(arg_enemy):
	_set_enemy_audio_id_override_on_death__to_last_death(arg_enemy)

func _unconfig_enemy_as_last_standing(arg_enemy):
	_unset_enemy_audio_id_override_on_death(arg_enemy)


#

func _set_enemy_audio_id_override_on_death__to_last_death(arg_enemy):
	arg_enemy.on_death__audio_id_to_play__override = audio_id_for_last_enemy_death

func _unset_enemy_audio_id_override_on_death(arg_enemy):
	arg_enemy.on_death__audio_id_to_play__override = -1



