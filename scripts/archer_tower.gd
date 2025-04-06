extends StaticBody2D

const ATTACK_DELAY = 0.5 # Seconds/attack
const ATTACK_DAMAGE = 5
const BULLET_SPEED = 5 # In 16px tiles/second (i.e. BULLET_SPEED = 1 means 16px/sec)
const RANGE = 4 # In 16px tiles from center TODO make a targeting guide pop up on click

var proj: PackedScene = ResourceLoader.load("res://scenes/arrow.tscn")

@onready var turret = get_node("ArcherTurretSprite")
const TURRET_PIXEL_OFFSET = 4

var time_remaining_before_attack = 0.0
var all_enemies_in_range = []

func euclidean_dist_to(tgt: Vector2) -> float:
	return sqrt((tgt[0]-global_position[0])**2 + (tgt[1]-global_position[1])**2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # TODO build animations are always classy imo, even if they're super simple.
	turret.play("Ready")

func shoot(tgt: Vector2) -> void:
	var unit_vec = (tgt-global_position) / euclidean_dist_to(tgt)
	turret.global_position = global_position + unit_vec * TURRET_PIXEL_OFFSET
	turret.global_rotation = get_angle_to(tgt)
	turret.play("Reloading")
	
	var arrow: Node2D = proj.instantiate()
	arrow.global_position = turret.global_position
	arrow.global_rotation = turret.global_rotation
	
	add_sibling(arrow)

func find_target(): # Returns Vector2 or null
	var best_target = null
	var best_dist = RANGE*16
	
	for enemy in Static.all_enemies:
		var dist = euclidean_dist_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best_target = enemy.global_position
	
	return best_target
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		time_remaining_before_attack = ATTACK_DELAY

func destroy() -> void:
	queue_free()
