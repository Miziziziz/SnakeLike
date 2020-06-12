extends Control


func _ready():
	var txt = "-Stats-\n"
	txt += "Sheep eaten: " + str(LevelManager.total_sheep - LevelManager.sheep_not_eaten)
	txt += "/" + str(LevelManager.total_sheep) + "\n"
	txt += "Villagers saved: " + str(LevelManager.villagers_saved)
	txt += "/" + str(LevelManager.total_villagers) + "\n"
	var grade_letter = calc_grade()
	txt += "Grade: " + grade_letter + "\n"
	
	if grade_letter == "A":
		txt += "Perfect Score!"
	elif grade_letter == "B":
		txt += "Could be better; play again?"
	elif grade_letter == "C":
		txt += "Kinda bad; maybe try again?"
	elif grade_letter == "D":
		txt += "Pretty bad tbh, maybe with practice you can get a C"
	else:
		txt += "Wow you suck lol."
	
	$Stats.text = txt
	
	
	LevelManager.total_sheep = 0
	LevelManager.sheep_not_eaten = 0
	LevelManager.villagers_saved = 0
	LevelManager.total_villagers = 0

func calc_grade():
	if LevelManager.sheep_not_eaten == 0 and LevelManager.villagers_saved == LevelManager.total_villagers:
		return "A"
	if LevelManager.total_villagers == 0 or LevelManager.total_sheep == 0:
		return "Error"
	var grade_val = float(LevelManager.villagers_saved) / LevelManager.total_villagers
	grade_val += float(LevelManager.total_sheep - LevelManager.sheep_not_eaten) / LevelManager.total_sheep
	grade_val /= 2.0
	if grade_val < 0.6:
		return "F"
	if grade_val < 0.7:
		return "D"
	if grade_val < 0.8:
		return "C"
	return "B"


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("continue"):
		LevelManager.load_next_level(0)
