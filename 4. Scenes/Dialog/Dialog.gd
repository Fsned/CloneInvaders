extends Node


const dialogPath = "res://6. GUI/DialogBox.tscn"
var numberOfDialogBoxes = 0
var children
var currentDialog = 0
export var timerInitiation = true
export var initiationTimerValue = 5


export (PoolStringArray) var dialogs


func _ready():
	numberOfDialogBoxes = dialogs.size()
	
	for a in range(numberOfDialogBoxes):
		var child = load(dialogPath).instance()
		add_child(child)
		print ("Setting child text to dialogs[" + str(a) + "]")
		child.setText(dialogs[a])
	
	children = get_children()
	
	if (timerInitiation):
		$InitiationTimer.wait_time = initiationTimerValue
		$InitiationTimer.start()
	
func _process(_delta):
	if Input.is_action_just_pressed("nextDialog"):
		showNext()
	
func showNext():
	if (currentDialog >= 1):
		children[currentDialog].hide()
	
	if (currentDialog < numberOfDialogBoxes):
		currentDialog += 1
		children[currentDialog].show()
			
	
 
func _on_InitiationTimer_timeout():
	showNext()
	
	

