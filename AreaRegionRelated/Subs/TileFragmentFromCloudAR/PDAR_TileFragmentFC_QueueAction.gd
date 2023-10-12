extends "res://AreaRegionRelated/Subs/PlayerDetectionAreaRegion/PlayerDetectionAreaRegion.gd"


enum ActionType {
	QUEUE_ADD = 0,
	QUEUE_FREE = 1,
}
export(ActionType) var action_type : int
export(float) var action_within_duration_sec : float = 0.0

export(NodePath) var path_of_tile_cloud_container : NodePath

#

func _init():
	triggerable_only_once = true
	

#

func _ready():
	triggerable_only_once = true
	connect("player_entered_in_area", self, "_on_player_entered_in_area__TFFC", [], CONNECT_ONESHOT)


func _on_player_entered_in_area__TFFC():
	var tile_cloud_container = get_node(path_of_tile_cloud_container)
	
	for tile_cloud in tile_cloud_container.get_children():
		if action_type == ActionType.QUEUE_ADD:
			#tile_cloud.summon_particles(action_within_duration_sec)
			#if tile_cloud.has_method("summon_particles"):
			tile_cloud.call_deferred("summon_particles", action_within_duration_sec)
		elif action_type == ActionType.QUEUE_FREE:
			#tile_cloud.queue_free_all_fragments(action_within_duration_sec)
			#if tile_cloud.has_method("queue_free_all_fragments"):
			tile_cloud.call_deferred("queue_free_all_fragments", action_within_duration_sec)
			



