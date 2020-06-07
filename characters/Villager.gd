extends Character

const MOVE_RATE = 3 # steps player moves before this character moves
var move_counter = 0
export var hold_position = false

func _ready():
	$Graphics/Female.hide()
	$Graphics/Male.hide()
	if randi() % 2 == 0:
		$Graphics/Female.show()
	else:
		$Graphics/Male.show()

func incremement_move_counter():
	move_counter += 1
	move_counter %= MOVE_RATE
	if move_counter == 0 and !hold_position:
		move()
	if move_counter == 2:
		choose_dir_to_move_in()

func choose_dir_to_move_in():
	var orcs = get_tree().get_nodes_in_group("orcs")
	cur_direction = null
	var dist = -1
	var nearest_orc = null
	for orc in orcs:
		if has_line_of_sight(global_position, orc.global_position):
			var t_dist = global_position.distance_squared_to(orc.global_position)
			if dist < 0 or t_dist < dist:
				nearest_orc = orc
	if nearest_orc == null:
		return
	cur_direction = get_dir_to_flee_from(nearest_orc.global_position)

func kill():
	emit_signal("killed")
	queue_free()
