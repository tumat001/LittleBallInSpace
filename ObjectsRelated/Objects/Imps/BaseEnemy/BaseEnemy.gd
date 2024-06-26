tool
extends "res://ObjectsRelated/Objects/BaseObject.gd"

#

#const BaseModule_AttackModule = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/BaseModule_AttackModule.gd")

const Module_AimOccluder = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimOccluderModules/Module_AimOccluder.gd")
const Module_AimTrajectory_VeloPredict = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimTrajectoryModules/Module_AimTrajectory_VeloPredict.gd")
#const Module_AttackModule_Laser = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.gd")
const Module_AttackModule_Laser_Scene = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.tscn")
const Module_AttackModule_Ball_Scene = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Ball.tscn")

const Module_TargetDetection = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/TargetDetectionModule/Module_TargetDetection.gd")


const Texture_Fragment__SeeThruFrame_N = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_SeeThruFrame_N.png")
const Texture_Fragment__SeeThruFrame_NW = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_SeeThruFrame_NW.png")
const Texture_Fragment__SeeThruFrame_W = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_SeeThruFrame_W.png")

const Texture_Fragment__AimerFrame_N = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_AimerFrame_N.png")

const Texture_Fragment__BodyFrame_N = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_Frame_N.png")
const Texture_Fragment__BodyFrame_NW = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_Frame_NW.png")

const Texture_Fragment__MainScreen_NW = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_Screen_NW.png")

const Texture_Fragment__WeaponLaser_N01 = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_Weapon_Laser_N01.png")
const Texture_Fragment__WeaponLaser_N02 = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_Weapon_Laser_N02.png")
const Texture_Fragment__WeaponLaser_N03 = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BreakFragments/BaseEnemy_BreakFragments_Weapon_Laser_N03.png")


#

signal current_attack_cooldown_changed(arg_val)

signal current_health_changed(arg_val)
signal alive_status_changed(arg_is_alive)

#

var _base_enemy_size : Vector2

#

const PHY_OBJ_MASS = 140.0

#

const LASER_COLOR__PREDICTIVE_LASER = Color("#DA0205")
const LASER_COLOR__NON_PREDICTIVE_LASER = Color("#FF8000")
const LASER_COLOR__BALL = Color("#D9D602")

var associated_proj_or_laser_color__based_on_type_template : Color

#

const SHOTS_TO_DESTROY_PLAYER = 2

#

const RANGE_FOR_TRUE_AGGRO = 600.0

#

enum EnemyTypeExportTemplate {
	NONE = 0
	LASER__PREDICT_XRAY = 1
	LASER__NORMAL_XRAY = 2
	BALL = 3
}
export(EnemyTypeExportTemplate) var enemy_type_template__for_export : int


#

enum EnemyType {
	LASER = 0,
	BALL = 1
}
export(EnemyType) var enemy_type : int
var attack_module

const REWIND_DATA__ATTACK_MODULE_REWIND_DATA = "attack_module_rewind_data"

#

enum AimTrajectoryType {
	NO_MODIF = 0,
	VELO_PREDICT = 1,
}
export(AimTrajectoryType) var aim_trajectory_type : int
var aim_trajectory_module

#

enum AimOccluderType {
	NO_OCCLUDER = 0,
	TILE_OCCLUDED = 1,
}
export(AimOccluderType) var aim_occulder_type : int

var aim_occluder_module : Module_AimOccluder


#

var sprite__laser : Sprite
var sprite__ball : Sprite
var sprite__aim_frame : Sprite
var sprite__xray_frame : Sprite

#

enum TargetDetectionModeId {
	STANDARD = 0
}
export(TargetDetectionModeId) var target_detection_mode_id : int

var target_detection_module : Module_TargetDetection
const REWIND_DATA__TARGET_DETECTION_MODULE = "target_detection_module"

###

#enum IsActivatedClauseId {
#
#}

#


enum CanNotAttackClauseIds {
	IN_COOLDOWN = 0,
	GAME_RESULT_DECIDED = 1,
	#IS_ATTACKING = 1,
	#WEAPON_ROTATING = 1,
}
var can_not_attack_conditional_clause : ConditionalClauses
var last_calc_can_attack : bool
#var _rewind__can_not_attack_conditional_clause_clauses__has_changes : bool
const REWIND_DATA__can_not_attack_conditional_clause_clauses = "can_not_attack_conditional_clause"



const ATTACK_COOLDOWN : float = 6.0
const ATTACK_COOLDOWN__AS_STARTING_DELAY : float = 2.5
var _current_attack_cooldown : float setget _set_current_attack_cooldown

#var _rewind__current_attack_cooldown__has_changes : bool
const REWIND_DATA__current_attack_cooldown = "_current_attack_cooldown"


#

enum StartingAttackCooldownModeId {
	NO_COOLDOWN = 0,
	WITH_DELAY_COOLDOWN = 1,
	RANDOM_COOLDOWN_FROM_EXPORT = 2,
}
export(StartingAttackCooldownModeId) var starting_attack_cooldown_mode_id : int = StartingAttackCooldownModeId.WITH_DELAY_COOLDOWN

export(float) var starting_random_cooldown_export__min : float
export(float) var starting_random_cooldown_export__max : float

#

enum StartingActivationModeId {
	NOT_TARGET_SEEKING = 0,
	TARGET_SEEKING = 1,
}
export(StartingActivationModeId) var starting_activation_mode_id #= #StartingActivationModeId.TARGET_SEEKING

#

var current_health : float setget set_current_health
const REWIND_DATA__current_health = "current_health"

var _is_robot_dead : bool

#

const CIRCLE_PARTITION = (2*PI/8) #North, NW, W, ...
var intent_final_robot_face_angle : float

#

enum PreventDrawEnemyRangeClauseId {
	NOT_YET_ENTERED_RANGE_ONCE = 0,
	CUSTOM_WORLD_SLICE = 1,
}
var prevent_draw_enemy_range_cond_clause : ConditionalClauses
var last_calc_draw_enemy_range : bool


