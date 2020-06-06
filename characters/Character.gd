extends Node2D

class_name Character

onready var tilemap : TileMap = get_parent()

enum DIRECTIONS {UP, RIGHT, DOWN, LEFT}
var cur_direction = DIRECTIONS.UP
var facing_right = false

var group_to_ignore = ""

func move(slide_on_walls=true):
	if cur_direction == null:
		return false
	var offset = get_offset_for_dir(cur_direction)
	if tilemap.can_move_to_pos(global_position + offset, true, group_to_ignore):
		pass
	elif slide_on_walls and tilemap.can_move_to_pos(global_position + get_offset_for_dir((cur_direction + 1) % DIRECTIONS.size())):
		offset = get_offset_for_dir((cur_direction + 1) % DIRECTIONS.size())
	elif slide_on_walls and tilemap.can_move_to_pos(global_position + get_offset_for_dir((cur_direction + 3) % DIRECTIONS.size())):
		offset = get_offset_for_dir((cur_direction + 3) % DIRECTIONS.size())
	else:
		return false
	
	global_position += offset
	round_position()
	return true

func get_offset_for_dir(direction):
	var offset = Vector2()
	match direction:
		DIRECTIONS.UP:
			offset = Vector2.UP
		DIRECTIONS.DOWN:
			offset = Vector2.DOWN
		DIRECTIONS.RIGHT:
			offset = Vector2.RIGHT
			if !facing_right:
				flip()
		DIRECTIONS.LEFT:
			offset = Vector2.LEFT
			if facing_right:
				flip()
		_:
			offset = Vector2.ZERO
	return offset * 8

func round_position():
	global_position.x = int(round(global_position.x))
	global_position.y = int(round(global_position.y))

func flip():
	facing_right = !facing_right
	scale.x *= -1

func has_line_of_sight(start_pos: Vector2, end_pos: Vector2):
	var start_vec = tilemap.world_to_map(start_pos)
	var end_vec = tilemap.world_to_map(end_pos)
	var start_coord = [int(round(start_vec.x)), int(round(start_vec.y))]
	var end_coord = [int(round(end_vec.x)), int(round(end_vec.y))]
	
	return has_line_of_sight_one_way(start_coord, end_coord) and has_line_of_sight_one_way(end_coord, start_coord)

func has_line_of_sight_one_way(start_coord, end_coord):
	var x1 = start_coord[0]
	var y1 = start_coord[1]
	var x2 = end_coord[0]
	var y2 = end_coord[1]
	var dx = x2 - x1
	var dy = y2 - y1
	# Determine how steep the line is
	var is_steep = abs(dy) > abs(dx)
	var tmp = 0
	# Rotate line
	if is_steep:
		tmp = x1
		x1 = y1
		y1 = tmp
		tmp = x2
		x2 = y2
		y2 = tmp
	# Swap start and end points if necessary and store swap state
	var swapped = false
	if x1 > x2:
		tmp = x1
		x1 = x2
		x2 = tmp
		tmp = y1
		y1 = y2
		y2 = tmp
		swapped = true
	# Recalculate differentials
	dx = x2 - x1
	dy = y2 - y1
	
	# Calculate error
	var error = int(dx / 2.0)
	var ystep = 1 if y1 < y2 else -1

	# Iterate over bounding box generating points between start and end
	var y = y1
	var points = []
	for x in range(x1, x2 + 1):
		var coord = [y, x] if is_steep else [x, y]
		points.append(coord)
		error -= abs(dy)
		if error < 0:
			y += ystep
			error += dx
	
	if swapped:
		points.invert()
	
	for point in points:
		if tilemap.get_cell(point[0], point[1]) >= 0:
			return false
	return true

func get_dir_to_flee_from(pos):
	var dir = null
	if !has_line_of_sight(global_position, pos):
		return dir
	
	var x_offset = pos.x - global_position.x
	var y_offset = pos.y - global_position.y
	var move_y = abs(x_offset) > abs(y_offset)
	var move_right = x_offset < 0
	var move_up = y_offset > 0
	
	if move_y:
		if move_right:
			dir = DIRECTIONS.RIGHT
		else:
			dir = DIRECTIONS.LEFT
	else:
		if move_up:
			dir = DIRECTIONS.UP
		else:
			dir = DIRECTIONS.DOWN
	
	return dir

func kill():
	pass # override
