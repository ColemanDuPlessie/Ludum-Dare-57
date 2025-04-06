extends CharacterBody2D
class_name Bat

const MAX_HP = 20.0
const SPEED = 6

var hp = MAX_HP

var pathfinding: Node

var movement_direction = Vector2.ZERO

var repathfind_timer = 0

var stunned_for = 0.0
var frozen_velocity = Vector2(0, 0)

func stun(duration: float) -> void:
	if stunned_for == 0:
		frozen_velocity = velocity
		velocity = Vector2(0, 0)
		get_node("AnimatedSprite2D").pause()
	stunned_for = max(stunned_for, duration)

func _physics_process(true_delta):
	var delta = true_delta
	if stunned_for > 0.0:
		if stunned_for > true_delta:
			stunned_for -= true_delta
			return
		else:
			delta -= stunned_for
			stunned_for = 0
			velocity = frozen_velocity
			get_node("AnimatedSprite2D").play()
	if repathfind_timer <= 0:
		movement_direction = pathfinding.move_enemy(global_position)

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
				Static.game_manager.begin_building()

	move_and_slide()

func destroy() -> void:
	var idx = Static.all_enemies.find(self)
	if idx > -1: Static.all_enemies.remove_at(idx)
	queue_free()

func take_damage(dmg: int) -> void:
		hp -= dmg

		if hp <= 0:
			destroy()

			if len(Static.all_enemies) == 0:
				Static.game_manager.begin_building()

func _on_hitbox_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		take_damage(body.hit())
