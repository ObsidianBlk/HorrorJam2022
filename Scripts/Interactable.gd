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
export var variable_key_name : String = ""

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _triggered : bool = false
var _db : DBResource = null

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	if variable_key_name != "":
		_db = System.get_db("game_state")
	_triggered = _GetDBVar("triggered", _triggered)
	if _triggered:
		call_deferred("_on_interact")
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------

func _SetDBVar(sub_key_name : String, value) -> void:
	if _db != null and variable_key_name != "":
		var key = variable_key_name + "." + sub_key_name
		_db.set_value(key, value)

func _GetDBVar(sub_key_name : String, default = null):
	if _db != null and variable_key_name != "":
		var key = variable_key_name + "." + sub_key_name
		return _db.get_value(key, default)
	return default

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
		_on_interact()
		if trigger_once:
			_triggered = true
			_SetDBVar("triggered", _triggered)

func _on_interact() -> void:
	emit_signal("trigger_on")
