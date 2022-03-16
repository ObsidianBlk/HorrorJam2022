extends Camera2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------

const THRESHOLD : float = 0.01
const TRAUMA_POWER : float = 2.0

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var target_node_path : NodePath = ""			setget set_target_node_path
export var max_target_distance : float = 1000.0		setget set_max_target_distance

export var trauma_seed : int = 0
export var trauma_decay : float = 0.8
export var trauma_max_offset : Vector2 = Vector2(100, 100)
export var trauma_max_roll : float = 0.1

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _target : Node2D = null
var _tween : Tween = null

var _lstpos : Vector2 = Vector2.ZERO

var _trauma : float = 0.0
var _noise_y : float = 0.0

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var noise : OpenSimplexNoise = OpenSimplexNoise.new()


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------

func set_target_node_path(np : NodePath) -> void:
	target_node_path = np
	if target_node_path == "":
		_target = null
	else:
		_target = get_node_or_null(target_node_path)

func set_max_target_distance(td : float) -> void:
	if td >= 0:
		max_target_distance = td

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_target_node_path(target_node_path)
	_tween = Tween.new()
	add_child(_tween)
	
	noise.seed = trauma_seed
	noise.period = 4
	noise.octaves = 2

func _process(delta : float) -> void:
	if _target != null:
		if _lstpos.distance_to(_target.global_position) > THRESHOLD:
			_lstpos = _target.global_position
			_tween.stop_all()
			
			var dist : float = global_position.distance_to(_target.global_position)
			if dist > max_target_distance:
				snap_to_target()
			else:
				_tween.interpolate_property(
					self, "global_position", 
					global_position, _target.global_position, 
					0.1,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
				)
				_tween.start()
	
	if _trauma > 0.0:
		_trauma = max(_trauma - trauma_decay * delta, 0)
		_Shake()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _Shake() -> void:
	_noise_y += 1.0
	var amount = pow(_trauma, TRAUMA_POWER)
	rotation = trauma_max_roll * amount * noise.get_noise_2d(noise.seed, _noise_y)
	offset.x = trauma_max_offset.x * amount * noise.get_noise_2d(noise.seed*2, _noise_y)
	offset.y = trauma_max_offset.y * amount * noise.get_noise_2d(noise.seed*3, _noise_y)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func snap_to_target() -> void:
	if _target != null:
		_tween.stop_all()
		global_position = _target.global_position

func add_trauma(amount : float) -> void:
	_trauma = max(min(_trauma + amount, 1.0), 0.0)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
