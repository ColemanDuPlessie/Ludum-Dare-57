extends CharacterBody2D
class_name Bat

const MAX_HP = 20.0
const SPEED = 6

var hp = MAX_HP

var pathfinding: Node

var movement_direction = Vector2.ZERO

var repathfind_timer = 0

func _physics_process(delta):
	if repathfind_timer <= 0:
		movement_direction = pathfinding.move_enemy(global_position)

		repathfind_timer = 0.4

		if movement_direction == Vector2i.RIGHT:
			velocity = Vector2(30, -70)
		elif movement_direction == Vector2i.LEFT:
			velocity = Vector2(-30, -70)
		elif movement_direction == Vector2i.UP:
			velocity = Vector2(0, -90)
		elif movement_direction == Vector2i.DOWN:
			velocity = Vector2(0, -15)
			
	velocity += Vector2(0, 300) * delta

	repathfind_timer -= delta

	if global_position.y <= 8:
			Static.game_manager.take_damage()
			
			destroy()

	move_and_slide()

func destroy() -> void:
	var idx = Static.all_enemies.find(self)
	if idx > -1: Static.all_enemies.remove_at(idx)
	queue_free()

func take_damage(dmg: int) -> void:
		hp -= dmg
		 # TODO health indicator goes here!
		if hp <= 0:
			destroy()

func _on_hitbox_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		take_damage(body.hit())
