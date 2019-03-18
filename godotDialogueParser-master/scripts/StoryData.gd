extends Node

const book = preload("res://scripts/story.gd")

var story = book.new()
onready var stage = get_node("Output")

func _ready():
	#var options1 = {"background":"res://images/Environments/wizardtower.png", "decisionTime":5, "music":"res://Audio/song18.ogg"}
	#var options2 = {"image":"res://images/clara/clara.png", "background":"res://images/Environments/coldmountain.png", "pauseTime":1, "sfx":"res://Audio/completetask_0.ogg"}
	#var choices = {1:"Stay", 2:"Go"}
	
	#Establish chapters
	story.addChapter("The Start", 1)
	story.addChapter("The Middle", 2, 0)
	story.addChapter("The End", 3)
	
	#Write chapter 1
	story.addPage("Some Text", "speaker")
	story.addPage("*CRASH!!*")
	
	#Write chapter 2
	story.nextChapter()
	story.addPage("Hi, my name is Steven!", "Steven")
	
	#Write chapter 3
	story.nextChapter()
	story.addPage("This is where it all ends", "Ominous Voice")
	story.nextChapter()
	
	#Story must be reset to beginning and loaded to the VisCompManager
	story.reset()
	stage.loadStory(story)
	
	stage.showPage()