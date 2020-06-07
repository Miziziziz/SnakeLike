extends Node2D

enum DIRECTIONS {UP, RIGHT, DOWN, LEFT}
var cur_direction = DIRECTIONS.UP
var last_direction = DIRECTIONS.UP

onready var head_sprite = $HeadSprite
onready var sprites = $Sprites.get_children()
var last_positions = []

var move_speed = 0.5
var sprint_speed = 0.2

var dead = false

onready var move_timer = $MoveTimer
onready var tilemap : TileMap = get_parent()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	move_timer.connect("timeout", self, "move")
	var offset = Vector2.DOWN * 8
	for sprite in sprites:
		sprite.global_position = offset + head_sprite.global_position
		round_position(sprite)
		last_positions.append(sprite.global_position)
		offset += Vector2.DOWN * 8
	update_rotations()
	
	var num_of_segments = LevelManager.cur_player_length
	if num_of_segments > 3:
		for i in range(num_of_segments - 3):
			add_segment()

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if dead:
		return
	
	if Input.is_action_pressed("sprint"):
		move_timer.wait_time = sprint_speed
	else:
		move_timer.wait_time = move_speed
	
#	if Input.is_action_just_pressed("ui_accept"):
#		add_segment()
	
	var pressed_move = false
	if Input.is_action_just_pressed("move_up") and last_direction != DIRECTIONS.DOWN:
		cur_direction = DIRECTIONS.UP
		pressed_move = true
	if Input.is_action_just_pressed("move_down") and last_direction != DIRECTIONS.UP:
		cur_direction = DIRECTIONS.DOWN
		pressed_move = true
	if Input.is_action_just_pressed("move_right") and last_direction != DIRECTIONS.LEFT:
		cur_direction = DIRECTIONS.RIGHT
		pressed_move = true
	if Input.is_action_just_pressed("move_left") and last_direction != DIRECTIONS.RIGHT:
		cur_direction = DIRECTIONS.LEFT
		pressed_move = true
	
	if pressed_move:
#		if move_timer.wait_time - move_timer.time_left < 0.05:
#			return # give a little buffer so you dont move twice on accident
		move_timer.start()
		move()

func move():
	var new_pos = head_sprite.global_position + get_offset_for_dir(cur_direction)
	if !tilemap.can_move_to_pos(new_pos, false):
		kill()
		return
	
	var ind = 0
	for pos in last_positions:
		if ind == last_positions.size()-1:
			break
		if new_pos.distance_to(pos) < 1:
			kill()
			return
		ind += 1
	
	last_positions.push_front(head_sprite.global_position)
	head_sprite.global_position = new_pos
	round_position(head_sprite)
	
	last_positions.pop_back()
	for i in range(sprites.size()):
		var cur_sprite = sprites[i]
		cur_sprite.global_position = last_positions[i]
		round_position(cur_sprite)
	update_rotations()
	
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character.global_position.distance_squared_to(head_sprite.global_position) < 3:
			if character.has_method("kill"):
				character.kill()
			else:
				character.queue_free()
			add_segment()
		elif character.has_method("incremement_move_counter"):
			character.incremement_move_counter()
	
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	for projectile in projectiles:
		if projectile.global_position.distance_squared_to(new_pos) < 3:
			if (projectile.cur_direction + 2) % 4 == cur_direction:
				kill()
				projectile.kill()
		if projectile.has_method("incremement_move_counter"):
			projectile.incremement_move_counter()
	last_direction = cur_direction
	
	if tilemap.reached_portal():
		LevelManager.load_next_level(sprites.size())

const ANGLE_SPRITE_POS = Vector2(16, 56)
const STRAIGHT_SPRITE_POS = Vector2(8, 56)

