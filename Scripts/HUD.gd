extends Control

@onready var crosshair = $Crosshair
var hit_cross_time = 0.15
var hit_cross_time_save = hit_cross_time
var hit_cross = preload("res://Sprites/Prototype Textures/crosshairhit.png")
var cross = preload("res://Sprites/Prototype Textures/crosshair.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_cross_time = 0

func _on_hit():
	hit_cross_time = hit_cross_time_save

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(hit_cross_time > 0):
		crosshair.texture = hit_cross
		hit_cross_time -= delta
	else:
		crosshair.texture = cross
