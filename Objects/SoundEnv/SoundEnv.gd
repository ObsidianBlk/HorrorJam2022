tool
extends Area2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const STEP_SET = [
	"steps",
	"steps_carpet"
]

enum STEPS {Tile=0, Carpet=1}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var trigger_area : Vector2 = Vector2(10,10)		setget set_trigger_area
export var override_environment : bool = false
export var environment_effect : String = "RealWorld"
export (STEPS) var step_effect : int = STEPS.Tile

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


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SetEvironment() -> void:
	if Engine.editor_hint:
		return
	
	var effects = System.get_sfx_effects()
	if effects.find(environment_effect) >= 0:
		System.set_audio_sfx_effect(environment_effect)
		print("Audio SFX Now Set to: ", System.get_audio_sfx_effect())

func _SetStepSet() -> void:
	if Engine.editor_hint:
		return
	
	var _db = System.get_db("game_state")
	if _db:
		_db.set_value("player.footsteps.soundset", STEP_SET[step_effect], true)


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if body.is_in_group("Player"):
		if override_environment:
			_SetEvironment()
		_SetStepSet()
