extends StaticBody2D

const TYPE = "CANNON"

const ATTACK_DELAY = [2.1, 1.4] # Seconds/attack
const ATTACK_DAMAGE = [6, 9]
const BULLET_TIME = [0.9, 0.9] # Seconds until bullet lands
const RANGE = [4.5, 5.5] # In 16px tiles from center TODO make a targeting guide pop up on click

const MAX_LEVEL = 1
var level = 0

var proj: PackedScene = ResourceLoader.load("res://scenes/towers/projectiles/bomb.tscn")

var time_remaining_before_attack = 0.0
var all_enemies_in_range = []

var size = 0.0
var appearing = true
const APPEAR_TIME = 1.0

func euclidean_dist_to(tgt: Vector2) -> float:
	return sqrt((tgt[0]-global_position[0])**2 + (tgt[1]-global_position[1])**2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(0, 0)

func upgrade() -> void:
	if level < MAX_LEVEL:
		level += 1
		if level == 1:
			pass # TODO base.play("Level2")

func shoot(tgt: Vector2) -> void:
	var bomb: Node2D = proj.instantiate()
	bomb.global_position = global_position
	bomb.destination = tgt
	bomb.start_pos = global_position
	bomb.level = level
	add_sibling(bomb)

func find_target(): # Returns Vector2 or null
	var best_target = null
	var best_dist = RANGE[level]*16
	
	for enemy in Static.all_enemies:
		var pos = enemy.global_position + enemy.movement_direction * enemy.SPEED * BULLET_TIME[level]

		var dist = euclidean_dist_to(pos)

		if dist < best_dist:
			best_dist = dist
			best_target = pos
	
	return best_target
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if appearing:
		size += delta/APPEAR_TIME
		size = clampf(size, 0, 1)
		scale = Vector2(log(size*24+1)/log(25), log(size*24+1)/log(25))
		if size == 1.0:
			scale = Vector2(1, 1)
			appearing = false
	if time_remaining_before_attack > 0:
		time_remaining_before_attack -= delta
		time_remaining_before_attack = max(0, time_remaining_before_attack)
		if time_remaining_before_attack > 0:
			return
	
	var target = find_target()
	if target != null:
		shoot(target)
		time_remaining_before_attack = ATTACK_DELAY[level]

func destroy() -> void:
	queue_free()
	Static.all_tower_locations.erase(global_position)
