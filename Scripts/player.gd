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
var core_blast_prefab = preload("res://Prefabs/core_blast.tscn")

@onready var hud = $HUD
@onready var nanobot_slider = $HUD/HUD_NanobotSlider
@onready var void_energy_slider = $HUD/HUD_VOIDEnergySlider
@onready var nanobot_regen_rate_counter = $HUD/HUD_NanobotSlider/HUD_NanobotRegenRate
@onready var nanobot_counter = $HUD/HUD_NanobotSlider/HUD_NanobotCount
@onready var void_energy_counter = $HUD/HUD_VOIDEnergySlider/HUD_VOIDEnergyCount

# Shooting Variables
var damage = 1
var headshot_multi = 5
var hit_point = load("res://hit_point.tscn")
@onready var aim_ray = $HEAD_Player/AimRay
var bullet_trail = load("res://Prefabs/bullet_trail.tscn")
var instance
@onready var bullet_spawn = $HEAD_Player/WeaponHolder/Revolver/Bullet_spawn
@onready var aim_ray_end = $HEAD_Player/AimRayEnd


#movement variables
var input
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
@onready var camera = $HEAD_Player/RECOIL_HEAD_Player/CAMERA_Player
@onready var head = $HEAD_Player
@export var cam_speed : float = 0.001
@export var cam_rotation_amount : float = 1
var mouse_input : Vector2
@onready var weapon_holder = $HEAD_Player/WeaponHolder
@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1
@onready var def_weapon_holder_pos = weapon_holder.position
 
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
func _input(event):
	if camera: 
		if(event is InputEventMouseMotion):
			head.rotation.x -= event.relative.y * cam_speed
			head.rotation.x = clamp(head.rotation.x,-1.25,1.5)
			rotation.y -= event.relative.x * cam_speed
			mouse_input = event.relative
	if event is InputEventKey:
		previousinputs.append(event.as_text_keycode())
		if(len(previousinputs) > 20):
			previousinputs.remove_at(0)
func _ready():
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _reload_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	
func _shoot():
	if($HEAD_Player/WeaponHolder/Revolver/Sketchfab_model/AnimationPlayer.is_playing()):
		return
	$HEAD_Player/WeaponHolder/Revolver/Sketchfab_model/AnimationPlayer.play("shoot")
	camera._camera_shake()
	instance = bullet_trail.instantiate()
	instance.player_object = self
	if aim_ray.is_colliding():
		instance.init(bullet_spawn.global_position, aim_ray.get_collision_point())
		if( aim_ray.get_collider() is enemy):
			var collider = aim_ray.get_collider()
			var i = aim_ray.get_collider_shape()
			var hit_node = collider.shape_owner_get_owner(i)
			if(hit_node.name == "HeadCollider"):
				aim_ray.get_collider()._take_damage(damage * headshot_multi)
			else:
				aim_ray.get_collider()._take_damage(damage)
	else:
		instance.init(bullet_spawn.global_position, aim_ray_end.global_position)
	get_parent().add_child(instance)
	instance.rotation_degrees.y = rotation_degrees.y
	instance.rotation_degrees.z = head.rotation_degrees.z
	instance.rotation_degrees.x = head.rotation_degrees.x
	instance.global_position = bullet_spawn.global_position
	
func _death():
	get_tree().paused = true
	dead = true
	
func _physics_process(delta):
	if(dead == true):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
		
		
		
	velocity.y += -gravity * delta
	input = Input.get_vector("left", "right", "forward", "back")
	_weapon_tilt(delta)
	_cam_tilt(delta)
	_weapon_sway(delta)
	_weapon_bob(velocity.length(), delta)
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
			camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 2.0, 0.2)
		elif(input.x > 0):
			camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, -2.0, 0.2)
		else:
			camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 0.0, 0.2)

			
	# Slide Process
	
	if(is_sliding == true and slide_length > 0):
		if(slide_cost_time > 0):
			slide_cost_time -= delta
		else:
			nanobot_count -= slide_cost
			slide_cost_time = slide_cost_time_base
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
	void_energy_counter.text = str("Void Energy:", void_energy_value)
	nanobot_regen_rate_counter.text = str(nanobot_regen_per_second, "/S")
	nanobot_counter.text = str("Nanobots: ", nanobot_count)
	nanobot_slider.value = nanobot_count
	void_energy_slider.value = void_energy_value
	if(dead == true):
		$HUD/Death_Screen.visible = true
	
	# Value processes
	if(nanobot_count <= 0):
		_death()
	

	if Input.is_action_just_pressed("quick_exit"):
		get_tree().quit()

func _return_direction(loc: Vector3):
	return position.direction_to(loc)

func _cam_tilt(delta):
	if head:
		head.rotation.z = lerp(head.rotation.z, -input.x * cam_rotation_amount, 10 * delta)
func _weapon_tilt(delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input.x * weapon_rotation_amount, 10 * delta)

func _weapon_sway(delta):
	mouse_input = lerp(mouse_input, Vector2.ZERO, 10 * delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_sway_amount, 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_sway_amount, 10 * delta)

func _weapon_bob(vel: float, delta):
	if weapon_holder:
		if vel > 0.4:
			var bob_amount: float = 0.01
			var bob_freq: float = 0.01
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq / 2) * bob_amount, 10 * delta)
		else:
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10 * delta)
