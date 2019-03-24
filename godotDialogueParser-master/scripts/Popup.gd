extends Popup

export (bool) var fatal = true setget setFatal, getFatal
export (String) var msg = "Error" setget setE, getE

func _ready():
	setE(msg)
	setFatal(fatal)

func setFatal(fate):
	fatal = fate

func getFatal():
	return fatal

func setE(e):
	msg = e
	$Body.text = msg

func getE():
	return msg

func _on_Button_pressed():
	if fatal:
		get_tree().quit()
	else:
		hide()
