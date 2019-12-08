extends Reference

enum {CHAPTER, PAGE, OPTIONS}

const chapterFeatures = ["name", "number", "path"]
const pageFeatures = ["speaker", "speech", "options", "choices"]
const optionList = ["name", "image", "music", "sfx", "background", "pause", "choice_flair"]

const imgPrefix = "res://images/"
const musicPrefix = "res://Audio/"
const imgSuffix = ".png"
const musicSuffix = ".ogg"

#First int indicates current index by chapter, 2nd int denotes active page of dialogue
var path = 0
var bookmark = Vector2(0, 0)    setget reset, get_bookmark
var chapters = []
var branchMap = []        #Array of chapter[] coords, x-index for number, y-index for path
var textureBuffer = []    #Hold textures in memory to reduce load times when drawn to screen
var data_clusters = []    #2D array, each 0th index holds an "id" string and each non-zero element holds a dictionary
var story_data = {}       #Dictionaries of placeholder values and what to fill with them

func add_chapter(chapName:String, chapNumber:int = 0, chapBranch:int = 0) -> int:
	var newArray = []
	var newChapter = {name = chapName,
		number = chapNumber,
		path = chapBranch,
	}
	
	newArray.append(newChapter)
	chapters.append(newArray)
	
	chapters.sort_custom(MyCustomSorter, "sort")
	_update_branch_map()
	
	return get_chapter_by_coords(Vector2(chapNumber, chapBranch))

func add_cluster(id:Dictionary) -> bool:	#Test if Dictionary type can be replaced by String
	if cluster_exists(id):
		return false
	var new_arr = [1]
	new_arr[0] = id
	data_clusters.append(new_arr)
	return true

func add_data(placeholder:String, data):	#Used by visCompManager
	story_data[placeholder] = data

func add_to_cluster(id:Dictionary, newPairs:Array) -> bool:
	var cluster_arr = get_cluster(id)
	if cluster_arr == []:
		return false
	
	for i in range(0, newPairs.size()):
		var newPair = newPairs[i]
		if typeof(newPair) != TYPE_DICTIONARY:
			return false
		cluster_arr.append(newPair)
	return true


#Creates and appends a new page of dialogue to the current chapter's path
func add_page(spch:String, optList:Dictionary = {}, choiceList:Dictionary = {}):
	var newPage = {
		speech = spch,
		options = optList,
		choices = choiceList,
		speaker = ""
	}
	
	if optList.has("name"):
		newPage["speaker"] = optList["name"]
	
	if _valid_dict(optList, OPTIONS):
		get_chapter().append(newPage)
		if newPage.options.keys().has("background"):
			newPage.options.background = imgPrefix + newPage.options.background + imgSuffix
			textureBuffer.append(load(newPage.options.background))
		if newPage.options.keys().has("image") and !newPage.options.image.begins_with(imgPrefix):
			newPage.options.image = imgPrefix + newPage.options.image + imgSuffix
			if newPage.options.image.find("%") == -1:
				textureBuffer.append(load(newPage.options.image))
		if newPage.options.keys().has("music"):
			newPage.options.music = musicPrefix + newPage.options.music + musicSuffix
		if newPage.options.keys().has("sfx"):
			newPage.options.sfx = musicPrefix + newPage.options.sfx + musicSuffix
	else:
		print("Dict not valid")
	return true

func cluster_exists(id:Dictionary) -> bool:
	if get_cluster(id) != []:
		return true
	return false

func get_all_chapter_paths(find_chapter:int) -> Array:
	var ret_arr = []
	
	for i in range(0, chapters.size()):
		if get_chapter_index(i).number == find_chapter:
			ret_arr.append(get_chapter_index(i).path)
	
	return ret_arr

func get_bookmark() -> Vector2:
	return bookmark

func get_chapter(chap:int = bookmark.x):
	if chap >= chapters.size() or chap < 0:
		return false
	return chapters[chap]

func get_chapter_by_coords(coords:Vector2) -> int:
	return branchMap.bsearch(coords)

