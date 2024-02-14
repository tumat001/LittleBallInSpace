extends "res://MiscRelated/VisualsRelated/VisualInstructionsRelated/BaseVisualInstruction.gd"


#

#enum AnimResIds {
#	BALL_SHOOT = 0,
#	GLASS_HOVER_MOUSE = 1,
#}
#export(int) var anim_res_id_to_use : int = -1 setget set_anim_res_id_to_use

export(float) var initial_delay_before_anim_loop__after_start_display_finished : float = 0.5

#


onready var anim_sprite_of_vis_ins = $AnimSpriteOfVisIns

#

#func set_anim_res_id_to_use(arg_id):
#	if !is_inside_tree():
#		return
#
#	var sprite_frames : SpriteFrames
#	match arg_id:
#		AnimResIds.BALL_SHOOT:
#			sprite_frames = load("res://MiscRelated/VisualsRelated/VisualInstructionsRelated/Res/VisIns_BallShoot.tres")
#		AnimResIds.GLASS_HOVER_MOUSE:
#			sprite_frames = load("res://MiscRelated/VisualsRelated/VisualInstructionsRelated/Res/VisIns_GlassHoverMouse.tres")
#
#	anim_sprite_of_vis_ins.frames = sprite_frames

#

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	anim_sprite_of_vis_ins.stop()
	connect("start_display_finished", self, "_on_start_display_finished", [], CONNECT_ONESHOT)

func _on_start_display_finished():
	var tweener = create_tween()
	tweener.tween_interval(initial_delay_before_anim_loop__after_start_display_finished)
	tweener.tween_callback(anim_sprite_of_vis_ins, "play")