#

export(bool) var is_immovable_and_invulnerable : bool = false setget set_is_immovable_and_invulnerable
var _old_body_mode_val_before_is_immovable_and_invulnerable_is_set : int = -1

#

var _objects_to_not_collide_with : Array
var _objects_to_collide_with_after_exit : Array
var _objects_to_add_mask_layer_collision_after_exit : Array

#

var on_death__audio_id_to_play : int
var on_death__audio_id_to_play__override : int = -1

#

#const REWIND_DATA__IS_PLAYER_IN_CONTACT = "is_player_in_contact"
#var is_player_in_contact : bool

const REWIND_DATA__LAST_NON_TILE_BODY_IN_CONTACT_IS_PLAYER = "last_non_tile_body_in_contact_is_player_on_ground"
var last_non_tile_body_in_contact_is_player_on_ground : bool

const REWIND_DATA__CAM_ROTATION_ON_PLAYER_CONTACT = "cam_rotation_on_player_contact"
var cam_rotation_on_player_contact : float


const REWIND_DATA__IS_ON_GROUND = "is_on_ground"
var is_on_ground : bool

####### FRAGMENTS RELATED

const ROT_QUARTER = PI/4
const ROT_HALF = PI/2


const FRAGMENT__XRAY_FRAME__POS__N = Vector2(0, -9)
const FRAGMENT__XRAY_FRAME__POS__NW = Vector2(-11, -6)
const FRAGMENT__XRAY_FRAME__POS__W = Vector2(-14, 0)

const FRAGMENT__BODY_PART__POS__N = Vector2(0, -13)
const FRAGMENT__BODY_PART__POS__NW = Vector2(-9, -9)

const FRAGMENT__AIMER_FRAME__POS_N = Vector2(0, -14)

const FRAGMENT__FACE_SCREEN__POS__NW = Vector2(-5, -3)

const FRAGMENT__WEAPON_LASER__POS__01 = Vector2(0, -8)
const FRAGMENT__WEAPON_LASER__POS__02 = Vector2(2, 4)
const FRAGMENT__WEAPON_LASER__POS__03 = Vector2(0, 13)


#

onready var weapon_sprite_container = $WeaponSpriteContainer

onready var robot_face = $RobotFace

onready var area_for_proj_or_player__coll_shape = $CollForProjOrPlayer/CollisionShape2D
onready var area_for_tileset__coll_shape = $CollForTileset/CollisionShape2D

##

func _init():
	if !Engine.editor_hint:
		current_health = GameSettingsManager.combat__current_max_enemy_health
		on_death__audio_id_to_play = StoreOfAudio.AudioIds.SFX_Enemy_DeathExplode
		
	
	can_not_attack_conditional_clause = ConditionalClauses.new()
	can_not_attack_conditional_clause.connect("clause_inserted", self, "_on_can_not_attack_conditional_clause_updated")
	can_not_attack_conditional_clause.connect("clause_removed", self, "_on_can_not_attack_conditional_clause_updated")
	_update_last_calc_can_attack()
	
	prevent_draw_enemy_range_cond_clause = ConditionalClauses.new()
	prevent_draw_enemy_range_cond_clause.attempt_insert_clause(PreventDrawEnemyRangeClauseId.NOT_YET_ENTERED_RANGE_ONCE)
	prevent_draw_enemy_range_cond_clause.connect("clause_inserted", self, "_on_prevent_draw_enemy_range_cond_clause_updated")
	prevent_draw_enemy_range_cond_clause.connect("clause_removed", self, "_on_prevent_draw_enemy_range_cond_clause_updated")
	_update_can_draw_enemy_range()
	
	ignore_object_destroying_region = true

#

func _on_can_not_attack_conditional_clause_updated(arg_clause):
	_update_last_calc_can_attack()
	

func _update_last_calc_can_attack():
	last_calc_can_attack = can_not_attack_conditional_clause.is_passed


#

func _on_prevent_draw_enemy_range_cond_clause_updated(arg_clause_id):
	_update_can_draw_enemy_range()

func _update_can_draw_enemy_range():
	last_calc_draw_enemy_range = prevent_draw_enemy_range_cond_clause.is_passed
	
	update()

func _draw():
	if Engine.editor_hint:
		draw_arc(Vector2(0, 0), RANGE_FOR_TRUE_AGGRO, 0, PI*2, 64, Color(1, 0.6, 0.6), 3)
	elif last_calc_draw_enemy_range:
		draw_arc(Vector2(0, 0), RANGE_FOR_TRUE_AGGRO, 0, PI*2, 64, Color(1, 0.6, 0.6, 0.2), 3)

#####

func _ready():
	if Engine.editor_hint:
		return
	
	_base_enemy_size = Vector2(16, 16)
	
	_config_self_based_on_enemy_type_template()
	set_is_immovable_and_invulnerable(is_immovable_and_invulnerable)
	
	add_monitor_to_collision_shape_for_rewind(area_for_proj_or_player__coll_shape)
	add_monitor_to_collision_shape_for_rewind(area_for_tileset__coll_shape)
	
	mass = PHY_OBJ_MASS
	call_deferred("_deferred_ready")
	
	add_to_group(SingletonsAndConsts.GROUP_NAME__BASE_ENEMY)

#

func _config_self_based_on_enemy_type_template():
	if enemy_type_template__for_export == EnemyTypeExportTemplate.LASER__PREDICT_XRAY:
		enemy_type = EnemyType.LASER
		aim_trajectory_type = AimTrajectoryType.VELO_PREDICT
		aim_occulder_type = AimOccluderType.NO_OCCLUDER
		target_detection_mode_id = TargetDetectionModeId.STANDARD
		associated_proj_or_laser_color__based_on_type_template = LASER_COLOR__PREDICTIVE_LASER
		
	elif enemy_type_template__for_export == EnemyTypeExportTemplate.LASER__NORMAL_XRAY:
		enemy_type = EnemyType.LASER
		aim_trajectory_type = AimTrajectoryType.NO_MODIF
		aim_occulder_type = AimOccluderType.NO_OCCLUDER
		target_detection_mode_id = TargetDetectionModeId.STANDARD
		associated_proj_or_laser_color__based_on_type_template = LASER_COLOR__NON_PREDICTIVE_LASER
		
	elif enemy_type_template__for_export == EnemyTypeExportTemplate.BALL:
		enemy_type = EnemyType.BALL
		aim_trajectory_type = AimTrajectoryType.NO_MODIF
		aim_occulder_type = AimOccluderType.TILE_OCCLUDED
		target_detection_mode_id = TargetDetectionModeId.STANDARD
		associated_proj_or_laser_color__based_on_type_template = LASER_COLOR__BALL
	
	


