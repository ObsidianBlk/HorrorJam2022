extends "res://Scripts/Interactable.gd"


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (int, "toggle", "on", "off") var trigger_state : int = 0
export var timeline_name : String = ""
export var trigger_node_path : NodePath = ""		setget set_trigger_node_path

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _state : int = 0

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_trigger_node_path(tn : NodePath) -> void:
	_SetTriggerNode(tn)
	trigger_node_path = tn

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	enabled = false
	_SetTriggerNode(trigger_node_path, true)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SetTriggerNode(tn : NodePath, force : bool = false) -> void:
	if trigger_node_path != tn or force:
		var t_node : Node = get_node_or_null(trigger_node_path)
		if t_node:
			if t_node.is_connected("trigger_on", self, "_on_trigger_on"):
				t_node.disconnect("trigger_on", self, "_on_trigger_on")
		t_node = null
		
		if tn != "":
			t_node = get_node_or_null(tn)
			if t_node:
				if t_node.has_signal("trigger_on"):
					t_node.connect("trigger_on", self, "_on_trigger_on")

func _EnableMe() -> void:
	if not enabled:
		enabled = true

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_trigger_on() -> void:
	call_deferred("_EnableMe")


func _on_interact() -> void:
	if timeline_name != "":
		match trigger_state:
			0: # Toggle
				_state = 1 if _state == 0 else 0
			1: # On
				_state = 1
			2: # Off
				_state = 0
		emit_signal("trigger_on" if _state == 1 else "trigger_off")
		if _state == 1 and not _triggered:
			System.request_dialog(timeline_name)


