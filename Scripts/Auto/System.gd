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
	load_or_create_db("settings", "user://settings.tres")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func load_db(db_name : String, filepath : String, replace_existing : bool = false) -> bool:
	if db_name in _dbs and not replace_existing:
		if _dbs[db_name].filepath == filepath:
			return true
		else:
			printerr("WARNING: Database with name '", db_name, "' already loaded with a different filepath.")
			return false
	
	if ResourceLoader.exists(filepath, "DBResource"):
		var db = ResourceLoader.load(filepath, "DBResource", true)
		if db:
			_dbs[db_name] = {"db":db, "filepath":filepath}
			return true
		printerr("WARNING: Failed to load database at '", filepath, "'.")
	return false


func save_db(db_name : String, filepath : String = "") -> bool:
	if db_name in _dbs:
		if filepath == "":
			filepath = _dbs[db_name].filepath
		if filepath != "":
			var result = ResourceSaver.save(filepath, _dbs[db_name].db)
			if result == OK:
				return true
			else:
				printerr("SAVE FAILED: Failed to save database '", db_name, "' to filepath '", filepath, "'.")
		else:
			printerr("SAVE FAILED: Cannot save database No filepath given.")
	else:
		printerr("SAVE FAILED: No database named '", db_name, "' found.")
	return false


func create_db(db_name : String, replace_existing : bool = false) -> bool:
	if db_name in _dbs and not replace_existing:
		printerr("WARNING: Database with name '", db_name, "' already exists.")
		return false
	
	_dbs[db_name] = {"db":DBResource.new(), "filepath":""}
	return false


func load_or_create_db(db_name : String, filepath : String, replace_existing : bool = false) -> bool:
	if not load_db(db_name, filepath, replace_existing):
		if create_db(db_name, replace_existing):
			return save_db(db_name, filepath)
	return true


func get_db(db_name : String) -> DBResource:
	if db_name in _dbs:
		return _dbs[db_name].db
	return null

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
