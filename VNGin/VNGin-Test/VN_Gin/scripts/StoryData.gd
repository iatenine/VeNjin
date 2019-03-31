extends Node

const book = preload("res://scripts/story.gd")

var story = book.new()
onready var stage = get_node("Output")

func _ready():
	var options1 = {"image":"CreativeCommons/JustinNichol/Kain", "pause":2.0}
	var options2 = {"image":"CreativeCommons/JustinNichol/Alec", "background":"CC0/Environments/coldmountain", "sfx":"completetask_0"}
	var optionsMusic = {"music":"song18"}
	var choices = {0:"Pauses and character shifts", 1:"Background music"}
	
	#Establish chapters
	story.add_chapter("VN Gin Test Run", 1) #Last chapter - 0
	story.add_chapter("Diplomacy", 2, 30)
	story.add_chapter("Difference", 4, 30) #Not last chapter - 2
	story.add_chapter("Diplomacy", 6, 28) #Last chapter - 3
	story.add_chapter("Diplomacy", 6, 30)
	
	#Write chapter 1
	story.add_page("Hi!\nWhat would you like me to demonstrate?\nWe're using branching storylines to give you these options", "Stewie", options2, choices)
	story.add_page("Dramatic pause!\nAnd a character shift", "", options1)    #Default path pages are written into the main chapter
	
	story.move_path(1)
	story.add_page("Enjoy the music, you can end the demo at any time by clicking \"end of chapter\"", "Stewie", optionsMusic)
	
	# True, False, True, True
	story.set_chapter(0)
	print(story.is_last_chapter())
	story.set_chapter(2)
	print(story.is_last_chapter())
	story.set_chapter(3)
	print(story.is_last_chapter())
	story.set_chapter(4)
	print(story.is_last_chapter())
	
	#Story must be reset to beginning and loaded to the VisCompManager	
	story.reset()
	stage.load_story(story)
	
	stage.show_page()