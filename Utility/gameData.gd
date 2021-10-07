extends Node

const saveFilePath = "res://Utility/saveData.save"

var defaultData = {
	"score": 0,
	"musicVolume": 60,
	"sfxVolume": 60
}


var data = {}

func saveGame():
	var file
	
	for node in get_tree().get_nodes_in_group("persist"):
		var nodeData = node.call("getSaveData")
		for item in nodeData:
			data[str(item)] = nodeData[str(item)]
	
	
	file = File.new()
	file.open(saveFilePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	
	
func loadGame(scope = "all"):
	var file = File.new()
	
	if not file.file_exists(saveFilePath):
		resetData()
		return data
		
	file.open(saveFilePath, file.READ)
	
	var text = file.get_as_text()
	
	data = parse_json(text)
	file.close()
	
	return data
	
	
func getKey(key):
	loadGame()
	
	if ! key in data:
		data[key] = defaultData[key]
		return data[key]
	
	
	
func setKey(key, value):
	loadGame()
	data[key] = value
	saveGame()
	
	print ("Setting " + key + " to: " + str(value))
	
func resetData():
	data = defaultData
