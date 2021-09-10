extends Node

export var spawn = true
export var asteroidSpawnChance = 80
export var objectPath = ""

const asteroidSpeed = 350


func _ready():
	pass
	
	
	
func _process(_delta):
	
	if spawn and objectPath != "":
		asteroidSpawner()
		
			
	
	
func asteroidSpawner():
	if $spawnTimer.is_stopped():
		randomize()
		var randomNumber = randi() % 100
		
		if (randomNumber <= asteroidSpawnChance):
			spawnAsteroid()
			asteroidSpawnChance = 10
		else:
			asteroidSpawnChance += 0.2*asteroidSpawnChance
			
		$spawnTimer.start()
			
			
			
func spawnAsteroid():
	var obstacleEntity = load(objectPath).instance()
	add_child(obstacleEntity)
	obstacleEntity.set_as_toplevel(true)
	obstacleEntity.global_transform = $spawnPoint.global_transform
	obstacleEntity.position.x = randi() % 1012
	obstacleEntity.linear_velocity = Vector2(0, 1) * ((randi() % 110 + 90)/100.0 * asteroidSpeed)