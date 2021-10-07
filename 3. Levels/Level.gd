extends Node2D

var enemyCount = 0
export var level = "0"
var enemiesAdded = false

var meteosCollected = 0
var score = 0

var saveDict = {}

func _ready():
	get_tree().call_group("GUI", "setLevel", level)		



func win():
	print ("Winning!")
	$Timers/winTimer.start()


func add_entity(type):
	if type == "enemy":
		if !enemiesAdded:
			enemiesAdded = true
		enemyCount += 1
		print ("Enemycount: " + str(enemyCount))
		
func unitDied(unitType):
	match unitType:
		1:	# Enemy died
			enemyCount -= 1
			meteosCollected += 5
			get_tree().call_group("GUI", "setMeteorites", meteosCollected)
			get_tree().call_group("GUI", "setScore", score)
			score += 1
			
			if enemyCount == 0:
				win()
		2:	# Boss died
			get_tree().call_group("GUI", "setRemainingEnemies", enemyCount)
			pass
		3:	# Pickup disappeared
			pass
	
	
func setLevelKillGoal(killsToGoal):
	if killsToGoal == 0:
		enemyCount = -1
		get_tree().call_group("GUI", "setRemainingEnemies", enemyCount)
	else:
		enemyCount = killsToGoal
		

func _on_winTimer_timeout():
	Dialog.openDialogBox("Nice! you won this level...")
	get_tree().paused = true


func _on_loseTimer_timeout():
	get_tree().paused = true
	get_tree().call_group("loseMenu", "setScore", score)
	
	if score > GameData.getKey("score"):
		print ("Overwriting highscore!")
		GameData.setKey("score", score)
		
	else:
		print ("score not good enough :P")
		
	$loseMenu.show()

func _on_Player_died(_unitType):
	print ("died")
	$Timers/loseTimer.start()


func _on_scoreTimer_timeout():
	score += 1
	get_tree().call_group("GUI", "setScore", score)
	
func getScore():
	return score
	

	
func getSaveData():
	var data = {}
	data["score"] = score
	return data
