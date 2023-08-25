extends "res://WorldRelated/AbstractWorldSlice.gd"

const Shader_Rainbow = preload("res://MiscRelated/ShadersRelated/Shader_PickupableOutline_Rainbow.tres")

const GameLogo_BannerSized = preload("res://_NonMainGameRelateds/GameDetails/ALBIS_GameLogo_450x260.png")


#

var _launch_ball_modi

var _is_displaying_switch_aim_mode : bool

#

onready var vkp_launch_ball = $MiscContainer/VBoxContainer/VKP_LaunchBall
onready var vkp_rewind = $MiscContainer/VBoxContainer2/VKP_Rewind


onready var CDSU_pickupable_launcher = $ObjectContainer/CDSUPickupable_Launcher
onready var CDSU_pickupable_remote = $ObjectContainer/CDSUPickupable_Remote
onready var CDSU_pickupable_remote__sprite = $ObjectContainer/CDSUPickupable_Remote/Sprite

onready var god_rays_sprite = $MiscContainer/GodRays

onready var PDAR_cancel_dialog_remote = $AreaRegionContainer/PDAreaRegion_CancelDialog02

#onready var launch_ball_ins_label = $MiscContainer/LaunchBallInsLabel
#onready var rewind_reminder_label = $MiscContainer/RewindReminderLabel

onready var PDAR_fakeout_disable_rewind = $AreaRegionContainer/PDAreaRegion_Fakeout_DisableRewind

onready var PDAR_near_fakeout = $AreaRegionContainer/PDAreaRegion_NearFakeout

#

func _init():
	can_spawn_player_when_no_current_player_in_GE = true
	


func _on_after_game_start_init():
	._on_after_game_start_init()
	
	CDSU_pickupable_launcher.connect("player_entered_self__custom_defined", self, "_on_player_entered_self__custom_defined__launcher")
	CDSU_pickupable_remote.set_collidable_with_player(false)
	
	_configure_labels()
	
	PDAR_fakeout_disable_rewind.connect("player_entered_in_area", self, "_on_player_entered_PDAR_fakeout_disable_rewind", [], CONNECT_ONESHOT)
	
	PDAR_near_fakeout.connect("player_entered_in_area", self, "_on_player_entered_in_area__PDAR_near_fakeout", [], CONNECT_ONESHOT)


func _configure_labels():
	#var orig_text__launch_ball = launch_ball_ins_label.text
	#var launch_ball_keypress_text = InputMap.get_action_list("game_launch_ball")[0].as_text()
	#launch_ball_ins_label.text = orig_text__launch_ball % [launch_ball_keypress_text, launch_ball_keypress_text]
	
	#var orig_text__reminder_label = rewind_reminder_label.text
	#rewind_reminder_label.text = orig_text__reminder_label % [InputMap.get_action_list("rewind")[0].as_text()]
	
	var orig_text__launch_ball = vkp_launch_ball.text_for_keypress
	vkp_launch_ball.text_for_keypress = orig_text__launch_ball % InputMap.get_action_list("game_launch_ball")[0].as_text()
	
	var orig_text__reminder_label = vkp_rewind.text_for_keypress
	vkp_rewind.text_for_keypress = orig_text__reminder_label % [InputMap.get_action_list("rewind")[0].as_text()]
	

############

func _on_player_entered_self__custom_defined__launcher():
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Pickupable_LaunchBallModi, 1.0, null)
	
	_play_animations_for_acquiring_launcher()

func _play_animations_for_acquiring_launcher():
	_on_end_of_animations_for_acquiring_launcher()
	


func _on_end_of_animations_for_acquiring_launcher():
	_add_launch_ball_modi()
	
	_start_hide_god_rays()
	_start_remote_dialog__01()


