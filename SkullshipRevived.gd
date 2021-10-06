extends "res://4. Scenes/CharacterTemplate.gd"

export var minimumDistanceToDestination = 5
var possibleDestinations = []
export var expReward = 50
export var meteoReward = 5
export var charge = true
var charging = false
const speed = 100

onready var navigation = get_tree().get_root().find_node("Navigation2D", true, false)
onready var availableDestinations
var path
#var motion

func _ready():
#	health = 10
	
	makePath()
	

func _process(_delta):
	handleEnemyInput()
#	if (charge): handleCharge()
	navigate()
		
		
		
		
func navigate():
	var distanceToDestination = position.distance_to(possibleDestinations[0].position)
	
	if distanceToDestination > minimumDistanceToDestination:
		move()
	else:
		possibleDestinations.remove(0)
	
func move():
	motion = (possibleDestinations[0].position - position).normalized() * SPEED
#	move_and_collide(motion)
	move_and_slide(motion, Vector2(0, 1))
	
	
func updatePath():
	if path.size() == 1:
		if $Timer.is_stopped():
			$Timer.start()
	else:
		path.remove(0)
	
	
	
func makePath():
	possibleDestinations = get_node("Destinations").get_children()