func set_is_immovable_and_invulnerable(arg_val : bool):
	is_immovable_and_invulnerable = arg_val
	
	if is_immovable_and_invulnerable:
		_old_body_mode_val_before_is_immovable_and_invulnerable_is_set = body_mode_to_use
		set_body_mode_to_use(BodyMode.STATIC)
		
	else:
		if _old_body_mode_val_before_is_immovable_and_invulnerable_is_set != -1:
			set_body_mode_to_use(_old_body_mode_val_before_is_immovable_and_invulnerable_is_set)
		


#

func _deferred_ready():
	_ready__config_self__any()
	
	if enemy_type == EnemyType.LASER:
		_ready__config_self_as_type_laser()
		
	elif enemy_type == EnemyType.BALL:
		_ready__config_self_as_type_ball()
		
	
	SingletonsAndConsts.current_game_result_manager.connect("game_result_decided", self, "_on_game_result_decided")

func _on_game_result_decided(arg_result):
	can_not_attack_conditional_clause.attempt_insert_clause(CanNotAttackClauseIds.GAME_RESULT_DECIDED)


func _ready__config_self__any():
	target_detection_module = Module_TargetDetection.new()
	
	if target_detection_mode_id == TargetDetectionModeId.STANDARD:
		_config_target_detection_module__as_standard()
	
	target_detection_module.set_origin_node(self)
	target_detection_module.set_current_target__to_player()
	target_detection_module.connect("attempted_ping", self, "_on_target_detection_module_attempted_ping")
	target_detection_module.connect("pinged_target_successfully", self, "_on_target_module_pinged_target_successfully__for_attack")
	
	##
	
	if aim_occulder_type == AimOccluderType.NO_OCCLUDER:
		sprite__xray_frame = Sprite.new()
		sprite__xray_frame.texture = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BaseEnemy_SeeThruFrame.png")
		add_child(sprite__xray_frame)
	
	if aim_occulder_type == AimOccluderType.TILE_OCCLUDED:
		aim_occluder_module = Module_AimOccluder.new()
		aim_occluder_module.direct_space_state = get_world_2d().direct_space_state
		
	
	##
	
	if aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
		sprite__aim_frame = Sprite.new()
		sprite__aim_frame.texture = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BaseEnemy_AimerFrame.png")
		add_child(sprite__aim_frame)
		
		aim_trajectory_module = Module_AimTrajectory_VeloPredict.new()
	
	##
	
	if starting_attack_cooldown_mode_id == StartingAttackCooldownModeId.WITH_DELAY_COOLDOWN:
		_set_current_attack_cooldown(ATTACK_COOLDOWN__AS_STARTING_DELAY)
	elif starting_attack_cooldown_mode_id == StartingAttackCooldownModeId.RANDOM_COOLDOWN_FROM_EXPORT:
		_set_current_attack_cooldown__using_random(starting_random_cooldown_export__min, starting_random_cooldown_export__max)
	
	if starting_activation_mode_id == StartingActivationModeId.TARGET_SEEKING:
		call_deferred("activate_target_detection")
	

func _ready__config_self_as_type_laser():
	# sprite for LASER
	sprite__laser = Sprite.new()
	sprite__laser.texture = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BaseEnemy_Weapon_Laser.png")
	sprite__laser.offset.y = 20
	weapon_sprite_container.add_child(sprite__laser)
	
	# attk module
	attack_module = Module_AttackModule_Laser_Scene.instance()
	attack_module.can_draw_laser = false
	attack_module.laser_color = associated_proj_or_laser_color__based_on_type_template
	attack_module.connect("hit_player", self, "_on_attack_module_laser__hit_player")
	add_child(attack_module)
	
	# conn to target detection module
	#target_detection_module.connect("pinged_target_successfully", self, "_on_target_module_pinged_target_successfully__for_laser")

func _ready__config_self_as_type_ball():
	#attk module
	attack_module = Module_AttackModule_Ball_Scene.instance()
	attack_module.can_draw_laser = false
	attack_module.laser_color = associated_proj_or_laser_color__based_on_type_template
	attack_module.body_to_ignore_on_ball_launch = self
	attack_module.ball_flat_dmg = GameSettingsManager.combat__current_max_player_health / SHOTS_TO_DESTROY_PLAYER
	attack_module.ball_dmg__max_bonus_dmg_based_on_lin_vel = GameSettingsManager.combat__current_max_player_health/2
	attack_module.ball_modulate_to_use_for_hit_damage_particle = associated_proj_or_laser_color__based_on_type_template
	add_child(attack_module)

#

func _config_target_detection_module__as_standard():
	target_detection_module.default_ping_rate_for_outside_most_outer_detection_range = 3.5
	target_detection_module.add_detection_range_to_ping_rate_entry(1700, 2.0, false, false)
	target_detection_module.add_detection_range_to_ping_rate_entry(1200, 0.75, false, false)
	target_detection_module.add_detection_range_to_ping_rate_entry(900, 0.2, false, false)
	#last
	target_detection_module.add_detection_range_to_ping_rate_entry(RANGE_FOR_TRUE_AGGRO, 0, true, true)
	

# occlude related

func is_target_pos_occluded(arg_pos : Vector2) -> bool:
	if aim_occluder_module == null:
		return false
		
	else:
		aim_occluder_module.target_actual_position = arg_pos
		aim_occluder_module.origin_position = global_position
		return aim_occluder_module.is_aim_to_target_occluded()


