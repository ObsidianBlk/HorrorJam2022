tool
extends Node2D


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal request_zone_change(scene, door_name)

# -------------------------------------------------------------------------
# ENUMs
# -------------------------------------------------------------------------
enum FACING {Up=0, Down=1, Left=2, Right=3}
enum STATE {Opened=0, Blocked=1, Transition=2}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (FACING) var facing : int = FACING.Up					setget set_facing
export (STATE) var state : int = STATE.Opened					setget set_state
export (String, FILE, "*.tscn") var connected_scene : String = ""
export var connected_door : String = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var trigger_node : Area2D = get_node("TriggerArea")
onready var col_shape_node : CollisionShape2D = get_node("TriggerArea/CollisionShape2D")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_facing(f : int) -> void:
	if FACING.values.find(f) >= 0:
		facing = f

func set_state(s : int) -> void:
	if STATE.values().find(s) >= 0:
		state = s

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_facing(facing)
	set_state(state)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

func _ConnectBody(body : Node2D, enable : bool = true) -> void:
	if enable:
		if not body.is_connected("interact", self, "on_interact"):
			body.connect("interact", self, "on_interact", [body])
			body.connect("trigger", self, "on_trigger", [body])
	else:
		if body.is_connected("interact", self, "on_interact"):
			body.disconnect("interact", self, "on_interact")
			body.disconnect("trigger", self, "on_trigger")


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func get_facing_vector() -> Vector2:
	match facing:
		FACING.Up:
			return Vector2.UP
		FACING.Down:
			return Vector2.DOWN
		FACING.Left:
			return Vector2.LEFT
		FACING.Right:
			return Vector2.RIGHT
	return Vector2.ZERO

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

func on_body_exited(body : Node2D) -> void:
	if body.is_in_group("Actor") and body.has_signal("interact"):
		_ConnectBody(body, false)


func on_body_entered(body : Node2D) -> void:
	if body.is_in_group("Actor") and body.has_signal("interact"):
		_ConnectBody(body)


func on_interact(body : Node2D) -> void:
	pass

func on_trigger(body : Node2D) -> void:
	if state == STATE.Opened and connected_scene != "" and connected_door != "":
		_ConnectBody(body, false)
		var dir_name = "up"
		match facing:
			FACING.Down:
				dir_name = "down"
			FACING.Left:
				dir_name = "left"
			FACING.Right:
				dir_name = "right"
		body.fade_out(dir_name)
		yield(body, "faded")
		emit_signal("request_zone_change", connected_scene, connected_door)

