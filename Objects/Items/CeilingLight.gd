extends "res://Scripts/Lighting.gd"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var trigger_node_path : NodePath = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


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
			if t_node.is_connected("trigger_off", self, "_on_trigger_off"):
				t_node.disconnect("trigger_off", self, "_on_trigger_off")
		t_node = null
		
		if tn != "":
			t_node = get_node_or_null(tn)
			if t_node:
				if t_node.has_signal("trigger_on") and t_node.has_signal("trigger_off"):
					t_node.connect("trigger_on", self, "_on_trigger_on")
					t_node.connect("trigger_off", self, "_on_trigger_off")


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_trigger_on() -> void:
	turn_on()

func _on_trigger_off() -> void:
	turn_off()


