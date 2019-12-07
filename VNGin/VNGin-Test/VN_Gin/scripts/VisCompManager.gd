extends Node

#VisCompManager.gd
#Intermediary class to connect story.gd data with visual components of a scene

#Dependencies: story.gd, Dialogue_Panel.tscn
#dPanel, character and background images must be specified in editor
#story data must be passed via load_story() function

export (float) var TITLE_TIME = 0
const book = preload("res://scripts/story.gd")

export (NodePath) var foreground_img
export (NodePath) var background_img
export (NodePath) var character_img
export (NodePath) var dPanel
export (NodePath) var animPlayer


var speechBox            #Box for displaying dialogue
var nameBox              #Shows speaking character's name
var next_Button
var options_Container    #HBox Container recommended

var story                #null reference until load_story() is called


#Audio streams
var bgmStream = AudioStreamPlayer.new()
var sfxStream = AudioStreamPlayer.new()

func _on_choice_pressed(selection):
	var key = selection.keys()[0]
	var value = selection.values()[0]
	
	if typeof(key) == TYPE_INT:
		if !story.move_path(key):
			print("E: Could not move story to path: ", selection)
	elif typeof(key) == TYPE_STRING:
		if story.get_data(key) != null:
			print("Warning: Overwriting previously written value: ", story.get_data(key))
		story.add_data(key, value)
	
	clear_inputs()
	_on_next_pressed()

func _on_next_pressed():
	if story != null:
		if (story.turn_page()):
			show_page()
		elif(story.next_chapter()):
			show_page()
		else:
			end_story()

func _ready():
	dPanel = get_node(str(dPanel) + "/NinePatchRect")
	foreground_img = get_node(foreground_img)
	background_img = get_node(background_img)
	character_img = get_node(character_img)
	speechBox = dPanel.get_node("TextLabel")
	nameBox = dPanel.get_node("NameLabel")
	next_Button = dPanel.get_node("NextButton")
	options_Container = dPanel.get_node("HBoxContainer")
	animPlayer = get_node(animPlayer)
	
	#Add children
	add_child(sfxStream)
	add_child(bgmStream)
	
	next_Button.connect("pressed", self, "_on_next_pressed")
	
	clear_boxes()

func add_button(var button):
	next_Button.hide();
	options_Container.add_child(button);

func clear_boxes():
	speechBox.set_text("");
	nameBox.set_text("");
	
	next_Button.hide();
	speechBox.hide()
	nameBox.hide()

func clear_inputs():
	for c in options_Container.get_children():
		c.queue_free();
	next_Button.show();

func end_story():
	get_tree().quit()

func fade_anim(target:String, backwards:bool = false):
	var animName
	
	match(target):
		"CHARACTER":
			animName = "character_fade_in"
		"BG":
			animName = "bg_fade_in"
		"FG":
			animName = "fg_fade_in"
		_:
			print("Animation target: " + target + " not valid")
	
	if !backwards:
		animPlayer.play(animName)
	else:
		animPlayer.play_backwards(animName)

func load_story(newBook):
	story = newBook

func option_handler(page, buffer:bool = false):
	var opts = page.options
	
	
	if opts.has("background"):
		var tex = load(page.options.background)
		set_background(tex)
	
	if !buffer:
		if opts.has("image"):
			var tex = load(page.options.image)
			set_image(tex)
		
		if opts.has("sfx") or opts.has("music"):
			play_page_sounds(page)
		
		if page.choices.size() != 0:
			for i in page.choices.size():
				var nButton = Button.new()
				nButton.text = page.choices.keys()[i]
				add_button(nButton)
				
				nButton.connect("pressed", self, "_on_choice_pressed", [{page.choices.values()[i]:page.choices.keys()[i]}])
		
			next_Button.hide()

func play_page_sounds(page):
	if page.options.keys().has("sfx"):
		var stream_sfx = load(page.options.sfx)
		stream_sfx.loop = false
		sfxStream.set_stream(stream_sfx)
		sfxStream.play()
	
	if page.options.keys().has("music"):
		var stream_bg = load(page.options.music)
		bgmStream.set_stream(stream_bg)
		bgmStream.play()

func set_background(var texture):
	background_img.set_texture(texture);

func set_image(var texture):
	character_img.set_texture(texture);

func set_name(var t):
	if(t == ""):
		nameBox.hide()
	else:
		nameBox.show()
		nameBox.set_text(t);

func set_text(var t):
	speechBox.set_text(t);
	speechBox.show()
	pass

func show_page(page:Dictionary = story.get_page()):
	var keys = page.keys()
	
	next_Button.show()
	if(story.is_last_page()):
		next_Button.text = "Next Chapter"
	if story.is_last_chapter() and story.is_last_page():
		next_Button.flat = true
		next_Button.text = "The End"
	
	#Pages
	if keys.has("speech"):
		set_name(page.speaker)
		set_text(page.speech)
		
		option_handler(page)
		
		if page.options.keys().has("pause"):
			next_Button.hide()
			yield(get_tree().create_timer(page.options.pause), "timeout")
			next_Button.show()
	
	#Chapter Changes
	elif keys.has("number"):
		dPanel.hide()
		foreground_img.show()
		if page.number != 0:
			foreground_img.set_Title("Chapter " + str(page.number) + "\n" +page.name)
		else:
			foreground_img.set_Title("Prologue\n" +page.name)
		#Fade-in
		fade_anim("FG")
		yield(animPlayer, "animation_finished")
		
		#Preload background for next page
		var nextPage = story.get_page(story.get_bookmark() + Vector2(0, 1))
		if nextPage != null:
			option_handler(nextPage, true)
		
		#Pause + fade-out
		yield(get_tree().create_timer(TITLE_TIME), "timeout")
		fade_anim("FG", true)
		yield(animPlayer, "animation_finished")
		
		#Ensure content continues flowing
		dPanel.show()
		foreground_img.hide()
		_on_next_pressed()
	else:
		pass