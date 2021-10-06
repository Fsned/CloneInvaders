extends Node


var series = {}

signal seriesDialogClosed

func _ready():
	add_to_group("dialogs")

func openDialogBox(dialogBoxText, showSpaceTooltip = false, seriesId = ""):
	var dialogBox = load("res://6. GUI/DialogBox.tscn").instance()
	dialogBox.setText(dialogBoxText)
	dialogBox.displaySpaceTip = showSpaceTooltip
	add_child(dialogBox)
	dialogBox.show()
	
	if seriesId != "":
		dialogBox.setSeries(seriesId)
	
	
func createDialogSeries(seriesId, timeToggled = false, spaceToggled = false, timeToggleTimer = 0):
	series[seriesId] = {"timeToggled": timeToggled,
						"spaceToggled": spaceToggled,
						"timeToggleTimer": timeToggleTimer,
						"playing": false,
						"currentDialog": -1,
						"dialogs": []
						}
	print ("Created dialogseries: " + seriesId)

func deleteSeries(seriesId):
	if series[seriesId] == null: return false
	series.erase(seriesId)
	return true
		
	
func addDialogToSeries(seriesId, dialogBoxText, _showSpaceTooltip = false):
	if series[seriesId] == null: return false
	series[seriesId]["dialogs"].push_back(dialogBoxText)
	print ("Added dialog to series: " + seriesId + ", dialog: " + dialogBoxText)

func playSeries(seriesId):
	if series[seriesId] == null: return false
	if series[seriesId]["playing"] == true: return false
	if series[seriesId]["dialogs"].size() <= 0: return false
	
	series[seriesId]["playing"] = true
	nextSeriesDialog(seriesId)
	
	return true
	pass
	

func nextSeriesDialog(seriesId):
	if series[seriesId] == null: return false
	if series[seriesId]["playing"] == false: return false
	
	if series[seriesId]["dialogs"].size() > series[seriesId]["currentDialog"] + 1:
		series[seriesId]["currentDialog"] = series[seriesId]["currentDialog"] + 1
		get_tree().call_group("dialogs", "closeAllDialogs")
			
		openDialogBox(series[seriesId]["dialogs"][series[seriesId]["currentDialog"]], series[seriesId]["spaceToggled"], seriesId)
		return true
	else:
		series.erase(seriesId)
		emit_signal("seriesDialogClosed")
	
		
	
func openDialogBoxWith1Button(_dialogBoxText, _buttonText):
	pass
	
	
func openDialogBoxWith2Buttons(_dialogBoxText, _button1Text, _button1Group, _button1Signal, _button2Text, _button2Group, _button2Signal):
	pass


func seriesDialogClosed(seriesId):
	if series[seriesId] != null:
		nextSeriesDialog(seriesId)
