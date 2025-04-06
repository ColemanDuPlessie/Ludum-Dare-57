extends Node

@export var tower_menu: Node2D
@export var upgrade_menu: Node2D
@export var fog_of_war: TileMapLayer
@export var tiles: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func check_for_opening_tower_menu(mouse_pos: Vector2) -> bool:
	var snap = Vector2(floor(mouse_pos[0]/16+0.5)*16, floor(mouse_pos[1]/16+0.5)*16)
	if tower_menu.size == 0 and upgrade_menu.size == 0: # The menu is closed
		if fog_of_war.check_duplo_revealed(snap): # The place we want to build is not obscured by fog
			if tiles.check_duplo_exists(snap): # The place we want to build is currently ground tiles
				var legal_to_open = true
				for tower_loc in Static.all_tower_locations.keys():
					if abs(snap[0]-tower_loc[0]) < 16 and abs(snap[1]-tower_loc[1]) < 16:
						upgrade_menu.open_at(tower_loc)
						return true
					elif abs(snap[0]-tower_loc[0]) < 20 and abs(snap[1]-tower_loc[1]) < 20:
						legal_to_open = false
				if legal_to_open:
					tower_menu.open_at(snap)
					return true
	else:
		if abs(tower_menu.global_position[0] - mouse_pos[0]) > 32 or abs(tower_menu.global_position[1] - mouse_pos[1]) > 32:
			tower_menu.disappear()
		if abs(upgrade_menu.global_position[0] - mouse_pos[0]) > 32 or abs(upgrade_menu.global_position[1] - mouse_pos[1]) > 32:
			upgrade_menu.disappear()

	return false

const correctionOffsets = [ Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1) ]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed('mouse_click'):
		if Static.game_manager.state == "building":
			var mouse_pos = get_parent().get_local_mouse_position() 

			for correctionOffset in correctionOffsets:
				var result = check_for_opening_tower_menu(mouse_pos + correctionOffset * 16)

				if result:
					break
		elif Static.game_manager.state == "combat":
			pass # Shooting is handled by the player script
