extends "res://4. Scenes/Characters/CharacterTemplate.gd"


var currentHullLevel = 0
var currentShotLevel = 0
var currentWeaponLevel = 0

#var wep = Weapons.new()
#var myWeapon = Weapons.new()
#var properties = PlayerProperties.new()

func _ready():
	get_tree().call_group("GUI", "updatePlayerValues", properties)
	

func _process(delta):
	followMouse()
	handlePlayerInput()
	handlePlayerMovement(delta)
	
	
func _input(_event):
		
	if Input.is_action_just_pressed("UpgradeShot") && getCoins() >= 5:
		get_tree().call_group("actionBar", "startUpgrade", 0)
		
	if Input.is_action_just_pressed("UpgradeHull") && getCoins() >= 10:
		get_tree().call_group("actionBar", "startUpgrade", 1)
		
	if Input.is_action_just_pressed("UpgradeWeapon") && getCoins() >= 15:
		get_tree().call_group("actionBar", "startUpgrade", 2)
		
#	if Input.is_action_just_pressed("Shoot"):
#		myWeapon.fire("e3e01a")
	
		
		
func upgradeHull():	
	deductCoins(10)
	currentHullLevel = clamp(currentHullLevel + 1, 0, 8)
	
	properties.setMaxHealth(properties.getMaxHealth() + 20)
	properties.heal(20)
	
	if currentHullLevel % 2 == 0:
		upgradeSprite(currentHullLevel)
		print ("Upgrading sprite!")
	
	
func upgradeShot():
	deductCoins(5)
	setWeaponCooldown(getWeaponCooldown() * 0.95)
	
	
func upgradeWeapon():
	deductCoins(15)
	currentWeaponLevel = clamp(currentWeaponLevel + 1, 0, 3)
	match (currentWeaponLevel):
		0:
			switchWeapon(weapon.basic)
		1:
			switchWeapon(weapon.double)
		2:
			switchWeapon(weapon.triple)
		3:
			switchWeapon(weapon.cone)
	
	
func upgradeSprite(hullLevel):
	
	match(hullLevel):
		
		2:
			$Sprite.texture = load("res://1. GFX/Kenney/PNG/Retina/ship_I.png")
			$Sprite.scale = Vector2(0.5, 0.5)
		4:
			$Sprite.texture = load("res://1. GFX/Kenney/PNG/Retina/ship_G.png")
			$Sprite.scale = Vector2(0.5, 0.5)
		6:
			$Sprite.texture = load("res://1. GFX/Kenney/PNG/Retina/ship_L.png")
			$Sprite.scale = Vector2(0.5, 0.5)
		_:
			pass
	
	
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





func _on_ActionBar_hullUpgradeDone():
	upgradeHull()

func _on_ActionBar_shotSpeedUpgradeDone():
	upgradeShot()
	
func _on_ActionBar_weaponUpgradeDone():
	upgradeWeapon()
