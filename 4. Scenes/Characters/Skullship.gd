extends "res://4. Scenes/Characters/CharacterTemplate.gd"

var minimumDistanceToDestination = 20
var expReward = 50
var meteoReward = 5

# -- Misc 
export var frozen = false

# -- Abilities --
export var charge = false
export var shooting = true

# -- Movement --
export var followPath = false
export var moveForward = true
export var moveForwardSpeed = 10000
export var lookAtPlayer = true

# -- Charging --
var charging = false
var reachedGoal = false
var initialPosition
var goalPosition


# -- Navigation
var navigationPaused = false
var possibleDestinations = []


onready var navigation = get_tree().get_root().find_node("Navigation2D", true, false)
onready var availableDestinations
var path



func _ready():
	makePath()
	properties.setMaxHealth(50)
	
	
	
func _physics_process(delta):
	if !frozen:
		if (moveForward): handleMoveForward(delta)
		if (lookAtPlayer): look_at(Global.getPlayerPosition())
		if (followPath): navigate(delta)
		if (shooting): handleEnemyInput()
		if (charge): handleCharge(delta)



func handleMoveForward(delta):
	motion = ((global_position + Vector2(-1, 0)) - global_position).normalized() * moveForwardSpeed * delta
	var _a = move_and_slide(motion, Vector2(0, -1))		

func navigate(delta):
	if (navigationPaused): return
	
	var distanceToDestination = position.distance_to(possibleDestinations[0].position)
	
	if distanceToDestination > minimumDistanceToDestination:
		move(delta)
	else:
		if possibleDestinations.size() == 1:
			makePath()
		else:
			possibleDestinations.remove(0)
	
	
func move(delta):
	motion = (possibleDestinations[0].position - position).normalized() * moveForwardSpeed * delta
	var _a = move_and_slide(motion, Vector2(0, -1))
	
	
func updatePath():
	if path.size() == 1:
		if $Timer.is_stopped():
			$Timer.start()
	else:
		path.remove(0)
	
func makePath():
	possibleDestinations = get_node("Destinations").get_children()

func toggleNavigation():
	navigationPaused = !navigationPaused

func toggleShooting():
	shooting = !shooting
	
func handleCharge(delta):
	
	if $ChargeRaycast.is_colliding() && !charging && $chargeCooldown.is_stopped():
		print ("Starting a charge!")
		startCharge()
		
	if charging:
		if !reachedGoal:
			motion = (goalPosition - global_position).normalized() * moveForwardSpeed * 5 * delta
		else:
			motion = (initialPosition - global_position).normalized() * moveForwardSpeed * 0.5 * delta
			
		var _a = move_and_slide(motion, Vector2(0, -1))
		
		if !reachedGoal:
			if global_position.distance_to(goalPosition) < minimumDistanceToDestination:
				reachedGoal = true
		else:
			if global_position.distance_to(initialPosition) < minimumDistanceToDestination:
				print ("Reached goal! stopping charge...")
				charging = false
				reachedGoal = false	
				if followPath: toggleNavigation()
				if shooting: toggleShooting()
				$chargeCooldown.start()
	

func startCharge():
	charging = true
	initialPosition = global_position
	goalPosition = $chargePosition.global_position
	if followPath: toggleNavigation()
	if shooting: toggleShooting()
	
func disappear():
	get_tree().call_group("levelManager", "mobDied", "skeleton")
	queue_free()
	



func _on_VisibilityNotifier2D_screen_entered():
	invincible = false


func _on_VisibilityNotifier2D_screen_exited():
	disappear()
