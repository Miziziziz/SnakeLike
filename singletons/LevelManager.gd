extends Node

var levels = [
	"res://levels/Intro.tscn",
	"res://levels/FirstOffering.tscn",
	"res://levels/SecondOffering.tscn",
	"res://levels/EnterTheVillage.tscn",
	"res://levels/Townhouse.tscn",
	"res://levels/ShootingGallery.tscn",
	"res://levels/ArrowRiver.tscn",
	"res://levels/OrcCamp.tscn",
	"res://levels/Outro.tscn"
]
var cur_level_ind = 0
var cur_player_length = 0

var total_sheep = 0
var sheep_not_eaten = 0

var total_villagers = 0
var villagers_saved = 0

func load_next_level(new_player_length: int):
	villagers_saved += get_tree().get_nodes_in_group("villagers").size()
	sheep_not_eaten += get_tree().get_nodes_in_group("sheep").size()
		
	cur_player_length = new_player_length
	cur_level_ind += 1
	cur_level_ind %= levels.size()
	get_tree().change_scene(levels[cur_level_ind])
	yield(get_tree(),"idle_frame")
	
	total_villagers += get_tree().get_nodes_in_group("villagers").size()
	total_sheep += get_tree().get_nodes_in_group("sheep").size()

