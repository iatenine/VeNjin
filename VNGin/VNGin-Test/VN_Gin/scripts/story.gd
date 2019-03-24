extends Reference

enum {CHAPTER, PAGE, OPTIONS, CHOICES}

const chapterFeatures = ["name", "number", "path"]
const pageFeatures = ["speaker", "speech", "options", "choices", "chapterEnd", "getData"]
const optionList = ["image", "music", "sfx", "background", "pauseTime", "decisionTime"]

#First int indicates current index by chapter, 2nd int denotes active page of dialogue
var path = 0
var bookmark = Vector2(0, 0)    setget reset, getBookmark
var lastChapter = 0
var chapters = []
var textureBuffer = []    #Hold textures in memory to reduce load times when drawn to screen

func addChapter(chapName:String, chapNumber:int = 0, chapBranch:int = 0):
	var newArray = []
	var newChapter = {name = chapName,
		number = chapNumber,
		path = chapBranch,
	}
	
	if chapNumber > lastChapter:
		lastChapter = chapNumber
	
	newArray.append(newChapter)
	chapters.append(newArray)

#Creates and appends a new page of dialogue to the current chapter's path
func addPage(spch:String, spker:String = "", optList:Dictionary = {}, choiceList:Dictionary = {}):
	var newPage = {
		speech = spch,
		speaker = spker,
		options = optList,
		choices = choiceList
	}
	
	if validDict(optList, OPTIONS):
		getChapter().append(newPage)
		if newPage.options.keys().has("background"):
			textureBuffer.append(load(newPage.options.background))
		if newPage.options.keys().has("image"):
			textureBuffer.append(load(newPage.options.image))
	else:
		print("Dict not valid")
	return true

func getBookmark() -> Vector2:
	return bookmark

func getChapter(chap:int = bookmark.x):
	if chap >= chapters.size() or chap < 0:
		return false
	return chapters[chap]

#Returns dict with chapter properties
func getChapIndex(chap:int = bookmark.x) -> Dictionary:
	return getChapter(chap)[0]

func getPage(page:Vector2 = bookmark) -> Dictionary:
	return getChapter()[page.y]

func getTOC() -> Array:
	var ret = []
	ret.resize(chapters.size())
	
	for i in ret.size():
		ret[i] = getChapIndex(i)
	
	return ret

func isBookEnd() -> bool:
	if isLastChapter() == true and isLastPage() == true:
		return true
	return false

func isLastChapter() -> bool:
	if bookmark.x == chapters.size()-1:
		return true
	return false

func isLastPage() -> bool:
	if bookmark.y == getChapter().size() -1:
		return true
	return false

func jumpToPage(newPage:int):
	if newPage >= 0 and newPage < getChapter().size():
		bookmark.y = newPage
	else:
		print("NEW PAGE ",newPage, " OUT OF BOUNDS")

func movePath(newBranch:int) -> bool:
	var currChap = getChapIndex()
	
	if currChap.path == newBranch:
		return true
	
	for i in chapters.size():
		if(getChapter(i)[0].path == newBranch and getChapter(i)[0].number == currChap.number):
			bookmark = Vector2(i, 0)
			path = newBranch
			return true
	
	return false

#Return false if there isn't a next chapter
func nextChapter() -> bool:
	if isLastChapter():
		return false
	
	var fallback = bookmark
	
	bookmark.y = 0
	var nextChapter = getChapIndex().number + 1
	
	while bookmark.x < chapters.size() - 1:
		bookmark.x += 1
		if nextChapter == getChapIndex().number and path == getChapIndex().path:
			return true 
	
	#Reset bookmark if not found
	bookmark = fallback
	return false

func prevChapter() -> bool:
	if bookmark.x > 0:
		bookmark.x -= 1
		bookmark.y = 0
		return true
	
	return false

func reset(newLoc:Vector2 = Vector2(0, 0)):
	bookmark = newLoc
	path = 0

func setChapter(newChap:int) -> bool:
	if newChap == clamp(float(newChap), 0, float(chapters.size())):
		bookmark = Vector2(newChap, 0)
		return true
	
	return false

func turnPage() -> bool:
	if typeof(getChapter()) == TYPE_BOOL:
		return false
	
	elif bookmark.y < getChapter().size()-1:
		bookmark.y += 1
		return true
	
	return false

func validDict(dict:Dictionary, dictType):
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