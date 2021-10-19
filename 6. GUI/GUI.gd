extends CanvasLayer

var actionbarItems = []
var actionbarItemCount = 0

var currentItemInFocus = 0

export var level = ""

func _ready():
	processActionBar()
	$Container/CenterContainer/scoreLabel.self_modulate = "ffffff"
	
	
func processActionBar():
	for a in actionbarItems:
		pass



func addItemToActionBar(_itemName):
	pass

func setHealth(value):
	$Container/LeftSideContainer/HealthBar.setValue(value)

func setPower(value):
	$Container/LeftSideContainer/PowerBar.setValue(value)

func setMeteorites(value):
	$Container/RightSideContainer/HBoxContainer/MeteoriteCounter.text = str(value)

func setExp(_currValue, _maxValue):
	pass
	
func updatePlayerValues(a: PlayerProperties):
	setHealth(a.currentHealth)
	setPower(a.currentPower)
	
func setScore(value):
	$Container/CenterContainer/scoreLabel.text = "Score: " + str(value)


func _on_Player_healthChanged(value):
	setHealth(value)


func toggleEnemiesRemaining():
	$Container/CenterContainer/enemiesLeftLabel.visible = !$Container/CenterContainer/enemiesLeftLabel.visible


func newHighscore():
	$Container/CenterContainer/scoreLabel.self_modulate = "1d9f25"


func _on_Player_coinsChanged(value):
	$Container/RightSideContainer/HBoxContainer/MeteoriteCounter.text = str(value)
