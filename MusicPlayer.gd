extends AudioStreamPlayer

func play_menu_theme():
	play_track(load("res://music/breves_dies_hominis.ogg"))

func play_town_theme():
	play_track(load("res://music/the_field_of_dreams.ogg"))

func play_battle_theme():
	play_track(load("res://music/battleThemeA.ogg"))

func play_forest_theme():
	play_track(load("res://music/TownTheme.ogg"))

func play_battleb_theme():
	play_track(load("res://music/BattleLoop2.ogg"))

func play_pursuit_theme():
	play_track(load("res://music/determined_pursuit_loop.ogg"))

func play_track(new_stream):
	if stream == new_stream:
		return
	stream = new_stream
	play()
