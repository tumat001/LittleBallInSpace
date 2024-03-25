extends "res://WorldRelated/AbstractWorldSlice.gd"

const Shader_Rainbow = preload("res://MiscRelated/ShadersRelated/Shader_PickupableOutline_Rainbow.tres")

const GameLogo_BannerSized = preload("res://_NonMainGameRelateds/GameDetails/ALBIS_GameLogo_450x260.png")


#

const ROTATION_FOR_AIM_ARROW__DIFF : float = PI/5
#var toggle_aim_arrow_anim_full_duration
var per_toggle_mode_show_duration : float = 2.0

#

var _launch_ball_modi

var _is_displaying_switch_aim_mode : bool

#

var _ghost_vis_tweener : SceneTreeTween

var _toggle_aim_mode_arrow_rotation_tweener : SceneTreeTween

var _launch_ball_panel

#

onready var vkp_launch_ball = $MiscContainer/VisIns_BallShoot/VKP_LaunchBall
#onready var vkp_rewind = $MiscContainer/VBoxContainer2/VKP_Rewind

onready var CDSU_pickupable_launcher = $ObjectContainer/CDSUPickupable_Launcher
onready var CDSU_pickupable_remote = $ObjectContainer/CDSUPickupable_Remote
onready var CDSU_pickupable_remote__sprite = $ObjectContainer/CDSUPickupable_Remote/Sprite

onready var god_rays_sprite = $MiscContainer/GodRays

#onready var launch_ball_ins_label = $MiscContainer/LaunchBallInsLabel
#onready var rewind_reminder_label = $MiscContainer/RewindReminderLabel

onready var PDAR_fakeout_disable_rewind = $AreaRegionContainer/PDAreaRegion_Fakeout_DisableRewind

onready var PDAR_near_fakeout = $AreaRegionContainer/PDAreaRegion_NearFakeout


#onready var vbox_container_01__launch_ball_tut_panel = $MiscContainer/VBoxContainer
#onready var vbox_container_02__rewind_reminder_panel = $MiscContainer/VBoxContainer2

onready var vis_ins_anim__ball_shoot = $MiscContainer/VisIns_BallShoot

onready var ghost_sprite = $MiscContainer/GhostSprite01
onready var ghost_sprite_vis_notif_2d = $MiscContainer/GhostSprite01/GhostSpriteVisibilityNotifier2D

onready var vis_ins_anim__toggle_aim_mode = $MiscContainer/VisIns_ToggleAimMode
onready var vis_ins_anim__toggle_aim_mode__anim_sprite = vis_ins_anim__toggle_aim_mode.anim_sprite_of_vis_ins
onready var vis_ins_anim__toggle_aim_mode__arrow_sprite = $MiscContainer/VisIns_ToggleAimMode/ToggleAimArrowSprite

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	

func as_test__override__do_insta_win():
	#as_test__override__do_insta_win__template_capture_all_points()
	
	GameSettingsManager.set_game_control_name_string__is_hidden("game_launch_ball", false)
	game_elements.game_result_manager.attempt_set_current_game_result(game_elements.game_result_manager.GameResult.WIN)
	_do_game_state_modifying_actions__setup_for_layout_02()
	
	
	StoreOfLevels.unlock_stage_02__and_start_at_stage_02_01_on_level_finish__if_appropriate()
	call_deferred("_deferred_do_insta_win")

func _deferred_do_insta_win():
	game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()


func _ready():
	pass
	#vbox_container_01__launch_ball_tut_panel.modulate.a = 0
	#vbox_container_02__rewind_reminder_panel.modulate.a = 0

#

func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CDSU_pickupable_launcher.connect("player_entered_self__custom_defined", self, "_on_player_entered_self__custom_defined__launcher")
	CDSU_pickupable_remote.set_collidable_with_player(false)
	
	_configure_labels()
	
	PDAR_fakeout_disable_rewind.connect("player_entered_in_area", self, "_on_player_entered_PDAR_fakeout_disable_rewind", [], CONNECT_ONESHOT)
	
	PDAR_near_fakeout.connect("player_entered_in_area", self, "_on_player_entered_in_area__PDAR_near_fakeout", [], CONNECT_ONESHOT)
	
	_init_ghost_sprite()
	
	if game_elements.is_game_front_hud_initialized:
		_on_GFH_initialized(game_elements.game_front_hud)
	else:
		game_elements.connect("game_front_hud_initialized", self, "_on_GFH_initialized", [], CONNECT_ONESHOT)


