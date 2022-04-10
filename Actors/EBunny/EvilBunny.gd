extends "res://Actors/Humanoid.gd"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var on_key : String = ""
export (int, "hide", "show") var on_key_action = 0
export var timeline_name : String = ""
export var trigger_key : String = ""
export var trigger_once : bool = true
export (Array, NodePath) var patrol_node_paths : Array = []
export var patrol_distance_threshold : float = 12.0


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _rng : RandomNumberGenerator = null
var _target_position : Node2D = null
var _patrol_enabled : bool = true
var _triggered : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	var _db : DBResource = System.get_db("game_state")
	if _db and on_key != "":
		var key_val = _db.get_value(on_key, false)
		if key_val and on_key_action == 0:
			queue_free()
		elif not key_val and on_key_action == 1:
			queue_free()

func _process(_delta : float) -> void:
	_Patrol()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _Patrol() -> void:
	if _target_position == null and patrol_node_paths.size() > 0:
		var np = patrol_node_paths[_rng.randi_range(0, patrol_node_paths.size())]
		var t = get_node_or_null(np)
		if t is Node2D:
			_target_position = t
	
	if _target_position != null:
		var dist = global_position.distance_to(_target_position.global_position)
		if dist <= patrol_distance_threshold:
			_target_position = null
			move(Vector2.ZERO)
		else:
			var dir = global_position.direction_to(_target_position.global_position)
			move(dir)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

func _on_Trigger_area_entered(area : Area2D) -> void:
	var parent = area.get_parent()
	if parent != null and parent.is_in_group("Player"):
		face_target(parent)
		if not parent.is_connected("interact", self, "_on_interact"):
			parent.connect("interact", self, "_on_interact")
			_patrol_enabled = false


func _on_Trigger_area_exited(area : Area2D) -> void:
	var parent = area.get_parent()
	if parent != null and parent.is_in_group("Player"):
		if parent.is_connected("interact", self, "_on_interact"):
			parent.disconnect("interact", self, "_on_interact")
			_patrol_enabled = true

func _on_interact() -> void:
	if not _triggered or not trigger_once:
		_triggered = true
		if timeline_name != "":
			System.request_dialog(timeline_name)
			if trigger_key != "":
				var _db : DBResource = System.get_db("game_state")
				if _db != null:
					_db.set_value(trigger_key, true, true)
