extends Node

@export var tower_menu: Node2D
@export var fog_of_war: TileMapLayer
@export var tiles: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func check_for_opening_tower_menu(mouse_pos: Vector2) -> void:
	var snap = Vector2(floor(mouse_pos[0]/16+0.5)*16, floor(mouse_pos[1]/16+0.5)*16)
	if tower_menu.size == 0: # The menu is closed
		if fog_of_war.check_duplo_revealed(snap): # The place we want to build is not obscured by fog
			if tiles.check_duplo_exists(snap): # The place we want to build is currently ground tiles
				# TODO check it's not already part of a tower
				tower_menu.open_at(snap)
	elif abs(tower_menu.global_position[0] - mouse_pos[0]) > 32 or abs(tower_menu.global_position[1] - mouse_pos[1]) > 32:
		tower_menu.disappear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed('mouse_click'):
		if Static.in_shop:
			return
		var mouse_pos = get_parent().get_local_mouse_position()
		check_for_opening_tower_menu(mouse_pos)
