extends ParallaxLayer

const BackgroundEle_Star = preload("res://GameBackgroundRelated/Subs/Star/BackgroundEle_Star.gd")
const BackgroundEle_Star_Scene = preload("res://GameBackgroundRelated/Subs/Star/BackgroundEle_Star.tscn")

#

export(int) var star_count__at_start : int

export(Vector2) var grid_size : Vector2
export(Vector2) var grid_cell_size : Vector2

# if (1,1), then consume grid cells within 1,1 count (or within grid_cell_size dist)
export(Vector2) var grid_cell_dist_count_consume_on_star_placed : Vector2

#

export(int) var visible_star_count : int = 8 setget set_visible_star_count
var _current_visible_stars : Array

export(float) var delay_per_star_show_or_hide : float = 0.25

#

var _available_grid_cell_poses : Array

#

var _rng_to_use : RandomNumberGenerator

#

var _all_stars : Array

#

var _is_in_ready : bool

#

var _star_vis_setter_tweener : SceneTreeTween

#

const NO_SPACE_LEFT_VECTOR = Vector2(-9999, -9999)

###

func _ready():
	_is_in_ready = true
	_rng_to_use = StoreOfRNG.get_rng(StoreOfRNG.RNGSource.NON_ESSENTIAL)
	_init__available_grid_cell_poses()
	_populate_with_stars()
	set_visible_star_count(visible_star_count)
	
	#position -= (Vector2(960, 540)) * scale
	
	#_init_poses_of_children()
	
	_is_in_ready = false

func _init__available_grid_cell_poses():
	var interval = grid_size / grid_cell_size
	for i__x in interval.x:
		for i__y in interval.y:
			_available_grid_cell_poses.append(Vector2(grid_cell_size.x * i__x, grid_cell_size.y * i__y))

#func _init_poses_of_children():
#	for child in get_children():
#		child.position += (Vector2(960, 540) / 2) - (grid_size / 2)
#

##

func _populate_with_stars():
	for i in star_count__at_start:
		var success = _populate__one_star()
		if !success:
			print("no more star space left")
			break
	

func _populate__one_star() -> bool:
	var pos = _get_random_ele_in_available_grid_cell_poses__and_consume_nearby()
	if pos == NO_SPACE_LEFT_VECTOR:
		return false
	else:
		_create_and_configure_star(pos)
		
		return true

func _create_and_configure_star(arg_pos):
	var star = BackgroundEle_Star_Scene.instance()
	
	star.position = arg_pos - global_position #- #(grid_size / 2)
	
	_all_stars.append(star)
	call_deferred("_deferred_add_star_as_child", star)
	
	return star

#

func _deferred_add_star_as_child(arg_star):
	add_child(arg_star)

#

func _get_random_ele_in_available_grid_cell_poses__and_consume_nearby() -> Vector2:
	if _available_grid_cell_poses.size() != 0:
		var pos = StoreOfRNG.randomly_select_one_element(_available_grid_cell_poses, _rng_to_use)
		_consume_grid_cell_poses_near_pos(pos)
		return pos
	else:
		return NO_SPACE_LEFT_VECTOR

func _consume_grid_cell_poses_near_pos(arg_pos : Vector2):
	var dist_of_check = grid_cell_size * grid_cell_dist_count_consume_on_star_placed
	for pos in _available_grid_cell_poses:
		if arg_pos.distance_to(pos) <= dist_of_check.length():
			_available_grid_cell_poses.erase(pos)

##

func set_visible_star_count(arg_val):
	var old_val = visible_star_count
	visible_star_count = arg_val
	
	if old_val != arg_val or _is_in_ready:
		if is_inside_tree():
			if _current_visible_stars.size() > visible_star_count:
				_hide_stars_until_vis_count_met()
				
			else:
				_show_stars_until_vis_count_met()
				


func _hide_stars_until_vis_count_met():
	_start_star_vis_setter_tweener__hide_until()
	

func _show_stars_until_vis_count_met():
	_start_star_vis_setter_tweener__show_until()
	

func _kill_star_vis_setter_tweener():
	if _star_vis_setter_tweener != null:
		_star_vis_setter_tweener.kill()
		_star_vis_setter_tweener = null


func _start_star_vis_setter_tweener__show_until():
	_kill_star_vis_setter_tweener()
	
	_star_vis_setter_tweener = create_tween()
	_star_vis_setter_tweener.set_loops()
	_star_vis_setter_tweener.tween_callback(self, "_show_star__via_setter_tweener")
	_star_vis_setter_tweener.tween_interval(delay_per_star_show_or_hide)

func _show_star__via_setter_tweener():
	var index = _current_visible_stars.size()
	
	if index + 1 >= visible_star_count:
		_kill_star_vis_setter_tweener()
	
	var star_at_all_index = _all_stars[index]
	_current_visible_stars.append(star_at_all_index)
	
	star_at_all_index.set_is_invis(false, true)
	
	#print("curr_pos: %s" % global_position)
	#print("showing %s" % star_at_all_index.global_position)

func _start_star_vis_setter_tweener__hide_until():
	_kill_star_vis_setter_tweener()
	
	_star_vis_setter_tweener = create_tween()
	_star_vis_setter_tweener.set_loops()
	_star_vis_setter_tweener.tween_callback(self, "_hide_star__via_setter_tweener")
	_star_vis_setter_tweener.tween_interval(delay_per_star_show_or_hide)

func _hide_star__via_setter_tweener():
	var star = _current_visible_stars.pop_back()
	
	star.set_is_invis(true, true)
	
	if _current_visible_stars.size() == visible_star_count:
		_kill_star_vis_setter_tweener()

