extends Node

const book = preload("res://scripts/story.gd")

var story = book.new()
onready var stage = get_node("Output")

func _ready():
	var options1 = {"image":"res://images/CreativeCommons/JustinNichol/Kain.png", "pause":2.0}
	var options2 = {"image":"res://images/CreativeCommons/JustinNichol/Alec.png", "background":"res://images/Environments/coldmountain.png", "sfx":"res://Audio/completetask_0.ogg"}
	var optionsMusic = {"music":"res://Audio/song18.ogg"}
	var choices = {0:"Pauses and character shifts", 1:"Background music"}
	
	#Establish chapters
	story.addChapter("VN Gin Test Run", 1)
	#Alternate paths need a separate "chapter" that shares a number but not a path
	story.addChapter("Diplomacy", 1, 1)
	
	#Write chapter 1
	story.addPage("Hi!\nWhat would you like me to demonstrate?\nWe're using branching storylines to give you these options", "Stewie", options2, choices)
	story.addPage("Dramatic pause!\nAnd a character shift", "", options1)    #Default path pages are written into the main chapter
	
	story.movePath(1)
	story.addPage("Enjoy the music, you can end the demo at any time by clicking \"end of chapter\"", "Stewie", optionsMusic)
	
	#Story must be reset to beginning and loaded to the VisCompManager
	story.reset()
	stage.loadStory(story)
	
	stage.showPage()