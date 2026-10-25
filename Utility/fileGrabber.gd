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
	var fileList = []

	for rawName in DirAccess.get_files_at(path):
		# In exported builds files show up as "x.png.import" / "x.tscn.remap",
		# but load() still works with the original name.
		var fileName = rawName.trim_suffix(".import").trim_suffix(".remap")
		if fileList.has(path + fileName):
			continue

		match matchCase:
			0:
				if (fileName.begins_with(xFix)):
					fileList.append(path + fileName)

			1:
				if (fileName.ends_with(xFix)):
					fileList.append(path + fileName)

	return fileList
