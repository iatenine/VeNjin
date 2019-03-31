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
	story.add_chapter("VN Gin Test Run", 1)
	#Alternate paths need a separate "chapter" that shares a number but not a path
	story.add_chapter("Diplomacy", 1, 1)
	
	#Write chapter 1
	story.add_page("Hi!\nWhat would you like me to demonstrate?\nWe're using branching storylines to give you these options", "Stewie", options2, choices)
	story.add_page("Dramatic pause!\nAnd a character shift", "", options1)    #Default path pages are written into the main chapter
	
	story.move_path(1)
	story.add_page("Enjoy the music, you can end the demo at any time by clicking \"end of chapter\"", "Stewie", optionsMusic)
	
	#Story must be reset to beginning and loaded to the VisCompManager
	story.reset()
	stage.load_story(story)
	
	stage.show_page()