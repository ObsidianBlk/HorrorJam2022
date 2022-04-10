tool
extends Area2D

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var trigger_area : Vector2 = Vector2(10,10)		setget set_trigger_area
export var time_to_kill : float = 1.0 # In seconds
export var timeline_name : String = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _cur_time : float = 0.0
var _triggered : bool = false
var _player : Node2D = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var col_shape_node : CollisionShape2D = get_node("CollisionShape2D")

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_trigger_area(a : Vector2) -> void:
	if a.x > 0.0 and a.y > 0.0:
		trigger_area = a
		if col_shape_node:
			if col_shape_node.shape == null:
				col_shape_node.shape = RectangleShape2D.new()
			col_shape_node.shape.extents = trigger_area

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	if col_shape_node.shape == null:
		col_shape_node.shape = RectangleShape2D.new()
		col_shape_node.shape.extents = trigger_area
	if not Engine.editor_hint:
		connect("body_entered", self, "_on_body_entered")


func _process(delta : float) -> void:
	if Engine.editor_hint:
		return
	
	if not Memetics.is_memetic_active() and _triggered and _cur_time < time_to_kill:
		_cur_time = max(time_to_kill, _cur_time + delta)
		if _cur_time == time_to_kill:
			if is_instance_valid(_player) and _player.has_method("move"):
				_player.move(Vector2.ZERO)
			System.request_dialog(timeline_name)
			_cur_time = 0.0
			_triggered = false

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if not _triggered and timeline_name != "":
		if body.is_in_group("Player"):
			_triggered = true
			_player = body

func _on_body_exited(body : Node2D) -> void:
	if _triggered:
		if body.is_in_group("Player"):
			_triggered = false
			_cur_time = 0.0
			_player = null


