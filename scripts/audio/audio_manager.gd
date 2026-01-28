class_name AudioManager
extends Node

## Central audio system for Epic Pixels 2D.
## Manages SFX, music, and ambience with volume controls and polyphony limits.

const SfxPoolScript = preload("res://scripts/audio/sfx_pool.gd")

# Bus names (must match default_bus_layout.tres)
const BUS_MASTER := "Master"
const BUS_SFX := "SFX"
const BUS_MUSIC := "Music"
const BUS_AMBIENCE := "Ambience"

# Polyphony limits per category
const MAX_SFX_VOICES := 32
const MAX_MUSIC_VOICES := 2
const MAX_AMBIENCE_VOICES := 4

# Bus indices (cached on ready)
var _bus_master_idx: int = 0
var _bus_sfx_idx: int = 1
var _bus_music_idx: int = 2
var _bus_ambience_idx: int = 3

# SFX Pool for efficient sound playback
var _sfx_pool: SfxPool = null

# Active voice counts for music/ambience (SFX uses pool)
var _active_music_count: int = 0
var _active_ambience_count: int = 0

# Reference to combat events for auto-wiring
var _combat_events: Node = null


func _ready() -> void:
	# Cache bus indices
	_bus_master_idx = AudioServer.get_bus_index(BUS_MASTER)
	_bus_sfx_idx = AudioServer.get_bus_index(BUS_SFX)
	_bus_music_idx = AudioServer.get_bus_index(BUS_MUSIC)
	_bus_ambience_idx = AudioServer.get_bus_index(BUS_AMBIENCE)

	# Validate buses exist
	if _bus_sfx_idx == -1:
		push_error("[AudioManager] SFX bus not found! Check default_bus_layout.tres")
	if _bus_music_idx == -1:
		push_error("[AudioManager] Music bus not found! Check default_bus_layout.tres")
	if _bus_ambience_idx == -1:
		push_error("[AudioManager] Ambience bus not found! Check default_bus_layout.tres")

	# Create SFX pool
	_sfx_pool = SfxPoolScript.new(MAX_SFX_VOICES, BUS_SFX)
	_sfx_pool.name = "SfxPool"
	add_child(_sfx_pool)


## Connect to a CombatEventBus to auto-play sounds for combat events.
func connect_to_combat_events(events: Node) -> void:
	_combat_events = events
	events.weapon_fired.connect(_on_weapon_fired)
	events.target_hit.connect(_on_target_hit)
	events.unit_died.connect(_on_unit_died)


func _on_weapon_fired(_from_pos: Vector2, _to_pos: Vector2, _shooter: Node2D) -> void:
	# Placeholder for rifle fire sounds (Task 3)
	pass


func _on_target_hit(_target: Node2D, _damage: float, _hit_pos: Vector2) -> void:
	# Placeholder for bullet impact sounds (Task 4)
	pass


func _on_unit_died(_unit: Node2D, _death_pos: Vector2) -> void:
	# Placeholder for death sounds (Task 5)
	pass


#region Volume Controls

## Set master volume (0.0 to 1.0).
func set_master_volume(linear: float) -> void:
	_set_bus_volume(_bus_master_idx, linear)


## Set SFX volume (0.0 to 1.0).
func set_sfx_volume(linear: float) -> void:
	_set_bus_volume(_bus_sfx_idx, linear)


## Set music volume (0.0 to 1.0).
func set_music_volume(linear: float) -> void:
	_set_bus_volume(_bus_music_idx, linear)


## Set ambience volume (0.0 to 1.0).
func set_ambience_volume(linear: float) -> void:
	_set_bus_volume(_bus_ambience_idx, linear)


## Get master volume (0.0 to 1.0).
func get_master_volume() -> float:
	return _get_bus_volume(_bus_master_idx)


## Get SFX volume (0.0 to 1.0).
func get_sfx_volume() -> float:
	return _get_bus_volume(_bus_sfx_idx)


## Get music volume (0.0 to 1.0).
func get_music_volume() -> float:
	return _get_bus_volume(_bus_music_idx)


## Get ambience volume (0.0 to 1.0).
func get_ambience_volume() -> float:
	return _get_bus_volume(_bus_ambience_idx)


func _set_bus_volume(bus_idx: int, linear: float) -> void:
	if bus_idx < 0:
		return
	linear = clampf(linear, 0.0, 1.0)
	# Convert linear to dB (0.0 = -80dB silence, 1.0 = 0dB)
	var db := linear_to_db(linear) if linear > 0.0 else -80.0
	AudioServer.set_bus_volume_db(bus_idx, db)


func _get_bus_volume(bus_idx: int) -> float:
	if bus_idx < 0:
		return 0.0
	var db := AudioServer.get_bus_volume_db(bus_idx)
	return db_to_linear(db)

#endregion


#region SFX Playback (Pooled)

## Play a weapon sound at position (highest priority).
func play_weapon_sfx(stream: AudioStream, position: Vector2,
					 volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer2D:
	if _sfx_pool == null:
		return null
	return _sfx_pool.play_at(stream, position, SfxPool.Priority.WEAPON, volume_db, pitch_scale)


## Play an impact sound at position (medium priority).
func play_impact_sfx(stream: AudioStream, position: Vector2,
					 volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer2D:
	if _sfx_pool == null:
		return null
	return _sfx_pool.play_at(stream, position, SfxPool.Priority.IMPACT, volume_db, pitch_scale)


## Play an ambience sound at position (lowest priority).
func play_ambience_sfx(stream: AudioStream, position: Vector2,
					   volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer2D:
	if _sfx_pool == null:
		return null
	return _sfx_pool.play_at(stream, position, SfxPool.Priority.AMBIENCE, volume_db, pitch_scale)


## Play a sound with explicit priority.
func play_sfx(stream: AudioStream, position: Vector2, priority: SfxPool.Priority,
			  volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer2D:
	if _sfx_pool == null:
		return null
	return _sfx_pool.play_at(stream, position, priority, volume_db, pitch_scale)


## Get the SFX pool for direct access if needed.
func get_sfx_pool() -> SfxPool:
	return _sfx_pool

#endregion


#region Polyphony Management

## Check if we can play another SFX voice (pool has available slots).
func can_play_sfx() -> bool:
	if _sfx_pool == null:
		return false
	return _sfx_pool.get_available_count() > 0


## Check if we can play another music voice.
func can_play_music() -> bool:
	return _active_music_count < MAX_MUSIC_VOICES


## Check if we can play another ambience voice.
func can_play_ambience() -> bool:
	return _active_ambience_count < MAX_AMBIENCE_VOICES


## Register that a music voice started playing.
func register_music_voice() -> void:
	_active_music_count += 1


## Register that a music voice stopped playing.
func unregister_music_voice() -> void:
	_active_music_count = maxi(_active_music_count - 1, 0)


## Register that an ambience voice started playing.
func register_ambience_voice() -> void:
	_active_ambience_count += 1


## Register that an ambience voice stopped playing.
func unregister_ambience_voice() -> void:
	_active_ambience_count = maxi(_active_ambience_count - 1, 0)


## Get current SFX voice count (from pool).
func get_active_sfx_count() -> int:
	if _sfx_pool == null:
		return 0
	return _sfx_pool.get_active_count()


## Get current music voice count.
func get_active_music_count() -> int:
	return _active_music_count


## Get current ambience voice count.
func get_active_ambience_count() -> int:
	return _active_ambience_count

#endregion
