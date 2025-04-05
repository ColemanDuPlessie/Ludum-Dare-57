extends CharacterBody2D

var speed: float = 30
var rise_gravity: float = 400
var fall_gravity: float = 600
var jump: float = 120

var y_velocity = 0

@onready var sprite: AnimatedSprite2D = get_node("Sprite")

func _physics_process(delta: float) -> void:
	var movement = Input.get_axis("left", "right")

	if is_on_floor():
		y_velocity = 0

		if Input.is_action_pressed("up"):
			y_velocity = -jump

	if is_on_ceiling():
		y_velocity = 0

	if y_velocity > 0:
		y_velocity += delta * fall_gravity
	else:
		y_velocity += delta * rise_gravity

	velocity = Vector2(movement * speed, y_velocity)

	move_and_slide()

	if movement != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	if movement < 0:
		sprite.flip_h = true
	elif movement > 0:
		sprite.flip_h = false
