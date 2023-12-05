extends "res://ObjectsRelated/Objects/BaseObject.gd"

#

#const Module_AimOccluder = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimOccluderModules/Module_AimOccluder.gd")
#const Module_AimTrajectory_Plain = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimTrajectoryModules/Module_AimTrajectory_Plain.gd")
#const Module_AimTrajectory_VeloPredict = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimTrajectoryModules/Module_AimTrajectory_VeloPredict.gd")
#const Module_AttackModule_Laser = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.gd")
const Module_TargetDetection = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/TargetDetectionModule/Module_TargetDetection.gd")

#

enum EnemyType {
	LASER = 0,
	#BALL = 1
}
export(int) var enemy_type : int

#

enum AimTrajectoryType {
	NO_MODIF = 0,
	VELO_PREDICT = 1,
}
export(int) var aim_trajectory_type : int
var aim_trajectory_module

#

enum AimOccluderType {
	NO_OCCLUDER = 0,
	TILE_OCCLUDED = 1,
}
export(int) var aim_occulder_type : int

var aim_occluder_module #: Module_AimOccluder


#

var sprite__laser : Sprite
var sprite__ball : Sprite
var sprite__aim_frame : Sprite
var sprite__xray_frame : Sprite

var attack_module

#

enum TargetDetectionModeId {
	STANDARD = 0
}
var target_detection_mode_id : int

var target_detection_module : Module_TargetDetection

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


const ATTACK_COOLDOWN : float = 8.0
var _current_attack_cooldown : float setget _set_current_attack_cooldown

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
	_ready__config_self__any()
	
	if enemy_type == EnemyType.LASER:
		_ready__config_self_as_type_laser()
		
	else:
		pass
		
	



func _ready__config_self__any():
	target_detection_module = Module_TargetDetection.new()
	
	if target_detection_mode_id == TargetDetectionModeId.STANDARD:
		_config_target_detection_module__as_standard()
	
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
	
	


func _ready__config_self_as_type_laser():
	# sprite for LASER
	sprite__laser = Sprite.new()
	sprite__laser.texture = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AesthRelateds/_Assets/BaseEnemy_Weapon_Laser.png")
	weapon_sprite_container.add_child(sprite__laser)
	
	# attk module
	attack_module = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AttackModules/Module_AttackModule_Laser.tscn").instance()
	attack_module.can_draw_laser = true
	attack_module.laser_color = Color("#DA0205")
	add_child(attack_module)
	
	# conn to target detection module
	#target_detection_module.connect("pinged_target_successfully", self, "_on_target_module_pinged_target_successfully__for_laser")
	
	# occlude relateds
	if aim_occulder_type == AimOccluderType.TILE_OCCLUDED:
		aim_occluder_module = preload("res://ObjectsRelated/Objects/Imps/BaseEnemy/AimOccluderModules/Module_AimOccluder.gd").new()
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
		robot_face.helper__eyes_look_toward_position(global_position)
	

func _on_target_module_pinged_target_successfully__for_attack(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target):
	if is_target_pos_occluded(arg_pos_target):
		
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
					
					var lookahead_duration = attack_module.LASER_DURATION__CHARGING + attack_module.LASER_DURATION__TO_MAX
					trajectory_modified_pos = get_modified_target_pos_using_aim_type__velo_predict(arg_pos_target, target_velocity, lookahead_duration)
					
				
				attack_module.target_pos_to_draw_laser_to = arg_pos_target
				sprite__laser.rotation = global_position.angle_to_point(arg_pos_target)
				
				robot_face.helper__eyes_look_toward_position(arg_pos_target)
		
		if last_calc_can_attack:
			_attempt_attack_target()
		

func _attempt_attack_target():
	if enemy_type == EnemyType.LASER:
		if !attack_module.is_in_fire_sequence():
			attack_module.start_fire_sequence()
			_current_attack_cooldown = ATTACK_COOLDOWN
			
		
		
		#can_not_attack_conditional_clause.attempt_insert_clause(CanNotAttackClauseIds.IS_ATTACKING)



#

func _physics_process(delta):
	if _current_attack_cooldown > 0:
		_set_current_attack_cooldown(_current_attack_cooldown - delta)
	

func _set_current_attack_cooldown(arg_val):
	_current_attack_cooldown = arg_val
	
	if _current_attack_cooldown <= 0:
		can_not_attack_conditional_clause.remove_clause(CanNotAttackClauseIds.IN_COOLDOWN)
	else:
		can_not_attack_conditional_clause.attempt_insert_clause(CanNotAttackClauseIds.IN_COOLDOWN)


# LASER SPECIFIC

#func _on_target_module_pinged_target_successfully__for_laser(arg_actual_distance, arg_threshold_distance, arg_refresh_rate, arg_pos_target, arg_angle, arg_target):
#	sprite__laser.rotation = arg_angle
#

#

func _on_CollForProjOrPlayer_body_entered(body):
	pass # Replace with function body.
	



###################### 
# REWIND RELATED
#####################

func get_rewind_save_state():
	return .get_rewind_save_state()

func load_into_rewind_save_state(arg_state):
	.load_into_rewind_save_state(arg_state)

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


