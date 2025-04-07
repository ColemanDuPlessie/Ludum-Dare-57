extends CharacterBody2D

var MAX_HP = 75.0
const SPEED = 18

var hp = MAX_HP

var pathfinding: Node

var moving = false
var movement_progress = 0
var movement_direction = Vector2i.ZERO
var last_position = Vector2.ZERO

const SPAWN_DURATION = 1.5

var stunned_for = SPAWN_DURATION

func _ready():
	last_position = global_position
	if Static.round_number > len(Static.game_manager.waves):
		var overtime = Static.round_number - len(Static.game_manager.waves)
		MAX_HP *= 1.15**overtime
		hp *= 1.15**overtime

func stun(duration: float) -> void:
	if stunned_for == 0:
		get_node("AnimatedSprite2D").pause()
	stunned_for = max(stunned_for, duration)

func _physics_process(true_delta):
	var delta = true_delta
	if stunned_for > 0.0:
		if stunned_for > true_delta:
			stunned_for -= true_delta
			delta = 0.0
		else:
			delta -= stunned_for
			stunned_for = 0
			get_node("AnimatedSprite2D").play()
	if !moving and delta > 0.0:
		get_movement_direction(delta)
 
	if moving:
		move(delta)
	
	if global_position.y <= 8 && global_position.x >= -24 && global_position.x <= 24:
		Static.game_manager.take_damage()
		destroy()

		if Static.health > 0 && len(Static.all_enemies) == 0:
			Static.game_manager.end_combat()

func get_movement_direction(delta):
	var prev_movement_direction = movement_direction
	movement_direction = pathfinding.move_enemy(global_position)
	if movement_direction == Vector2i.UP and movement_direction != prev_movement_direction:
			get_node("AnimatedSprite2D").play("up")
	elif movement_direction == Vector2i.RIGHT and movement_direction != prev_movement_direction:
			get_node("AnimatedSprite2D").play("right")
			get_node("AnimatedSprite2D").flip_h = false
	elif movement_direction == Vector2i.LEFT and movement_direction != prev_movement_direction:
			get_node("AnimatedSprite2D").play("right")
			get_node("AnimatedSprite2D").flip_h = true
	elif movement_direction == Vector2i.DOWN and movement_direction != prev_movement_direction:
			get_node("AnimatedSprite2D").play("down")
			
		
	moving = true
 
func move(delta):
	movement_progress += delta * SPEED/16
 
	movement_progress = clampf(movement_progress, 0, 1)
 
	global_position = last_position + movement_direction * 16 * movement_progress
 
	if movement_progress == 1:
		last_position = global_position
		moving = false
		movement_progress = 0

func destroy() -> void:
	var idx = Static.all_enemies.find(self)
	if idx > -1: Static.all_enemies.remove_at(idx)
	queue_free()

func take_damage(dmg: int) -> void:
		hp -= dmg

		if hp <= 0:
			destroy()

			if len(Static.all_enemies) == 0:
				Static.game_manager.end_combat()
		else:
			get_node("HP").scale = Vector2(hp/MAX_HP, 1)

func _on_hitbox_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		take_damage(body.hit())
