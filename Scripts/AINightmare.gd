extends Node


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const AREAS = [
	{ # AREA 1
		"Hall_001": ["Hall_002"],
		"Hall_002": ["Hall_001", "Hall_003", "Cafe"],
		"Hall_003": ["Hall_002"],
		"Cafe": ["Hall_002"],
	}
]


enum STATE {WANDERING=0, HUNTING=1, CHASING=2, FADING=3}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var section_wait_time : float = 2.0
export var nightmare_sounds_path : NodePath = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _rng : RandomNumberGenerator = null

var _nightmare_node : KinematicBody2D = null
var _nightmaresnd_node : Node2D = null
var _area : int = 0
var _section : String = ""
var _state : int = STATE.HUNTING
var _faded : bool = false

var _waiting : float = 0.0

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	_GetNextSection()

func _process(delta : float) -> void:
	_FindNightmare()
	if _nightmare_node != null:
		var db = System.get_db("game_state")
		
		match _state:
			STATE.WANDERING:
				_ProcessWandering(delta)
			STATE.HUNTING:
				_ProcessHunting(delta)
			STATE.CHASING:
				_ProcessChasing(delta, db)
		

# -------------------------------------------------------------------------
# Private State Methods
# -------------------------------------------------------------------------
func _ProcessWandering(delta : float) -> void:
	if _GetDBValue("player.world", "real") == "alt":
		if _GetDBValue("world.zone_name", "") == _section:
			if _SetSpawnPosition():
				_nightmare_node.fade_in()
				_state = STATE.FADING
		else:
			_state = STATE.HUNTING
		return
	
	if _waiting > 0.0:
		_waiting = max(0.0, _waiting - delta)
		if _waiting <= 0.0:
			_GetNextSection()


func _ProcessHunting(delta : float) -> void:
	if _GetDBValue("player.world", "real") == "alt":
		if _GetDBValue("world.zone_name", "") == _section:
			if _SetSpawnPosition():
				_nightmare_node.fade_in()
				_state = STATE.FADING
			return
	else:
		_state = STATE.WANDERING
		return
	
	if _waiting > 0.0:
		_waiting = max(0.0, _waiting - delta)
		if _waiting <= 0.0:
			_GetNextSection()


func _ProcessChasing(_delta : float, db : DBResource) -> void:
	if _GetDBValue("player.world", "real") != "alt" or _GetDBValue("world.zone_name", "") != _section:
		_nightmare_node.fade_out()
		_state = STATE.FADING
		return
		
	var lastpos = db.get_value("ai.nightmare.position")
	var nppos = _nightmare_node.global_position
	var player = _GetPlayer()
	if player:
		var dist = nppos.distance_to(player.global_position)
		if dist > 24 and dist < 200:
			var trauma = (176 - (dist - 24)) / 176
			var direction : Vector2 = nppos.direction_to(player.global_position)
			_nightmare_node.move(direction.normalized())
			_ShakeDaCamera(trauma * _delta)
		else:
			_nightmare_node.move(Vector2.ZERO)
			if dist >= 200:
				_nightmare_node.fade_out()
				_state = STATE.FADING
			else:
				var trauma = (176 - (dist - 24)) / 176
				_ShakeDaCamera(trauma * _delta)
	if db and (lastpos == null or lastpos != _nightmare_node.global_position):
		db.set_value("ai.nightmare.position", _nightmare_node.global_position)


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetDBValue(key : String, default):
	var db : DBResource = System.get_db("game_state")
	if db:
		return db.get_value(key, default)
	return default

func _SetDBValue(key : String, value, create_if_nexists : bool = false) -> void:
	var db : DBResource = System.get_db("game_state")
	if db:
		db.set_value(key, value, create_if_nexists)


func _IsPlayerInSection() -> bool:
	if _GetDBValue("player.world", "real") == "alt":
		return _GetDBValue("world.zone_name", "") == _section
	return false

func _SetSpawnPosition() -> bool:
	var nspl = get_tree().get_nodes_in_group("Nightmare_Spawn")
	if nspl.size() > 0:
		var player = _GetPlayer()
		if player:
			var nsp = null
			var dist = 0
			for p in nspl:
				if p is Node2D:
					var d = player.global_position.distance_to(p.global_position)
					if nsp == null or d < dist:
						nsp = p
						dist = d
			if nsp != null:
				_nightmare_node.global_position = nsp.global_position
				return true
		else:
			var nsp = nspl[_rng.randi_range(0, nspl.size() - 1)]
			if nsp is Node2D:
				_nightmare_node.global_position = nsp.global_position
				return true
	return false



func _FindNightmare() -> void:
	if _nightmare_node == null:
		var nmlist = get_tree().get_nodes_in_group("Nightmare")
		for nm in nmlist:
			if nm is KinematicBody2D:
				_nightmare_node = nm
				_nightmare_node.connect("faded", self, "_on_nightmare_faded")
				if not _IsPlayerInSection():
					_state = STATE.FADING
					_nightmare_node.fade_out()
				break
	elif not is_instance_valid(_nightmare_node):
		_nightmare_node = null
	
	if _nightmaresnd_node == null:
		if nightmare_sounds_path != "":
			var n = get_node_or_null(nightmare_sounds_path)
			if n != null and n.has_method("play_random_set"):
				_nightmaresnd_node = n
	elif not is_instance_valid(_nightmaresnd_node):
		_nightmaresnd_node = null

func _GetPlayer() -> KinematicBody2D:
	var plist = get_tree().get_nodes_in_group("Player")
	for p in plist:
		if p is KinematicBody2D:
			return p
	return null


func _GetNextSection() -> void:
	if _section == "":
		_section = _GetDBValue("ai.nightmare.section", "")
		if _section == "":
			var seclist : Array = AREAS[_area].keys()
			if seclist.size() > 0:
				var idx = _rng.randi_range(0, seclist.size() - 1)
				_section = seclist[idx]
				print("AI starts in: ", _section)
				_waiting = section_wait_time
				_SetDBValue("ai.nightmare.section", _section, true)
			else:
				printerr("WARNING: AI is lost!!")
	else:
		# NOTE: This should be different depending on if _state is HUNTING vs WANDERING.
		#  However, I am running out of time, so they're both being treated the same.
		var idx = _rng.randi_range(0, AREAS[_area][_section].size() - 1)
		_section = AREAS[_area][_section][idx]
		_SetDBValue("ai.nightmare.section", _section, true)
		print("AI moved to: ", _section)
		if _nightmaresnd_node != null and _GetDBValue("world.zone_name", "") == _section:
			_nightmaresnd_node.play_random_set("hunt")
		_waiting = section_wait_time

func _ShakeDaCamera(amount : float) -> void:
	var camlist : Array = get_tree().get_nodes_in_group("ShakeCamera")
	for cam in camlist:
		if cam.has_method("add_trauma"):
			cam.add_trauma(amount)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_nightmare_faded() -> void:
	_faded = not _faded
	print("Fade State: ", _faded)
	if _GetDBValue("player.world", "real") == "alt":
		if _GetDBValue("world.zone_name", "") == _section:
			if _faded:
				if _SetSpawnPosition():
					print("New Spawn Position")
					_nightmare_node.fade_in()
			else:
				print("Chasing")
				_state = STATE.CHASING
		else:
			print("Hunting")
			_state = STATE.HUNTING
	else:
		print("Wandering")
		_state = STATE.WANDERING



