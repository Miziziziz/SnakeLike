extends Node2D

var blood_particles = preload("res://sfx/BloodParticles.tscn")
func spawn_blood():
	var blood_inst = blood_particles.instance()
	get_tree().get_root().add_child(blood_inst)
	blood_inst.global_position = global_position
