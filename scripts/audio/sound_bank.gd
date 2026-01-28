class_name SoundBank
extends Resource

## A collection of sound variations for a single logical sound effect.
## Supports random selection and pitch variation for organic audio.

## Array of audio streams to randomly select from
@export var streams: Array[AudioStream] = []

## Base volume in dB
@export var volume_db: float = 0.0

## Minimum pitch multiplier (e.g., 0.9 for -10%)
@export var pitch_min: float = 0.95

## Maximum pitch multiplier (e.g., 1.1 for +10%)
@export var pitch_max: float = 1.05


## Get a random stream from the bank. Returns null if empty.
func get_random_stream() -> AudioStream:
	if streams.is_empty():
		return null
	return streams[randi() % streams.size()]


## Get a random pitch value within the configured range.
func get_random_pitch() -> float:
	return randf_range(pitch_min, pitch_max)


## Check if this bank has any sounds loaded.
func has_sounds() -> bool:
	return not streams.is_empty()
