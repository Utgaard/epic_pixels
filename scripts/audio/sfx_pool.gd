class_name SfxPool
extends Node

## Pool of AudioStreamPlayer2D nodes for efficient SFX playback.
## Supports priority-based voice stealing when pool is exhausted.

## Priority levels for SFX (higher = more important)
enum Priority {
	AMBIENCE = 0,   # Lowest - environmental sounds
	IMPACT = 1,     # Medium - bullet impacts, hits
	WEAPON = 2,     # Highest - weapon fire sounds
}

## Emitted when a pooled player finishes and returns to pool
signal player_released(player: AudioStreamPlayer2D)

# Pool configuration
const DEFAULT_POOL_SIZE := 32
const DEFAULT_BUS := "SFX"

# Pool state
var _available: Array[AudioStreamPlayer2D] = []
var _active: Array[AudioStreamPlayer2D] = []
var _player_priorities: Dictionary = {}  # AudioStreamPlayer2D -> Priority
var _player_start_times: Dictionary = {}  # AudioStreamPlayer2D -> float (for stealing oldest)

var _pool_size: int = DEFAULT_POOL_SIZE
var _bus_name: String = DEFAULT_BUS


func _init(pool_size: int = DEFAULT_POOL_SIZE, bus: String = DEFAULT_BUS) -> void:
	_pool_size = pool_size
	_bus_name = bus


func _ready() -> void:
	_prewarm_pool()


## Pre-instantiate all AudioStreamPlayer2D nodes.
func _prewarm_pool() -> void:
	for i in _pool_size:
		var player := AudioStreamPlayer2D.new()
		player.bus = _bus_name
		player.finished.connect(_on_player_finished.bind(player))
		add_child(player)
		_available.append(player)


## Acquire a player from the pool. Returns null if unavailable and no stealable voice.
## If pool is exhausted, will steal from lowest priority (or oldest same-priority) sound.
func acquire(priority: Priority = Priority.IMPACT) -> AudioStreamPlayer2D:
	var player: AudioStreamPlayer2D = null

	if _available.size() > 0:
		# Pool has available players
		player = _available.pop_back()
	else:
		# Pool exhausted - try to steal a voice
		player = _try_steal_voice(priority)
		if player == null:
			push_warning("[SfxPool] Pool exhausted and no stealable voice for priority %d" % priority)
			return null

	_active.append(player)
	_player_priorities[player] = priority
	_player_start_times[player] = Time.get_ticks_msec()
	return player


## Release a player back to the pool (called automatically on finished).
func release(player: AudioStreamPlayer2D) -> void:
	if player in _active:
		player.stop()
		_active.erase(player)
		_player_priorities.erase(player)
		_player_start_times.erase(player)
		_available.append(player)
		player_released.emit(player)


## Try to steal a voice from a lower priority (or oldest same-priority) sound.
func _try_steal_voice(requesting_priority: Priority) -> AudioStreamPlayer2D:
	if _active.is_empty():
		return null

	var best_steal_target: AudioStreamPlayer2D = null
	var best_steal_priority: int = requesting_priority + 1  # Must be <= requesting
	var best_steal_time: float = INF

	for player in _active:
		var player_priority: int = _player_priorities.get(player, Priority.IMPACT)
		var player_time: float = _player_start_times.get(player, 0.0)

		# Can steal if lower priority, or same priority but older
		if player_priority < requesting_priority:
			# Lower priority - prefer lowest priority, then oldest
			if player_priority < best_steal_priority or \
			   (player_priority == best_steal_priority and player_time < best_steal_time):
				best_steal_target = player
				best_steal_priority = player_priority
				best_steal_time = player_time
		elif player_priority == requesting_priority:
			# Same priority - steal oldest
			if best_steal_target == null or player_time < best_steal_time:
				if best_steal_priority >= requesting_priority:
					best_steal_target = player
					best_steal_priority = player_priority
					best_steal_time = player_time

	if best_steal_target:
		# Stop and reclaim
		best_steal_target.stop()
		_active.erase(best_steal_target)
		_player_priorities.erase(best_steal_target)
		_player_start_times.erase(best_steal_target)
		return best_steal_target

	return null


## Called when an AudioStreamPlayer2D finishes playing.
func _on_player_finished(player: AudioStreamPlayer2D) -> void:
	release(player)


## Play a sound at a position with given priority. Returns the player or null.
func play_at(stream: AudioStream, position: Vector2, priority: Priority = Priority.IMPACT,
			 volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer2D:
	var player := acquire(priority)
	if player == null:
		return null

	player.stream = stream
	player.global_position = position
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	return player


## Get count of available players in pool.
func get_available_count() -> int:
	return _available.size()


## Get count of active (playing) players.
func get_active_count() -> int:
	return _active.size()


## Get total pool size.
func get_pool_size() -> int:
	return _pool_size