func get_chapter_pos(chap = get_chapter()) -> int:	#Figure this shit out
	for i in range(0, chapters.size()):
		if chapters[i] == chap:
			return i
	
	print("E: Could not find chapter: ", chap[0])
	return -1

func get_chapter_index(chap:int = bookmark.x) -> Dictionary:
	return get_chapter(chap)[0]

func get_cluster(id:Dictionary) -> Array:    #Returns reference to the array under this particular id dictionary
	for i in data_clusters.size():
		if _dict_compare(data_clusters[i][0], id):    #Can't believe I had to write this...
			return data_clusters[i]
	return []

func get_data(placeholder:String):
	return story_data.get(placeholder)

func get_data_all():
	return story_data

func get_page(page:Vector2 = bookmark) -> Dictionary:
	var ret = _fill_in_placeholders(get_chapter()[page.y])
	return ret

func get_toc() -> Array:	#Branching storyline support?
	var ret = []
	ret.resize(chapters.size())
	
	for i in ret.size():
		ret[i] = get_chapter_index(i)
	
	return ret

func get_unique_chapter_nums() -> Array:
	var x = 0
	var hold = []
	hold.resize(chapters.size())
	
	for i in range(0, chapters.size()):
		if hold.find(get_chapter_index(i).number) == -1:
			hold[x] = get_chapter_index(i).number
			x += 1
	
	hold.sort()
	return hold

func get_unique_paths() -> Array:
	var x = 0
	var hold = []
	hold.resize(chapters.size())    #Probably excessive
	
	for i in range(0, chapters.size()):	#Add protection against short highly-fragmented stories
		if hold.find(get_chapter_index(i).path) == -1:
			hold[x] = get_chapter_index(i).path
			x += 1
	
	hold.sort()
	return hold

func is_book_end() -> bool:
	if is_last_chapter() == true and is_last_page() == true:
		return true
	return false

#TODO: Make functional with paths that don't reach the highest chapter number
func is_last_chapter() -> bool:
	
	if get_chapter_pos() == chapters.size()-1:
		return true
	
	var ref_Vector = Vector2(get_chapter_index().number, get_chapter_index().path)
	var start_pos = get_chapter_by_coords(ref_Vector)+1
	
	for i in range(start_pos, branchMap.size()):
		if branchMap[i].y != ref_Vector.y:
			if i != branchMap.size()-1:     #Why does this break when converted to an 'and' statement?
				continue     #Only continue if not at end of loop
		else:
			return false
		
		if i == branchMap.size()-1:
			return true       #End of path reached, returning true
	
	return false

func is_last_page() -> bool:
	if bookmark.y == get_chapter().size() -1:
		return true
	return false

func jump_to_page(newPage:int):
	if newPage >= 0 and newPage < get_chapter().size():
		bookmark.y = newPage
	else:
		print("NEW PAGE ",newPage, " OUT OF BOUNDS")

func move_path(newBranch:int) -> bool:
	var currChap = get_chapter_index()
	
	if currChap.path == newBranch:
		return true
	
	for i in chapters.size():
		if(get_chapter(i)[0].path == newBranch and get_chapter(i)[0].number == currChap.number):
			bookmark = Vector2(i, 0)
			path = newBranch
			return true
	
	return false

func next_chapter() -> bool:
	if is_last_chapter():
		return false
	
	var fallback = bookmark
	
	bookmark.y = 0
	var next_chapter = get_chapter_index().number + 1
	
	while bookmark.x < chapters.size() - 1:
		bookmark.x += 1
		if next_chapter == get_chapter_index().number and path == get_chapter_index().path:
			return true 
	
	#Reset bookmark if not found
	bookmark = fallback
	return false

func prev_chapter() -> bool:
	if bookmark.x > 0:
		bookmark.x -= 1
		bookmark.y = 0
		return true
	
	return false

#TODO: protect from out-of-bounds error
func reset(new_spot:Vector2 = Vector2(0,0)) -> int:
	if new_spot.x >= 0 and new_spot.y >= 0:
		if new_spot.x < chapters.size() - 1 and new_spot.y < branchMap.size() -1:
			bookmark = new_spot
			return 0
		else:
			return ERR_INVALID_PARAMETER
	else:
		return ERR_INVALID_PARAMETER

