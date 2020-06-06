extends Label

signal ate_all_in_group

export var group_to_track = "sheep"
var num_eaten = 0
var num_in_group = 0

func _ready():
	var group_nodes = get_tree().get_nodes_in_group(group_to_track)
	num_in_group = group_nodes.size()
	for group_member in group_nodes:
		group_member.connect("killed", self, "inc_count")
	update_display()

func inc_count():
	num_eaten += 1
	update_display()
	if num_eaten == num_in_group:
		emit_signal("ate_all_in_group")

func update_display():
	text = group_to_track + ": " + str(num_eaten) + "/" + str(num_in_group)
