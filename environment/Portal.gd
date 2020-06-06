extends Node2D

func _ready():
	hide()

func activate():
	show()
	get_parent().clear_tile(global_position)
