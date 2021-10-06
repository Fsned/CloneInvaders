extends "res://4. Scenes/CharacterTemplate.gd"


func _ready():
	get_tree().call_group("GUI", "updatePlayerValues", properties)
	

func _process(_delta):
	followMouse()
	handlePlayerInput()
	handlePlayerMovement()
	
	
func _input(_event):
	if Input.is_action_pressed("scrollUp"):
		currentWeapon = clamp(currentWeapon + 1, weapon.basic, weapon.cone)
		switchWeapon(currentWeapon)		
	if Input.is_action_pressed("scrollDown"):
		currentWeapon = clamp(currentWeapon - 1, weapon.basic, weapon.cone)
		switchWeapon(currentWeapon)
	
func getKill(expAmount, meteoReward):
	properties.addExp(expAmount)
	properties.meteorites += meteoReward
	
	updateExp()
	updateMeteos()

	
func updateHealth():
	get_tree().call_group("GUI", "setHealth", properties.currentHealth)
	
func updatePower():
	get_tree().call_group("GUI", "setPower", properties.currentPower)

func updateExp():
	get_tree().call_group("GUI", "setExp", properties.currentExp, properties.expGoal)
	
func updateMeteos():
	get_tree().call_group("GUI", "setMeteorites", properties.meteorites)
	


func _on_VisibilityNotifier2D_screen_entered():
	invincible = false
