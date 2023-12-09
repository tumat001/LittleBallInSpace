extends "res://ObjectsRelated/Objects/BaseObject.gd"

#

const Module_AimOccluder = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimOccluderModules/Module_AimOccluder.gd")
const Module_AimTrajectory_VeloPredict = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimTrajectoryModules/Module_AimTrajectory_VeloPredict.gd")
#const Module_AttackModule_Laser = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.gd")
const Module_AttackModule_Laser_Scene = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.tscn")

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

#

const SHOTS_TO_DESTROY_PLAYER = 1 #2 #temptodo

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
	#IS_ATTACKING = 1,
	#WEAPON_ROTATING = 1,
}
var can_not_attack_conditional_clause : ConditionalClauses
var last_calc_can_attack : bool
#var _rewind__can_not_attack_conditional_clause_clauses__has_changes : bool
const REWIND_DATA__can_not_attack_conditional_clause_clauses = "can_not_attack_conditional_clause"



const ATTACK_COOLDOWN : float = 8.0
var _current_attack_cooldown : float setget _set_current_attack_cooldown

#var _rewind__current_attack_cooldown__has_changes : bool
const REWIND_DATA__current_attack_cooldown = "_current_attack_cooldown"


#

enum StartingAttackCooldownModeId {
	NO_COOLDOWN = 0,
	WITH_DELAY_COOLDOWN = 1,
}
export(StartingAttackCooldownModeId) var starting_attack_cooldown_mode_id : int


enum StartingActivationModeId {
	NOT_TARGET_SEEKING = 0,
	TARGET_SEEKING = 1,
}
export(StartingActivationModeId) var starting_activation_mode_id

#

const INITIAL_HEALTH = 2
var current_health : float = INITIAL_HEALTH setget set_current_health
const REWIND_DATA__current_health = "current_health"

var _is_robot_dead : bool

#

const CIRCLE_PARTITION = (2*PI/8) #North, NW, W, ...
var intent_final_robot_face_angle : float

#

var _objects_to_not_collide_with : Array
var _objects_to_collide_with_after_exit : Array
var _objects_to_add_mask_layer_collision_after_exit : Array


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

##

func _init():
	can_not_attack_conditional_clause = ConditionalClauses.new()
	can_not_attack_conditional_clause.connect("clause_inserted", self, "_on_can_not_attack_conditional_clause_updated")
	can_not_attack_conditional_clause.connect("clause_removed", self, "_on_can_not_attack_conditional_clause_updated")
	_update_last_calc_can_attack()
	

func _on_can_not_attack_conditional_clause_updated(arg_clause):
	_update_last_calc_can_attack()
	

func _update_last_calc_can_attack():
	last_calc_can_attack = can_not_attack_conditional_clause.is_passed


#

func _ready():
	call_deferred("_deferred_ready")
	

func _deferred_ready():
	_ready__config_self__any()
	
	if enemy_type == EnemyType.LASER:
		_ready__config_self_as_type_laser()
		
	else:
		pass
		
	


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
	
	##
	
	if aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
		sprite__aim_frame = Sprite.new()
		sprite__aim_frame.texture = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BaseEnemy_AimerFrame.png")
		add_child(sprite__aim_frame)
		
		aim_trajectory_module = Module_AimTrajectory_VeloPredict.new()
	
	##
	
	if starting_attack_cooldown_mode_id == StartingAttackCooldownModeId.WITH_DELAY_COOLDOWN:
		_set_current_attack_cooldown(ATTACK_COOLDOWN / 2)
	
	if starting_activation_mode_id == StartingActivationModeId.TARGET_SEEKING:
		call_deferred("activate_target_detection")
	

