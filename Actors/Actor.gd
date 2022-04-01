extends KinematicBody2D

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal interact()
signal trigger()

signal faded()

signal collision()

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var walk_speed : float = 60.0
export var walk_accel : float = 100.0
export var run_speed : float = 120.0
export var run_accel : float = 200.0

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _velocity : Vector2 = Vector2.ZERO
var _direction : Vector2 = Vector2.ZERO
var _facing : Vector2 = Vector2(1,1)
var _running : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var viz_node : Node2D = $Viz

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------

func set_running(r : bool) -> void:
	_running = r

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


func _physics_process(delta : float) -> void:
	_UpdateViz()
	if _direction.length_squared() > 0.01:
		var speed = run_speed if _running else walk_speed
		var accel = run_accel if _running else walk_accel
		_velocity += _direction * accel * delta
		if _velocity.length() > speed:
			_velocity = _velocity.normalized() * speed
	else:
		_velocity = lerp(_velocity, Vector2.ZERO, 0.5)
		if _velocity.length() < 0.01:
			_velocity = Vector2.ZERO
	_velocity = move_and_slide(_velocity)
	if get_last_slide_collision() != null:
		emit_signal("collision")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

func _UpdateViz() -> void:	
	pass

func _Fade(anim_name : String) -> void:
	pass


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func move(dir : Vector2) -> void:
	var hsign = sign(_direction.x)
	_direction = dir
	if dir.length_squared() > 1:
		_direction = dir.normalized()
	if dir.length() > 0:
		_facing = Vector2(sign(dir.x), sign(dir.y))
		if sign(_direction.x) != hsign:
			_velocity.x = 0.0

func face(dir : Vector2) -> void:
	if dir.length() > 0:
		_facing = Vector2(sign(dir.x), sign(dir.y))

func face_target(target : Node2D) -> void:
	face(global_position.direction_to(target.global_position))

func interact() -> void:
	emit_signal("interact")

func trigger() -> void:
	emit_signal("trigger")

func hide_viz(enable : bool = true) -> void:
	viz_node.visible = not enable
	set_physics_process(not enable)

func fade_in(dir_name : String) -> void:
	if not viz_node.visible:
		viz_node.visible = true
	if ["up", "down", "left", "right"].find(dir_name) < 0:
		emit_signal("faded")
		return
	_Fade("fade_in_" + dir_name)

func fade_out(dir_name : String) -> void:
	if ["up", "down", "left", "right"].find(dir_name) < 0:
		emit_signal("faded")
		return
	_Fade("fade_out_" + dir_name)

func is_walking() -> bool:
	return not _running

func is_running() -> bool:
	return _running

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

