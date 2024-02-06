extends Node


const AnimSpriteComponentPool = preload("res://MiscRelated/PoolRelated/Imps/AnimSpriteComponentPool.gd")

const LaunchBallPickupableParticle = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Particles/LaunchBallPickupableParticle.gd")
const LaunchBallPickupableParticle_Scene = preload("res://ObjectsRelated/Pickupables/Subs/LaunchBalls/Particles/LaunchBallPickupableParticle.tscn")

#const BatteryPickupableParticle = preload("res://ObjectsRelated/Pickupables/Subs/Battery/Particles/BatteryPickupableParticle.gd")
#const BatteryPickupableParticle_Scene = preload("res://ObjectsRelated/Pickupables/Subs/Battery/Particles/BatteryPickupableParticle.tscn")

#

onready var launch_ball_circle_draw_node = $LaunchBallCircleDrawNode
onready var battery_circle_draw_node = $BatteryCircleDraw
onready var wrench_circle_draw_node = $WrenchCircleDraw


#

var ball_pickup_particles_pool_component : AnimSpriteComponentPool
#var battery_pickup_particles_pool_component : AnimSpriteComponentPool


#

func _enter_tree():
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster = self
	

func _exit_tree():
	SingletonsAndConsts.current_game_front_hud__other_hud_non_screen_hoster = null

#

func _ready():
	_init_all_launch_ball_pickup_relateds()
	#_init_all_battery_pickup_relateds()

##

func _init_all_launch_ball_pickup_relateds():
	ball_pickup_particles_pool_component = AnimSpriteComponentPool.new()
	ball_pickup_particles_pool_component.node_to_listen_for_queue_free = self
	ball_pickup_particles_pool_component.node_to_parent = self
	ball_pickup_particles_pool_component.func_name_for_create_resource = "_create_ball_pickup_particle__for_pool"
	ball_pickup_particles_pool_component.source_of_create_resource = self
	ball_pickup_particles_pool_component.reclaim_resource_on_anim_finished = false

func _create_ball_pickup_particle__for_pool():
	var particle = LaunchBallPickupableParticle_Scene.instance()
	
	
	return particle

#

func play_launch_ball_pickup_particle_effects(arg_node : Node2D, arg_initial_offset : Vector2, arg_radius_from_initial_pos : float, arg_anim_name : String,
		arg_delay_for_final_dest_tween : float) -> LaunchBallPickupableParticle:
	var particle : LaunchBallPickupableParticle = ball_pickup_particles_pool_component.get_or_create_resource_from_pool()
	particle.visible = true
	particle.modulate.a = 0.6
	
	var node_pos_on_screen : Vector2 = arg_node.get_global_transform_with_canvas().origin
	particle.global_position = node_pos_on_screen + arg_initial_offset
	
	##
	var arg_first_dest_pos_modi = Vector2(arg_radius_from_initial_pos, 0).rotated(arg_initial_offset.angle())
	
	var first_dest_pos = node_pos_on_screen + arg_first_dest_pos_modi
	var final_dest_pos = SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel.get_pos_of_center_ball_hud_image()
	particle.change_anim_to_anim_name(arg_anim_name)
	particle.play_particle_effect_actions(first_dest_pos, final_dest_pos, arg_delay_for_final_dest_tween)
	
	#
	
	return particle


func play_orange_ring__pickup_of_launch_ball(arg_origin, arg_initial_radius : float, arg_final_radius : float, arg_duration_to_full_radius, arg_mod_a):
	var arg_additional_lifetime = 0.2
	
	var draw_param = launch_ball_circle_draw_node.DrawParams.new()
	
	draw_param.center_pos = arg_origin
	draw_param.current_radius = arg_initial_radius
	draw_param.max_radius = 9999
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = Color(255/255.0, 128/255.0, 0.0, arg_mod_a)
	draw_param.outline_width = 2
	
	draw_param.lifetime_of_draw = arg_duration_to_full_radius + arg_additional_lifetime
	draw_param.has_lifetime = true
	
	draw_param.lifetime_to_start_transparency = arg_duration_to_full_radius
	
	launch_ball_circle_draw_node.add_draw_param(draw_param)
	
	#
	
	var tweener = create_tween()
	tweener.tween_property(draw_param, "current_radius", arg_final_radius, arg_duration_to_full_radius).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweener.tween_property(draw_param, "current_radius", arg_final_radius + (arg_final_radius / 3.0), arg_additional_lifetime)


#################

#func _init_all_battery_pickup_relateds():
#	battery_pickup_particles_pool_component = AnimSpriteComponentPool.new()
#	battery_pickup_particles_pool_component.node_to_listen_for_queue_free = self
#	battery_pickup_particles_pool_component.node_to_parent = self
#	battery_pickup_particles_pool_component.func_name_for_create_resource = "_create_battery_pickup_particle__for_pool"
#	battery_pickup_particles_pool_component.source_of_create_resource = self
#	battery_pickup_particles_pool_component.reclaim_resource_on_anim_finished = false

