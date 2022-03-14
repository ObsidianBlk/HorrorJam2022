extends Node2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player_actor : Node2D = null
var _camera : Camera2D = null

var _input_dir = [0,0,0,0]


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	var pnodes = get_tree().get_nodes_in_group("Player")
	if pnodes.size() > 0:
		for p in pnodes:
			if p.has_method("move"):
				_player_actor = p
				break
	
	var cnodes = get_tree().get_nodes_in_group("ShakeCamera")
	if cnodes.size() > 0:
		for c in cnodes:
			if c.has_method("add_trauma"):
				_camera = c
				break

func _unhandled_input(event) -> void:
	if _player_actor == null:
		return
	
	if event is InputEventKey:
		if event.is_action_pressed("move_left"):
			_input_dir[0] = -1
		elif event.is_action_released("move_left"):
			_input_dir[0] = 0
		
		if event.is_action_pressed("move_right"):
			_input_dir[1] = 1
		elif event.is_action_released("move_right"):
			_input_dir[1] = 0
		
		if event.is_action_pressed("move_up"):
			_input_dir[2] = -1
		elif event.is_action_released("move_up"):
			_input_dir[2] = 0
		
		if event.is_action_pressed("move_down"):
			_input_dir[3] = 1
		elif event.is_action_released("move_down"):
			_input_dir[3] = 0
		
		if event.is_action_pressed("run_toggle"):
			_player_actor.set_running(true)
		elif event.is_action_released("run_toggle"):
			_player_actor.set_running(false)
		
		if event.is_action_pressed("test_key") and _camera != null:
			_camera.add_trauma(0.5)
		
		_player_actor.move(
			Vector2(
				_input_dir[0] + _input_dir[1],
				_input_dir[2] + _input_dir[3]
			).normalized()
		)
	elif event is InputEventJoypadMotion:
		pass


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

