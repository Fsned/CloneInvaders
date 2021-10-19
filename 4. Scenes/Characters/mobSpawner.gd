extends Node


const skullshipScene = preload("res://4. Scenes/Characters/Skullship.tscn")

export (String) var mobSceneString

export (int, 0, 100) var spawnSingleChance = 70
export (int, 0, 100) var spawnDoubleChance = 15
export (int, 0, 100) var spawnTripleChance = 10
export (int, 0, 100) var spawnQuadChance = 5

export var levelKillGoal = 0
var mobsSpawned = 0

export var isActive = false


func _ready():
	
	if isActive && mobSceneString != "":
		mobSceneString = load(mobSceneString)
		$spawnTimer.start()
	
	
func _on_spawnTimer_timeout():
	if isActive:
		randomize()
		var spawnRoll = rand_range(1, 100)
		if levelKillGoal > 0:
			if spawnRoll <= spawnQuadChance && mobsSpawned + 4 <= levelKillGoal:
				spawnQuadlet(mobSceneString)
				mobsSpawned += 4
				
			elif spawnRoll <= spawnTripleChance && mobsSpawned + 3 <= levelKillGoal:
				spawnTriplet(mobSceneString)
				mobsSpawned += 3
			elif spawnRoll <= spawnDoubleChance && mobsSpawned + 2 <= levelKillGoal:
				spawnDoublet(mobSceneString)
				mobsSpawned += 2
			elif spawnRoll <= spawnSingleChance && mobsSpawned + 1 <= levelKillGoal:
				spawnSinglet(mobSceneString)
				mobsSpawned += 1
		
		else:
			if spawnRoll <= spawnQuadChance:
				spawnQuadlet(mobSceneString)
				mobsSpawned += 4
				
			elif spawnRoll <= spawnTripleChance:
				spawnTriplet(mobSceneString)
				mobsSpawned += 3
			elif spawnRoll <= spawnDoubleChance:
				spawnDoublet(mobSceneString)
				mobsSpawned += 2
			elif spawnRoll <= spawnSingleChance:
				spawnSinglet(mobSceneString)
				mobsSpawned += 1
			
			
	
	
func spawnSinglet(mobScene, x = $spawnPoint.position.x, y = rand_range(50, 550)):
	var yPlacementDirection = false
	
	if y + 0 <= 550:
		yPlacementDirection = true
	
	for a in range(1):
		var mob = mobScene.instance()
		mob.set_as_toplevel(true)
		mob.global_transform = $spawnPoint.global_transform
		mob.position.x = x
		mob.rotation_degrees = 180
		
		if yPlacementDirection:
			mob.position.y = y + a*50
		else:
			mob.position.y = y - a*50
		add_child(mob)
	
func spawnDoublet(mobScene, x = $spawnPoint.position.x, y = clamp(randi() % 600, 50, 550)):
	var yPlacementDirection = false
	
	if y + 50 <= 550:
		yPlacementDirection = true
	
	for a in range(2):
		var mob = mobScene.instance()
		mob.set_as_toplevel(true)
		mob.global_transform = $spawnPoint.global_transform
		mob.position.x = x
		mob.rotation_degrees = 180
		if yPlacementDirection:
			mob.position.y = y + a*50
		else:
			mob.position.y = y - a*50
		add_child(mob)
	
	
func spawnTriplet(mobScene, x = $spawnPoint.position.x, y = randi() % 600):
	var yPlacementDirection = false
	
	if y + 100 <= 550:
		yPlacementDirection = true
	
	for a in range(3):
		var mob = mobScene.instance()
		mob.set_as_toplevel(true)
		mob.global_transform = $spawnPoint.global_transform
		mob.position.x = x
		mob.rotation_degrees = 180
		if yPlacementDirection:
			mob.position.y = y + a*50
		else:
			mob.position.y = y - a*50
		add_child(mob)
	

func spawnQuadlet(mobScene, x = $spawnPoint.position.x, y = randi() % 600):
	var yPlacementDirection = false
	
	if y + 150 <= 550:
		yPlacementDirection = true
	
	for a in range(4):
		var mob = mobScene.instance()
		mob.set_as_toplevel(true)
		mob.global_transform = $spawnPoint.global_transform
		mob.position.x = x
		mob.rotation_degrees = 180
		if yPlacementDirection:
			mob.position.y = y + a*50
		else:
			mob.position.y = y - a*50
		add_child(mob)


func diffBump(_score):
	randomize()
	var randomNumber = rand_range(1, 5)
	match(randomNumber):
		1:
			spawnSingleChance += 5
		2:
			spawnDoubleChance += 3
		3:
			spawnTripleChance += 2
		4:
			spawnQuadChance += 1
		5:
			pass
			
	
	
	
	
	


func _on_Level1_difficultyBump(score):
	diffBump(score)
	
	

