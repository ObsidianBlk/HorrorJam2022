extends "res://Logic/logic_trigger.gd"

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (Array, NodePath) var triggers : Array = []

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _trigger_list : Array = []

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_in_triggers(tl : Array) -> void:
	triggers = tl
	_UpdateTriggerList()


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateTriggerList() -> void:
	var ntl = []
	
	for trigger in _trigger_list:
		if triggers.find(trigger) < 0:
			var tn : Node = get_node_or_null(trigger)
			if tn.is_connected("active", self, "_on_trigger_active"):
				tn.disconnect("active", self, "_on_trigger_active")
			if tn.is_connected("inactive", self, "_on_trigger_inactive"):
				tn.disconnect("inactive", self, "_on_trigger_inactive")
		else:
			ntl.append(trigger)
	_trigger_list = ntl
	
	for trigger in triggers:
		if _trigger_list.find(trigger) < 0:
			var tn : Node = get_node_or_null(trigger)
			if _IsNodeATrigger(tn):
				tn.connect("active", self, "_on_trigger_active", [tn])
				tn.connect("inactive", self, "_on_trigger_inactive", [tn])


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_trigger_active(tnode : Node) -> void:
	pass

func _on_trigger_inactive(tnode : Node) -> void:
	pass
