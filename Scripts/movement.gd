extends CharacterBody3D

#movement variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 8
var jump_speed = 5
var mouse_sensitivity = 0.002
var acceleration = 0.2
var deceleration: float = 0.2




#sliding variables
var BOING = 1
var is_sliding = false
var slide_length = 5
var slide_length_save = slide_length
var slide_start_state

#dashing variables
var is_dashing = false
var dash_delay = 0.3
var dash_delay_save = dash_delay
var dash_length = 0.2
var dash_length_save = dash_length
var dash_force = 20


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
			velocity.x = lerp(velocity.x, movement_dir.x * speed, acceleration * 1.1)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, acceleration * 1.1)
		elif(is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, deceleration / 3)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, deceleration /3)
	
	move_and_slide()
	if(is_on_wall() and is_sliding == true):
		$AUDIO_Player.play()
		is_sliding = false
		velocity = -slide_start_state * BOING
	if(is_sliding == true and slide_length > 0):
		
		slide_length -= delta
		velocity = slide_start_state
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
	if  Input.is_action_just_pressed("slide"):
		if is_on_floor() and is_sliding == false:
			if(input != Vector2.ZERO):
				slide_start_state = transform.basis * Vector3(input.x, 0, input.y) * dash_force
			else:
				slide_start_state = transform.basis * Vector3(0, 0, -1) * dash_force
			is_sliding = true
			slide_length = slide_length_save
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
	
