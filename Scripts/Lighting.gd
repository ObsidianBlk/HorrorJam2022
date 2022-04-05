extends Light2D

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const FLICKER_SOUND_SET_NAME = "flicker" # Hardcoding this for coding speed.

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var light_on : bool = true
export var sound_control_path : NodePath = ""
export var hum_audio_path : NodePath = ""
export var energy_variance : float = 0.0			setget set_energy_variance
export (float, 0.0, 1.0, 0.01) var hum_constant_volume : float = 0.0
export var hum_min_energy : float = 1.2
export var hum_max_energy : float = 1.4
export var flicker_count_min : int = 0
export var flicker_count_max : int = 1
export var flicker_interval : float = 0.0			setget set_flicker_interval
export var flicker_interval_variance : float = 0.0	setget set_flicker_interval_variance

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _timer : Timer = null
var _tween : Tween = null
var _base_energy : float = 0.0
var _flick : int = 0
var _rng : RandomNumberGenerator = null
var _isready : bool = false


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_light_on(l : bool) -> void:
	if l:
		turn_on()
	else:
		turn_off()


func set_energy_variance(ev : float) -> void:
	if ev >= 0.0:
		energy_variance = ev


func set_flicker_interval(fi : float) -> void:
	if fi >= 0.0:
		flicker_interval = fi


func set_flicker_interval_variance(fiv : float) -> void:
	if fiv >= 0.0:
		flicker_interval_variance = fiv


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	_tween = Tween.new()
	add_child(_tween)
	_tween.connect("tween_all_completed", self, "_on_tween_completed")
	
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_flicker_timeout")
	
	_base_energy = energy
	set_light_on(light_on)
	_isready = true



func _process(_delta : float) -> void:
	var haudio = get_node_or_null(hum_audio_path)
	if not haudio:
		return
	
	if energy >= hum_min_energy:
		if haudio is AudioStreamPlayer2D and haudio.stream != null:
			var vol = max(0.0001, min(1.0, (energy - hum_min_energy) / (hum_max_energy - hum_min_energy)))
			haudio.volume_db = linear2db(vol)
			if not haudio.playing:
				haudio.play()
	elif haudio.playing:
		haudio.stop()


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetSoundControl() -> Node2D:
	if sound_control_path != "":
		var sc = get_node_or_null(sound_control_path)
		if sc and sc.has_method("play_random_set"):
			return sc
	return null

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func turn_on() -> void:
	if light_on and _isready:
		return
	
	light_on = true
	if flicker_interval > 0.0 and flicker_count_min > 0 and flicker_count_max > flicker_count_min:
		_on_flicker_timeout()
	if hum_audio_path == "" and hum_constant_volume > 0.0:
		var haudio = get_node_or_null(hum_audio_path)
		if haudio:
			haudio.volume_db = linear2db(hum_constant_volume)
			haudio.play()
	if energy_variance > 0.0:
		_on_tween_completed()
	else:
		_tween.remove_all()
		_tween.interpolate_property(
			self, "energy",
			energy, _base_energy,
			0.4,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		_tween.start()

func turn_off() -> void:
	if not light_on and _isready:
		return
		
	light_on = false
	_tween.remove_all()
	_tween.interpolate_property(
		self, "energy",
		energy, 0.0,
		0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	_tween.start()
	

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_flicker_timeout() -> void:
	if light_on:
		if _flick == 0:
			enabled = true
			var variance : float = flicker_interval * flicker_interval_variance
			var duration : float = _rng.randf_range(
				flicker_interval - variance,
				flicker_interval + variance
			)
			_flick = _rng.randi_range(flicker_count_min, flicker_count_max)
			_timer.start(duration)
		else:
			if enabled:
				_flick -= 1
				enabled = false
			else:
				enabled = true
				var sc = _GetSoundControl()
				if sc != null:
					sc.play_random_set(FLICKER_SOUND_SET_NAME)
			_timer.start(_rng.randf_range(0.02, 0.1))
	else:
		_timer.stop()
		_flick = 0


func _on_tween_completed() -> void:
	if light_on:
		var variance = _base_energy * energy_variance
		var target_energy = _rng.randf_range(
			_base_energy - variance,
			_base_energy + variance
		)
		var duration : float = _rng.randf_range(0.1, 4.0)
		_tween.interpolate_property(
			self, "energy",
			energy, target_energy,
			duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		_tween.start()


