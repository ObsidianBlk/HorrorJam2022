extends Area2D

# -----------------------------------------------------------------------------
# Signals
# -----------------------------------------------------------------------------
signal trigger_on()
signal trigger_off()


# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export var enabled : bool = true
export var trigger_once : bool = false

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _triggered : bool = false

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------

func _on_area_entered(area : Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("Actor"):
		if parent.has_signal("interact") and not parent.is_connected("interact", self, "_on_internal_interact"):
			parent.connect("interact", self, "_on_internal_interact")


func _on_area_exited(area : Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("Actor"):
		if parent.has_signal("interact") and parent.is_connected("interact", self, "_on_internal_interact"):
			parent.disconnect("interact", self, "_on_internal_interact")

func _on_internal_interact() -> void:
	if not enabled:
		return
	
	if not trigger_once or not _triggered:
		_triggered = true
		_on_interact()

func _on_interact() -> void:
	emit_signal("trigger_on")
