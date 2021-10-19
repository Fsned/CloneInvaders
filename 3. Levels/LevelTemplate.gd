extends Node2D

export var level = "0"

var score = 0
var currentHighscore = 0
var newHighscore = false

var saveDict = {}

signal difficultyBump

func _ready():
	currentHighscore = GameData.getKey("score")
	newHighscore = false


func unitDied(unitType):
	match unitType:
		1:	# Enemy died
			get_tree().call_group("GUI", "setScore", score)
			increaseScore(1)
			if score > currentHighscore && newHighscore == false:
				get_tree().call_group("GUI", "newHighscore")
				newHighscore = true

		2:	# Boss died
#			get_tree().call_group("GUI", "setRemainingEnemies", enemyCount)
			pass
		3:	# Pickup disappeared
			pass
			

func _on_loseTimer_timeout():
	get_tree().paused = true
	get_tree().call_group("loseMenu", "setScore", score)
	
	if score > GameData.getKey("score"):
		GameData.setKey("score", score)

	$loseMenu.show()

func _on_Player_died(_unitType):
	print ("died")
	$Timers/loseTimer.start()


func _on_scoreTimer_timeout():
	increaseScore(1)
	get_tree().call_group("GUI", "setScore", score)
	
func getScore():
	return score
	
	
func getSaveData():
	var data = {}
	data["score"] = score
	return data


func increaseScore(value):
	score += value
	
	if score > currentHighscore && newHighscore == false:
		get_tree().call_group("GUI", "newHighscore")
		newHighscore = true
		
	if score % 10 == 0 && score > 0:
		emit_signal("difficultyBump", score)
