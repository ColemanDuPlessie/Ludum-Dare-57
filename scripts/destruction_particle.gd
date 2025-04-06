extends RigidBody2D

var timer = 0

func _ready() -> void:
    apply_impulse((Vector2.RIGHT * randf_range(100, 200)).rotated(randf_range(-PI, PI)))

func _process(delta):
    if timer > 1:
        modulate = Color(1, 1, 1, 2 - timer)

    if timer > 2:
        queue_free()

    timer += delta