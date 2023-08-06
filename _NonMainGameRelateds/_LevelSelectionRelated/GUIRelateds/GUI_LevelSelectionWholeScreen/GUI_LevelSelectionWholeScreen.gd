extends Control

const GUI_AbstractLevelLayout = preload("res://_NonMainGameRelateds/_LevelSelectionRelated/GUIRelateds/GUI_LevelLayout/GUI_AbstractLevelLayout.gd")

#

signal prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)

#

var _current_active_level_layout

var _layout_id_to_level_layout_map : Dictionary

#

onready var abstract_level_layout_container = $AbstractLevelLayoutContainer
onready var hud_container = $HUDContainer

onready var dialog_panel = $HUDContainer/DialogPanel
onready var level_title_tooltip_body = $HUDContainer/DialogPanel/Marginer/VBoxContainer/LevelTitleTooltipBody
onready var level_desc_tooltip_body = $HUDContainer/DialogPanel/Marginer/VBoxContainer/LevelDescTooltipBody

#

#############

func _ready():
	level_title_tooltip_body.bbcode_align_mode = level_title_tooltip_body.BBCodeAlignMode.CENTER

#

func show_level_layout__last_saved_in_save_manager():
	show_level_layout(GameSaveManager.last_opened_level_layout_id, GameSaveManager.last_hovered_over_level_layout_element_id)


func show_level_layout(arg_layout_id, arg_layout_element_id_of_cursor):
	for child in abstract_level_layout_container.get_children():
		if child.level_layout_id != arg_layout_id:
			_set_level_layout_as_inactive(child)
	
	#
	
	var layout_scene : GUI_AbstractLevelLayout
	if _layout_id_to_level_layout_map.has(arg_layout_id):
		layout_scene = _layout_id_to_level_layout_map[arg_layout_id]
	else:
		layout_scene = StoreOfLevelLayouts.generate_instance_of_layout(arg_layout_id)
		layout_scene.level_layout_id = arg_layout_id
		abstract_level_layout_container.add_child(layout_scene)
	
	
	layout_scene.layout_ele_id_to_summon_cursor_to = arg_layout_element_id_of_cursor
	_set_level_layout_as_current_and_active(layout_scene)


func _set_level_layout_as_inactive(layout_scene : GUI_AbstractLevelLayout):
	layout_scene.is_layout_enabled = false
	

func _set_level_layout_as_current_and_active(layout_scene : GUI_AbstractLevelLayout):
	GameSaveManager.last_opened_level_layout_id = layout_scene.level_layout_id
	
	_current_active_level_layout = layout_scene
	
	layout_scene.is_layout_enabled = true
	
	layout_scene.connect("currently_hovered_layout_ele_changed", self, "_on_layout_currently_hovered_layout_ele_changed")
	layout_scene.connect("prompt_entered_into_level", self, "_on_layout_prompt_entered_into_level")
	layout_scene.connect("prompt_entered_into_link_to_other_layout", self, "_on_layout_prompt_entered_into_link_to_other_layout")
	
	_on_layout_currently_hovered_layout_ele_changed(layout_scene.get_currently_hovered_layout_ele_id(), layout_scene.get_currently_hovered_tile())

#


func _update_level_desc_tooltip_body(arg_level_details):
	if arg_level_details != null:
		level_title_tooltip_body.descriptions = arg_level_details.level_name
		level_desc_tooltip_body.descriptions = arg_level_details.level_desc
		
		level_title_tooltip_body.update_display()
		level_desc_tooltip_body.update_display()
	else:
		level_title_tooltip_body.descriptions = []
		level_desc_tooltip_body.descriptions = []
		
		level_title_tooltip_body.update_display()
		level_desc_tooltip_body.update_display()
		
	


#

func _on_layout_currently_hovered_layout_ele_changed(arg_id, arg_currently_hovered_tile):
	_update_level_desc_tooltip_body(arg_currently_hovered_tile.level_details)
	

func _on_layout_prompt_entered_into_level(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	emit_signal("prompt_entered_into_level", arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id)
	

func _on_layout_prompt_entered_into_link_to_other_layout(arg_currently_hovered_tile, arg_currently_hovered_layout_ele_id):
	var level_layout_details = StoreOfLevelLayouts.get_or_construct_layout_details(arg_currently_hovered_tile.layout_id_to_link_to)
	
	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(level_layout_details.transition_id__entering_layout__out)
	transition.circle_center = arg_currently_hovered_tile.get_center_position()
	transition.connect("transition_finished", self, "_on_transition_in__from_old_layout_finished", [arg_currently_hovered_tile, level_layout_details, transition])
	SingletonsAndConsts.current_master.play_transition(transition)

func _on_transition_in__from_old_layout_finished(arg_hovered_tile, arg_level_layout_details, arg_old_transition):
	show_level_layout(arg_hovered_tile.layout_id_to_link_to, arg_hovered_tile.layout_ele_id_to_put_cursor_to)
	arg_old_transition.queue_free()
	
	var transition = SingletonsAndConsts.current_master.construct_transition__using_id(arg_level_layout_details.transition_id__entering_layout__in)
	transition.queue_free_on_end_of_transition = true
	transition.circle_center = arg_hovered_tile.get_center_position()
	SingletonsAndConsts.current_master.play_transition(transition)


