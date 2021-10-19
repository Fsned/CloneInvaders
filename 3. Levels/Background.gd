extends CanvasLayer


var planetTextures = FileGrabber.fileGrab("res://1. GFX/Planets/", 1, ".png")

var texts = []

func _ready():
	texts.append(ResourceLoader.load("res://1. GFX/Planets/Baren.png"))
	texts.append(ResourceLoader.load("res://1. GFX/Planets/Ice.png"))
	texts.append(ResourceLoader.load("res://1. GFX/Planets/Lava.png"))
	texts.append(ResourceLoader.load("res://1. GFX/Planets/Terran.png"))
	
	
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
		if planetTextures.size() > 0:
			var randomTexture = planetTextures[randi() % planetTextures.size()]
			var randomScale = randi() % 6 + 2
			$planetParticles.scale_amount = randomScale
			$planetParticles.texture = load(randomTexture)
			$planetParticles.emitting = true


func _on_planetTimer_timeout():
	spawnRandomPlanet()
	setPlanetTimer()
