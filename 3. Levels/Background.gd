extends CanvasLayer


var planetTextures = FileGrabber.fileGrab("res://1. GFX/Planets/", 1, ".png")


func _ready():
	setPlanetTimer()
	


func setPlanetTimer(a = 0):
	
	var timer = a
	
	if (timer == 0):
		randomize()
		timer = randi() % 2 + 5
			
	$planetTimer.wait_time = timer
	$planetTimer.start()
	



	
func spawnRandomPlanet():
	if $planetParticles.emitting == false:
		randomize()
		var randomTexture = planetTextures[randi() % planetTextures.size()]
		var randomScale = randi() % 6 + 2
		$planetParticles.scale_amount = randomScale
		$planetParticles.texture = load(randomTexture)
		$planetParticles.emitting = true


func _on_planetTimer_timeout():
	spawnRandomPlanet()
	setPlanetTimer()
