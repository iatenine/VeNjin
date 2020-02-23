extends Node2D

const book = preload("res://scripts/story.gd")

var story = book.new()

var page = {"page_num":1, "speech":"Hello", "profile":0, 
"Wakeekee": false, "choices": {"Here": 0, "There": 1}}
var page2 = {"page_num":1, "path": 1, "speech": "Hi, there!"}
var page3 = {"page_num":2, "profile":"default"}
var format = {"path": 0, 
"chap_num": 2, 
"page_num": 5, 
"chap_name": "Hello!", 
"speech": "Hi, there!", 
"choices": {"Mustard":0, "Ketchup":1},
"name": "Stephen", 
"image": "CreativeCommons/JustinNichol/Jordan", 
"music": "Licensed/FunkyColdMedina", 
"sfx": "Crash", 
"background": "classical/Oh, Fortuna", 
"pause": 0.0}

func _ready():
	story.add_page(page3)
	story.add_page(page2)
	story.add_page(page)
	story.add_page(format)
	
	story.save_book()


