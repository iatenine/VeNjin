extends Reference

enum {CHAPTER, PAGE, OPTIONS, CHOICES}

const chapterFeatures = ["name", "number", "path"]
const pageFeatures = ["speaker", "speech", "options", "choices", "chapterEnd", "getData"]
const optionList = ["image", "music", "sfx", "background", "pause"]

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

func add_chapter(chapName:String, chapNumber:int = 0, chapBranch:int = 0):
	var newArray = []
	var newChapter = {name = chapName,
		number = chapNumber,
		path = chapBranch,
	}
	
	newArray.append(newChapter)
	chapters.append(newArray)
	
	chapters.sort_custom(MyCustomSorter, "sort")
	update_branch_map(newChapter)

#Creates and appends a new page of dialogue to the current chapter's path
func add_page(spch:String, spker:String = "", optList:Dictionary = {}, choiceList:Dictionary = {}):
	var newPage = {
		speech = spch,
		speaker = spker,
		options = optList,
		choices = choiceList
	}
	
	if valid_dict(optList, OPTIONS):
		get_chapter().append(newPage)
		if newPage.options.keys().has("background"):
			newPage.options.background = imgPrefix + newPage.options.background + imgSuffix
			textureBuffer.append(load(newPage.options.background))
		if newPage.options.keys().has("image"):
			newPage.options.image = imgPrefix + newPage.options.image + imgSuffix
			textureBuffer.append(load(newPage.options.image))
		if newPage.options.keys().has("music"):
			newPage.options.music = musicPrefix + newPage.options.music + musicSuffix
		if newPage.options.keys().has("sfx"):
			newPage.options.sfx = musicPrefix + newPage.options.sfx + musicSuffix
	else:
		print("Dict not valid")
	return true

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

func get_chapter_pos(chap = get_chapter()) -> int:
	return chapters.bsearch(chap)

func get_chapter_index(chap:int = bookmark.x) -> Dictionary:
	return get_chapter(chap)[0]

func get_page(page:Vector2 = bookmark) -> Dictionary:
	return get_chapter()[page.y]

func get_toc() -> Array:
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

func is_book_end() -> bool:
	if is_last_chapter() == true and is_last_page() == true:
		return true
	return false

#TODO: Make functional with paths that don't reach the highest chapter number
func is_last_chapter() -> bool:
	var all_chapters = get_unique_chapter_nums()
	var last_index = all_chapters.size()-1
	
	if get_chapter_index().number == all_chapters[last_index]:
		return true
	
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

func reset(newLoc:Vector2 = Vector2(0, 0)):
	bookmark = newLoc
	path = 0

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

func update_branch_map(chapter):
	var index = chapters.bsearch(chapter)
	var coords = Vector2(chapter.number, chapter.path)
	
	if branchMap.size() <= index:
		branchMap.resize(index+1)
	
	branchMap[index] = Vector2(coords.x, coords.y)

func valid_dict(dict:Dictionary, dictType):
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