# aim trajectory related

#func get_modified_target_pos_based_on_aim_trajectory_type(arg_pos : Vector2, arg_target_velo : Vector2) -> Vector2:
#	var angle_to_use
#	if aim_trajectory_module == null:
#		return arg_pos
#
#	else:
#		if aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
#			aim_trajectory_module.target_actual_position = arg_pos
#			aim_trajectory_module.origin_position = global_position
#			aim_trajectory_module.target_velocity = arg_target_velo
#			aim_trajectory_module.origin_velocity
#
#
#			angle_to_use = aim_trajectory_module.get_calculated_angle_of_aim()
#
#
#	var vec
#	return vec


func get_modified_target_pos_using_aim_type__none(arg_pos : Vector2) -> Vector2:
	return arg_pos

func get_modified_target_pos_using_aim_type__velo_predict(arg_pos : Vector2, arg_target_velo : Vector2, arg_lookahead : float, arg_consider_projectile_velocity = false, arg_proj_velocity : Vector2 = Vector2.ONE) -> Vector2:
	aim_trajectory_module.target_actual_position = arg_pos
	aim_trajectory_module.origin_position = global_position
	aim_trajectory_module.target_velocity = arg_target_velo
	aim_trajectory_module.origin_velocity = linear_velocity
	aim_trajectory_module.lookahead_duration = arg_lookahead
	aim_trajectory_module.consider_projectile_velocity = arg_consider_projectile_velocity
	aim_trajectory_module.projectile_velocity = arg_proj_velocity
	
	return aim_trajectory_module.get_calculated_position_of_aim()



#

func activate_target_detection():
	target_detection_module.register_to_GE__and_activate()
	

func deactivate_target_detection():
	target_detection_module.unregister_to_GE__and_deactivate()
	


#

func _on_target_detection_module_attempted_ping(arg_success):
	if !arg_success:
		if enemy_type == EnemyType.LASER:
			attack_module.can_draw_laser = false
			
		elif enemy_type == EnemyType.BALL:
			attack_module.can_draw_laser = false
			
		
		_look_toward_position(global_position, false)
		
	else:
		if enemy_type == EnemyType.LASER:
			pass
			
		elif enemy_type == EnemyType.BALL:
			pass
		
		##
		if !last_calc_draw_enemy_range:
			prevent_draw_enemy_range_cond_clause.remove_clause(PreventDrawEnemyRangeClauseId.NOT_YET_ENTERED_RANGE_ONCE)
	
	#print("attempted ping target: %s" % [arg_success])

func _on_target_module_pinged_target_successfully__for_attack(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target):
	#print("pinged target. is occluded: %s" % [is_target_pos_occluded(arg_pos_target)])
	
	if !is_target_pos_occluded(arg_pos_target) and !_is_robot_dead:
		
		
		
		if enemy_type == EnemyType.LASER:
			attack_module.can_draw_laser = true
			
			#update target pos if not in fire sequence
			if !attack_module.is_in_fire_sequence():
				var trajectory_modified_pos = _get_calc_trajectory_modified_pos(arg_pos_target, arg_target, attack_module.LASER_DURATION__LOOKAHEAD_PREDICT)
				attack_module.target_pos_to_draw_laser_to = trajectory_modified_pos
				sprite__laser.rotation = global_position.angle_to_point(trajectory_modified_pos) + PI/2
				
				_look_toward_position(trajectory_modified_pos, true)
			
			
			if last_calc_can_attack:
				_attempt_attack_target__as_laser()
			#print("is not in fire sequence: %s. fire_state: %s" % [!attack_module.is_in_fire_sequence(), attack_module._fire_sequence_state])
			
			
		elif enemy_type == EnemyType.BALL:
			attack_module.can_draw_laser = true
			
			var ball_speed = attack_module.get_launch_strength_to_use(global_position, arg_pos_target)
			var ball_velocity_no_modi := Vector2(ball_speed, 0).rotated(arg_angle + PI)
			
			#update target pos if not in fire sequence
			if !attack_module.is_in_fire_sequence():
				var trajectory_modified_pos = _get_calc_trajectory_modified_pos(arg_pos_target, arg_target, attack_module.LASER_DURATION__LOOKAHEAD_PREDICT, true, ball_velocity_no_modi)
				attack_module.target_pos_to_draw_laser_to = trajectory_modified_pos
				
				_look_toward_position(trajectory_modified_pos, true)
			
			
			if last_calc_can_attack:
				var trajectory_modified_pos = _get_calc_trajectory_modified_pos(arg_pos_target, arg_target, attack_module.LASER_DURATION__LOOKAHEAD_PREDICT, true, ball_velocity_no_modi)
				
				#trajectory_modified_pos = _clean_up_targeted_pos__when_near_90_deg_intervals(trajectory_modified_pos, global_position)
				
				var angle_of_trajectory_modified_pos = global_position.angle_to_point(trajectory_modified_pos)
				#angle_of_trajectory_modified_pos = _clean_up_angle__when_near_90_deg_interval(angle_of_trajectory_modified_pos)
				
				var final_lin_vel_of_ball : Vector2 = Vector2(ball_speed, 0).rotated(angle_of_trajectory_modified_pos + PI)
				
				_attempt_attack_target__as_ball(final_lin_vel_of_ball)
			
			
		
		
	else:
		
		if enemy_type == EnemyType.LASER:
			attack_module.can_draw_laser = false
			
		elif enemy_type == EnemyType.BALL:
			attack_module.can_draw_laser = false
			
		
		

#

