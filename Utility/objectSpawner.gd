extends Node

export var spawn = true
export (String, MULTILINE) var objectPath

export (int, 0.1, 100.0) var spawnTimerWaitTime = 3.0
export (int, 0, 100) var spawnChance = 100

export (Vector2) var spawnPosition = Vector2.ZERO
export var xSpread = 0
export var ySpread = 0

export var linearDirection = Vector2(0,0)
export var linearSpeed = 20
export var linearRotation = 0

export var angularSpeed = 0

var originalSpawnChance = spawnChance

var object

export (int, 0.0, 100.0) var badLuckProtection = 0.00

func _ready():
	if spawn:
		$spawnTimer.wait_time = spawnTimerWaitTime 
		$spawnTimer.start()

func _on_spawnTimer_timeout():
	randomize()
	
	var randomNumber = randi() % 100 + 1
	
	if (randomNumber <= spawnChance):
		spawnThing()
		spawnChance = originalSpawnChance
	
	else:
		spawnChance += badLuckProtection
	
	
	
func spawnThing():
	var spawnObject = load(objectPath).instance()
	var randomSpreadX = 0
	var randomSpreadY = 0
	
	if xSpread > 0:	randomSpreadX = (randi() % (xSpread*2)) - xSpread
	if ySpread > 0: randomSpreadY = (randi() % (ySpread*2)) - ySpread
	 
	spawnObject.position.x = spawnPosition.x + randomSpreadX
	spawnObject.position.y = spawnPosition.y + randomSpreadY
	
	spawnObject.linear_velocity = linearDirection * linearSpeed
	
	spawnObject.linear_velocity = spawnObject.linear_velocity.rotated((linearRotation/180) * PI)
	spawnObject.angular_velocity = angularSpeed
	
	add_child(spawnObject)
