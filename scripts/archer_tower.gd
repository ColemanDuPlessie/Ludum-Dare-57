extends StaticBody2D

const TYPE = "ARCHER"

const ATTACK_DELAY = [0.75, 0.5] # Seconds/attack
const ATTACK_DAMAGE = [4, 6]
const BULLET_SPEED = [4.0, 5.5] # In 16px tiles/second (i.e. BULLET_SPEED = 1 means 16px/sec)
const RANGE = [3.5, 4.25] # In 16px tiles from center

const MAX_LEVEL = 1
var level = 0

var proj: PackedScene = ResourceLoader.load("res://scenes/towers/projectiles/arrow.tscn")

@onready var turret = get_node("ArcherTurretSprite")
@onready var base = get_node("TowerSprite")
const TURRET_PIXEL_OFFSET = 0

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
	turret.play("Ready")
	base.play("Level1")

func upgrade() -> void:
	if level < MAX_LEVEL:
		level += 1
		if level == 1:
			base.play("Level2")

func shoot(tgt: Vector2) -> void:
	var unit_vec = (tgt-global_position) / euclidean_dist_to(tgt)
	turret.global_position = global_position + unit_vec * TURRET_PIXEL_OFFSET
	turret.global_rotation = get_angle_to(tgt)
	turret.play("Reloading")
	
	var arrow: Node2D = proj.instantiate()
	arrow.level = level
	arrow.global_position = turret.global_position
	arrow.global_rotation = turret.global_rotation
	
	add_sibling(arrow)

func find_target(): # Returns Vector2 or null
	var best_target = null
	var best_dist = RANGE[level]*16
	
	for enemy in Static.all_enemies:
		var pos = enemy.global_position
		if enemy.stunned_for <= 0.0:
			pos += Vector2(enemy.pathfinding.move_enemy(enemy.global_position, false))*enemy.SPEED
		var dist = euclidean_dist_to(pos)
		if dist < best_dist:
			best_dist = dist
			best_target = enemy.global_position
	
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
		else:
			turret.play("Ready")
	
	var target = find_target()
	if target != null:
		shoot(target)
		time_remaining_before_attack = ATTACK_DELAY[level]



func destroy() -> void:
	queue_free()
	Static.all_tower_locations.erase(global_position)