#func _create_battery_pickup_particle__for_pool():
#	var particle = BatteryPickupableParticle_Scene.instance()
#
#
#	return particle



#func play_battery_pickup_particle_effects(arg_pos_on_screen : Vector2, arg_anim_name : String,
#		arg_revolutions : int, arg_starting_radius, arg_ending_radius):
#
#	var particle : BatteryPickupableParticle = battery_pickup_particles_pool_component.get_or_create_resource_from_pool()
#	particle.visible = true
#	particle.modulate.a = 0.6
#
#	particle.global_position = arg_pos_on_screen
#
#	particle.change_anim_to_anim_name(arg_anim_name)
#	particle.play_particle_effect_actions(arg_revolutions, arg_starting_radius, arg_ending_radius)
#
#func play_battery_pickup_particle_effects__multiple(arg_pos_on_screen : Vector2,
#		arg_rand_revolutions_min : int, arg_rand_revolutions_max : int,
#		arg_rand_starting_radius_min : float, arg_rand_starting_radius_max : float,
#		arg_rand_ending_radius_min : float, arg_rand_ending_radius_max : float,
#		arg_count : int, arg_delay_between_each_particle : float):
#
#	var non_essential_rng : RandomNumberGenerator = SingletonsAndConsts.non_essential_rng
#
#	var tweener = create_tween()
#	for i in arg_count:
#		var anim_name : String = StoreOfRNG.randomly_select_one_element(BatteryPickupableParticle.all_anim_names, non_essential_rng)
#		var revolution = non_essential_rng.randi_range(arg_rand_revolutions_min, arg_rand_revolutions_max)
#		var starting_rad = non_essential_rng.randf_range(arg_rand_starting_radius_min, arg_rand_starting_radius_max)
#		var ending_rad = non_essential_rng.randf_range(arg_rand_ending_radius_min, arg_rand_ending_radius_max)
#
#		tweener.tween_callback(self, "play_battery_pickup_particle_effects", [arg_pos_on_screen, anim_name, revolution, starting_rad, ending_rad]).set_delay(arg_delay_between_each_particle)



func play_yellow_ring__pickup_of_battery(arg_origin, arg_initial_radius : float, arg_final_radius : float, arg_duration_to_full_radius, arg_mod_a):
	var arg_additional_lifetime = 0.2
	
	var draw_param = battery_circle_draw_node.DrawParams.new()
	
	draw_param.center_pos = arg_origin
	draw_param.current_radius = arg_initial_radius
	draw_param.max_radius = 9999
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = Color(218/255.0, 164/255.0, 2/255.0, arg_mod_a)
	draw_param.outline_width = 2
	
	draw_param.lifetime_of_draw = arg_duration_to_full_radius + arg_additional_lifetime
	draw_param.has_lifetime = true
	
	draw_param.lifetime_to_start_transparency = arg_duration_to_full_radius
	
	battery_circle_draw_node.add_draw_param(draw_param)
	
	#
	
	var tweener = create_tween()
	tweener.tween_property(draw_param, "current_radius", arg_final_radius, arg_duration_to_full_radius).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweener.tween_property(draw_param, "current_radius", arg_final_radius + (arg_final_radius / 3.0), arg_additional_lifetime)



func play_blue_ring__pickup_of_wrench(arg_origin, arg_initial_radius : float, arg_final_radius : float, arg_duration_to_full_radius, arg_mod_a):
	var arg_additional_lifetime = 0.2
	
	var draw_param = wrench_circle_draw_node.DrawParams.new()
	
	draw_param.center_pos = arg_origin
	draw_param.current_radius = arg_initial_radius
	draw_param.max_radius = 9999
	draw_param.radius_per_sec = 0
	draw_param.fill_color = Color(0, 0, 0, 0)
	
	draw_param.outline_color = Color(95/255.0, 131/255.0, 236/255.0, arg_mod_a)
	draw_param.outline_width = 2
	
	draw_param.lifetime_of_draw = arg_duration_to_full_radius + arg_additional_lifetime
	draw_param.has_lifetime = true
	
	draw_param.lifetime_to_start_transparency = arg_duration_to_full_radius
	
	wrench_circle_draw_node.add_draw_param(draw_param)
	
	#
	
	var tweener = create_tween()
	tweener.tween_property(draw_param, "current_radius", arg_final_radius, arg_duration_to_full_radius).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweener.tween_property(draw_param, "current_radius", arg_final_radius + (arg_final_radius / 3.0), arg_additional_lifetime)


############################################


