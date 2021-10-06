extends Node



var numberOfDialogBoxes = 0
var children
var currentDialog = -1


func _ready():
	numberOfDialogBoxes = get_child_count()
	if (numberOfDialogBoxes > 0):
		children = get_children()
	
	
func showNext():
	if (currentDialog >= 0):
		children[currentDialog].hide()
	
	if (currentDialog < numberOfDialogBoxes):	
		currentDialog += 1
		children[currentDialog].show()
	
	
	