func _on_GFH_initialized(arg_GFH):
	_launch_ball_panel = SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel
	_launch_ball_panel.template__setup_starting_animations()


func _configure_labels():
	#var orig_text__launch_ball = launch_ball_ins_label.text
	#var launch_ball_keypress_text = InputMap.get_action_list("game_launch_ball")[0].as_text()
	#launch_ball_ins_label.text = orig_text__launch_ball % [launch_ball_keypress_text, launch_ball_keypress_text]
	
	#var orig_text__reminder_label = rewind_reminder_label.text
	#rewind_reminder_label.text = orig_text__reminder_label % [InputMap.get_action_list("rewind")[0].as_text()]
	
	#var orig_text__launch_ball = vkp_launch_ball.text_for_keypress
	#vkp_launch_ball.text_for_keypress = orig_text__launch_ball % InputMap.get_action_list("game_launch_ball")[0].as_text()
	vkp_launch_ball.game_control_action_name = "game_launch_ball"
	
	#var orig_text__reminder_label = vkp_rewind.text_for_keypress
	#vkp_rewind.text_for_keypress = orig_text__reminder_label % [InputMap.get_action_list("rewind")[0].as_text()]
	#vkp_rewind.game_control_action_name = "rewind"

############

func _on_player_entered_self__custom_defined__launcher():
	var player_pos = game_elements.get_current_player().global_position
	
	var param = PickupImportantItemCutsceneParam.new()
	param.item_texture = CDSU_pickupable_launcher.sprite.texture
	param.staring_pos = CDSU_pickupable_launcher.global_position
	param.ending_pos = player_pos
	
	helper__start_cutscene_of_pickup_important_item(param, self, "_on_item_cutscene_end", null)
	
	StoreOfAudio.BGM_playlist_catalog.stop_play()
	
#	game_elements.configure_game_state_for_cutscene_occurance(true, true)
#	AudioManager.helper__play_sound_effect__plain(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallModi, 1.0, null)
#
#	_play_animations_for_acquiring_launcher()
#
#func _play_animations_for_acquiring_launcher():
#	_on_end_of_animations_for_acquiring_launcher()
#


#func _on_end_of_animations_for_acquiring_launcher():
func _on_item_cutscene_end(arg_param):
	_add_launch_ball_modi()
	
	SingletonsAndConsts.current_game_front_hud.template__start_focus_on_launch_ball_panel__with_glow_up(0.4, self, "_on_highlight_launchball_panel_ended", null)
	_launch_ball_panel.template__play_tween_start_startup_animation()
	
	var BGM_playlist_id_to_play = StoreOfAudio.BGMPlaylistId.RISING_01
	if !StoreOfAudio.is_BGM_playlist_id_playing(BGM_playlist_id_to_play):
		StoreOfAudio.BGM_playlist_catalog.start_play_audio_play_list(BGM_playlist_id_to_play)
	


func _on_highlight_launchball_panel_ended(arg_param):
	_start_hide_god_rays()
	
	game_elements.configure_game_state_for_end_of_cutscene_occurance(true)
	#game_elements.allow_rewind_manager_to_store_and_cast_rewind()
	#_start_remote_dialog__01()


func _add_launch_ball_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	modi.starting_ball_count = 0
	modi.show_player_trajectory_line = false
	modi.can_change_aim_mode = false
	_launch_ball_modi = modi
	game_elements.player_modi_manager.add_modi_to_player(modi)
	
	modi.can_launch_player_when_on_air = false

func _start_hide_god_rays():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(god_rays_sprite, "modulate:a", 0.0, 2.0)
	tweener.tween_callback(self, "_make_god_rays_sprite_invisible")

func _make_god_rays_sprite_invisible():
	god_rays_sprite.visible = false


#######


func _on_PDAR_LaunchBallControlUnhide_player_entered_in_area():
	GameSettingsManager.set_game_control_name_string__is_hidden("game_launch_ball", false)
	
	vis_ins_anim__ball_shoot.start_display()
	

#

func _on_player_entered_in_area__PDAR_near_fakeout():
	StoreOfAudio.BGM_playlist_catalog.start_play_audio_play_list(StoreOfAudio.BGMPlaylistId.SPECIALS_01, StoreOfAudio.AudioIds.BGM_Special01_FakeoutSuspense)
	
	#
	
	_launch_ball_modi.can_launch_player_when_on_air = true