func _ready__config_self_as_type_laser():
	# sprite for LASER
	sprite__laser = Sprite.new()
	sprite__laser.texture = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BaseEnemy_Weapon_Laser.png")
	weapon_sprite_container.add_child(sprite__laser)
	
	# attk module
	attack_module = Module_AttackModule_Laser_Scene.instance()
	attack_module.can_draw_laser = false
	attack_module.laser_color = Color("#DA0205")
	attack_module.connect("hit_player", self, "_on_attack_module_laser__hit_player")
	add_child(attack_module)
	
	# conn to target detection module
	#target_detection_module.connect("pinged_target_successfully", self, "_on_target_module_pinged_target_successfully__for_laser")
	
	# occlude relateds
	if aim_occulder_type == AimOccluderType.TILE_OCCLUDED:
		aim_occluder_module = Module_AimOccluder.new()
		aim_occluder_module.direct_space_state = get_world_2d().direct_space_state
		



#

func _config_target_detection_module__as_standard():
	target_detection_module.default_ping_rate_for_outside_most_outer_detection_range = 3.5
	target_detection_module.add_detection_range_to_ping_rate_entry(1700, 2.0, false, false)
	target_detection_module.add_detection_range_to_ping_rate_entry(1200, 0.75, false, false)
	target_detection_module.add_detection_range_to_ping_rate_entry(900, 0.2, false, false)
	#last
	target_detection_module.add_detection_range_to_ping_rate_entry(600, 0, true, true)
	

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

func get_modified_target_pos_using_aim_type__velo_predict(arg_pos : Vector2, arg_target_velo : Vector2, arg_lookahead : float) -> Vector2:
	aim_trajectory_module.target_actual_position = arg_pos
	aim_trajectory_module.origin_position = global_position
	aim_trajectory_module.target_velocity = arg_target_velo
	aim_trajectory_module.origin_velocity = linear_velocity
	aim_trajectory_module.lookahead_duration = arg_lookahead
	
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
		
		_look_toward_position(global_position, false)
		
	else:
		if enemy_type == EnemyType.LASER:
			#depends if occluded or not
			#attack_module.can_draw_laser = true
			pass
			
	
	#print("attempted ping target: %s" % [arg_success])

func _on_target_module_pinged_target_successfully__for_attack(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target):
	#print("pinged target. is occluded: %s" % [is_target_pos_occluded(arg_pos_target)])
	
	if !is_target_pos_occluded(arg_pos_target) and !_is_robot_dead:
		attack_module.can_draw_laser = true
		
		if enemy_type == EnemyType.LASER:
			
			#update target pos if not in fire sequence
			if !attack_module.is_in_fire_sequence():
				var trajectory_modified_pos = arg_pos_target
				if aim_trajectory_type == AimTrajectoryType.NO_MODIF:
					trajectory_modified_pos = get_modified_target_pos_using_aim_type__none(arg_pos_target)
					
				elif aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
					var target_velocity = Vector2.ZERO
					if is_instance_valid(arg_target) and ("linear_velocity" in arg_target):
						target_velocity = arg_target.linear_velocity
					
					var lookahead_duration = attack_module.LASER_DURATION__LOOKAHEAD_PREDICT
					trajectory_modified_pos = get_modified_target_pos_using_aim_type__velo_predict(arg_pos_target, target_velocity, lookahead_duration)
					
				
				#print("aim_traj_type: %s" % aim_trajectory_type)
				
				trajectory_modified_pos = attack_module.extend_vector_to_length(global_position, trajectory_modified_pos, attack_module.LASER_LENGTH)
				attack_module.target_pos_to_draw_laser_to = trajectory_modified_pos
				sprite__laser.rotation = global_position.angle_to_point(trajectory_modified_pos) + PI/2
				
				_look_toward_position(trajectory_modified_pos, true)
			
			
			#print("is not in fire sequence: %s. fire_state: %s" % [!attack_module.is_in_fire_sequence(), attack_module._fire_sequence_state])
			
			
		elif enemy_type == EnemyType.BALL:
			pass
			
		
		if last_calc_can_attack:
			_attempt_attack_target()
		
		
	else:
		
		attack_module.can_draw_laser = false

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
		
		

func _clean_up_angle__perfect_translated_for_circle_partition(arg_angle):
	var translated = arg_angle / CIRCLE_PARTITION
	var perfected_translated = round(translated)
	return perfected_translated * CIRCLE_PARTITION
	

