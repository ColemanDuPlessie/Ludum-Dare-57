extends StaticBody2D

const TYPE = "ARCHER"

const ATTACK_DELAY = [1.1, 0.9] # Seconds/attack
const DMG = [3, 5]
const RANGE = [4.0, 4.5] # In 16px tiles from center TODO make a targeting guide pop up on click
const STUN_DURATION = [0.5, 0.7]

const ZAP_LINGER_DURATION = [0.2, 0.3]
var zap_linger_time = 0

const MAX_LEVEL = 1
var level = 0

@onready var base = get_node("TowerSprite")
@onready var laser = get_node("Laser")

const TURRET_PIXEL_OFFSET = 0

var time_remaining_before_attack = 0.0
var all_enemies_in_range = []

func euclidean_dist_to(tgt: Vector2) -> float:
	return sqrt((tgt[0]-global_position[0])**2 + (tgt[1]-global_position[1])**2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # TODO build animations are always classy imo, even if they're super simple.
	base.play("Level1Idle")
	laser.set_visible(false)

func upgrade() -> void:
	if level < MAX_LEVEL:
		level += 1
		if level == 1:
			base.play("Level2Idle")

func shoot(tgt: Vector2, unit) -> void:
	var unit_vec = (tgt-global_position) / euclidean_dist_to(tgt)
	laser.rotation = get_angle_to(tgt)
	laser.scale = Vector2(euclidean_dist_to(tgt), 1)
	laser.set_visible(true)
	unit.take_damage(DMG[level])
	unit.stun(STUN_DURATION[level])
	zap_linger_time = ZAP_LINGER_DURATION[level]

func find_target(): # Returns Vector2 or null
	var best_target = null
	var best_enemy = null
	var best_dist = RANGE[level]*16
	
	for enemy in Static.all_enemies:
		var dist = euclidean_dist_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best_target = enemy.global_position
			best_enemy = enemy
	
	return [best_target, best_enemy]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if zap_linger_time > 0:
		zap_linger_time -= delta
		if zap_linger_time < 0:
			laser.set_visible(false)
	if time_remaining_before_attack > 0:
		time_remaining_before_attack -= delta
		time_remaining_before_attack = max(0, time_remaining_before_attack)
		if time_remaining_before_attack > 0:
			return
		else:
			if level == 0:
				base.play("Level1Idle")
			else:
				base.play("Level2Idle")
	
	var out = find_target()
	var target = out[0]
	if target != null:
		var enemy = out[1]
		shoot(target, enemy)
		time_remaining_before_attack = ATTACK_DELAY[level]



func destroy() -> void:
	queue_free()
	Static.all_tower_locations.erase(global_position)
