extends Character

const FIRE_RATE = 5 # steps player moves before this character moves
var move_counter = 0

var arrow_obj = preload("res://characters/Arrow.tscn")

var dead = false

func _ready():
	$Orc.global_rotation = 0
	$Orc.connect("killed", self, "kill")

func incremement_move_counter():
	if dead:
		return
	move_counter += 1
	move_counter %= FIRE_RATE
	if move_counter == 0:
		fire()

func fire():
	var arrow_inst = arrow_obj.instance()
	tilemap.add_child(arrow_inst)
	arrow_inst.global_position = $Firepoint.global_position
	arrow_inst.global_rotation = global_rotation
	arrow_inst.init()
	$ShootArrowSound.play()

func kill():
	emit_signal("killed")
	$Orc.queue_free()
	dead = true