func _attempt_attack_target():
	if enemy_type == EnemyType.LASER:
		if !attack_module.is_in_fire_sequence():
			attack_module.start_fire_sequence()
			_current_attack_cooldown = ATTACK_COOLDOWN
			
		
		
		#can_not_attack_conditional_clause.attempt_insert_clause(CanNotAttackClauseIds.IS_ATTACKING)
		
	elif enemy_type == EnemyType.BALL:
		pass
		
	
	

#

func _tween_rotate_robot_face(arg_rotation):
	if intent_final_robot_face_angle != arg_rotation:
		intent_final_robot_face_angle = arg_rotation
		
		var angle_tweener = create_tween()
		angle_tweener.tween_property(robot_face, "rotation", arg_rotation, GameSettingsManager.settings_config__cam_rotation_duration__default).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	

#

func _physics_process(delta):
	if _current_attack_cooldown > 0 and !_is_robot_dead:
		_set_current_attack_cooldown(_current_attack_cooldown - delta)
	

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
	

# LASER SPECIFIC

#func _on_target_module_pinged_target_successfully__for_laser(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target):
#	sprite__laser.rotation = arg_angle
#


######

func _on_attack_module_laser__hit_player(arg_contact_pos):
	var player = SingletonsAndConsts.current_game_elements.get_current_player()
	player.set_current_robot_health(player.get_current_robot_health() - (player.get_max_robot_health() / SHOTS_TO_DESTROY_PLAYER))


#########################

func _on_CollForProjOrPlayer_body_entered(body):
	if !has_object_to_not_collide_with(body):
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
	if body.get("is_class_type_obj_ball"):
		dmg = _calc_damage_of_obj_ball(body)
	elif body.get("is_player"):
		dmg = _calc_damage_of_player(body)
	
	if dmg > 0:
		set_current_health(current_health - dmg)

func _calc_damage_of_obj_ball(arg_obj_ball):
	var lin_vel = (arg_obj_ball.linear_velocity - linear_velocity).length()
	
	if lin_vel >= 365: #375:
		return 1
		
	else:
		return 0
	

func _calc_damage_of_player(arg_player):
	var lin_vel = (arg_player.linear_velocity - linear_velocity).length()
	
	if lin_vel >= 250:
		return 2
		
	elif lin_vel >= 195:
		return 1
		
	else:
		return 0



func set_current_health(arg_val):
	current_health = arg_val
	
	if current_health < 0:
		current_health = 0
	
	if current_health <= 0:
		if !_is_robot_dead:
			_set_is_robot_dead__and_do_death_actions()
		
	else:
		
		_is_robot_dead = false

func _set_is_robot_dead__and_do_death_actions():
	_is_robot_dead = true
	queue_free()
	
	if enemy_type == EnemyType.LASER:
		attack_module.cancel_all_windups_and_charges__on_wielder_death()

func is_robot_alive():
	return !_is_robot_dead

#

func deferred_create_break_fragments():
	## screen face additional frame
	if aim_occulder_type == AimOccluderType.NO_OCCLUDER:
		_create_break_fragments__for_occulder_type__no_occluder()
	
	# aim frame
	if aim_trajectory_type == AimTrajectoryType.VELO_PREDICT:
		_create_break_fragments__for_traj_type__velo_predict()
	
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
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, 0, 0, Texture_Fragment__SeeThruFrame_NW)
	#SW
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__SeeThruFrame_NW)
	#SE
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, ROT_HALF, ROT_HALF, Texture_Fragment__SeeThruFrame_NW)
	#NE
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__XRAY_FRAME__POS__NW, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__SeeThruFrame_NW)


