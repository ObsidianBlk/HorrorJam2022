extends Node

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _dbs = {}

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	load_or_create_database("settings", "user://settings.tres")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func load_or_create_database(db_name : String, filepath : String) -> void:
	var db = null
	if ResourceLoader.exists(filepath, "DBResource"):
		db = ResourceLoader.load(filepath, "DBResource", true)
	else:
		db = DBResource.new()
	if db:
		_dbs[db_name] = db

#func drop_database(db_name : String, save_changes : bool = false) -> void:
#	if db_name in _dbs:
#		var db : Resource = _dbs[db_name]
#		if db.resource_path:
#			pass

func get_db(db_name : String) -> DBResource:
	if db_name in _dbs:
		return _dbs[db_name]
	return null

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
