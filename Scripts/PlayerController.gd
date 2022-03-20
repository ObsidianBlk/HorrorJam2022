extends Node


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : KinematicBody2D = null
var _input_dir = [0,0,0,0]

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_Prepare()


func _unhandled_input(event) -> void:
	if _player == null or not _player.is_inside_tree():
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
			_player.set_running(true)
		elif event.is_action_released("run_toggle"):
			_player.set_running(false)
		
		if event.is_action_pressed("interact"):
			_player.interact()
		
		_player.move(
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
func _Prepare() -> void:
	var pnode = get_tree().get_nodes_in_group("Player")
	if pnode.size() > 0:
		if pnode.size() > 1:
			printerr("WARNING: More than one 'player' node found. Using first found.")
		_player = pnode[0]
		_player.connect("collision", self, "on_player_collision")
	else:
		printerr("WARNING: No 'Player' nodes found!!")


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_player_collision() -> void:
	if _input_dir[2] != 0:
		_player.trigger()


