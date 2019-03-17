extends Node

const book = preload("res://scripts/story.gd")

var story = book.new()
onready var stage = get_node("Output")

func _ready():
	#stage = stage.get_script()
	print(stage)
	var options1 = {"background":"res://images/forest_road.jpg", "decisionTime":5, "sfx":"res://Audio/completetask_0.ogg"}
	var options2 = {"image":"res://images/clara/clara.png", "background":"res://images/Dense-winter-forest.jpg", "pauseTime":1, "sfx":"res://Audio/completetask_0.ogg"}
	var choices = {1:"Stay", 2:"Go"}
	
	story.addChapter("The Start", 1)
	story.addChapter("The Middle", 2, 0)
	story.addChapter("The End", 0)
	
	story.addPage("Some Text", "speaker", options1)
	story.addPage("*CRASH!!*")
	
	story.nextChapter()
	story.addPage("Hi, my name is Steven!", "Steven", options2, choices)
	
	story.nextChapter()
	story.addPage("This is where it all ends", "Ominous Voice")
	
	story.reset()
	stage.loadStory(story)