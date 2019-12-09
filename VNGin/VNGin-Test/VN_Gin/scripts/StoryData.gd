extends Node

const book = preload("res://scripts/story.gd")

var story = book.new()
onready var stage = get_node("Output")

func _ready():
	var player = {"image":"%PLAYER_IMG%", "name":"%PLAYER_NAME%"}
	var landon = {"image":"CreativeCommons/JustinNichol/Jordan", "name":"Landon"}
	var hellen = {"image":"CreativeCommons/JustinNichol/Leslie", "name":"Hellen"}
	var hellen_thinking = hellen.duplicate()
	hellen_thinking["pause"] = 1.9
	var port_town = {"background":"CreativeCommons/JAP/fortress", "image":"CreativeCommons/JustinNichol/Jordan", "name":"Landon"}
	
	var mystery = {"pause":1}
	var ezekiel = {"image":"CreativeCommons/JustinNichol/Linksvayer", "name":"Ezekiel"}
	#var optionsMusic = {"music":"song18"}
	
	#Player choices must have keys and values inversed to avoid key collisions
	var player_choice = {"Hellen":"player_name", "Landon":"player_name"}
	var path_choice = {"Crushing Poverty": 0, "Oppressive Upper-Class":1}
	
	story.add_cluster({"player_name":"Hellen"})
	story.add_cluster({"player_name":"Landon"})
	story.add_to_cluster({"player_name":"Landon"}, [{"player_img":"CreativeCommons/JustinNichol/Jordan"}, {"test_str":"This"}])
	story.add_to_cluster({"player_name":"Hellen"}, [{"player_img":"CreativeCommons/JustinNichol/Leslie"}, {"test_str":"That"}])
	
	#Establish chapters
	story.add_chapter("Lady on the Water", 0)
	story.add_chapter("Lady on the Water", 0, 1)
	
	#Write prologue
	
	story.add_page("Finally! \nAll we need to do now is cross the channel and we're free", port_town)
	
	story.add_page("Not exactly the easiest final step, is it?", hellen)
	
	story.add_page("Relax \nIt's a port town \nWe just need to find somebody with a boat looking for some work", landon)
	
	story.add_page("First of all, I'm the only one with any money here! \nAnd second, sailors are notoriously superstitious!", hellen)
	
	story.add_page("Was your whole plan to just use me to flip the bill on your travel expenses?", hellen)
	
	story.add_page("I..", landon)
	
	story.add_page("Maybe I didn't have a plan, alright?...", landon)
	
	story.add_page("But we both have reasons we can't turn back... \nWhat else can we do but try?", landon)
	
	story.add_page("Ahoy, there!", mystery)
	
	story.add_page("Couldn't help but overhear your dilemma", ezekiel)
	
	story.add_page("I don't like the vibe of this guy, Landon", hellen)
	
	story.add_page("The name's Ezekiel, friend \nand for the right price... \nI may be willing to risk provoking the Lord himself by harboring a member of the fairer sex aboard my vessel", ezekiel)
	
	story.add_page("Hellen, this is exactly what we need! \nYou said it yourself this is a superstitious lot", landon)
	
	story.add_page("Yes, but I don't want to be alone with that guy \nHe freaks me out", hellen)
	
	story.add_page("OK, then we'll drop you off first", landon)
	
	story.add_page("You'll never have to see me again  \nand I'll have earned my fare", landon)
	
	story.add_page("...", hellen_thinking)
	
	story.add_page("Fine...", hellen)
	
	story.add_page("Mr. Ezekiel, \nyou have yourself a deal", landon)
	
	story.add_page("Happy to help", ezekiel)
	
	story.add_page("Who would you like to be?", {}, player_choice)
	
	story.add_page("What are you fleeing?", {}, path_choice)
	
	#Story paths diverge the moment the player chooses them so final pages must be duplicated
	story.add_page("More content coming soon, %PLAYER_NAME% %TEST_STR%", player)
	story.move_path(1)
	story.add_page("More content coming soon, %PLAYER_NAME% %TEST_STR%", player)
	#story.add_chapter("New Dawn", 2, 0)
	
	#Story must be reset to beginning and loaded to the VisCompManager
	story.reset()
	stage.load_story(story)
	
	stage.show_page()