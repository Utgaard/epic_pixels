extends AnimatedSprite2D

## Generic one-shot animated FX. Plays once and frees itself.


func _ready() -> void:
	animation_finished.connect(_on_finished)
	play()


func _on_finished() -> void:
	queue_free()