func _get_calc_trajectory_modified_pos(arg_pos_target, arg_target, lookahead_duration, arg_consider_projectile_velocity = false, arg_proj_velocity : Vector2 = Vector2.ONE):
	var trajectory_modified_pos = arg_pos_target
	if aim_trajectory_type == AimTrajectoryType.NO_MODIF:
		trajectory_modified_pos = get_modified_target_pos_using_aim_type__none(arg_pos_target)
		
	elif aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
		var target_velocity = Vector2.ZERO
		if is_instance_valid(arg_target) and ("linear_velocity" in arg_target):
			target_velocity = arg_target.linear_velocity
		
		#var lookahead_duration = attack_module.LASER_DURATION__LOOKAHEAD_PREDICT
		trajectory_modified_pos = get_modified_target_pos_using_aim_type__velo_predict(arg_pos_target, target_velocity, lookahead_duration, arg_consider_projectile_velocity, arg_proj_velocity)
		
	
	trajectory_modified_pos = attack_module.extend_vector_to_length(global_position, trajectory_modified_pos, attack_module.LASER_LENGTH)
	return trajectory_modified_pos


func _clean_up_angle__when_near_90_deg_interval(arg_angle):
	var excess = abs(fmod(arg_angle, PI/2))
	
	if excess > PI/4:
		excess -= PI/2
	excess = abs(excess)
	
	if excess <= PI/32:
		return _clean_up_angle__perfect_translated_for_param(arg_angle, PI/2)
	
	return arg_angle

#func _clean_up_targeted_pos__when_near_90_deg_intervals(arg_target_pos : Vector2, arg_ref_pos : Vector2):
#	var angle = arg_target_pos.angle_to_point(arg_ref_pos)
#	var excess = abs(fmod(angle, PI/2))
#	if excess > PI/4:
#		excess -= PI/2
#	#var excess = abs(angle / (PI/2))
#	excess = abs(excess)
#	if excess <= PI/32:
#		var cleaned_angle = _clean_up_angle__perfect_translated_for_param(angle, PI/2)
#		var dist = arg_target_pos.distance_to(arg_ref_pos)
#
#		return Vector2(dist, 0).rotated(cleaned_angle)
#
#	return arg_target_pos


func _look_toward_position(arg_pos : Vector2, arg_is_looking_at_target):
	robot_face.helper__eyes_look_toward_position(arg_pos, true)
	
	if arg_is_looking_at_target:
		var angle = arg_pos.angle_to_point(global_position)
		#var orig_angle = angle
		angle = _clean_up_angle__perfect_translated_for_circle_partition(angle)
		
		#print("orig_angle: %s, angle: %s" % [orig_angle, angle])
		
		_tween_rotate_robot_face(angle)
		
	else:
		pass
		
		


func _clean_up_angle__perfect_translated_for_param(arg_angle, arg_circle_partition_param):
	var translated = arg_angle / arg_circle_partition_param
	var perfected_translated = round(translated)
	return perfected_translated * arg_circle_partition_param

func _clean_up_angle__perfect_translated_for_circle_partition(arg_angle):
	return _clean_up_angle__perfect_translated_for_param(arg_angle, CIRCLE_PARTITION)


func _attempt_attack_target__as_laser():
	if !attack_module.is_in_fire_sequence():
		attack_module.start_fire_sequence()
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Laser_ChargeUp, global_position, 1, null, AudioManager.MaskLevel.Minor_SoundFX)
		_current_attack_cooldown = ATTACK_COOLDOWN

func _attempt_attack_target__as_ball(arg_ball_lin_vel : Vector2):
	attack_module.ball_lin_vel_to_use = arg_ball_lin_vel
	
	if !attack_module.is_in_fire_sequence():
		attack_module.start_fire_sequence()
		AudioManager.helper__play_sound_effect__2d(StoreOfAudio.AudioIds.SFX_Enemy_ChargeBall, global_position, 1, null, AudioManager.MaskLevel.Minor_SoundFX)
		_current_attack_cooldown = ATTACK_COOLDOWN
	
	
#	attack_module.fire_ball_toward_position(global_position, arg_ball_lin_vel)
#	_current_attack_cooldown = ATTACK_COOLDOWN
	

#

func _tween_rotate_robot_face(arg_rotation):
	if intent_final_robot_face_angle != arg_rotation:
		intent_final_robot_face_angle = arg_rotation
		
		var angle_tweener = create_tween()
		angle_tweener.tween_property(robot_face, "rotation", arg_rotation, GameSettingsManager.settings_config__cam_rotation_duration__default).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	

#

func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	if _current_attack_cooldown > 0 and !_is_robot_dead and attack_module.can_draw_laser:
		_set_current_attack_cooldown(_current_attack_cooldown - delta)
	

#

func _integrate_forces(state):
	var old__use_integ_forces_new_vals = _use_integ_forces_new_vals
	._integrate_forces(state)
	
	if !SingletonsAndConsts.current_rewind_manager.is_rewinding and !old__use_integ_forces_new_vals:
		_adjust_curr_velocities_based_on_conditions()


#

func _set_current_attack_cooldown(arg_val):
	_current_attack_cooldown = arg_val
	
	if _current_attack_cooldown <= 0:
		if can_not_attack_conditional_clause.has_clause(CanNotAttackClauseIds.IN_COOLDOWN):
			can_not_attack_conditional_clause.remove_clause(CanNotAttackClauseIds.IN_COOLDOWN)
			#_rewind__can_not_attack_conditional_clause_clauses__has_changes = true
		
	else:
		if !can_not_attack_conditional_clause.has_clause(CanNotAttackClauseIds.IN_COOLDOWN):
			can_not_attack_conditional_clause.attempt_insert_clause(CanNotAttackClauseIds.IN_COOLDOWN)
			#_rewind__can_not_attack_conditional_clause_clauses__has_changes = true
		
	
	emit_signal("current_attack_cooldown_changed", arg_val)
	
	#_rewind__current_attack_cooldown__has_changes = true
	

func _set_current_attack_cooldown__using_random(arg_min, arg_max):
	var attk_cooldown = SingletonsAndConsts.non_essential_rng.randf_range(arg_min, arg_max)
	_set_current_attack_cooldown(attk_cooldown)



# LASER SPECIFIC

#func _on_target_module_pinged_target_successfully__for_laser(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target):
#	sprite__laser.rotation = arg_angle
#