func _add_launch_ball_modi():
	var modi = StoreOfPlayerModi.load_modi(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	modi.starting_ball_count = 0
	modi.show_player_trajectory_line = false
	modi.can_change_aim_mode = false
	_launch_ball_modi = modi
	game_elements.player_modi_manager.add_modi_to_player(modi)

func _start_hide_god_rays():
	var tweener = create_tween()
	tweener.set_parallel(false)
	tweener.tween_property(god_rays_sprite, "modulate:a", 0.0, 2.0)
	tweener.tween_callback(self, "_make_god_rays_sprite_invisible")

func _make_god_rays_sprite_invisible():
	god_rays_sprite.visible = false



func _start_remote_dialog__01():
	var dialog_desc = [
		["Is anyone there? Did you take the ball launcher?", []],
		["Anyways, pick up the remote control so we can talk.", []]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__01", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()


func _on_display_of_desc_finished__01(arg_metadata):
	game_elements.configure_game_state_for_end_of_cutscene_occurance(false)
	
	CDSU_pickupable_remote__sprite.material.shader = Shader_Rainbow
	CDSU_pickupable_remote.set_collidable_with_player(true)
	CDSU_pickupable_remote.connect("player_entered_self__custom_defined", self, "_on_player_entered_self__custom_defined__remote")
	


func _on_player_entered_self__custom_defined__remote():
	game_elements.configure_game_state_for_cutscene_occurance(true, true)
	AudioManager.helper__play_sound_effect__plain__major(StoreOfAudio.AudioIds.SFX_Pickupable_RemoteControl, 1.0, null)
	
	_start_remote_dialog__02()

func _start_remote_dialog__02():
	var dialog_desc = [
		[".....", []],
		#["Oh, is this %s?" % GameSaveManager.player_name, []],
		["Oh, could this be?", []],
		["Ok. There's an escape pod in ship. It's near the snacks area.", []],
		
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__02", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 0, null)


func _on_display_of_desc_finished__02(arg_metadata):
	game_elements.configure_game_state_for_end_of_cutscene_occurance(false)
	
	PDAR_cancel_dialog_remote.connect("player_entered_in_area", self, "_on_PDAR_cancel_dialog_remote_player_entered_area")


func _on_PDAR_cancel_dialog_remote_player_entered_area():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	
	game_elements.allow_rewind_manager_to_store_and_cast_rewind()

#######

func _on_player_entered_in_area__PDAR_near_fakeout():
	var dialog_desc = [
		["You're near the escape pod!", []],
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__03", [], CONNECT_ONESHOT)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 0, null)
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()
	
	#
	
	StoreOfAudio.BGM_playlist_catalog.start_play_audio_play_list(StoreOfAudio.BGMPlaylistId.SPECIALS_01, StoreOfAudio.AudioIds.BGM_Special01_FakeoutSuspense)
	


func _on_display_of_desc_finished__03(arg_metadata):
	var timer_tweener = create_tween()
	timer_tweener.tween_callback(self, "_on_delay_after_displaying_desc_03").set_delay(2.0)

func _on_delay_after_displaying_desc_03():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()


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
	game_elements.game_result_manager.end_game__as_win()
	



########

func _do_game_state_modifying_actions__setup_for_layout_02():
	var lin_vel : Vector2 = game_elements.get_current_player().linear_velocity
	GameSaveManager.set_metadata_of_level_id(StoreOfLevels.LevelIds.LEVEL_01__STAGE_2, [lin_vel.x, lin_vel.y, true])
	
	#
	
	GameSaveManager.unlock_stage_02__and_start_at_stage_02_01_on_level_finish__if_appropriate()


####

func _on_PDAR_TeachAndEnableAimMode_player_entered_in_area():
	#_launch_ball_modi.can_change_aim_mode = true
	var launch_ball_modi = game_elements.player_modi_manager.get_modi_or_null(StoreOfPlayerModi.PlayerModiIds.LAUNCH_BALL)
	
	var dialog_desc = [
		["Look at the bottom left, and you'll see a glowing button. Click it to toggle between aim modes.", []]
	]
	
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.connect("display_of_desc_finished", self, "_on_display_of_desc_finished__teach_toggle_aim")
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.start_display_of_descs(dialog_desc, 1.5, 15.0, null)
	SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel.connect("toggle_button_of_mode_change_pressed", self, "_on_toggle_button_of_mode_change_pressed")
	SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel.show_highlight_of_aim_mode_swap_button()
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.show_self()
	_is_displaying_switch_aim_mode = true

func _on_toggle_button_of_mode_change_pressed():
	_end_show_of_change_aim_mode()

func _on_display_of_desc_finished__teach_toggle_aim(arg_metadata):
	_end_show_of_change_aim_mode()

func _end_show_of_change_aim_mode():
	SingletonsAndConsts.current_game_front_hud.game_dialog_panel.hide_self()
	SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel.end_highlight_of_aim_mode_swap_button()
	
	if SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel.is_connected("toggle_button_of_mode_change_pressed", self, "_on_toggle_button_of_mode_change_pressed"):
		SingletonsAndConsts.current_game_front_hud.ability_panel.launch_ball_ability_panel.disconnect("toggle_button_of_mode_change_pressed", self, "_on_toggle_button_of_mode_change_pressed")
	
	if SingletonsAndConsts.current_game_front_hud.game_dialog_panel.is_connected("display_of_desc_finished", self, "_on_display_of_desc_finished__teach_toggle_aim"):
		SingletonsAndConsts.current_game_front_hud.game_dialog_panel.disconnect("display_of_desc_finished", self, "_on_display_of_desc_finished__teach_toggle_aim")
	
	_is_displaying_switch_aim_mode = false




func _on_PDAR_EndTeachAimMode_player_entered_in_area():
	if _is_displaying_switch_aim_mode:
		_end_show_of_change_aim_mode()


func _on_PDAR_LaunchBallControlUnhide_player_entered_in_area():
	GameSaveManager.set_game_control_name_string__is_hidden("game_launch_ball", false)
	


