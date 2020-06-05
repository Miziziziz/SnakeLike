extends Character

const MOVE_RATE = 2 # steps player moves before this character moves
var move_counter = 0

func incremement_move_counter():
	move_counter += 1
	move_counter %= 2
	if move_counter == 0:
		move()
	if move_counter == 1:
		choose_dir_to_move_in()

func choose_dir_to_move_in():
	var snake_head = get_tree().get_nodes_in_group("snake_head")[0]
	if !has_line_of_sight(global_position, snake_head.global_position):
		cur_direction = null
		return
	
	var x_offset = snake_head.global_position.x - global_position.x
	var y_offset = snake_head.global_position.y - global_position.y
	var move_y = abs(x_offset) > abs(y_offset)
	var move_right = x_offset < 0
	var move_up = y_offset > 0
	
	if move_y:
		if move_right:
			cur_direction = DIRECTIONS.RIGHT
		else:
			cur_direction = DIRECTIONS.LEFT
	else:
		if move_up:
			cur_direction = DIRECTIONS.UP
		else:
			cur_direction = DIRECTIONS.DOWN

func kill():
	queue_free()
