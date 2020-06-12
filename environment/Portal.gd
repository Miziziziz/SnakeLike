extends Node2D

func _ready():
	hide()
	$ActivateSound.play()

func activate():
	show()
	get_parent().clear_tile(global_position)
	$ActivateSound.play()
	$Particles2D.emitting = true
