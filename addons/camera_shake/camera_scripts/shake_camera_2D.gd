class_name ShakeCamera2D
extends Camera2D

export var max_offset : float = 5.0
export var max_roll : float = 5.0
export var shakeReduction : float = 2.5

var stress : float = 0.0
var shake : float = 0.0


func _process(_delta):  
	_process_shake(global_transform.origin, 0.0, _delta)
	


func _process_shake(center, angle, delta) -> void:
	shake = stress * stress

	#rotation_degrees = angle + (max_roll * shake *  _get_noise(randi(), delta))
	
	var offset_shake = Vector2()
	offset_shake.x = (max_offset * shake * _get_noise(randi(), delta + 1.0))
	offset_shake.y = (max_offset * shake * _get_noise(randi(), delta + 2.0))
	
	offset_h = offset_shake.x
	offset_v = offset_shake.y
	
	stress -= (shakeReduction / 100.0)
	
	stress = clamp(stress, 0.0, 1.0)


func _get_noise(noise_seed, time) -> float:
	var n = OpenSimplexNoise.new()
	
	n.seed = noise_seed
	n.octaves = 4
	n.period = 20.0
	n.persistence = 0.8
	
	return n.get_noise_1d(time)


func add_stress(amount : float) -> void:
	stress += amount
	stress = clamp(stress, 0.0, 1.0)
