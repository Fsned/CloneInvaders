extends Node

#### Path	####################################################################################
# Description: This is the filepath to the folder, at which you want to look for certain files
#### matchCase	########################################################################
# Description: decide whether to check if files 'ends_with' or 'begins_with'
#	0: begins_with(xFix)
#	1: ends_with(xFix)
#### xFix	########################################################################
# Description: string determining the pre- or suffix you want to check.
#	Example:
#	matchCase == 1
#	xFix == ".txt"
#	will return all files in (path) that ends_with ".txt"


func fileGrab(path, matchCase, xFix):
	
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	
	var fileName = dir.get_next()
	var fileList = []
	while (fileName != ""):
		match matchCase:
			0:
				if (fileName.begins_with(xFix)):
					fileList.append(path + fileName)
				
			1:
				if (fileName.ends_with(xFix)):
					fileList.append(path + fileName)
				
		fileName = dir.get_next()
		
	return fileList