#######

func _on_player_entered_PDAR_fakeout_disable_rewind():
	game_elements.ban_rewind_manager_to_store_and_cast_rewind()
	game_elements.game_result_manager.attempt_set_current_game_result(game_elements.game_result_manager.GameResult.WIN)
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_player_entered_PDAR_fakeout_disable_rewind__after_delay").set_delay(2.5)


func _on_player_entered_PDAR_fakeout_disable_rewind__after_delay():
	game_elements.configure_game_state_for_cutscene_occurance(false, true)
	
	CameraManager.set_current_default_zoom_normal_vec(Vector2(2, 2), true, 2.0)
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_fakeout_zoom_out_complete").set_delay(2.5)
	
	
	######
	_do_game_state_modifying_actions__setup_for_layout_02()
	


func _on_fakeout_zoom_out_complete():
	_start_show_game_logo()
	
	var tweener = create_tween()
	tweener.tween_callback(self, "_on_delay_for_game_end_complete").set_delay(4.5)



func _start_show_game_logo():
	var logo_tex_rect = TextureRect.new()
	logo_tex_rect.texture = GameLogo_BannerSized
	logo_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_tex_rect.modulate.a = 0
	
	SingletonsAndConsts.current_game_front_hud.misc_center_container.add_child(logo_tex_rect)
	
	var mod_a_tweener = create_tween()
	mod_a_tweener.tween_property(logo_tex_rect, "modulate:a", 1.0, 1.5)


func _on_delay_for_game_end_complete():
	#game_elements.game_result_manager.set_current_game_result_as_win__and_instant_end()
	game_elements.game_result_manager.special_case__end_game__as_win()



########

func _do_game_state_modifying_actions__setup_for_layout_02():
	var lin_vel : Vector2 = game_elements.get_current_player().linear_velocity
	GameSaveManager.set_metadata_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_2, [lin_vel.x, lin_vel.y, true])
	
	#
	
	StoreOfLevels.unlock_stage_02__and_start_at_stage_02_01_on_level_finish__if_appropriate()


#########

func _init_ghost_sprite():
	ghost_sprite.modulate.a = 0.5
	ghost_sprite_vis_notif_2d.connect("screen_entered", self, "_on_ghost_vis_notifier_screen_entered", [], CONNECT_ONESHOT)

func _on_ghost_vis_notifier_screen_entered() -> void:
	var tweener = create_tween()
	tweener.tween_interval(2.75)
	tweener.tween_callback(self, "_tween_hide_ghost_then_queue_free", [0.75])
	
	_ghost_vis_tweener = tweener
	
	##
	
	if !CameraManager.is_connected("camera_zoom_changed", self, "_on_camera_zoom_changed_on_ghost_in_screen"):
		CameraManager.connect("camera_zoom_changed", self, "_on_camera_zoom_changed_on_ghost_in_screen")


func _on_camera_zoom_changed_on_ghost_in_screen(arg_is_default_zoom):
	if !arg_is_default_zoom:
		_tween_hide_ghost_then_queue_free(0.2)

func _disconnect_cam_manager_zoom_changed_for_ghost():
	if CameraManager.is_connected("camera_zoom_changed", self, "_on_camera_zoom_changed_on_ghost_in_screen"):
		CameraManager.disconnect("camera_zoom_changed", self, "_on_camera_zoom_changed_on_ghost_in_screen")

func _tween_hide_ghost_then_queue_free(arg_fade_duration : float):
	var hide_tweener = create_tween()
	hide_tweener.tween_property(ghost_sprite, "modulate:a", 0.0, arg_fade_duration)
	hide_tweener.tween_callback(ghost_sprite, "queue_free")
	
	if _ghost_vis_tweener != null and _ghost_vis_tweener.is_valid():
		_ghost_vis_tweener.kill()
	
	_disconnect_cam_manager_zoom_changed_for_ghost()


########

func _on_PDAR_ActivateVisIns_ToggleAim_player_entered_in_area() -> void:
	#_config_toggle_aim_arrow_durations_related_based_on_res()
	vis_ins_anim__toggle_aim_mode__anim_sprite.play("omni")
	
	vis_ins_anim__toggle_aim_mode.start_display()
	vis_ins_anim__toggle_aim_mode.connect("start_display_finished", self, "_on_vis_ins_anim__toggle_aim_mode__start_display_finished", [], CONNECT_ONESHOT)
	#_start_show_toggle_aim__as_omni()
	
	_launch_ball_modi.set_can_change_aim_mode(true)

