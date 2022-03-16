extends Resource
class_name DBResource

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const DELIMITER : String = "."

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _records : Dictionary = {}

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------

func _get(property : String):
	match property:
		"records":
			return _records
	
	return null

func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		"records":
			if typeof(value) == TYPE_DICTIONARY:
				_records = value
			else : success = false
		_:
			success = false

	if success:
		property_list_changed_notify()
	return success


func _get_property_list():
	return [
		{
			name = "records",
			type = TYPE_DICTIONARY,
			usage = PROPERTY_USAGE_STORAGE,
		},
	]


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------

func has_key(key : String) -> bool:
	return false

func get_value(key : String, default = null):
	if key in _records:
		return _records[key]
	return default

# TODO: Set_if_not_exists
func set_value(key : String, value) -> void:
	_records[key] = value


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


