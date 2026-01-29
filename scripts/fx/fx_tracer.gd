extends Node2D

## A brief tracer line from shooter to target. Fades and frees itself.

@export var lifetime: float = 0.12
@export var fade_time: float = 0.08
@export var line_width: float = 0.3
@export var color: Color = Color(1.0, 0.95, 0.6, 1.0)  # Warm yellow tracer

var _age: float = 0.0
var _total_time: float
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _current_alpha: float = 1.0


func _ready() -> void:
	_total_time = lifetime + fade_time
	z_index = 11


func _process(delta: float) -> void:
	_age += delta

	if _age >= _total_time:
		queue_free()
		return

	# Fade out during fade phase
	if _age > lifetime:
		var fade_progress = (_age - lifetime) / fade_time
		_current_alpha = 1.0 - fade_progress
		queue_redraw()


func _draw() -> void:
	var draw_color = Color(color.r, color.g, color.b, _current_alpha)
	draw_line(_from, _to, draw_color, line_width, true)  # true = antialiased


## Set tracer line from world positions. Call after adding to scene tree.
func set_endpoints(from_pos: Vector2, to_pos: Vector2) -> void:
	_from = to_local(from_pos)
	_to = to_local(to_pos)
	queue_redraw()
