tool
extends "res://MiscRelated/EnvironmentEventPlayerRelated/BaseEnvEventPlayer/BaseEnvEventPlayer_Looping.gd"


const SpriteComponentPool = preload("res://MiscRelated/PoolRelated/Imps/SpriteComponentPool.gd")
const EnvParticle_ElecSpark = preload("res://MiscRelated/EnvironmentEventPlayerRelated/Imps/EnvEvent_ElecSparks/Subs/EnvParticle_ElecSpark.gd")
const EnvParticle_ElecSpark_Scene = preload("res://MiscRelated/EnvironmentEventPlayerRelated/Imps/EnvEvent_ElecSparks/Subs/EnvParticle_ElecSpark.tscn")

#

export(int) var spark_count_min : int = 2
export(int) var spark_count_max : int = 5

export(float, 0.0, 360) var angle_deg_start : float = 0 setget set_angle_deg_start
export(float, 0.0, 360) var angle_deg_end : float = 360 setget set_angle_deg_end

export(float) var dist_min : float = 16.0
export(float) var dist_max : float = 40.0

#

var spark_sprites_compo_pool : SpriteComponentPool

#

func _ready():
	_init_sprites_compo_pool()

func _init_sprites_compo_pool():
	spark_sprites_compo_pool = SpriteComponentPool.new()
	spark_sprites_compo_pool.node_to_listen_for_queue_free = self
	spark_sprites_compo_pool.node_to_parent = self
	spark_sprites_compo_pool.func_name_for_create_resource = "_create_spark_particle__for_pool"
	spark_sprites_compo_pool.source_of_create_resource = self
	

func _create_spark_particle__for_pool():
	var particle = EnvParticle_ElecSpark_Scene.instance()
	
	return particle


#

func set_angle_deg_start(arg_val):
	angle_deg_start = arg_val
	
	if Engine.editor_hint:
		update()

func set_angle_deg_end(arg_val):
	angle_deg_end = arg_val
	
	if Engine.editor_hint:
		update()


func _draw():
	if Engine.editor_hint:
		var vec_line = Vector2(30, 0)
		var vec_line_start = vec_line.rotated(deg2rad(angle_deg_start))
		draw_line(Vector2(0, 0), vec_line_start, Color(1, 1, 0, 0.5), 3)
		
		var vec_line_end = vec_line.rotated(deg2rad(angle_deg_end))
		draw_line(Vector2(0, 0), vec_line_end, Color(1, 1, 0, 1), 3)
		

##

func _execute_environment_action__loop_wait_finished():
	for i in SingletonsAndConsts.non_essential_rng.randi_range(spark_count_min, spark_count_max):
		_create_and_show_spark_particle()
	
	AudioManager.helper__play_sound_effect__2d__lower_volume_based_on_dist(StoreOfAudio.AudioIds.SFX_Environment_ElectricSpark_01, global_position, 1, null, AudioManager.MaskLevel.Minor_SoundFX)


func _create_and_show_spark_particle():
	var spark_particle : EnvParticle_ElecSpark = spark_sprites_compo_pool.get_or_create_resource_from_pool()
	
	spark_particle.global_position = global_position
	
	spark_particle.lifetime_min = 0.8
	spark_particle.lifetime_max = 1.1
	spark_particle.angle_rad_start = deg2rad(angle_deg_start)
	spark_particle.angle_rad_end = deg2rad(angle_deg_end)
	spark_particle.dist_min = dist_min
	spark_particle.dist_max = dist_max
	spark_particle.randomize_all_and_start()


