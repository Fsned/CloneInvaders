extends Node







func getPlayerPosition():
	
	var player = get_tree().get_root().find_node("Player", true, false)
	return player.position
