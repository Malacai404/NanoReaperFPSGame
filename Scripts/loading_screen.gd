extends CanvasLayer

signal loading_screen_has_full_coverage

var tooltiptimer = 0
var tooltiptimer_save = 5.0

var tooltips: Array = ["Theres a bomb at 36.4057° S, 174.6568° E (THIS IS A JOKE)", "He is coming", "Press W to move forward", "Play Horse Plinko Tycoon", "The European Aspen Tree is Kai's Favourite Tree", "Its like saying a violinist plays the viola", "Literally 1984"]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar : ProgressBar = $Panel/ProgressBar

func _tooltip_reset():
	$Panel/Label.text = tooltips.pick_random()

func _process(delta):
	tooltiptimer -= delta
	if(tooltiptimer <= 0):
		var text = str("Tip: ",tooltips.pick_random())
		$Panel/Label.text = text
		tooltiptimer = tooltiptimer_save

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)
func _start_outro_animation() -> void:
	animation_player.play("end_load")
	await Signal(animation_player, "animation_finished")
	self.queue_free()
