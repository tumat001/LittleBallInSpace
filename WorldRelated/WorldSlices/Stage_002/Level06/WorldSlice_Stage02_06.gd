extends "res://WorldRelated/AbstractWorldSlice.gd"



const VIS_INS__ANIM_NAME__HIDE_ALL = "hide_all"
const VIS_INS__ANIM_NAME__HIDE_EXCEPT_MOUSE = "hide_except_mouse"


onready var portal_for_transition = $ObjectContainer/Portal

onready var vis_ins_hide_hud = $MiscContainer/VisIns_HideHud
onready var vis_ins_hide_hud_anim_sprite : AnimatedSprite = vis_ins_hide_hud.anim_sprite_of_vis_ins
onready var vkp_hide_hud__all = $MiscContainer/VisIns_HideHud/VBoxContainer2/VKP_HideHud_All
onready var vkp_hide_hud__except_mouse = $MiscContainer/VisIns_HideHud/VBoxContainer2/VKP_HideHud_ExceptForMouse

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	game_elements.game_result_manager.end_game__as_win()
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	portal_for_transition.connect("player_entered__as_scene_transition", self, "_on_player_entered__as_scene_transition")



func _on_player_entered__as_scene_transition(arg_player):
	SingletonsAndConsts.current_game_elements.configure_game_state_for_cutscene_occurance(true, true)
	
	#
	
	StoreOfLevels.unlock_stage_03__and_start_at_stage_03_01_on_level_finish__if_appropriate()
	
	#
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_wait_after_portal_enter_done").set_delay(2.0)

func _on_wait_after_portal_enter_done():
	game_elements.game_result_manager.end_game__as_win()
	
	

#

func _ready() -> void:
	vis_ins_hide_hud_anim_sprite.connect("animation_finished", self, "_on_vis_ins_anim_finished")
	_swap_to_anim__hide_all()
	
	vkp_hide_hud__all.any_control_action_name = "toggle_hide_hud"
	vkp_hide_hud__except_mouse.any_control_action_name = "toggle_focus_mode" 


func _on_vis_ins_anim_finished():
	if vis_ins_hide_hud_anim_sprite.animation == VIS_INS__ANIM_NAME__HIDE_ALL:
		_swap_to_anim__hide_except_mouse()
	else:
		_swap_to_anim__hide_all()
		

func _swap_to_anim__hide_all():
	vis_ins_hide_hud_anim_sprite.animation = VIS_INS__ANIM_NAME__HIDE_ALL
	vkp_hide_hud__all.set_modulate_normal(Color("#F2F9BE"))
	vkp_hide_hud__except_mouse.set_modulate_normal(Color("#55cfcfcf"))

func _swap_to_anim__hide_except_mouse():
	vis_ins_hide_hud_anim_sprite.animation = VIS_INS__ANIM_NAME__HIDE_EXCEPT_MOUSE
	vkp_hide_hud__all.set_modulate_normal(Color("#55cfcfcf"))
	vkp_hide_hud__except_mouse.set_modulate_normal(Color("#F2F9BE"))

