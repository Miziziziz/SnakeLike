extends Node

var levels = [
	"res://levels/FirstOffering.tscn",
	"res://levels/SecondOffering.tscn",
]
var cur_level_ind = 0
var cur_player_length = 0

func load_next_level(new_player_length: int):
	cur_player_length = new_player_length
	cur_level_ind += 1
	cur_level_ind %= levels.size()
	get_tree().change_scene(levels[cur_level_ind])
