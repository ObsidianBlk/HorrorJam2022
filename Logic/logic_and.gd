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
var _trigger_set = {}

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_in_triggers(tl : Array) -> void:
	triggers = tl
	_UpdateTriggerList()

func set_active(a : bool) -> void:
	# Explicitly ignoring the set value in favore of the connected trigger states.
	_VerifyActive()

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateTriggerList() -> void:
	for trigger in _trigger_set.keys():
		if triggers.find(trigger) < 0:
			_DisconnectTriggerNode(trigger)

	
	for trigger in triggers:
		if not trigger in _trigger_set:
			var tn : Node = get_node_or_null(trigger)
			if _IsNodeATrigger(tn):
				tn.connect("active", self, "_on_trigger_active", [trigger])
				tn.connect("inactive", self, "_on_trigger_inactive", [trigger])
				tn.connect("tree_exited", self, "_on_trigger_exited", [trigger])
				_trigger_set[trigger] = tn.is_active()

func _DisconnectTriggerNode(trigger : String) -> void:
	var tn : Node = get_node_or_null(trigger)
	if tn:
		if tn.is_connected("active", self, "_on_trigger_active"):
			tn.disconnect("active", self, "_on_trigger_active")
		if tn.is_connected("inactive", self, "_on_trigger_inactive"):
			tn.disconnect("inactive", self, "_on_trigger_inactive")
		if tn.is_connected("tree_exited", self, "_on_trigger_exited"):
			tn.disconnect("tree_exited", self, "_on_trigger_exited")
		_trigger_set.erase(trigger)


func _VerifyActive() -> void:
	for trigger in _trigger_set.keys():
		if not _trigger_set[trigger]:
			.set_active(false)
			return
	.set_active(true)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_trigger_active(trigger : String) -> void:
	if trigger in _trigger_set:
		_trigger_set[trigger] = true
		_VerifyActive()

func _on_trigger_inactive(trigger : String) -> void:
	if trigger in _trigger_set:
		_trigger_set[trigger] = false
		_VerifyActive()

func _on_trigger_exited(trigger : String) -> void:
	if trigger in _trigger_set:
		_DisconnectTriggerNode(trigger)
		_VerifyActive()
