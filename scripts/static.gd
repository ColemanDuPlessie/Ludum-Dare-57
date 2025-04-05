extends Node

const GAME_WIDTH = 10 * 2

const DIRT_TILE = Vector2i(16, 1)
const GOLD_TILE = Vector2i(17, 1)
const GEMS_TILE = Vector2i(16, 2)
const OBSIDIAN_TILE = Vector2i(16, 3)
const BEDROCK = Vector2i(16, 5)

const FUEL_COSTS = {
	DIRT_TILE : 1,
	GOLD_TILE : 1,
	GEMS_TILE : 2,
	OBSIDIAN_TILE : 10,
	BEDROCK : 999999999,
}
