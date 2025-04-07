extends CharacterBody2D

var speed: float = 60
var rise_gravity: float = 400
var fall_gravity: float = 600
var jump: float = 180

var y_velocity = 0

@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var head: AnimatedSprite2D = get_node("Head")

var proj: PackedScene = ResourceLoader.load("res://scenes/player_laser.tscn")

var time_remaining_before_attack = 0.0

var ATTACK_DELAYS = [0.3, 0.24, 0.18, 0.12]

func euclidean_dist_to(tgt: Vector2) -> float:
	return sqrt((tgt[0]-global_position[0])**2 + (tgt[1]-global_position[1])**2)

func shoot(tgt: Vector2) -> void:
	
	var laser: Node2D = proj.instantiate()
	var laser_cheat = Vector2(4, -2)
	if sprite.flip_h:
		laser_cheat = Vector2(-4, -2)
	var unit_vec = (tgt-global_position) / euclidean_dist_to(tgt)
	laser.global_position = global_position+laser_cheat+unit_vec*3
	laser.global_rotation = get_angle_to(tgt-laser_cheat)
	
	add_sibling(laser)

	Static.camera.shake(0.4)

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
	
	
	var tgt = get_parent().get_local_mouse_position()
	var vec = tgt-global_position
	var angle = atan2(vec.y, vec.x)
	if head.flip_h == true:
		head.set_frame_and_progress(int(-angle*8/(2*PI)+ 4.5 + 8) % 8, 0.0)
	else:
		head.set_frame_and_progress(int(angle*8/(2*PI) + 4 + 4.5) % 8, 0.0)

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
		sprite.play("run", 2.0)
	else:
		sprite.play("idle")


	
	
	if movement < 0:
		sprite.flip_h = true
		head.flip_h = true
	elif movement > 0:
		sprite.flip_h = false
		head.flip_h = false
