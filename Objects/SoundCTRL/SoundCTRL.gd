extends Node2D

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (float, 0.0, 1.0, 0.001) var volume : float = 1.0
export var max_distance : float = 2000.0
export (Array, Array, String) var sounds = []
export (Array, Array, String) var sound_sets = []

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _sounds : Dictionary = {}
var _rng : RandomNumberGenerator = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var sfx1 : AudioStreamPlayer2D = get_node("SFX1")
onready var sfx2 : AudioStreamPlayer2D = get_node("SFX2")


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_max_distance(md : float) -> void:
	if md > 0.0:
		max_distance = md
		if sfx1:
			sfx1.max_distance = max_distance
		if sfx2:
			sfx2.max_distance = max_distance

func set_volume(v : float) -> void:
	v = max(0.0, min(1.0, v))
	volume = v
	if sfx1:
		sfx1.volume_db = linear2db(volume)
	if sfx2:
		sfx2.volume_db = linear2db(volume)

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_max_distance(max_distance)
	_rng = RandomNumberGenerator.new()
	_rng.seed = randi() * 821345
	for sound in sounds:
		add_sound(sound[0], sound[1])
	set_volume(volume)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetSoundsInSet(set_name : String) -> Array:
	var snds : Array = []
	for sset in sound_sets:
		if sset[0] == set_name:
			var slist = sset[1].split(",")
			for sound_name in slist:
				sound_name = sound_name.lstrip(" \t\r\n").rstrip(" \t\r\n")
				if sound_name in _sounds:
					snds.append(sound_name)
	return snds

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func add_sound(sound_name : String, path : String) -> void:
	if not sound_name in _sounds:
		#var dir : Directory = Directory.new()
		#if dir.file_exists(path):
		if ResourceLoader.exists(path):
			var snd = load(path)
			if snd and snd is AudioStream:
				_sounds[sound_name] = snd
			else:
				printerr("WARNING: Resource file \"", path, "\" is not an AudioStream.")
		else:
			printerr("WARNING: Unable to find resource \"", path, "\".")
	else:
		printerr("WARNING: Sound name \"", sound_name, "\" already defined.")

func play(sound_name : String) -> void:
	if sound_name in _sounds:
		var stream = _sounds[sound_name]
		if sfx1.stream == stream or sfx2.stream == stream:
			if sfx1.stream == stream:
				if not sfx1.playing:
					sfx1.play()
			if sfx2.stream == stream:
				if not sfx2.playing:
					sfx2.play()
		elif not sfx1.playing:
			sfx1.stream = stream
			sfx1.play()
		elif not sfx2.playing:
			sfx2.stream = stream
			sfx2.play()

func play_random_set(set_name : String) -> void:
	var sound_list : Array = _GetSoundsInSet(set_name)
	if sound_list.size() > 0:
		var idx = _rng.randi_range(0, sound_list.size() - 1)
		play(sound_list[idx])

func is_playing() -> bool:
	return sfx1.playing or sfx2.playing

func is_playing_sound(sound_name : String) -> bool:
	if sound_name in _sounds:
		var stream = _sounds[sound_name]
		if sfx1.stream == stream and sfx1.playing:
			return true
		if sfx2.stream == stream and sfx2.playing:
			return true
	return false

func stop() -> void:
	sfx1.stop()
	sfx2.stop()



# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

