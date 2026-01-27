extends Line2D

## A brief tracer line from shooter to target. Fades and frees itself.

@export var lifetime: float = 0.12
@export var fade_time: float = 0.08

var _age: float = 0.0
var _total_time: float


func _ready() -> void:
	_total_time = lifetime + fade_time
	width = 2.0
	default_color = Color(1.0, 0.95, 0.6, 1.0)  # Warm yellow tracer
	z_index = 11


func _process(delta: float) -> void:
	_age += delta

	if _age >= _total_time:
		queue_free()
		return

	# Fade out during fade phase
	if _age > lifetime:
		var fade_progress = (_age - lifetime) / fade_time
		default_color.a = 0.9 * (1.0 - fade_progress)


## Set tracer line from world positions. Call after adding to scene tree.
func set_endpoints(from_pos: Vector2, to_pos: Vector2) -> void:
	# Convert to local coords since Line2D draws in local space
	clear_points()
	add_point(to_local(from_pos))
	add_point(to_local(to_pos))
