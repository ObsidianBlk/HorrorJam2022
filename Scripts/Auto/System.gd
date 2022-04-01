extends Node

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _dbs = {}
var _settings_db = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	if load_or_create_db("settings", "user://settings.tres"):
		_settings_db = get_db("settings")
	
	if _settings_db:
		if _settings_db.has_key("audio.Master.volume"):
			set_audio_volume("Master", _settings_db.get_value("audio.Master.volume", 1.0))
		if _settings_db.has_key("audio.Music.volume"):
			set_audio_volume("Music", _settings_db.get_value("audio.Music.volume", 1.0))
		if _settings_db.has_key("audio.SFX.volume"):
			set_audio_volume("SFX", _settings_db.get_value("audio.SFX.volume", 1.0))

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func set_audio_sfx_effect(effect_name : String) -> void:
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx < 0:
		return
		
	var efx_idx = AudioServer.get_bus_index(effect_name)
	if efx_idx < 0:
		return
		
	var cur_effect_name = AudioServer.get_bus_send(sfx_idx)
	if cur_effect_name != effect_name:
		AudioServer.set_bus_send(sfx_idx, effect_name)

func get_audio_sfx_effect() -> String:
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx < 0:
		return ""
	var bus_name = AudioServer.get_bus_send(sfx_idx)
	return "" if bus_name == "SFXMaster" else bus_name

func get_sfx_effects() -> Array:
	var efx_list : Array = []
	if AudioServer.bus_count > 1:
		for i in range(1, AudioServer.bus_count - 1):
			var bus_name = AudioServer.get_bus_name(i)
			if ["Music", "SFXMaster", "SFX"].find(bus_name) < 0:
				efx_list.append(bus_name)
	return efx_list


func set_audio_volume(bus_name : String, vol : float) -> void:
	var bus_idx : int = -1
	match bus_name:
		"Master":
			bus_idx = AudioServer.get_bus_index("Master")
		"Music":
			bus_idx = AudioServer.get_bus_index("Music")
		"SFX":
			bus_idx = AudioServer.get_bus_index("SFXMaster")
	
	if bus_idx >= 0:
		vol = max(0.0, min(1.0, vol))
		AudioServer.set_bus_volume_db(bus_idx, linear2db(vol))
		if _settings_db:
			_settings_db.set_value("audio." + bus_name + ".volume", vol)

func get_audio_volume(bus_name : String) -> float:
	var bus_idx : int = -1
	match bus_name:
		"Master":
			bus_idx = AudioServer.get_bus_index("Master")
		"Music":
			bus_idx = AudioServer.get_bus_index("Music")
		"SFX":
			bus_idx = AudioServer.get_bus_index("SFXMaster")
	
	if bus_idx >= 0:
		return db2linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0


func load_db(db_name : String, filepath : String, replace_existing : bool = false) -> bool:
	if db_name in _dbs and not replace_existing:
		if _dbs[db_name].filepath == filepath:
			return true
		else:
			printerr("WARNING: Database with name '", db_name, "' already loaded with a different filepath.")
			return false
	
	if ResourceLoader.exists(filepath):
		var db = ResourceLoader.load(filepath, "", true)
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
	print("No Database: ", db_name)
	return null

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
