extends CharacterBody2D

var MAX_HP = 20.0
const SPEED = 24

var hp = MAX_HP

var pathfinding: Node

var movement_direction = Vector2.ZERO

var repathfind_timer = 0

var frozen_velocity = Vector2(0, 0)

const SPAWN_DURATION = 1.0

var stunned_for = SPAWN_DURATION

var damage_timer = 0

func _ready():
	if Static.round_number > len(Static.game_manager.waves):
		var overtime = Static.round_number - len(Static.game_manager.waves)
		MAX_HP *= 1.15**overtime
		hp *= 1.15**overtime

func stun(duration: float) -> void:
	if stunned_for == 0:
		frozen_velocity = velocity
		velocity = Vector2(0, 0)
		get_node("AnimatedSprite2D").pause()
	stunned_for = max(stunned_for, duration)

func _process(delta: float) -> void:
	damage_timer -= delta

	if damage_timer > 0:
		get_node("AnimatedSprite2D").material = ResourceLoader.load("res://flash_material.tres")
	else:
		get_node("AnimatedSprite2D").material = null

func _physics_process(true_delta):
	var delta = true_delta
	if stunned_for > 0.0:
		if stunned_for > true_delta:
			stunned_for -= true_delta
			delta = 0.0
		else:
			delta -= stunned_for
			stunned_for = 0
			velocity = frozen_velocity
			get_node("AnimatedSprite2D").play("default")
	if repathfind_timer <= 0 and delta > 0.0:
		movement_direction = pathfinding.move_enemy(global_position, true)

		repathfind_timer = 0.4

		if movement_direction == Vector2i.RIGHT:
			velocity = Vector2(30, -65)
		elif movement_direction == Vector2i.LEFT:
			velocity = Vector2(-30, -65)
		elif movement_direction == Vector2i.UP:
			velocity = Vector2(0, -90)
		elif movement_direction == Vector2i.DOWN:
			velocity = Vector2(0, -15)
		
		velocity += (floor(global_position / 16) * 16 + Vector2.ONE * 8 - global_position).normalized() * 5
			
	velocity += Vector2(0, 300) * delta

	repathfind_timer -= delta

	if global_position.y <= 8 && global_position.x >= -24 && global_position.x <= 24:
			Static.game_manager.take_damage()
			
			destroy()

			if Static.health > 0 && len(Static.all_enemies) == 0:
				Static.game_manager.end_combat()
				
	move_and_slide()

func destroy() -> void:
	var idx = Static.all_enemies.find(self)
	if idx > -1: Static.all_enemies.remove_at(idx)
	queue_free()

func take_damage(dmg: int) -> void:
		hp -= dmg

		damage_timer = 0.15

		if hp <= 0:
			var idx = Static.all_enemies.find(self)
			if idx > -1: Static.all_enemies.remove_at(idx)
			get_node("Death").play()
			get_node("Collision").disabled = true
			get_node("Hitbox/CollisionShape2D").disabled = true
			visible = false
			stunned_for = 999
			

			if len(Static.all_enemies) == 0:
				Static.game_manager.end_combat()
		else:
			get_node("HP").scale = Vector2(hp/MAX_HP, 1)

func _on_hitbox_entered(body: Node2D) -> void:
	if visible and body.has_method("hit"):
		take_damage(body.hit())


func _on_death_finished() -> void:
	destroy()
