extends Reference

#Story.gd
#Manages data for a single story including options, dialogues and chapter meta data

#Stories are effectively 2D arrays with each chapter occupying 1 column
#Item 0 in each chapter is a specialized page containing its name, number and path
#Linear stories should all use path 0 and branching stories will use this as the default

#Pages beyond 0 have the following features:
#Speaker: What you would like to appear in the name box
#Speech: The main text for a player to read, typically dialogue
#options: A dictionary of relevant options to this page (explained below)
#choices: A dictionary of dictionaries for branching storylines (explained below)

#Options:
#Use the following by passing a filepath
#   image: The image to be displayed front and center, usually a character who is speaking
#   music: Music to begin playing at this point (looping)
#   sfx: A sound to play at this point (non-looping)
#   background: A background to be loaded at this moment in the story
#Use the following by passing an int
#    pauseTime: Add a dramatic pause before showing the next button
#    decisionTime: Add a countdown for the player to make a decision
#                  (the current path will be treated as default if time runs out)

enum {CHAPTER, PAGE, OPTIONS, CHOICES}

const chapterFeatures = ["name", "number", "path"]
const pageFeatures = ["speaker", "speech", "options", "choices", "chapterEnd", "getData"]
const optionList = ["image", "music", "sfx", "background", "pauseTime", "decisionTime"]

#First int indicates current index by chapter, 2nd int denotes active page of dialogue
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

func isBookEnd():
	if isLastChapter() == true and isLastPage() == true:
		return true
	return false

func isLastChapter() -> bool:
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
		if(getChapter(i)[0].path == newBranch and getChapter(i)[0].number == currChap.number):
			bookmark = Vector2(i, 0)
			break

#Return false if there isn't a next chapter
func nextChapter() -> bool:
	if bookmark.x < chapters.size()-1:
		var currChap = getChapIndex().number
		bookmark.y = 0
		bookmark.x += 1
		
		#Use while loop in case there are multiple paths in the way
		while(currChap == getChapIndex().number):
			bookmark.x += 1
		return true
	
	return false

func prevChapter() -> bool:
	if bookmark.x > 0:
		bookmark.x -= 1
		bookmark.y = 0
		return true
	
	return false

func reset(newLoc:Vector2 = Vector2(0, 0)):
	bookmark = newLoc

func setChapter(newChap:int):
	if newChap >= 0 and newChap <= chapters.size():
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
