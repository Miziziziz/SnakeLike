extends Character

const MOVE_RATE = 2 # steps player moves before this character moves
var move_counter = 0

func _ready():
	group_to_ignore = "villagers"

func incremement_move_counter():
	move_counter += 1
	move_counter %= MOVE_RATE
	if move_counter == 0:
		move()
		check_to_kill()
	if move_counter == 1:
		choose_dir_to_move_in()

func choose_dir_to_move_in():
	var villagers = get_tree().get_nodes_in_group("villagers")
	var closest_villager = null
	var dist = -1
	for villager in villagers:
		var t_dist = tilemap.get_travel_dist_from_pos_to_pos(global_position, villager.global_position)
		if dist < 0  or t_dist < dist:
			closest_villager = villager
			dist = t_dist
	if closest_villager == null:
		cur_direction = null
		return
	cur_direction = tilemap.get_dir_from_pos_to_pos(global_position, closest_villager.global_position)

func check_to_kill():
	var villagers = get_tree().get_nodes_in_group("villagers")
	for villager in villagers:
		if global_position.distance_squared_to(villager.global_position) < 2:
			villager.kill()
			$DieSounds.play()
			$BloodSpawner.spawn_blood()

func kill():
	emit_signal("killed")
	queue_free()
