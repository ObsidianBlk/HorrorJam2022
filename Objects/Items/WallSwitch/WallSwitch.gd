tool
extends "res://Scripts/Interactable.gd"


# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
const COLOR_ON : Color = Color("#8dde81")
const COLOR_OFF : Color = Color("#fdc02f")

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------
export (int, 0, 1) var state : int = 0			setget set_state


# -----------------------------------------------------------------------------
# Onready Variables
# -----------------------------------------------------------------------------
onready var light_node : Light2D = get_node("Light2D")
onready var sprite_node : Sprite = get_node("Sprite")


# -----------------------------------------------------------------------------
# Setters / Getters
# -----------------------------------------------------------------------------
func set_state(s : int) -> void:
	if s == 0 or s == 1:
		if state != s:
			state = s
			_UpdateState()
			

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	_UpdateState()

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _UpdateState() -> void:
	if sprite_node:
		sprite_node.frame = state
	if light_node:
		light_node.color = COLOR_ON if state == 0 else COLOR_OFF
	emit_signal("trigger_on" if state == 0 else "trigger_off")


# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_interact() -> void:
	set_state(1 if state == 0 else 0)