func _create_break_fragments__for_traj_type__velo_predict():
	#N
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__AIMER_FRAME__POS_N, 0, 0, Texture_Fragment__AimerFrame_N)
	#S
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__AIMER_FRAME__POS_N, ROT_HALF, ROT_HALF, Texture_Fragment__AimerFrame_N)
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
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__N, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__BodyFrame_N)
	#E
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__N, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__BodyFrame_N)
	
	
	#NW
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__NW, 0, 0, Texture_Fragment__BodyFrame_NW)
	#SE
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__BODY_PART__POS__NW, ROT_HALF, ROT_HALF, Texture_Fragment__BodyFrame_NW)
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
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__FACE_SCREEN__POS__NW, -ROT_QUARTER, -ROT_QUARTER, Texture_Fragment__MainScreen_NW)
	#NE
	_create_obj_fragment__with_pos_modif_and_angle_and_texture(FRAGMENT__FACE_SCREEN__POS__NW, ROT_QUARTER, ROT_QUARTER, Texture_Fragment__MainScreen_NW)
	


func _deferred__create_obj_fragment__with_pos_modif_and_angle_and_texture(arg_pos_modif : Vector2, arg_pos_modif_angle : float, arg_sprite_rotation : float, arg_texture : Texture):
	call_deferred("_create_obj_fragment__with_pos_modif_and_angle_and_texture", arg_pos_modif, arg_pos_modif_angle, arg_sprite_rotation, arg_texture)

func _create_obj_fragment__with_pos_modif_and_angle_and_texture(arg_pos_modif : Vector2, arg_pos_modif_angle : float, arg_sprite_rotation : float, arg_texture : Texture):
	var fragment = StoreOfObjects.construct_object(StoreOfObjects.ObjectTypeIds.TILE_FRAGMENT)
	
	fragment.position = global_position + (arg_pos_modif.rotated(arg_pos_modif_angle))
	fragment.texture_to_use__fragment = arg_texture
	fragment.rotation = arg_sprite_rotation
	fragment.object_fragment_representation_id = StoreOfObjects.ObjectTypeIds.FRAGMENT__ENEMY_METALLIC #StoreOfObjects.FRAGMENT__ENEMY_METAILIC_SOUND_LIST
	
	SingletonsAndConsts.deferred_add_child_to_game_elements__other_node_hoster(fragment)
	
	return fragment



#####


func add_object_to_not_collide_with(arg_obj):
	if !_objects_to_not_collide_with.has(arg_obj):
		_objects_to_not_collide_with.append(arg_obj)
	

func remove_objects_to_not_collide_with(arg_obj):
	if _objects_to_not_collide_with.has(arg_obj):
		_objects_to_not_collide_with.erase(arg_obj)
	

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
		
		arg_obj.block_can_collide_with_player_cond_clauses.attempt_insert_clause(arg_obj.BlockCollisionWithPlayerClauseIds.BLOCK_UNTIL_EXIT_PLAYER)

func remove_objects_to_add_mask_layer_collision_after_exit(arg_obj):
	if _objects_to_add_mask_layer_collision_after_exit.has(arg_obj):
		_objects_to_add_mask_layer_collision_after_exit.erase(arg_obj)
		
		arg_obj.block_can_collide_with_player_cond_clauses.remove_clause(arg_obj.BlockCollisionWithPlayerClauseIds.BLOCK_UNTIL_EXIT_PLAYER)
		


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
	
	if is_instance_valid(attack_module):
		save_state[REWIND_DATA__ATTACK_MODULE_REWIND_DATA] = attack_module.get_rewind_save_state()
	
	if target_detection_module != null:
		save_state[REWIND_DATA__TARGET_DETECTION_MODULE] = target_detection_module.get_rewind_save_state()
	
	
	if enemy_type == EnemyType.BALL:
		save_state["_objects_to_not_collide_with"] = _objects_to_not_collide_with.duplicate(true)
		save_state["_objects_to_collide_with_after_exit"] = _objects_to_collide_with_after_exit.duplicate(true)
		save_state["_objects_to_add_mask_layer_collision_after_exit"] = _objects_to_add_mask_layer_collision_after_exit.duplicate(true)
	
	save_state[REWIND_DATA__current_health] = current_health
	
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


