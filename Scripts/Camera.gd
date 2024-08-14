extends Camera3D

@export var period = 0.3
@export var magnitude = 0.4

func _camera_shake():
	var initial_transform = self.transform 
	var elapsed_time = 0.0
	while elapsed_time < period:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)

		self.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	self.transform = initial_transform