######

func _on_attack_module_laser__hit_player(arg_contact_pos):
	var player = SingletonsAndConsts.current_game_elements.get_current_player()
	#player.set_current_robot_health(player.get_current_robot_health() - (player.get_max_robot_health() / SHOTS_TO_DESTROY_PLAYER))
	player.take_robot_health_damage((player.get_max_robot_health() / SHOTS_TO_DESTROY_PLAYER))
	
	SingletonsAndConsts.current_game_elements.request_play_damage_particles_on_pos__fragment(arg_contact_pos, associated_proj_or_laser_color__based_on_type_template)

#########################

func _on_CollForProjOrPlayer_body_entered(body):
	if !has_object_to_not_collide_with(body):
		var is_considered_non_collision : bool = false
		if body.get("is_class_type_obj_ball"):
			if body.is_ball_from_enemy:
				body.queue_free()
				is_considered_non_collision = true
		
		
		if body.get("is_player"):
			if body.is_on_ground() and is_on_ground:
				last_non_tile_body_in_contact_is_player_on_ground = true
				cam_rotation_on_player_contact = CameraManager.current_cam_rotation
			else:
				last_non_tile_body_in_contact_is_player_on_ground = false
			
		else:
			if !is_considered_non_collision:
				last_non_tile_body_in_contact_is_player_on_ground = false
		
		_do_calc_damage_if_appropriate(body)
	

func _on_CollForProjOrPlayer_body_exited(body):
	_on_body_exited__base_object(body)


#

func _on_body_exited__base_object(body):
	if _objects_to_collide_with_after_exit.has(body):
		remove_objects_to_not_collide_with(body)
		remove_objects_to_collide_with_after_exit(body)
	
	if _objects_to_add_mask_layer_collision_after_exit.has(body):
		remove_objects_to_add_mask_layer_collision_after_exit(body)
	


#



func _do_calc_damage_if_appropriate(body):
	var dmg = 0
	if !is_immovable_and_invulnerable:
		if body.get("is_class_type_obj_ball"):
			if body.enemy_dmg__enabled:
				dmg = _calc_damage_of_obj_ball(body)
		elif body.get("is_player"):
			dmg = _calc_damage_of_player(body)
	
	if dmg > 0:
		#set_current_health(current_health - dmg)
		take_health_damage(dmg)
		call_deferred("create_damage_fragment_particles_from_ball_collision", body.global_position, body.modulate)


func _calc_damage_of_obj_ball(arg_obj_ball):
	return arg_obj_ball.calculate_damage_to__enemy(linear_velocity)
	

func _calc_damage_of_player(arg_player):
	var lin_vel = (arg_player.linear_velocity - linear_velocity).length()
	
	if lin_vel >= 275:
		return GameSettingsManager.combat__current_max_enemy_health
		
	elif lin_vel >= 195:
		return GameSettingsManager.combat__current_max_enemy_health / 2
		
	else:
		return 0



func take_health_damage(arg_dmg, arg_damage_contact_pos : Vector2 = global_position):
	set_current_health(current_health - arg_dmg)
	
	play_damage_audio__based_on_states()

func play_damage_audio__based_on_states():
	#var audio_id_to_play : int
	if _is_robot_dead:
		play_damage_audio__on_death()
	else:
		play_damage_audio__on_non_death()
	

func play_damage_audio__on_death():
	var id = get_on_death__audio_id_to_play()
	AudioManager.helper__play_sound_effect__2d(id, global_position, 1.0, null)

func play_damage_audio__on_non_death():
	var id = StoreOfAudio.AudioIds.SFX_Enemy_Damage_01
	AudioManager.helper__play_sound_effect__2d(id, global_position, 1.0, null)



func set_current_health(arg_val):
	current_health = arg_val
	
	if current_health < 0:
		current_health = 0
	
	if current_health <= 0:
		if !_is_robot_dead:
			_set_is_robot_dead__and_do_death_actions()
			emit_signal("alive_status_changed", !_is_robot_dead)
		
	else:
		if _is_robot_dead:
			_is_robot_dead = false
			emit_signal("alive_status_changed", !_is_robot_dead)
		
	
	
	emit_signal("current_health_changed", arg_val)
	

func _set_is_robot_dead__and_do_death_actions():
	_is_robot_dead = true
	queue_free()
	
	if enemy_type == EnemyType.LASER:
		attack_module.cancel_all_windups_and_charges__on_wielder_death()
	elif enemy_type == EnemyType.BALL:
		attack_module.cancel_all_windups_and_charges__on_wielder_death()

func is_robot_alive():
	return !_is_robot_dead

#

func get_on_death__audio_id_to_play():
	if on_death__audio_id_to_play__override != -1:
		return on_death__audio_id_to_play__override
	else:
		return on_death__audio_id_to_play


##########

func create_damage_fragment_particles_from_ball_collision(arg_collider_pos : Vector2, arg_modulate_to_use):
	var pos_shift_center_of_particles = Vector2(_base_enemy_size.x, 0).rotated(arg_collider_pos.angle_to_point(global_position))
	SingletonsAndConsts.current_game_elements.request_play_damage_particles_on_pos__fragment(global_position + pos_shift_center_of_particles, arg_modulate_to_use)



func deferred_create_break_fragments():
	## screen face additional frame
	if aim_occulder_type == AimOccluderType.NO_OCCLUDER:
		_create_break_fragments__for_occulder_type__no_occluder()
	
	## aim frame
	if aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
		_create_break_fragments__for_traj_type__velo_predict()
	
	## laser
	if enemy_type == EnemyType.LASER:
		_create_break_fragments__for_laser()
	
	## body frame
	_create_break_fragments__for_main_body()
	
	## screen frame
	_create_break_fragments__for_screen_face()
	


