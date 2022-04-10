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

func _GetKeyBase(key : String) -> Dictionary:
	if key == "":
		return {"tail":"", "base":""}
	
	var subkeys : Array = key.split(DELIMITER)
	if subkeys.size() > 1:
		var pba : PoolStringArray = PoolStringArray(subkeys.slice(0, subkeys.size() - 2))
		return {"base":pba.join(DELIMITER), "tail":subkeys[subkeys.size() - 1]}
	return {"base":"", "tail":subkeys[0]}


func _GetRecord(key : String, create_if_not_exist : bool = false):
	if key == "":
		return _records
	
	var subkeys : Array = key.split(DELIMITER)
	var endkey : String = subkeys[subkeys.size() - 1]
	
	var rec : Dictionary = _records
	for subkey in subkeys:
		if subkey in rec:
			if typeof(rec[subkey]) != TYPE_DICTIONARY:
				break # Subkey is NOT a dictionary. We're done looking!
				
			if subkey == endkey:
				return rec[subkey]
			rec = rec[subkey]
		else:
			# Subkey not in current record...
			if create_if_not_exist:
				# ... create the record!
				rec[subkey] = {}
				rec = rec[subkey]
				if subkey == endkey:
					return rec
			else:
				break # ... we're don't looking.
	return null

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func get_keys(key : String = "") -> Array:
	var record = _GetRecord(key)
	var keys : Array = []
	if record != null:
		var rkeys = record.keys()
		for rkey in rkeys:
			keys.append(rkey if key == "" else key + DELIMITER + rkey)
			if typeof(record[rkey]) == TYPE_DICTIONARY:
				var subkeys : Array = get_keys(rkey if key == "" else key + DELIMITER + rkey)
				for subkey in subkeys:
					var nkey = rkey + DELIMITER + subkey
					if key != "":
						nkey = key + DELIMITER + nkey
					keys.append(nkey)
	return keys


func has_key(key : String) -> bool:
	var ktb = _GetKeyBase(key)
	if ktb.tail != "":
		var record = _GetRecord(ktb.base)
		if record != null:
			return ktb.tail in record
	return false

func is_key_record(key : String) -> bool:
	if key == "":
		return true
	
	var ktb = _GetKeyBase(key)
	if ktb.tail != "":
		return _GetRecord(ktb.base) != null
	
	return false

func drop_key(key : String) -> void:
	var ktb = _GetKeyBase(key)
	if ktb.tail != "":
		var record = _GetRecord(ktb.base)
		if record != null and ktb.tail in record:
			record.erase(ktb.tail)
			if record != _records and record.keys().size() <= 0:
				drop_key(ktb.base)

func has_value(key : String) -> bool:
	var ktb = _GetKeyBase(key)
	if ktb.tail != "":
		var record = _GetRecord(ktb.base)
		return record != null and ktb.tail in record and typeof(record[ktb.tail]) != TYPE_DICTIONARY
	return false

func get_value(key : String, default = null):
	var ktb = _GetKeyBase(key)
	if ktb.tail != "":
		var record = _GetRecord(ktb.base)
		if record != null and ktb.tail in record and typeof(record[ktb.tail]) != TYPE_DICTIONARY:
			return record[ktb.tail]
	return default


func set_value(key : String, value, set_if_not_exist : bool = true) -> void:
	if value == null:
		return # Will not set any value to null
	
	var ktb = _GetKeyBase(key)
	if ktb.tail != "":
		var record = _GetRecord(ktb.base, set_if_not_exist)
		if ktb.tail in record or (not ktb.tail in record and set_if_not_exist):
			record[ktb.tail] = value

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


