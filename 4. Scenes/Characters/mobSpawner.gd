extends Node


const skullshipScene = preload("res://4. Scenes/Characters/Skullship.tscn")


export (int, 0, 100) var spawnSingleChance = 70
export (int, 0, 100) var spawnDoubleChance = 15
export (int, 0, 100) var spawnTripleChance = 10
export (int, 0, 100) var spawnQuadChance = 5

export var levelKillGoal = 0
var mobsSpawned = 0

export var isActive = false


func _ready():
	get_tree().call_group("levelManager", "setLevelKillGoal", levelKillGoal)
	
	if isActive:
		$spawnTimer.start()
	
	
func _on_spawnTimer_timeout():
	if isActive:
		randomize()
		var spawnRoll = randi() % 100
		if levelKillGoal > 0:
			if spawnRoll <= spawnQuadChance && mobsSpawned + 4 <= levelKillGoal:
				spawnQuadlet(skullshipScene)
				mobsSpawned += 4
				
			elif spawnRoll <= spawnTripleChance && mobsSpawned + 3 <= levelKillGoal:
				spawnTriplet(skullshipScene)
				mobsSpawned += 3
			elif spawnRoll <= spawnDoubleChance && mobsSpawned + 2 <= levelKillGoal:
				spawnDoublet(skullshipScene)
				mobsSpawned += 2
			elif spawnRoll <= spawnSingleChance && mobsSpawned + 1 <= levelKillGoal:
				spawnSinglet(skullshipScene)
				mobsSpawned += 1
		
		else:
			if spawnRoll <= spawnQuadChance:
				spawnQuadlet(skullshipScene)
				mobsSpawned += 4
				
			elif spawnRoll <= spawnTripleChance:
				spawnTriplet(skullshipScene)
				mobsSpawned += 3
			elif spawnRoll <= spawnDoubleChance:
				spawnDoublet(skullshipScene)
				mobsSpawned += 2
			elif spawnRoll <= spawnSingleChance:
				spawnSinglet(skullshipScene)
				mobsSpawned += 1
			
			
	
	
func spawnSinglet(mobScene, x = $spawnPoint.position.x, y = randi() % 600):
	var yPlacementDirection = false
	
	if y + 0 <= 550:
		yPlacementDirection = true
	
	for a in range(1):
		var skullship = mobScene.instance()
		skullship.set_as_toplevel(true)
		skullship.global_transform = $spawnPoint.global_transform
		skullship.position.x = x
		skullship.rotation_degrees = 180
		
		if yPlacementDirection:
			skullship.position.y = y + a*50
		else:
			skullship.position.y = y - a*50
		add_child(skullship)
	
func spawnDoublet(mobScene, x = $spawnPoint.position.x, y = clamp(randi() % 600, 50, 550)):
	var yPlacementDirection = false
	
	if y + 50 <= 550:
		yPlacementDirection = true
	
	for a in range(2):
		var skullship = mobScene.instance()
		skullship.set_as_toplevel(true)
		skullship.global_transform = $spawnPoint.global_transform
		skullship.position.x = x
		skullship.rotation_degrees = 180
		if yPlacementDirection:
			skullship.position.y = y + a*50
		else:
			skullship.position.y = y - a*50
		add_child(skullship)
	
	
func spawnTriplet(mobScene, x = $spawnPoint.position.x, y = randi() % 600):
	var yPlacementDirection = false
	
	if y + 100 <= 550:
		yPlacementDirection = true
	
	for a in range(3):
		var skullship = mobScene.instance()
		skullship.set_as_toplevel(true)
		skullship.global_transform = $spawnPoint.global_transform
		skullship.position.x = x
		skullship.rotation_degrees = 180
		if yPlacementDirection:
			skullship.position.y = y + a*50
		else:
			skullship.position.y = y - a*50
		add_child(skullship)
	

func spawnQuadlet(mobScene, x = $spawnPoint.position.x, y = randi() % 600):
	var yPlacementDirection = false
	
	if y + 150 <= 550:
		yPlacementDirection = true
	
	for a in range(4):
		var skullship = mobScene.instance()
		skullship.set_as_toplevel(true)
		skullship.global_transform = $spawnPoint.global_transform
		skullship.position.x = x
		skullship.rotation_degrees = 180
		if yPlacementDirection:
			skullship.position.y = y + a*50
		else:
			skullship.position.y = y - a*50
		add_child(skullship)


