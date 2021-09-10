extends CanvasLayer

var actionbarItems = []
var actionbarItemCount = 0

var currentItemInFocus = 0


func _ready():
	processActionBar()
	
	
	
func processActionBar():
	for a in actionbarItems:
		pass



func addItemToActionBar(_itemName):
	pass

func setHealth(value):
	$Container/LeftSideContainer/HealthBar.setValue(value)
#
func setPower(value):
	$Container/LeftSideContainer/PowerBar.setValue(value)

func setMeteorites(value):
	$Container/RightSideContainer/HBoxContainer/MeteoriteCounter.text = str(value)

func setExp(_currValue, _maxValue):
	pass
	
func updatePlayerValues(a: PlayerProperties):
	setHealth(a.currentHealth)
	setPower(a.currentPower)
	
func setLevel(value):
	$Container/RightSideContainer/HBoxContainer2/LevelLabel.text = "Level " + str(value)
	