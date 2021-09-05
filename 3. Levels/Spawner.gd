extends Node



export(int) var skullShip = 0
export(int) var JohnnyShip = 0
export(int) var Blaster = 0
export(int) var Roamer = 0
export(int) var waves = 1


var enemyArray = [skullShip, JohnnyShip, Blaster, Roamer]
var enemiesPerWave = []
var enemyCount = skullShip + JohnnyShip + Blaster + Roamer

export(int, "Line", "Circle", "Square") var spawnPattern

func _ready():
	if (enemyCount > 0):		
		calcSpawnParams()
		match (spawnPattern):
			0:  # Spawn Line formation
				lineSpawn()
			1:	# Spawn Circle Formation
				circleSpawn()
			2:	# Spawn Square formation
				squareSpawn()
		
		
		
func calcSpawnParams():
	for a in range (enemyArray.size()):
		enemiesPerWave[a] = ceil(enemyArray[a] / waves)
	
	
		
	
	
func lineSpawn():
	for a in enemiesPerWave:
		while(a > 0):
			a -= 1
			
	
func circleSpawn():
	pass
	
func squareSpawn():
	pass
