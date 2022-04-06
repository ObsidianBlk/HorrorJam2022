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
export (FACING) var facing : int = FACING.Down					setget set_facing
export (STATE) var state : int = STATE.Opened					setget set_state
export var trigger_area : Vector2 = Vector2(10.0, 10.0)			setget set_trigger_area
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
onready var col_side_node : CollisionPolygon2D = get_node("TriggerArea/SideCollision")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_facing(f : int) -> void:
	if FACING.values().find(f) >= 0:
		facing = f
		_UpdateCollisionShapes()

func set_state(s : int) -> void:
	if STATE.values().find(s) >= 0:
		state = s

func set_trigger_area(ta : Vector2) -> void:
	if ta.x > 0 and ta.y > 0:
		trigger_area = ta
		_UpdateCollisionShapes()

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_facing(facing)
	set_state(state)
	if not Engine.editor_hint:
		if trigger_node != null:
			trigger_node.connect("body_entered", self, "on_body_entered")
			trigger_node.connect("body_exited", self, "on_body_exited")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------

func _UpdateCollisionShapes() -> void:
	if col_shape_node == null or col_side_node == null:
		return
	
	match facing:
		FACING.Up:
			col_shape_node.disabled = false
			col_side_node.disabled = true
			
			col_shape_node.position = Vector2(0, -trigger_area.y * 0.5)
			col_shape_node.shape.extents = trigger_area * 0.5
		FACING.Down:
			col_shape_node.disabled = false
			col_side_node.disabled = true
			
			col_shape_node.position = Vector2(0, trigger_area.y * 0.5)
			col_shape_node.shape.extents = trigger_area * 0.5
		FACING.Left:
			col_shape_node.disabled = true
			col_side_node.disabled = false
			var _v = (Vector2.DOWN.rotated(deg2rad(-45)) * trigger_area.y)
			col_side_node.polygon = PoolVector2Array([
				Vector2(-18, 0),
				Vector2(-18 - trigger_area.x, 0),
				Vector2(-18 - trigger_area.x, 0) + _v,
				Vector2(-18, 0) + _v,
			])
		FACING.Right:
			col_shape_node.disabled = true
			col_side_node.disabled = false
			var _v = (Vector2.DOWN.rotated(deg2rad(45)) * trigger_area.y)
			col_side_node.polygon = PoolVector2Array([
				Vector2(18, 0),
				Vector2(18 + trigger_area.x, 0),
				Vector2(18 + trigger_area.x, 0) + _v,
				Vector2(18, 0) + _v,
			])


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

func get_facing_name() -> String:
	for key in FACING.keys():
		if FACING[key] == facing:
			return key.to_lower()
	return ""

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

