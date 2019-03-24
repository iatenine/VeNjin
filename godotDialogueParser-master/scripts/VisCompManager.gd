extends Node

#VisCompManager.gd
#Intermediary class to connect story.gd data with visual components of a scene

#Dependencies: story.gd, Dialogue_Panel.tscn
#dPanel, character and background images must be specified in editor
#story data must be passed via loadStory() function

const book = preload("res://scripts/story.gd")

export (NodePath) var background_img
export (NodePath) var character_img
export (NodePath) var dPanel


var speechBox            #Box for displaying dialogue
var nameBox              #Shows speaking character's name
var next_Button
var options_Container    #HBox Container recommended

var story                #null reference until loadStory() is called

#Audio streams
var bgmStream = AudioStreamPlayer.new()
var sfxStream = AudioStreamPlayer.new()

#Timers
var decisionTimer = Timer.new()
var pauseTimer = Timer.new()

func _ready():
	dPanel = get_node(str(dPanel) + "/NinePatchRect")
	background_img = get_node(background_img)
	character_img = get_node(character_img)
	speechBox = dPanel.get_node("TextLabel")
	nameBox = dPanel.get_node("NameLabel")
	next_Button = dPanel.get_node("NextButton")
	options_Container = dPanel.get_node("HBoxContainer")
	
	#Add children
	add_child(sfxStream)
	add_child(decisionTimer)
	add_child(pauseTimer)
	add_child(bgmStream)
	pauseTimer.one_shot = true
	decisionTimer.one_shot = true
	
	next_Button.connect("pressed", self, "_on_next_pressed")
	
	pauseTimer.connect("timeout", self, "_on_pause_timeout")
	decisionTimer.connect("timeout", self, "_on_decision_timeout")
	
	clearBoxes()

func loadStory(newBook):
	story = newBook

func showPage(page:Dictionary = story.getPage()):
	var keys = page.keys()
	
	next_Button.show()
	if(story.isBookEnd()):
		next_Button.text = "The End"
	
	#Pages
	if keys.has("speech"):
		set_name(page.speaker)
		set_text(page.speech)
		optionHandler(page)
	
	#Chapter Changes
	elif keys.has("number"):
		set_name("Chapter " + str(page.number))
		set_text(page.name)
	else:
		pass

func optionHandler(page):
	var opts = page.options
	
	if opts.has("background"):
		var tex = load(page.options.background)
		set_background(tex)
	
	if opts.has("image"):
		var tex = load(page.options.image)
		set_image(tex)
	
	if opts.has("sfx") or opts.has("music"):
		playPageSounds(page)
	
	if opts.has("pauseTime") or opts.has("decisionTime"):
		handlePageTimers(page)
	
	if page.choices.size() != 0:
		for i in page.choices.size():
			var nButton = Button.new()
			nButton.text = page.choices.values()[i]
			add_button(nButton)
			
			nButton.connect("pressed", self, "_on_choice_pressed", [page.choices.keys()[i]])
		
		next_Button.hide()

func handlePageTimers(page):
	if page.options.keys().has("pauseTime"):
		var pTime = page.options.pauseTime
		pauseTimer.set_wait_time(pTime)
		pauseTimer.start()
		next_Button.hide()
	
	if page.options.keys().has("decisionTime"):
		var pTime = page.options.decisionTime
		decisionTimer.set_wait_time(pTime)
		decisionTimer.start()

func playPageSounds(page):
	if page.options.keys().has("sfx"):
		var stream_sfx = load(page.options.sfx)
		stream_sfx.loop = false
		sfxStream.set_stream(stream_sfx)
		sfxStream.play()
	
	if page.options.keys().has("music"):
		var stream_bg = load(page.options.music)
		bgmStream.set_stream(stream_bg)
		bgmStream.play()


func _on_decision_timeout():
	#TODO
	pass

func _on_pause_timeout():
	#TODO
		pass

func open():
	next_Button.show();
	
func set_text(var t):
	speechBox.set_text(t);
	speechBox.show()
	pass
	
func set_name(var t):
	if(t == ""):
		nameBox.hide()
	else:
		nameBox.show()
		nameBox.set_text(t);

func clearBoxes():
	speechBox.set_text("");
	nameBox.set_text("");
	
	next_Button.hide();
	speechBox.hide()
	nameBox.hide()

func add_button(var button):
	next_Button.hide();
	options_Container.add_child(button);
	
func add_input(var input):
	options_Container.add_child(input);
	
func clear_inputs():
	for c in options_Container.get_children():
		c.queue_free();
	next_Button.show();
	
func set_background(var texture):
	background_img.set_texture(texture);
	
func set_image(var texture):
	character_img.set_texture(texture);

func _on_next_pressed():
	if story != null:
		if (story.turnPage()):
			showPage()
		elif(story.nextChapter()):
			showPage()
		else:
			endStory()

func _on_choice_pressed(selection):
	if story.movePath(selection):
		clear_inputs()
		_on_next_pressed()

func endStory():
	get_tree().quit()