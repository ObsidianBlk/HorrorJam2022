extends Node

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _DB : Dictionary = {}

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func has_value(val_name : String) -> bool:
	return val_name in _DB

func get_value(val_name : String, default = null):
	if val_name in _DB:
		return _DB[val_name]
	return default

func set_value(val_name : String, value) -> void:
	_DB[val_name] = value

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
