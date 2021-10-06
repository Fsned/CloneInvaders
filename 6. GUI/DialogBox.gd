extends Control

export(String, MULTILINE) var message = ""
export var hasButton = false
export var displaySpaceTip = true

var series = ""


func _ready():
	$CenterContainer/Label/NinePatchRect/SpaceTipLabel.visible = displaySpaceTip
	


func hideIfShown():
	if (visible):
		hide()

func setText(text):
	$CenterContainer/Label.text = text



func _process(_delta):
	if Input.is_action_just_pressed("nextDialog"):
		if series != "":
			get_tree().call_group("dialogs", "seriesDialogClosed", series)
		hide()
		queue_free()

func setSeries(seriesId):
	series = seriesId

func getSeries():
	return series
func closeAllDialogs():
	hide()
