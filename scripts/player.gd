extends CharacterBody2D

var speed: float = 60
var rise_gravity: float = 400
var fall_gravity: float = 600
var jump: float = 180

var y_velocity = 0

@onready var sprite: AnimatedSprite2D = get_node("Sprite")

var proj: PackedScene = ResourceLoader.load("res://scenes/player_laser.tscn")

var time_remaining_before_attack = 0.0

var ATTACK_DELAYS = [0.3, 0.24, 0.18, 0.12]

func euclidean_dist_to(tgt: Vector2) -> float:
	return sqrt((tgt[0]-global_position[0])**2 + (tgt[1]-global_position[1])**2)

func shoot(tgt: Vector2) -> void:
	var unit_vec = (tgt-global_position) / euclidean_dist_to(tgt)
	
	var laser: Node2D = proj.instantiate()
	laser.global_position = global_position
	laser.global_rotation = get_angle_to(tgt)
	
	add_sibling(laser)

func try_shoot(tgt: Vector2) -> void:
	if time_remaining_before_attack > 0:
		return
	shoot(tgt)
	time_remaining_before_attack = ATTACK_DELAYS[Static.PLAYER_GUN_LEVEL]

func _process(delta: float) -> void:
	if time_remaining_before_attack > 0:
		time_remaining_before_attack -= delta
		time_remaining_before_attack = max(0, time_remaining_before_attack)
		if time_remaining_before_attack > 0:
			return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		try_shoot(get_parent().get_local_mouse_position())

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

	if !is_on_floor():
		if y_velocity < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif movement != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	if movement < 0:
		sprite.flip_h = true
	elif movement > 0:
		sprite.flip_h = false
