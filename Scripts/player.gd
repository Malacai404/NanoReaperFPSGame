extends CharacterBody3D

class_name player

# SECRET variables
var previousinputs = []
var konamicode = ["Up", "Up", "Up", "Up", "Down", "Down", "Down", "Down", "Left", "Left", "Right", "Right", "Left", "Left", "Right", "Right", "B", "B", "A", "A"]
var goofy_menu = false
@onready var goofy_menu_object = $HUD/HUD_SECRET_Goofy
#HUD variables
var dead = false
var nano_regen_rate = 1
var regen_time = 0.5
var regen_time_base = regen_time
var nanobot_regen_per_second = nano_regen_rate / regen_time
var nanobot_count = 150
var void_energy_value = 200
@onready var hud = $HUD
@onready var nanobot_slider = $HUD/HUD_NanobotSlider
@onready var void_energy_slider = $HUD/HUD_VOIDEnergySlider
@onready var nanobot_regen_rate_counter = $HUD/HUD_NanobotSlider/HUD_NanobotRegenRate
@onready var nanobot_counter = $HUD/HUD_NanobotSlider/HUD_NanobotCount
@onready var void_energy_counter = $HUD/HUD_VOIDEnergySlider/HUD_VOIDEnergyCount

# Shooting Variables

@onready var aim_ray = $HEAD_Player/AimRay
var bullet_trail = load("res://Prefabs/bullet_trail.tscn")
var instance
@onready var bullet_spawn = $HEAD_Player/Revolver/Bullet_Spawn
@onready var aim_ray_end = $HEAD_Player/AimRayEnd


#movement variables
var gravity = 15
var speed = 8
var jump_speed = 7
var mouse_sensitivity = 0.002
var acceleration = 0.2
var deceleration: float = 0.2
var air_deceleration_multiplier = 0.4
var air_acceleration_multiplier = 0.4

#camera variables

@export var tilt = true
@onready var camera = $HEAD_Player/CAMERA_Player
@onready var shake_fix = $HEAD_Player/ShakeFix
var initial_rotation : Vector3
var fov_max = 75
var base_fov = 75
var fov
var camera_fov_shift_speed = 25


#sliding variables
@export var BOINGACTIVE = false
var BOING = 1
var is_sliding = false
var slide_cost = 1
var slide_cost_time = 0.5
var slide_cost_time_base = slide_cost_time
var slide_force = 13
var slide_length = 15
var slide_length_save = slide_length
var slide_start_state

#dashing variables
var dash_cost = 15
var is_dashing = false
var dash_delay = 0.5
var dash_delay_save = dash_delay
var dash_length = 0.1
var dash_length_save = dash_length
var dash_force = 30

func _start_bounce():
	_bounce(slide_start_state)

func _bounce(slide_state):
	velocity = -slide_state
func _input(ev):
	if ev is InputEventKey:
		previousinputs.append(ev.as_text_keycode())
		if(len(previousinputs) > 20):
			previousinputs.remove_at(0)
func _ready():
	initial_rotation = camera.rotation_degrees
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	fov = base_fov
	
func _reload_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	
func _shoot():
	camera._camera_shake()
	instance = bullet_trail.instantiate()
	if aim_ray.is_colliding():
		instance.init(bullet_spawn.global_position, aim_ray.get_collision_point())
		if( aim_ray.get_collider() is enemy):
			aim_ray.get_collider()._take_damage(1)
	else:
		instance.init(bullet_spawn.global_position, aim_ray_end.global_position)
	get_parent().add_child(instance)
	
func _death():
	get_tree().paused = true
	dead = true
	
#camera follow logic
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$HEAD_Player.rotate_x(-event.relative.y * mouse_sensitivity)
		$HEAD_Player.rotation.x = clampf($HEAD_Player.rotation.x, -deg_to_rad(75), deg_to_rad(45))
		
