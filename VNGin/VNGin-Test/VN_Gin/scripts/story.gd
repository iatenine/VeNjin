extends Reference

const PAGE_OPTS = ["path", "chap_num", "page_num", "chap_name", "speech", "choices",
"name", "image", "music", "sfx", "background", "pause", "profile"]

const INDEX_PROP = "page_num"
const imgPrefix = "res://images/"
const musicPrefix = "res://Audio/"
const imgSuffix = ".png"
const musicSuffix = ".ogg"

#First int indicates current index by chapter, 2nd int denotes active page of dialogue
var path = 0
var bookmark = Vector2(0, 0)    setget reset, get_bookmark
var pages = [[]]
var occupied = []
var data_clusters = []    #2D array, each 0th index holds an "id" string and each non-zero element holds a dictionary
var story_data = {}       #Dictionaries of placeholder values and what to fill with them

#func add_cluster(id:Dictionary) -> bool:	#Test if Dictionary type can be replaced by String
#	return false

func add_data(placeholder:String, data):	#Used by visCompManager
	story_data[placeholder] = data

#func add_to_cluster(id:Dictionary, newPairs:Array) -> bool:
#	return false


#Returns -1 if invalid entry, or the number of rejected keys
func add_page(page_options:Dictionary = {}) -> int:
	if(!page_options.has(INDEX_PROP) or typeof(page_options[INDEX_PROP])!= TYPE_INT):
		return -1          #No page created
	
	var failed_keys = 0
	var iter = 0
	var new_page = {}
	
	for i in page_options:
		if(PAGE_OPTS.has(i)):
			new_page[i] = page_options.values()[iter]
		else:
			failed_keys += 1
		iter += 1
	
	if(!_write_page(new_page)):
		return -1
	return failed_keys

#func cluster_exists(id:Dictionary) -> bool:
#	return false

#func get_all_chapter_paths(find_chapter:int) -> Array:
#	return []

func get_book() -> Array:
	return pages

func get_bookmark() -> Vector2:
	return bookmark

func get_chapter(chap:int = bookmark.x):
	return pages[chap]

#func get_chapter_by_coords(coords:Vector2) -> int:
#	return 0

#func get_chapter_pos(chap = get_chapter()) -> int:	#Figure this shit out
#	return 0

#func get_chapter_index(chap:int = bookmark.x) -> Dictionary:
#	return {}

#func get_cluster(id:Dictionary) -> Array:    #Returns reference to the array under this particular id dictionary
#	return []

#func get_data(placeholder:String):
#	pass

func get_data_all():
	pass

#func get_page(page:Vector2 = bookmark) -> Dictionary:
#	return {}

func get_unique_chapter_nums() -> Array:
	return []

func get_unique_paths() -> Array:
	return []

func is_book_end() -> bool:
	return false

#TODO: Make functional with paths that don't reach the highest chapter number
func is_last_chapter() -> bool:
	return false

func is_last_page() -> bool:
	return false

#func jump_to_page(newPage:int):
#	pass

#func move_path(newBranch:int) -> bool:
#	return false

func next_chapter() -> bool:
	return false

func prev_chapter() -> bool:
	return false

#TODO: protect from out-of-bounds error
func reset(new_spot:Vector2 = Vector2(0,0)) -> int:
	return int(new_spot.x)

func save_book(FILENAME:String = "res://story.json") -> void:
	var f = File.new()
	var DATA = JSON.print(get_book(), " ")
	f.open(FILENAME, File.WRITE)
	f.store_string(DATA)
	f.close()

#func set_chapter(newChap:int) -> bool:
#	return false

func turn_page() -> bool:
	return false

func _update_branch_map():
	pass

#func _fill_in_placeholders(pageRef:Dictionary):
#	pass

func _write_page(new_page:Dictionary) -> bool:
	var pages_path = 0
	var coords = Vector2()
	if(new_page.has("path")):
		pages_path = new_page["path"]
		while pages.size() < pages_path+1:
			pages.append([])
	coords = Vector2(pages_path, new_page[INDEX_PROP])
	
	if occupied.has(coords):
		return false
	
	occupied.append(coords)
	pages[pages_path].append(new_page) 
	
	
	for i in pages:
		i.sort_custom(MyCustomSorter, "sort")
	occupied.sort()
	return true

static func _dict_compare(a:Dictionary, b:Dictionary) -> bool:
		if a.keys() == b.keys() and a.values() == b.values():
			return true
		return false

class MyCustomSorter:
	static func sort(small, big):
		if small[INDEX_PROP] < big[INDEX_PROP]:
			return true
		return false
	
