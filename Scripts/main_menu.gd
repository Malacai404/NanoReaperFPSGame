extends Control


var credits = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Input.mouse_mode= Input.MOUSE_MODE_VISIBLE
	if(credits == true):
		$credits.visible = true
	else:
		$credits.visible = false


func _on_tutorial_button_pressed():
	if(credits == false):
		LoadManager.load_scene("res://Scenes/tutorial.tscn")


func _on_endless_button_pressed():
	if(credits == false):
		LoadManager.load_scene("res://Scenes/world.tscn")


func _on_credits_button_pressed():
	credits = true


func _on_credits_close_button_pressed():
	credits = false


func _on_quit_pressed():
	get_tree().quit()
