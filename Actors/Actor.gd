extends KinematicBody2D

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
var _running : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var viz_node : Node2D = $Viz
onready var asprite_node : AnimatedSprite = $Viz/ASprite

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------

func set_running(r : bool) -> void:
	_running = r

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------

func _physics_process(delta : float) -> void:
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
			asprite_node.play("idle")
	_velocity = move_and_slide(_velocity)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func move(dir : Vector2) -> void:
	_direction = dir
	if dir.length_squared() > 1:
		_direction = dir.normalized()
	if dir.length() > 0:
		if _running:
			asprite_node.play("run")
		else:
			asprite_node.play("walk")
		if dir.x < 0.0:
			asprite_node.flip_h = true
		else:
			asprite_node.flip_h = false

func is_walking() -> bool:
	return not _running

func is_running() -> bool:
	return _running

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

