extends TileMap

var safe_tiles = [
	5,
	6
]

onready var player = $Player
onready var portal = $Portal
onready var map_top_left = $MapTopLeft
onready var map_bot_right = $MapBotRight

var astar : AStar2D
var astar_points_cache = {}

func _ready():
	init_astar()
	map_top_left.hide()
	map_bot_right.hide()

func can_move_to_pos(pos: Vector2, include_characters=true, dont_include_group=""):
#	if include_player:
	for wall in get_tree().get_nodes_in_group("walls"):
		if wall.global_position.distance_squared_to(pos) < 3:
				return false
	for position_taken in player.get_positions_taken():
		if position_taken.distance_squared_to(pos) < 3:
			return false
	if include_characters:
		for character in get_tree().get_nodes_in_group("characters"):
			if character.is_in_group(dont_include_group):
				continue
			if character.global_position.distance_squared_to(pos) < 3:
				return false
	var map_pos = world_to_map(pos)
	var id = get_cell(int(round(map_pos.x)), int(round(map_pos.y)))
	return can_move_on_tile(id)

func init_astar():
	astar = AStar2D.new()
	var tl_pos = world_to_map(map_top_left.global_position)
	var br_pos = world_to_map(map_bot_right.global_position)
	var start_x = round(int(tl_pos.x))
	var start_y = round(int(tl_pos.y))
	var end_x = round(int(br_pos.x))
	var end_y = round(int(br_pos.y))
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			if can_move_on_tile(get_cell(x, y)):
				var tile_id = astar.get_available_point_id()
				astar.add_point(tile_id, Vector2(x, y))
				astar_points_cache[coord_to_key(x, y)] = tile_id
			#	points_to_draw.append(coord_to_world_pos(x, y))
	
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			var cur_key = coord_to_key(x, y)
			if !cur_key in astar_points_cache:
				continue
			var cur_tile_id = astar_points_cache[cur_key]
			var prev_x_key = coord_to_key(x-1, y)
			var prev_y_key = coord_to_key(x, y-1)
			if prev_x_key in astar_points_cache:
				astar.connect_points(astar_points_cache[prev_x_key], cur_tile_id)
			#	lines_to_draw.append([coord_to_world_pos(x-1, y), coord_to_world_pos(x, y)])
			if prev_y_key in astar_points_cache:
				astar.connect_points(astar_points_cache[prev_y_key], cur_tile_id)
			#	lines_to_draw.append([coord_to_world_pos(x, y-1), coord_to_world_pos(x, y)])
	#update()

#var lines_to_draw = []
#var points_to_draw = []
#var path_to_draw = []
#var custom_draw_pos = Vector2()
#func _draw():
#	for line in lines_to_draw:
#		draw_line(line[0], line[1], Color.green, 1)
#	for point in points_to_draw:
#		draw_circle(point, 1, Color.red)
#	for path_point in path_to_draw:
#		draw_circle(path_point, 2, Color.blue)
#	draw_circle(custom_draw_pos, 3, Color.yellow)

#func _process(delta):
#	custom_draw_pos = map_to_world(world_to_map(get_global_mouse_position()))+Vector2(4,4)
#	update()

func can_move_on_tile(tile_id: int):
	return tile_id < 0 or tile_id in safe_tiles

func coord_to_key(x: int, y: int):
	return str(x) + "," + str(y)

func coord_to_world_pos(x: int, y: int):
	return map_to_world(Vector2(x, y)) + Vector2(4, 4)

func get_dir_from_pos_to_pos(start_pos: Vector2, end_pos: Vector2):
	var path = get_path_from_pos_to_pos(start_pos, end_pos)
#	path_to_draw = []
#	for path_point in path:
#		path_to_draw.append(map_to_world(path_point)+Vector2(4, 4))
#	update()
	
	if path.size() < 2:
		return null
	
	var p_pos = map_to_world(path[1])+Vector2(4, 4)
	
	var direction_to_go = null
	if p_pos.x > start_pos.x + 4:
		direction_to_go = Character.DIRECTIONS.RIGHT
	elif p_pos.x < start_pos.x - 4:
		direction_to_go = Character.DIRECTIONS.LEFT
	elif p_pos.y < start_pos.y - 4:
		direction_to_go = Character.DIRECTIONS.UP
	else:
		direction_to_go = Character.DIRECTIONS.DOWN
	
	#print(start_pos, " ", p_pos, " ", Character.DIRECTIONS.keys()[direction_to_go])
	return direction_to_go

func get_travel_dist_from_pos_to_pos(start_pos: Vector2, end_pos: Vector2):
	return get_path_from_pos_to_pos(start_pos, end_pos).size()

func get_path_from_pos_to_pos(start_pos: Vector2, end_pos: Vector2):
	var s_pos = world_to_map(start_pos)
	var e_pos = world_to_map(end_pos)
	var start_x = round(int(s_pos.x))
	var start_y = round(int(s_pos.y))
	var end_x = round(int(e_pos.x))
	var end_y = round(int(e_pos.y))
	
	var start_key = coord_to_key(start_x, start_y)
	var end_key = coord_to_key(end_x, end_y)
	
	if !start_key in astar_points_cache or !end_key in astar_points_cache:
		return []
	
	return astar.get_point_path(astar_points_cache[start_key], astar_points_cache[end_key])

func clear_tile(pos: Vector2):
	set_cellv(world_to_map(pos), -1)

func reached_portal():
	return player.head_sprite.global_position.distance_squared_to(portal.global_position) < 3