func _create_break_fragments__for_occulder_type__no_occluder():
	#N
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__N, 0, 0, Texture_Fragment__SeeThruFrame_N)
	#W
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__W, 0, 0, Texture_Fragment__SeeThruFrame_W)
	
	#S
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__N, ROT_HALF, ROT_HALF, Texture_Fragment__SeeThruFrame_N)
	#E
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__W, ROT_HALF, ROT_HALF, Texture_Fragment__SeeThruFrame_W)
	
	#NW
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, 0, 0, Texture_Fragment__SeeThruFrame_NW)
	#SW
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__SeeThruFrame_NW)
	#SE
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, ROT_HALF, ROT_HALF, Texture_Fragment__SeeThruFrame_NW)
	#NE
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__SeeThruFrame_NW)


func _create_break_fragments__for_traj_type__velo_predict():
	#N
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__AIMER_FRAME__POS_N, 0, 0, Texture_Fragment__AimerFrame_N)
	#S
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__AIMER_FRAME__POS_N, ROT_HALF, ROT_HALF, Texture_Fragment__AimerFrame_N)
	#W
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__AIMER_FRAME__POS_N, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__AimerFrame_N)
	#E
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__AIMER_FRAME__POS_N, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__AimerFrame_N)
	

func _create_break_fragments__for_main_body():
	#N
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__N, 0, 0, Texture_Fragment__BodyFrame_N)
	#S
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__N, ROT_HALF, ROT_HALF, Texture_Fragment__BodyFrame_N)
	#W
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__N, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__BodyFrame_N)
	#E
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__N, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__BodyFrame_N)
	
	
	#NW
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__NW, 0, 0, Texture_Fragment__BodyFrame_NW)
	#SE
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__NW, ROT_HALF, ROT_HALF, Texture_Fragment__BodyFrame_NW)
	#SW
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__NW, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__BodyFrame_NW)
	#NE
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__NW, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__BodyFrame_NW)
	


func _create_break_fragments__for_screen_face():
	#NW
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__FACE_SCREEN__POS__NW, 0, 0, Texture_Fragment__MainScreen_NW)
	#SE
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__FACE_SCREEN__POS__NW, ROT_HALF, ROT_HALF, Texture_Fragment__MainScreen_NW)
	#SW
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__FACE_SCREEN__POS__NW, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__MainScreen_NW)
	#NE
	#_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__FACE_SCREEN__POS__NW, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__MainScreen_NW)
	

func _create_break_fragments__for_laser():
	#01
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__WEAPON_LASER__POS__01, 0, 0, Texture_Fragment__WeaponLaser_N01)
	#01
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__WEAPON_LASER__POS__02, 0, 0, Texture_Fragment__WeaponLaser_N02)
	#01
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__WEAPON_LASER__POS__03, 0, 0, Texture_Fragment__WeaponLaser_N03)



func _deferred__create_obj_fragment__with_pos_modif_and_angle_and_texture(arg_pos_modif : Vector2, arg_pos_modif_angle : float, arg_sprite_rotation : float, arg_texture : Texture):
	call_deferred("_create_obj_fragment__with_pos_modif_and_angle_and_texture", arg_pos_modif, arg_pos_modif_angle, arg_sprite_rotation, arg_texture)

func _create_obj_fragment__with_pos_modif_and_angle_and_texture(arg_pos_modif : Vector2, arg_pos_modif_angle : float, arg_sprite_rotation : float, arg_texture : Texture):
	var fragment = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.TILE_FRAGMENT)
	
	fragment.position = global_position + (arg_pos_modif.rotated(arg_pos_modif_angle))
	fragment.texture_to_use__fragment = arg_texture
	fragment.rotation = arg_sprite_rotation
	fragment.object_fragment_representation_id = StoreOfObjects.ObjectTypeIds.FRAGMENT__ENEMY_METALLIC #StoreOfObjects.FRAGMENT__ENEMY_METAILIC_SOUND_LIST
	
	SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(fragment)
	
	fragment.current_lifespan = SingletonsAndConsts.non_essential_rng.randi_range(5, 9)
	fragment.has_finite_lifespan = true
	
	return fragment



#####


func add_object_to_not_collide_with(arg_obj):
	if !_objects_to_not_collide_with.has(arg_obj):
		_objects_to_not_collide_with.append(arg_obj)
		
		add_collision_exception_with(arg_obj)

func remove_objects_to_not_collide_with(arg_obj):
	if _objects_to_not_collide_with.has(arg_obj):
		_objects_to_not_collide_with.erase(arg_obj)
		
		remove_collision_exception_with(arg_obj)

func has_object_to_not_collide_with(arg_obj):
	return _objects_to_not_collide_with.has(arg_obj)



func add_objects_to_collide_with_after_exit(arg_obj):
	if !_objects_to_collide_with_after_exit.has(arg_obj):
		_objects_to_collide_with_after_exit.append(arg_obj)

func remove_objects_to_collide_with_after_exit(arg_obj):
	if _objects_to_collide_with_after_exit.has(arg_obj):
		_objects_to_collide_with_after_exit.erase(arg_obj)


func add_objects_to_add_mask_layer_collision_after_exit(arg_obj):
	if !_objects_to_add_mask_layer_collision_after_exit.has(arg_obj):
		_objects_to_add_mask_layer_collision_after_exit.append(arg_obj)
		
		#arg_obj.block_can_collide_with_player_cond_clauses.attempt_insert_clause(arg_obj.BlockCollisionWithPlayerClauseIds.BLOCK_UNTIL_EXIT_PLAYER)
		

func remove_objects_to_add_mask_layer_collision_after_exit(arg_obj):
	if _objects_to_add_mask_layer_collision_after_exit.has(arg_obj):
		_objects_to_add_mask_layer_collision_after_exit.erase(arg_obj)
		
		#arg_obj.block_can_collide_with_player_cond_clauses.remove_clause(arg_obj.BlockCollisionWithPlayerClauseIds.BLOCK_UNTIL_EXIT_PLAYER)
		


#

func _adjust_curr_velocities_based_on_conditions():
	if last_non_tile_body_in_contact_is_player_on_ground:
		var player = SingletonsAndConsts.current_game_elements.get_current_player()
		
		_snap_velocities_based_on_last_contact_cam_manager_rotation()


