extends Node


onready var dialogs = get_children()




func _on_Timer_timeout():
	if (dialogs.size() > 0):
		dialogs[0].visible = true
	
