extends Node

const saveFilePath = "res://Utility/saveData.save"

var defaultData = {
	"score": 0,
	"musicVolume": 60,
	"sfxVolume": 60
}


var data = {}


func _ready():
	loadGame()

	
func saveGame():
	var file = File.new()
	file.open(saveFilePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	
	
func loadGame(scope = "all"):
	var file = File.new()
	
	if not file.file_exists(saveFilePath):
		resetData()
		saveGame()
		return
		
	file.open(saveFilePath, file.READ)
	var text = file.get_as_text()
	file.close()
	data = parse_json(text)
	return
	
	
func getKey(key):
	loadGame()
	
	if key in data:
		return data[key]
	
	else:
		if ! key in defaultData:
			print("Data missing in defaultData: " + str(key))
			return 0
		else:
			data[key] = defaultData[key]
			return defaultData[key]
	
func setKey(key, value):
#	loadGame()
	data[key] = value
	saveGame()
	
	print ("Setting " + key + " to: " + str(value))
	
func resetData():
	data = defaultData