func _snap_velocities_based_on_last_contact_cam_manager_rotation():
	var cam_rotation = cam_rotation_on_player_contact
	if is_equal_approx(cam_rotation, 0) or is_equal_approx(abs(cam_rotation), PI):
		linear_velocity.y = _round_with_larger_margins(linear_velocity.y)
		global_position.y = _round_with_larger_margins(global_position.y)
		
	elif is_equal_approx(abs(cam_rotation), 3*PI/2) or is_equal_approx(abs(cam_rotation), PI/2):
		linear_velocity.x = _round_with_larger_margins(linear_velocity.x)
		global_position.x = _round_with_larger_margins(global_position.x)
	

#preserve sign??/direction of rounding
func _round_with_larger_margins(arg_val):
	var rounded_val = round(arg_val)
	if rounded_val > arg_val:
		return (rounded_val / 3) * 3
	elif rounded_val < arg_val:
		return (rounded_val * 3) / 3
	else:
		return rounded_val

#


func _on_CollForTileset_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	is_on_ground = true

func _on_CollForTileset_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	is_on_ground = false

###################### 
# REWIND RELATED
#####################

var _most_recent_rewind_state

func queue_free():
	if !is_dead_but_reserved_for_rewind:  #first time, and no repeats
		deferred_create_break_fragments()
	
	.queue_free()

func get_rewind_save_state():
	var save_state : Dictionary = .get_rewind_save_state()
	
	#if _rewind__can_not_attack_conditional_clause_clauses__has_changes:
	save_state[REWIND_DATA__can_not_attack_conditional_clause_clauses] = can_not_attack_conditional_clause.get_rewind_save_state()
	#	_rewind__can_not_attack_conditional_clause_clauses__has_changes = false
	
	#if _rewind__current_attack_cooldown__has_changes:
	save_state[REWIND_DATA__current_attack_cooldown] = _current_attack_cooldown
	#	_rewind__current_attack_cooldown__has_changes = false
	
	#
	
	if is_instance_valid(attack_module) and attack_module.is_rewindable:
		save_state[REWIND_DATA__ATTACK_MODULE_REWIND_DATA] = attack_module.get_rewind_save_state()
	
	if target_detection_module != null:
		save_state[REWIND_DATA__TARGET_DETECTION_MODULE] = target_detection_module.get_rewind_save_state()
	
	
	if enemy_type == EnemyType.BALL:
		save_state["_objects_to_not_collide_with"] = _objects_to_not_collide_with.duplicate(true)
		save_state["_objects_to_collide_with_after_exit"] = _objects_to_collide_with_after_exit.duplicate(true)
		save_state["_objects_to_add_mask_layer_collision_after_exit"] = _objects_to_add_mask_layer_collision_after_exit.duplicate(true)
	
	save_state[REWIND_DATA__current_health] = current_health
	
	save_state[REWIND_DATA__LAST_NON_TILE_BODY_IN_CONTACT_IS_PLAYER] = last_non_tile_body_in_contact_is_player_on_ground
	save_state[REWIND_DATA__CAM_ROTATION_ON_PLAYER_CONTACT] = cam_rotation_on_player_contact
	
	save_state[REWIND_DATA__IS_ON_GROUND] = is_on_ground
	
	return save_state


func load_into_rewind_save_state(arg_state : Dictionary):
	.load_into_rewind_save_state(arg_state)
	
	_most_recent_rewind_state = arg_state
	
	if arg_state.has(REWIND_DATA__can_not_attack_conditional_clause_clauses):
		can_not_attack_conditional_clause.load_into_rewind_save_state(arg_state[REWIND_DATA__can_not_attack_conditional_clause_clauses])
	
	#_set_current_attack_cooldown(arg_state[REWIND_DATA__current_attack_cooldown])
	_current_attack_cooldown = arg_state[REWIND_DATA__current_attack_cooldown]
	
	if arg_state.has(REWIND_DATA__ATTACK_MODULE_REWIND_DATA):
		attack_module.load_into_rewind_save_state(arg_state[REWIND_DATA__ATTACK_MODULE_REWIND_DATA])
	
	if arg_state.has(REWIND_DATA__TARGET_DETECTION_MODULE):
		target_detection_module.load_into_rewind_save_state(arg_state[REWIND_DATA__TARGET_DETECTION_MODULE])
	
	current_health = arg_state[REWIND_DATA__current_health]
	
	last_non_tile_body_in_contact_is_player_on_ground = arg_state[REWIND_DATA__LAST_NON_TILE_BODY_IN_CONTACT_IS_PLAYER]
	cam_rotation_on_player_contact = arg_state[REWIND_DATA__CAM_ROTATION_ON_PLAYER_CONTACT]
	
	is_on_ground = arg_state[REWIND_DATA__IS_ON_GROUND]


func destroy_from_rewind_save_state():
	.destroy_from_rewind_save_state()

func restore_from_destroyed_from_rewind():
	.restore_from_destroyed_from_rewind()


func started_rewind():
	.started_rewind()
	
	robot_face.play_sequence__rewinding()

func ended_rewind():
	.ended_rewind()
	
	
	robot_face.end_sequence__rewinding()
	
	_update_last_calc_can_attack()
	
	
	if enemy_type == EnemyType.BALL:
		_objects_to_not_collide_with.clear()
		for obj in _most_recent_rewind_state["_objects_to_not_collide_with"]:
			add_object_to_not_collide_with(obj)
		
		_objects_to_collide_with_after_exit.clear()
		for obj in _most_recent_rewind_state["_objects_to_collide_with_after_exit"]:
			add_objects_to_collide_with_after_exit(obj)
		
		_objects_to_add_mask_layer_collision_after_exit.clear()
		for obj in _most_recent_rewind_state["_objects_to_add_mask_layer_collision_after_exit"]:
			add_objects_to_add_mask_layer_collision_after_exit(obj)
	
	set_current_health(current_health)
	_set_current_attack_cooldown(_current_attack_cooldown)



