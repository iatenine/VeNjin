extends Node

const book = preload("res://scripts/story.gd")

var story = book.new()
onready var stage = get_node("Output")

func _ready():
	var options1 = {"image":"res://images/clara/clara_hit.png"}
	var options2 = {"image":"res://images/clara/clara.png", "background":"res://images/Environments/coldmountain.png", "sfx":"res://Audio/completetask_0.ogg"}
	var choices = {0:"Attack", 1:"Greet"}
	
	#Establish chapters
	story.addChapter("A Demon Appears", 1)
	#Alternate paths need a separate "chapter" that shares a number but not a path
	story.addChapter("Diplomacy", 1, 1)
	
	#Write chapter 1
	story.addPage("Hi! I'm Clara!", "Clara", options2, choices)
	story.addPage("Attack Noise!", "", options1)    #Default path pages are written into the main chapter
	
	story.movePath(1)
	story.addPage("Hi, my name is Steven!", "Steven", options2)
	
	#Story must be reset to beginning and loaded to the VisCompManager
	story.reset()
	stage.loadStory(story)
	
	stage.showPage()