extends TileMap

var safe_tiles = [
	5,
	6
]

onready var player = $Player

func can_move_to_pos(pos: Vector2, include_characters=true, include_player=true):
	if include_player:
		for position_taken in player.get_positions_taken():
			if position_taken.distance_squared_to(pos) < 3:
				return false
	if include_characters:
		for character in get_tree().get_nodes_in_group("characters"):
			if character.global_position.distance_squared_to(pos) < 3:
				return false
	var map_pos = world_to_map(pos)
	var id = get_cell(int(round(map_pos.x)), int(round(map_pos.y)))
	return id < 0 or id in safe_tiles
	
