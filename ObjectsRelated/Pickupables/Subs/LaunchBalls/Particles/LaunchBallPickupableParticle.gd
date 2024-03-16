extends AnimatedSprite

signal destination_reached()


const anim_name__red = "red"
const anim_name__green = "green"
const anim_name__blue = "blue"
const anim_name__white = "white"

#

const DURATION__TO_FIRST_DEST : float = 0.2

#

var curr_tweener : SceneTreeTween

var pitch_to_use : float

#

func change_anim_to_anim_name(arg_name):
	play(arg_name)
	

#

func play_particle_effect_actions(arg_initial_dest_pos : Vector2, arg_final_dest_pos : Vector2, arg_delay_for_final_dest : float):
	_play_particle_effect_action__pos_changes(arg_initial_dest_pos, arg_final_dest_pos, arg_delay_for_final_dest)


func _play_particle_effect_action__pos_changes(arg_initial_dest_pos : Vector2, arg_final_dest_pos : Vector2, arg_delay : float):
	var duration = DURATION__TO_FIRST_DEST
	
	var initial_pos_tween = create_tween()
	initial_pos_tween.set_parallel(true)
	initial_pos_tween.tween_property(self, "global_position:x", arg_initial_dest_pos.x, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	initial_pos_tween.tween_property(self, "global_position:y", arg_initial_dest_pos.y, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	initial_pos_tween.tween_callback(self, "_on_initial_pos_tween_finished", [arg_final_dest_pos]).set_delay(duration + arg_delay)
	
	curr_tweener = initial_pos_tween

func _on_initial_pos_tween_finished(arg_final_dest_pos : Vector2):
	var duration = 0.4
	
	var final_pos_tween = create_tween()
	final_pos_tween.set_parallel(true)
	final_pos_tween.tween_property(self, "global_position:x", arg_final_dest_pos.x, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	final_pos_tween.tween_property(self, "global_position:y", arg_final_dest_pos.y, duration).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	final_pos_tween.tween_callback(self, "_on_final_pos_tween_finished").set_delay(duration)
	
	curr_tweener = final_pos_tween

func _on_final_pos_tween_finished():
	visible = false
	emit_signal("destination_reached")

#func _process(delta):
#	print("%s, %s, %s" % [global_position, modulate.a, visible])


func _ready() -> void:
	var rewind_manager = SingletonsAndConsts.current_rewind_manager
	if is_instance_valid(rewind_manager):
		rewind_manager.connect("rewinding_started", self, "_on_rewinding_started")

func _on_rewinding_started():
	if curr_tweener != null and curr_tweener.is_valid():
		curr_tweener.kill()
	
	visible = false


