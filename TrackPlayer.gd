extends Node

enum TRACKS {MENU, FOREST, TOWN, BATTLE, BATTLEB, PURSUIT}
export(TRACKS) var cur_track

func _ready():
	match cur_track:
		TRACKS.MENU:
			MusicPlayer.play_menu_theme()
		TRACKS.FOREST:
			MusicPlayer.play_forest_theme()
		TRACKS.TOWN:
			MusicPlayer.play_town_theme()
		TRACKS.BATTLE:
			MusicPlayer.play_battle_theme()
		TRACKS.BATTLEB:
			MusicPlayer.play_battleb_theme()
		TRACKS.PURSUIT:
			MusicPlayer.play_pursuit_theme()
