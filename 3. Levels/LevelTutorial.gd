extends "res://3. Levels/LevelTemplate.gd"




func _ready():
#	get_tree().call_group("GUI", "toggleEnemiesRemaining")
	
	Dialog.createDialogSeries("tutorialSeries")
	Dialog.addDialogToSeries("tutorialSeries", "Hello!", true)
	Dialog.addDialogToSeries("tutorialSeries", "This is clone invaders", true)
	Dialog.addDialogToSeries("tutorialSeries", "My very first game :D", true)
	Dialog.addDialogToSeries("tutorialSeries", "Hope you like it!", true)

	


func _on_dialogTimer_timeout():
	Dialog.playSeries("tutorialSeries")
