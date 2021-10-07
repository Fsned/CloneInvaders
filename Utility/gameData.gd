extends Node

const saveFilePath = "res://Utility/saveData.save"


func saveGame():
	var persistingNodes = get_tree().get_nodes_in_group("persist")
	
	var saveData = {}
	for node in persistingNodes:
		saveData.append() += node.call("saveData")
		
	if saveData == {}:
		print ("No data to save")
		
	var saveFile = File.new()
	saveFile.open(saveFilePath, File.WRITE)
	saveFile.store_string(to_json(saveData))
	saveFile.close()
	
	
func loadGame(scope = "all"):
	var saveFile = File.new()
	if ! saveFile.file_exists(saveFilePath):
		print ("Couldn't find saveFile in path: " + saveFilePath)
		return false
		
	saveFile.open(saveFilePath, File.READ)
	var content = saveFile.get_as_text()
	saveFile.close()
	return to_json(content)
