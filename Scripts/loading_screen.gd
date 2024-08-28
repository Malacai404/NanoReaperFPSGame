extends CanvasLayer

signal loading_screen_has_full_coverage

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar : ProgressBar = $Panel/ProgressBar

func _update_progress_bar(new_value: float) -> void:
	progress_bar.set_value_no_signal(new_value * 100)
func _start_outro_animation() -> void:
	self.queue_free()
