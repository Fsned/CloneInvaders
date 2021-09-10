extends "res://4. Scenes/CharacterTemplate.gd"

var properties = PlayerProperties.new()


func _ready():
	get_tree().call_group("GUI", "updatePlayerValues", properties)
	properties.currentHealth = 29000
	

func _process(_delta):
	followMouse()
	handlePlayerInput()
	handlePlayerMovement()
	
func getKill(expAmount, meteoReward):
	properties.addExp(expAmount)
	properties.meteorites += meteoReward
	
	updateExp()
	updateMeteos()


func hurt(amount):
	properties.currentHealth -= amount
	if properties.currentHealth <= 0:
		get_tree().call_group("levelManager", "loseGame")
	if properties.currentHealth > 0:
		updateHealth()
	
func updateHealth():
	get_tree().call_group("GUI", "setHealth", properties.currentHealth)
	
func updatePower():
	get_tree().call_group("GUI", "setPower", properties.currentPower)

func updateExp():
	get_tree().call_group("GUI", "setExp", properties.currentExp, properties.expGoal)
	
func updateMeteos():
	get_tree().call_group("GUI", "setMeteorites", properties.meteorites)
	
