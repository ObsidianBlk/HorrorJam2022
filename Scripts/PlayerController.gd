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
	for joyID in Input.get_connected_joypads():
		print(Input.get_joy_name(joyID))
	Input.connect("joy_connection_changed",self,"on_joy_connection_changed")
	_Prepare()


func _unhandled_input(event) -> void:
	if _player == null or not _player.is_inside_tree():
		return
	
	if event is InputEventKey or event is InputEventJoypadButton:
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
		
		if event.is_action_pressed("memetic"):
			Memetics.activate_memetic(4.0)

		_player.move(
			Vector2(
				_input_dir[0] + _input_dir[1],
				_input_dir[2] + _input_dir[3]
			).normalized()
		)
#	elif event is InputEventJoypadMotion:
#		print("Axis: ", event.axis, " | Value: ", event.axis_value)
#		for joyID in Input.get_connected_joypads():
#			print(Input.get_joy_name(joyID))
#		var aval : float = event.axis_value
#		if abs(aval) < 0.1:
#			aval = 0
#		var idx : int = 0
#
#		match event.axis:
#			JOY_AXIS_0:
#				if aval > 0.0:
#					idx = 1
#			JOY_AXIS_1:
#				if aval < 0.0:
#					idx = 2
#				else:
#					idx = 3
#
#		if (idx == 0 or idx == 2) and aval == 0.0:
#			_input_dir[idx] = aval
#			_input_dir[idx + 1] = aval
#		else:
#			_input_dir[idx] = aval
#			if aval > 0.0:
#				_input_dir[idx - 1] = 0.0

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

func _IsDirectionalInputReleased() -> bool:
	for i in _input_dir:
		if i != 0:
			return false
	return true

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_player_collision() -> void:
	if not _IsDirectionalInputReleased():
		_player.trigger()

func on_joy_connection_changed(device_id, connected):
	print(device_id, connected)
