extends Node2D

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal world_shift()

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetDBValue(key : String, default = null):
	var _db = System.get_db("game_state")
	if _db:
		return _db.get_value(key, default)
	return default


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

func _on_TriggerZone_body_entered(body : Node2D) -> void:
	if body.is_in_group("Player"):
		if not body.is_connected("interact", self, "_on_interact"):
			body.connect("interact", self, "_on_interact", [body])


func _on_TriggerZone_body_exited(body : Node2D) -> void:
	if body.is_in_group("Player"):
		if body.is_connected("interact", self, "_on_interact"):
			body.disconnect("interact", self, "_on_interact")


func _on_interact(body : Node2D) -> void:
	if not _GetDBValue("Player.PortalAllowed", false):
		return
	
	if body.is_connected("interact", self, "_on_interact"):
		body.disconnect("interact", self, "_on_interact")
		emit_signal("world_shift")
