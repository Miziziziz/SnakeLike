extends Character

const MOVE_RATE = 2 # steps player moves before this character moves
var move_counter = 0

func incremement_move_counter():
	move_counter += 1
	move_counter %= MOVE_RATE
	if move_counter == 0:
		move()
	if move_counter == 1:
		choose_dir_to_move_in()

func choose_dir_to_move_in():
	var snake_head = get_tree().get_nodes_in_group("snake_head")[0]
	cur_direction = get_dir_to_flee_from(snake_head.global_position)

func kill():
	queue_free()
