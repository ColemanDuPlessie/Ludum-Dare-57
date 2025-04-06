extends Area2D

const MOVE_SPEED = 1 # In tiles/second
const MAX_HP = 20.0

var hp = MAX_HP

var pathfinding: Node

var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var queued_movement_direction = Vector2.ZERO # We need to do this math 1 step ahead so that cannon towers can track where enemies will be, not where they are
var last_position = Vector2.ZERO

func _ready():
	last_position = global_position
	# TODO dig out of the ground

func _physics_process(delta):
	if !moving: # TODO also add a state for "digging out of the ground for a second"
		get_movement_direction(delta)
	
	if moving:
		move(delta)

func get_movement_direction(delta):
	movement_direction = queued_movement_direction
	queued_movement_direction = pathfinding.move_enemy(global_position + Vector2(movement_direction*16))
	moving = true

func move(delta):
	movement_progress += delta * MOVE_SPEED

	movement_progress = clampf(movement_progress, 0, 1)
	
	global_position = last_position + movement_direction * 16 * movement_progress

	if movement_progress == 1:
		last_position = global_position
		moving = false
		movement_progress = 0

		if global_position.y <= 8:
			Static.game_manager.take_damage()
			
			destroy()

func destroy() -> void:
	var idx = Static.all_enemies.find(self)
	if idx > -1: Static.all_enemies.remove_at(idx)
	queue_free()

func take_damage(dmg: int) -> void:
		hp -= dmg
		 # TODO health indicator goes here!
		if hp <= 0:
			destroy()
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		take_damage(body.hit())
