extends Character

const MOVE_RATE = 1 # steps player moves before this character moves
var move_counter = 0

func init():
	var rot = global_rotation_degrees
	while rot < 0:
		rot += 360
	if rot < 45 or rot > 315:
		cur_direction = DIRECTIONS.UP
	elif rot >= 45 and rot < 135:
		cur_direction = DIRECTIONS.RIGHT
	elif rot >= 135 and rot < 225:
		cur_direction = DIRECTIONS.DOWN
	else: #if rot >= 225 and rot < 315:
		cur_direction = DIRECTIONS.LEFT

func incremement_move_counter():
	move_counter += 1
	move_counter %= MOVE_RATE
	if move_counter == 0:
		if !move(false):
			check_to_kill()
			kill()
		

func check_to_kill():
	var offset = get_offset_for_dir(cur_direction)
	var new_pos = global_position + offset
	for character in get_tree().get_nodes_in_group("characters"):
		if character.global_position.distance_squared_to(new_pos) < 3:
				character.kill()
				spawn_hit_fx()
				return
	if tilemap.player.head_sprite.global_position.distance_squared_to(new_pos) < 3:
		tilemap.player.kill()
		spawn_hit_fx()
	

func spawn_hit_fx():
	var die_sounds = load("res://sfx/DieSounds.tscn").instance()
	get_tree().get_root().add_child(die_sounds)
	die_sounds.global_position = global_position
	die_sounds.play()
	$BloodSpawner.spawn_blood()

func kill():
	queue_free()
