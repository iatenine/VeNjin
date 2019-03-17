extends Reference

enum {CHAPTER, PAGE, OPTIONS, CHOICES}

const chapterFeatures = ["chapterName", "chapter", "branch"]
const pageFeatures = ["speaker", "speech", "options", "choices", "chapterEnd", "getData"]
const optionList = ["image", "music", "sfx", "background", "pauseTime", "decisionTime"]

#First int indicates current index by chapter, 2nd int denotes active page of dialogue
var bookmark = Vector2(0, 0)    setget reset, getBookmark
var lastChapter = 0
var chapters = []
var textureBuffer = []    #Hold textures in memory to reduce load times when drawn to screen

func addChapter(chapName:String, chapNumber:int = 0, chapBranch:int = 0):
	var newArray = []
	var newChapter = {chapterName = chapName,
		chapter = chapNumber,
		branch = chapBranch,
	}
	if chapNumber > lastChapter:
		lastChapter = chapNumber
	
	newArray.append(newChapter)
	chapters.append(newArray)

#Creates and appends a new page of dialogue to the current chapter's branch
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
			#print(textureBuffer[textureBuffer.size()-1].resource_path)
	else:
		print("Dict not valid")
	return true

func getBookmark():
	return bookmark

func getChapter(chap:int = bookmark.x):
	if chap >= chapters.size() or chap < 0:
		return false
	return chapters[chap]

#Returns dict with chapter properties
func getChapIndex(chap:int = bookmark.x):
	return getChapter(chap)[0]

func getPage(page:int = bookmark.y, turn:bool = false):
	if typeof(getChapter()) == TYPE_BOOL:
		return false
	
	if turn == true:
		var canTurn = turnPage()
		if !canTurn:
			print("End of chapter")
	
	if page < getChapter().size():
		return getChapter()[page]

func getTOC():
	var ret = []
	ret.resize(chapters.size())
	
	for i in ret.size():
		ret[i] = getChapIndex(i)
	
	return ret

func isLastChapter():
	if bookmark.x == chapters.size()-1:
		return true
	return false

func isLastPage():
	if bookmark.y == getChapter().size() -1:
		return true
	return false

func jumpToPage(newPage:int):
	if newPage >= 0 and newPage < getChapter().size():
		bookmark.y = newPage
	else:
		print("NEW PAGE ",newPage, " OUT OF BOUNDS")

func moveBranch(newBranch:int):
	var currChap = getChapIndex()
	
	for i in chapters.size():
		if(getChapter(i)[0].branch == newBranch and getChapter(i)[0].chapter == currChap.chapter):
			bookmark = Vector2(i, 0)
			break

func nextChapter():
	if bookmark.x < chapters.size()-1:
		var currChap = getChapIndex().chapter
		bookmark.y = 0
		bookmark.x += 1
		while(currChap == getChapIndex().chapter):
			bookmark.x += 1
		return true
	
	return false

func prevChapter():
	if bookmark.x > 0:
		bookmark.x -= 1
		bookmark.y = 0
		return true
	
	return false

func reset(newLoc:Vector2 = Vector2(0, 0)):
	bookmark = newLoc
	return true

func setChapter(newChap:int):
	if newChap >= 0 and newChap <= chapters.size():
		bookmark = Vector2(newChap, 0)
		return true
	
	return false

func turnPage():
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