func _physics_process(delta):
	if(dead == true):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	velocity.y += -gravity * delta
	var input = Input.get_vector("left", "right", "forward", "back")
	
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	#movement code (DO NOT TOUCH)
	if(is_on_floor()):
		if(input != Vector2.ZERO and is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, acceleration)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, acceleration)
		elif(is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, deceleration)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, deceleration)
	else:
		if(input != Vector2.ZERO and is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, acceleration * air_acceleration_multiplier)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, acceleration * air_acceleration_multiplier)
		elif(is_dashing == false and is_sliding == false):
			velocity.x = lerp(velocity.x, movement_dir.x * speed, deceleration * air_deceleration_multiplier)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, deceleration * air_deceleration_multiplier)
	
	if(is_on_wall() and is_sliding == true or is_on_wall() and is_dashing == true):
		is_sliding = false
		if(BOINGACTIVE == true):
			velocity = -slide_start_state * BOING
			

	# Jump process
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
		is_sliding = false
		
	# Tilt process
	if(tilt == true):
		if(input.x < 0):
			$HEAD_Player/CAMERA_Player.rotation_degrees.z = lerp($HEAD_Player/CAMERA_Player.rotation_degrees.z, 2.0, 0.2)
		elif(input.x > 0):
			$HEAD_Player/CAMERA_Player.rotation_degrees.z = lerp($HEAD_Player/CAMERA_Player.rotation_degrees.z, -2.0, 0.2)
		else:
			$HEAD_Player/CAMERA_Player.rotation_degrees.z = lerp($HEAD_Player/CAMERA_Player.rotation_degrees.z, 0.0, 0.2)

			
	# Slide Process
	
	if(is_sliding == true and slide_length > 0):
		if(slide_cost_time > 0):
			slide_cost_time -= delta
		else:
			nanobot_count -= slide_cost
			slide_cost_time = slide_cost_time_base
		fov = fov_max
		$HEAD_Player.position.y = lerp($HEAD_Player.position.y, -0.2, 0.1)
		slide_length -= delta
		velocity.x = slide_start_state.x
		velocity.z = slide_start_state.z
	
	if(is_sliding == false):
		$HEAD_Player.position.y = lerp($HEAD_Player.position.y, 0.56, 0.1)
		
		
	
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	
	if(slide_length <= 0):
		is_sliding = false
		
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
		
	# Dash Process
	
	if(dash_delay >= 0 and is_dashing == false):
		dash_delay -= delta
		
	if(dash_length >= 0):
		dash_length -= delta
		is_dashing = true
	else:
		is_dashing = false
	
	if Input.is_action_just_pressed("dash") and dash_length <= 0 and dash_delay <= 0 and is_sliding == false:
		if(void_energy_value >= 0+ dash_cost):
			void_energy_value -= dash_cost
		else:
			return
		slide_start_state = transform.basis * Vector3(0, 0, -1) * dash_force
		if(input != Vector2.ZERO):
			velocity += transform.basis * Vector3(input.x, 0, input.y) * dash_force
			dash_length = dash_length_save
			dash_delay = dash_delay_save
		else:
			velocity += transform.basis * Vector3(0, 0, -1) * dash_force
			dash_length = dash_length_save
			dash_delay = dash_delay_save
	move_and_slide()

func _process(delta):
	
	# Secret processes
	if(previousinputs == konamicode):
		goofy_menu = true
	if(goofy_menu == true):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		goofy_menu_object.visible = true
	else:
		goofy_menu_object.visible = false
	# Hud processes
	void_energy_counter.text = str("Dark Energy:", void_energy_value)
	nanobot_regen_rate_counter.text = str(nanobot_regen_per_second, "/S")
	nanobot_counter.text = str("Nanobots: ", nanobot_count)
	nanobot_slider.value = nanobot_count
	void_energy_slider.value = void_energy_value
	if(dead == true):
		$HUD/Death_Screen.visible = true
	
	# Value processes
	if(nanobot_count <= 0):
		_death()
	
	if(regen_time > 0):
		regen_time -= delta
	else:
		nanobot_count += nano_regen_rate
		regen_time = regen_time_base
	

	if Input.is_action_just_pressed("quick_exit"):
		get_tree().quit()

