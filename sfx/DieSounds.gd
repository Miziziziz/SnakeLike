extends Node2D


func play():
	get_children()[randi() % get_child_count()].play()
