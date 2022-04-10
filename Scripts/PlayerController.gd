extends Node


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal player_died()

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _player : KinematicBody2D = null
var _input_dir = [0,0,0,0]

var _rng : RandomNumberGenerator = null

var _ai_mode : bool = false
var _patrol_distance_threshold : float = 12.0
var _patrol_target : Node2D = null


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	_Prepare()
	set_ai_mode(false)


func _unhandled_input(event) -> void:
	if _player == null or not _player.is_inside_tree() or not _player.is_alive():
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
			if _GetDBValue("Player.MemeticAllowed", false):
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


func _process(delta : float) -> void:
	_Patrol()


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
		_player.connect("life_changed", self, "on_player_life_changed")
		_player.connect("died", self, "on_player_died")
	else:
		printerr("WARNING: No 'Player' nodes found!!")

func _Patrol() -> void:
	if _patrol_target == null:
		var patrols = get_tree().get_nodes_in_group("Patrol")
		if patrols.size() > 0:
			var idx = _rng.randi_range(0, patrols.size() - 1)
			var patrol = patrols[idx]
			if patrol is Node2D:
				_patrol_target = patrol
	
	if _patrol_target != null:
		var dist = _player.global_position.distance_to(_patrol_target.global_position)
		if dist <= _patrol_distance_threshold:
			_patrol_target = null
			_player.move(Vector2.ZERO)
		else:
			var dir = _player.global_position.direction_to(_patrol_target.global_position)
			_player.move(dir)


func _IsDirectionalInputReleased() -> bool:
	for i in _input_dir:
		if i != 0:
			return false
	return true

func _GetDBValue(key : String, default = null):
	var _db = System.get_db("game_state")
	if _db:
		return _db.get_value(key, default)
	return default

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func set_ai_mode(enable : bool = true) -> void:
	_ai_mode = enable
	# NOTE: This is pretty much a cheat. Officially I wouldn't KNOW if the
	# player is alive or dead or if they should be revived, but I DO know for this
	# jam game. I don't have time to be more elegant.
	_player.revive()
	_player.hide_viz(false)
	_player.move(Vector2.ZERO)
	if _ai_mode:
		set_process(true)
		set_process_unhandled_input(false)
	else:
		_patrol_target = null
		set_process(false)
		set_process_unhandled_input(true)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func on_player_collision() -> void:
	if not _IsDirectionalInputReleased():
		_player.trigger()

func on_player_life_changed(percent : float) -> void:
	print("Player Life: ", percent)

func on_player_died() -> void:
	print("Player is now dead!")
	_player.move(Vector2.ZERO)
	emit_signal("player_died")

func on_joy_connection_changed(device_id, connected):
	print(device_id, connected)


func _on_player_as_ai(ai_mode : bool) -> void:
	set_ai_mode(ai_mode)