#func _config_toggle_aim_arrow_durations_related_based_on_res():
#	var sprite_frames : SpriteFrames = vis_ins_anim__toggle_aim_mode__anim_sprite.frames
#	toggle_aim_arrow_anim_full_duration = sprite_frames.get_frame_count("default") / sprite_frames.get_animation_speed("default")
#	per_toggle_mode_show_duration = toggle_aim_arrow_anim_full_duration/2

func _on_vis_ins_anim__toggle_aim_mode__start_display_finished():
	_start_show_toggle_aim__as_omni()


func _start_show_toggle_aim__as_omni():
	vis_ins_anim__toggle_aim_mode__anim_sprite.play("omni")
	
	_kill_tweener_toggle_aim_arrow_if_valid()
	_tween_toggle_aim_arrow_rotation__as_omni()
	_toggle_aim_mode_arrow_rotation_tweener.tween_callback(self, "_start_show_toggle_aim__as_snap")

func _kill_tweener_toggle_aim_arrow_if_valid():
	if _toggle_aim_mode_arrow_rotation_tweener != null and _toggle_aim_mode_arrow_rotation_tweener.is_valid():
		_toggle_aim_mode_arrow_rotation_tweener.kill()


func _tween_toggle_aim_arrow_rotation__as_omni():
	_toggle_aim_mode_arrow_rotation_tweener = create_tween()
	_toggle_aim_mode_arrow_rotation_tweener.tween_property(vis_ins_anim__toggle_aim_mode__arrow_sprite, "rotation", -ROTATION_FOR_AIM_ARROW__DIFF, per_toggle_mode_show_duration/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_toggle_aim_mode_arrow_rotation_tweener.tween_property(vis_ins_anim__toggle_aim_mode__arrow_sprite, "rotation", ROTATION_FOR_AIM_ARROW__DIFF, per_toggle_mode_show_duration/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_toggle_aim_mode_arrow_rotation_tweener.tween_property(vis_ins_anim__toggle_aim_mode__arrow_sprite, "rotation", 0.0, per_toggle_mode_show_duration/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	


func _start_show_toggle_aim__as_snap():
	vis_ins_anim__toggle_aim_mode__anim_sprite.play("snap")
	
	_kill_tweener_toggle_aim_arrow_if_valid()
	_tween_toggle_aim_arrow_rotation__as_snap()
	_toggle_aim_mode_arrow_rotation_tweener.tween_callback(self, "_start_show_toggle_aim__as_omni")

func _tween_toggle_aim_arrow_rotation__as_snap():
	_toggle_aim_mode_arrow_rotation_tweener = create_tween()
	_toggle_aim_mode_arrow_rotation_tweener.tween_interval(per_toggle_mode_show_duration/4)
	_toggle_aim_mode_arrow_rotation_tweener.tween_callback(self, "_set_toggle_aim_mode_arrow_rotation", [-ROTATION_FOR_AIM_ARROW__DIFF])
	_toggle_aim_mode_arrow_rotation_tweener.tween_interval(per_toggle_mode_show_duration/4)
	_toggle_aim_mode_arrow_rotation_tweener.tween_callback(self, "_set_toggle_aim_mode_arrow_rotation", [0.0])
	_toggle_aim_mode_arrow_rotation_tweener.tween_interval(per_toggle_mode_show_duration/4)
	_toggle_aim_mode_arrow_rotation_tweener.tween_callback(self, "_set_toggle_aim_mode_arrow_rotation", [ROTATION_FOR_AIM_ARROW__DIFF])
	_toggle_aim_mode_arrow_rotation_tweener.tween_interval(per_toggle_mode_show_duration/4)
	_toggle_aim_mode_arrow_rotation_tweener.tween_callback(self, "_set_toggle_aim_mode_arrow_rotation", [0.0])
	_toggle_aim_mode_arrow_rotation_tweener.tween_interval(per_toggle_mode_show_duration/4)

func _set_toggle_aim_mode_arrow_rotation(arg_rot : float):
	vis_ins_anim__toggle_aim_mode__arrow_sprite.rotation = arg_rot




