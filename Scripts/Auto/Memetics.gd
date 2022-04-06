extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal memetic_changed(memetic_value)

# -------------------------------------------------------------------------
# ENUMs
# -------------------------------------------------------------------------
enum STATE {Waiting=0, Up=1, Down=2}

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _state = STATE.Waiting
var _memetic_shift_val : float = 0.0
var _active_duration : float = 0.0
var _db : DBResource = null


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_GetDatabase()


func _process(delta : float) -> void:
	if _db == null:
		_GetDatabase()
	
	if _db != null:
		match _state:
			STATE.Waiting:
				if _ChangeDuration(delta):
					_SetState(STATE.Down)
			STATE.Up:
				if _ChangeShift(delta):
					_SetState(STATE.Waiting)
			STATE.Down:
				if _ChangeShift(-delta):
					_SetState(STATE.Waiting)


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SetState(s : int) -> void:
	if STATE.values().find(s) >= 0:
		_state = s
		if _db != null:
			_db.set_value("memetic.state", _state)

func _ChangeShift(amount : float) -> bool:
	_memetic_shift_val = max(0.0, min(1.0, _memetic_shift_val + amount))
	if _db != null:
		_db.set_value("memetic.shift", _memetic_shift_val)
	emit_signal("memetic_changed", _memetic_shift_val)
	return _memetic_shift_val <= 0.0 or _memetic_shift_val >= 1.0

func _ChangeDuration(amount : float) -> bool:
	if _active_duration > 0.0:
		_active_duration = max(0.0, _active_duration - amount)
		if _db != null:
			_db.set_value("memetic.duration", _active_duration)
		return _active_duration <= 0.0
	return false

func _GetDatabase() -> void:
	if _db == null:
		_db = System.get_db("game_state")
		if _db:
			_memetic_shift_val = _db.get_value("memetic.shift", _memetic_shift_val)
			_state = _db.get_value("memetic.state", _state)
			_active_duration = _db.get_value("memetic.duration", _active_duration)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func activate_memetic(duration : float) -> void:
	if _db == null:
		return
	
	if _active_duration <= 0.0 and duration > 0.0:
		_active_duration = duration
		_db.set_value("memetic.duration", _active_duration)
		_SetState(STATE.Up)


func stop_memetic() -> void:
	if _db == null:
		return
	
	if _active_duration > 0.0 or _memetic_shift_val > 0.0:
		_active_duration = 0.0
		_memetic_shift_val = 0.0
		_SetState(STATE.Waiting)
		_db.set_value("memetic.duration", _active_duration)
		_db.set_value("memetic.shift", _memetic_shift_val)
		emit_signal("memetic_changed", _memetic_shift_val)


func get_memetic_value() -> float:
	return _memetic_shift_val

func is_memetic_active() -> bool:
	return _memetic_shift_val > 0.0

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