func set_chapter(newChap:int) -> bool:
	if newChap == clamp(float(newChap), 0, float(chapters.size())):
		bookmark = Vector2(newChap, 0)
		return true
	
	return false

func turn_page() -> bool:
	if typeof(get_chapter()) == TYPE_BOOL:
		return false
	
	elif bookmark.y < get_chapter().size()-1:
		bookmark.y += 1
		return true
	
	return false

#TODO: Determine plausibility of privatizing function
func _update_branch_map():
	var temp_arr = chapters.duplicate(true)
	var coords
	
	if branchMap.size() <= temp_arr.size():
		branchMap.resize(temp_arr.size())
	
	for i in range(0, chapters.size()):
		coords = Vector2(get_chapter_index(i).number, get_chapter_index(i).path)
		branchMap[i] = coords

func _fill_in_placeholders(pageRef:Dictionary):
	pageRef = pageRef.duplicate(true)
	var data_keys = story_data.keys()
	
	
	for i in story_data.size():
		var find = data_keys[i]
		print("Find values: " + str(find))
		var cluster_arr = get_cluster({find:story_data[find]})
		print("cluster_arr: " + str(cluster_arr))
		print("Search values: " + str(cluster_arr[2].keys()))
		print("Replace value: " + str(cluster_arr[2].values()))
		
		for j in range(0, pageFeatures.size()):
			#print("iter " + str(j))
			#print(str(pageRef[pageFeatures[j]]))
			if typeof(pageRef[pageFeatures[j]]) != TYPE_STRING:
				#Handle dicts here
				var opts_ref = pageRef[pageFeatures[j]] #Create ref to dict
				var iter_arr = opts_ref.keys()          #Create an array corresponding w/ dict keys
				
				for k in range(0, iter_arr.size()):
					for l in range(0, cluster_arr.size()):
						find = "%" + cluster_arr[l].keys()[0].to_upper() + "%"
						var replace = cluster_arr[l].values()[0] 
						if typeof(opts_ref[iter_arr[k]]) == TYPE_STRING:
							if opts_ref[iter_arr[k]].find("%"):
								opts_ref[iter_arr[k]] = opts_ref[iter_arr[k]].replace(find, str(replace))
				continue
			
			for test in cluster_arr.size():
				print("Pair to find: " + str(cluster_arr[test].keys()) + ": " + str(cluster_arr[test].values()))
				
				find = str(cluster_arr[test].keys())
				var replace = str(cluster_arr[test].values())
				find = find.replace("[", "")
				replace = replace.replace("[", "")
				find = find.replace("]", "")
				replace = replace.replace("]", "")
				find = find.to_upper()
				if find.find("%") == -1:
					find = "%" + find + "%"  #Add % signs around those missing them
				print("Findthis: " + find)
				pageRef[pageFeatures[j]] = pageRef[pageFeatures[j]].replace(find, replace)
	
	return pageRef

static func _dict_compare(a:Dictionary, b:Dictionary) -> bool:
		if a.keys() == b.keys() and a.values() == b.values():
			return true
		return false

func _valid_dict(dict:Dictionary, dictType) -> bool:
	var ret = true
	var compDict    #Actually an array of strings
	
	match(dictType):
		CHAPTER:
			compDict = chapterFeatures
		PAGE:
			compDict = pageFeatures
		OPTIONS:
			compDict = optionList
		_:
			ret = false
			print("invalid dictType: ", dictType)
	
	if(dict.size() > compDict.size()):
			ret = false
			print("Exceeded maximum features for dictionary-type: ", dictType)
	else:
		var attempts = dict.keys()
		for i in attempts:
			if !compDict.has(i):
				ret = false
				print("KEY: <", i, "> NOT A VIABLE PROPERTY")
				break
	
	return ret

class MyCustomSorter:
	static func sort(small, big):
		if small[0].number < big[0].number:
			return true
		elif small[0].number == big[0].number and small[0].path < big[0].path:
			return true
		return false
	
	static func sortPaths(small, big):
		if small.x < big.x:
			return true
		elif small.x == big.x and small.y < big.y:
			return true
		return false
