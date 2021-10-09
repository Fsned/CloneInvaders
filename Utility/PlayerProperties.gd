extends Node2D

class_name PlayerProperties, "res://1. GFX/Spaceships/Player.png"

### Actionbar stuff
var actionBarItems = ["Single Laser"]

### Currency stuff
var meteorites = 0

### Stats
var maxHealth = 100
var maxPower = 100

var currentHealth = maxHealth
var currentPower = maxPower



### Exp vars
var playerLevel = 1
const initialExpGoal = 100
var currentExp = 0
var expGoal = initialExpGoal
var expLevelUpMultiplier = 1.2



func _ready():
	pass
	
func _process(_delta):
	pass




func addExp(expAmount):
	currentExp += expAmount
	
	if currentExp >= (expGoal + ((playerLevel-1)*expLevelUpMultiplier)):
		levelUp()
	
func levelUp():
	currentExp -= expGoal
	playerLevel += 1
	expGoal = ((playerLevel - 1) * expLevelUpMultiplier * initialExpGoal)
	print ("You just levelled up to level " + str(playerLevel) + "!")
	
func heal(amount):
	currentHealth += amount
	if currentHealth > maxHealth:
		currentHealth = maxHealth



func setMaxHealth(amount):
	maxHealth = amount
	if currentHealth > maxHealth:
		currentHealth = maxHealth
