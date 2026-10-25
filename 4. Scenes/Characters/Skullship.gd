extends "res://4. Scenes/Characters/CharacterTemplate.gd"

var minimumDistanceToDestination = 20
var expReward = 50
var meteoReward = 5

# -- Misc 
@export var frozen = false

# -- Abilities --
@export var charge = false
@export var shooting = true

# -- Movement --
@export var followPath = false
@export var moveForward = true
@export var moveForwardSpeed = 10000
@export var lookAtPlayer = true

# -- Charging --
var charging = false
var reachedGoal = false
var initialPosition
var goalPosition


# -- Navigation
var navigationPaused = false
var possibleDestinations = []

var parentNode


@onready var navigation = get_tree().get_root().find_child("Navigation2D", true, false)
@onready var availableDestinations
var path
var scrapInstance


func _ready():
	super()
	parentNode = get_tree().get_root().find_child("Scraps", true, false)
	var scraps = FileGrabber.fileGrab("res://4. Scenes/Objects/scraps/", 1, ".tscn")
	scrapInstance = load(scraps[randi() % scraps.size()])
	makePath()
	properties.setMaxHealth(50)
	projectileSpeed = 10
	
	
	
func _physics_process(delta):
	if !frozen:
		if (moveForward): handleMoveForward(delta)
		if (lookAtPlayer): look_at(Global.getPlayerPosition())
		if (followPath): navigate(delta)
		if (shooting): handleEnemyInput(delta)
		if (charge): handleCharge(delta)



func handleMoveForward(delta):
	if canMove:
		motion = ((global_position + Vector2(-1, 0)) - global_position).normalized() * moveForwardSpeed * delta
	else:
		set_velocity(Vector2.ZERO)
		set_up_direction(Vector2(0, -1))
		move_and_slide()
		motion = velocity
			
			
	set_velocity(motion)
	set_up_direction(Vector2(0, -1))
	move_and_slide()
	var _a = velocity

func navigate(delta):
	if (navigationPaused): return
	
	var distanceToDestination = position.distance_to(possibleDestinations[0].position)
	
	if distanceToDestination > minimumDistanceToDestination:
		move(delta)
	else:
		if possibleDestinations.size() == 1:
			makePath()
		else:
			possibleDestinations.remove_at(0)
	
	
func move(delta):
	motion = (possibleDestinations[0].position - position).normalized() * moveForwardSpeed * delta
	set_velocity(motion)
	set_up_direction(Vector2(0, -1))
	move_and_slide()
	var _a = velocity
	
	
func updatePath():
	if path.size() == 1:
		if $Timer.is_stopped():
			$Timer.start()
	else:
		path.remove_at(0)
	
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
			
		set_velocity(motion)
		set_up_direction(Vector2(0, -1))
		move_and_slide()
		var _a = velocity
		
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
	var scrapCopy = scrapInstance.instantiate()
	scrapCopy.global_transform = global_transform
	parentNode.add_child(scrapCopy)
	queue_free()
	
	
	



func _on_VisibilityNotifier2D_screen_entered():
	invincible = false


func _on_VisibilityNotifier2D_screen_exited():
	disappear()