func update_rotations():
	update_head_sprite_rotation()
	var last_pos = head_sprite.global_position
	for i in range(sprites.size()-1):
		var cur_sprite = sprites[i]
		var next_pos = sprites[i+1].global_position
		var cur_pos = cur_sprite.global_position
		var dir_to_next = get_direction_to(cur_pos, next_pos)
		var dir_to_last = get_direction_to(cur_pos, last_pos)
		
		cur_sprite.rotation = 0
		cur_sprite.flip_h = false
		cur_sprite.flip_v = false
		
		
		if (dir_to_last in [DIRECTIONS.RIGHT, DIRECTIONS.LEFT] and 
			dir_to_next in [DIRECTIONS.RIGHT, DIRECTIONS.LEFT]):
			cur_sprite.region_rect.position = STRAIGHT_SPRITE_POS
			
		elif (dir_to_last in [DIRECTIONS.DOWN, DIRECTIONS.UP] and 
			dir_to_next in [DIRECTIONS.DOWN, DIRECTIONS.UP]):
			cur_sprite.region_rect.position = STRAIGHT_SPRITE_POS
			cur_sprite.rotation = PI / 2
		else:
			cur_sprite.region_rect.position = ANGLE_SPRITE_POS
			if ((dir_to_last == DIRECTIONS.DOWN and dir_to_next == DIRECTIONS.RIGHT) or
				(dir_to_last == DIRECTIONS.RIGHT and dir_to_next == DIRECTIONS.DOWN)):
				cur_sprite.flip_h = true
			elif ((dir_to_last == DIRECTIONS.UP and dir_to_next == DIRECTIONS.RIGHT) or
				(dir_to_last == DIRECTIONS.RIGHT and dir_to_next == DIRECTIONS.UP)):
				cur_sprite.flip_h = true
				cur_sprite.flip_v = true
			elif ((dir_to_last == DIRECTIONS.UP and dir_to_next == DIRECTIONS.LEFT) or
				(dir_to_last == DIRECTIONS.LEFT and dir_to_next == DIRECTIONS.UP)):
				cur_sprite.flip_v = true
		
		last_pos = cur_sprite.global_position
	var last_sprite = sprites[-1]
	var last_dir = get_direction_to(last_sprite.global_position, last_pos)
	if last_dir == DIRECTIONS.DOWN:
		last_sprite.rotation = PI/2
	elif last_dir == DIRECTIONS.UP:
		last_sprite.rotation = -PI/2
	elif last_dir == DIRECTIONS.LEFT:
		last_sprite.rotation = PI
	else:
		last_sprite.rotation = 0

func get_direction_to(from_pos, to_pos):
	if to_pos.y > from_pos.y + 4: #add 4 to account for floating point errors
		return DIRECTIONS.DOWN
	elif to_pos.y < from_pos.y - 4:
		return DIRECTIONS.UP
	elif to_pos.x > from_pos.x + 4:
		return DIRECTIONS.RIGHT
	#elif to_pos.x > from_pos.x - 4:
	else:
		return DIRECTIONS.LEFT

func get_offset_for_dir(direction):
	var offset = Vector2()
	match direction:
		DIRECTIONS.UP:
			offset = Vector2.UP
		DIRECTIONS.DOWN:
			offset = Vector2.DOWN
		DIRECTIONS.RIGHT:
			offset = Vector2.RIGHT
		DIRECTIONS.LEFT:
			offset = Vector2.LEFT
	offset *= 8
	return offset

func round_position(sprite: Sprite):
	sprite.global_position.x = int(round(sprite.global_position.x))
	sprite.global_position.y = int(round(sprite.global_position.y))

func update_head_sprite_rotation():
	match cur_direction:
		DIRECTIONS.UP:
			head_sprite.rotation = -PI/2
		DIRECTIONS.DOWN:
			head_sprite.rotation = PI/2
		DIRECTIONS.RIGHT:
			head_sprite.rotation = 0
		DIRECTIONS.LEFT:
			head_sprite.rotation = PI

func add_segment():
	var new_segment = sprites[-1].duplicate()
	$Sprites.add_child(new_segment)
	sprites = $Sprites.get_children()
	last_positions.append(last_positions[-1])

func kill():
	$AnimationPlayer.play("die")
	dead = true
	move_timer.stop()
	$CanvasLayer/RestartMessage.show()

func get_positions_taken():
	return last_positions + [head_sprite.global_position]
