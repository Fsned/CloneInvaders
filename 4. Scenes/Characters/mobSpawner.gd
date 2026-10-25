extends Node


@export var mobSceneString: String
var mobScene: PackedScene

@export_range(0, 100) var spawnSingleChance = 70
@export_range(0, 100) var spawnDoubleChance = 15
@export_range(0, 100) var spawnTripleChance = 10
@export_range(0, 100) var spawnQuadChance = 5

# Mobs spawn at a random height in this range, just off the right edge of the screen
@export var spawnMinY = 80
@export var spawnMaxY = 1000
@export var groupSpacing = 50

@export var levelKillGoal = 0
var mobsSpawned = 0

@export var isActive = false


func _ready():

	if isActive && mobSceneString != "":
		mobScene = load(mobSceneString)
		$spawnTimer.start()


func _on_spawnTimer_timeout():
	if not isActive or mobScene == null:
		return

	var spawnRoll = randi_range(1, 100)
	var groupSize = 0

	if spawnRoll <= spawnQuadChance: groupSize = 4
	elif spawnRoll <= spawnTripleChance: groupSize = 3
	elif spawnRoll <= spawnDoubleChance: groupSize = 2
	elif spawnRoll <= spawnSingleChance: groupSize = 1

	if levelKillGoal > 0:
		groupSize = min(groupSize, levelKillGoal - mobsSpawned)

	if groupSize > 0:
		spawnGroup(groupSize)
		mobsSpawned += groupSize


# Spawns a vertical line of mobs. Lines grow down from the top half of the
# screen and up from the bottom half, so they stay inside the spawn area.
func spawnGroup(count, x = $spawnPoint.position.x, y = randf_range(spawnMinY, spawnMaxY)):
	var direction = 1 if y <= (spawnMinY + spawnMaxY) / 2.0 else -1

	for a in range(count):
		var mob = mobScene.instantiate()
		mob.set_as_top_level(true)
		mob.global_transform = $spawnPoint.global_transform
		mob.position.x = x
		mob.position.y = y + a * groupSpacing * direction
		mob.rotation_degrees = 180
		add_child(mob)


func diffBump(_score):
	# randi_range gives whole numbers - the old rand_range gave floats, so this never matched
	match randi_range(1, 5):
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
