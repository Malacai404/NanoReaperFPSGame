extends CharacterBody3D

#movement variables
var gravity = 15
var speed = 8
var jump_speed = 7
var mouse_sensitivity = 0.002
var acceleration = 0.2
var deceleration: float = 0.2




#sliding variables
var BOING = 0.1
var is_sliding = false
var slide_force = 10
var slide_length = 15
var slide_length_save = slide_length
var slide_start_state

#dashing variables
var is_dashing = false
var dash_delay = 0.5
var dash_delay_save = dash_delay
var dash_length = 0.1
var dash_length_save = dash_length
var dash_force = 30


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
#camera follow logic
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$HEAD_Player.rotate_x(-event.relative.y * mouse_sensitivity)
		$HEAD_Player.rotation.x = clampf($HEAD_Player.rotation.x, -deg_to_rad(75), deg_to_rad(45))
		
func _physics_process(delta):
	velocity.y += -gravity * delta
	var input = Input.get_vector("left", "right", "forward", "back")
	
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	#checks for input
	if(is_on_floor()):
		if(input != Vector2.ZERO and is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, acceleration)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, acceleration)
		elif(is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, deceleration)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, deceleration)
	else:
		if(input != Vector2.ZERO and is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, acceleration - 0.1)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, acceleration - 0.1)
		elif(is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, deceleration - 0.1)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, deceleration - 0.1)
	
	move_and_slide()
	if(is_on_wall() and is_sliding == true):
		is_sliding = false
	if(is_sliding == true and slide_length > 0):
		$HEAD_Player.position.y = lerp($HEAD_Player.position.y, -0.2, 0.1)
		slide_length -= delta
		velocity.x = slide_start_state.x
		velocity.z = slide_start_state.z
	if(is_sliding == false):
		$HEAD_Player.position.y = lerp($HEAD_Player.position.y, 0.56, 0.1)
	if(slide_length <= 0):
		
		is_sliding = false
	if(dash_delay >= 0 and is_dashing == false):
		dash_delay -= delta
	if(dash_length >= 0):
		dash_length -= delta
		is_dashing = true
	else:
		is_dashing = false
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
		is_sliding = false
		
	if(input.x < 0):
		$HEAD_Player/CAMERA_Player.rotation_degrees.z = lerp($HEAD_Player/CAMERA_Player.rotation_degrees.z, 2.0, 0.2)
	elif(input.x > 0):
		$HEAD_Player/CAMERA_Player.rotation_degrees.z = lerp($HEAD_Player/CAMERA_Player.rotation_degrees.z, -2.0, 0.2)
	else:
		$HEAD_Player/CAMERA_Player.rotation_degrees.z = lerp($HEAD_Player/CAMERA_Player.rotation_degrees.z, 0.0, 0.2)
	if Input.is_action_just_pressed("slide"):
		if(input != Vector2.ZERO):
			slide_start_state = transform.basis * Vector3(input.x, 0, input.y) * slide_force
		else:
			slide_start_state = transform.basis * Vector3(0, 0, -1) * slide_force
		if is_on_floor() and is_sliding == false:
			is_sliding = true
			slide_length = slide_length_save
	if Input.is_action_just_released("slide"):
		is_sliding = false
	if Input.is_action_just_pressed("dash") and dash_length <= 0 and dash_delay <= 0:
		if(input != Vector2.ZERO):
			velocity += transform.basis * Vector3(input.x, 0, input.y) * dash_force
			dash_length = dash_length_save
			dash_delay = dash_delay_save
		else:
			velocity += transform.basis * Vector3(0, 0, -1) * dash_force
			dash_length = dash_length_save
			dash_delay = dash_delay_save

func _process(delta):
	if Input.is_action_just_pressed("quick_exit"):
		get_tree().quit()
	
