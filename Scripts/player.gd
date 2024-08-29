extends CharacterBody3D

class_name player

# SECRET variables
var previousinputs = []
var konamicode = ["Up", "Up", "Up", "Up", "Down", "Down", "Down", "Down", "Left", "Left", "Right", "Right", "Left", "Left", "Right", "Right", "B", "B", "A", "A"]
var goofy_menu = false
@onready var goofy_menu_object = $HUD/HUD_SECRET_Goofy
#HUD variables
var dead = false
var nano_regen_rate = 2
var regen_time = 0.5
var regen_time_base = regen_time
var nanobot_regen_per_second = nano_regen_rate / regen_time
var nanobot_count = 150
var void_energy_value = 200


var slide_unqueued = false

@onready var hud = $HUD
@onready var nanobot_slider = $HUD/HUD_NanobotSlider
@onready var void_energy_slider = $HUD/HUD_VOIDEnergySlider
@onready var nanobot_counter = $HUD/HUD_NanobotSlider/HUD_NanobotCount
@onready var void_energy_counter = $HUD/HUD_VOIDEnergySlider/HUD_VOIDEnergyCount


#Audio variables
@onready var audio = $AUDIO_Player
var gunshot_noise = preload("res://Audio/gunshot.mp3")



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

@export var step_delay =0.2
@export var step_delay_save = step_delay

# Ability Variables

var shockwave_prefab = preload("res://Prefabs/shockwave.tscn")

var overload_time = 5
var overload_time_base = overload_time

var shockwave_delay = 2
var shockwave_delay_save = shockwave_delay

var overload_delay = 4
var overload_delay_save = overload_delay

var blast_prefab = preload("res://Prefabs/blast_prefab.tscn")
var is_charging_blast = false
var charge_time: float = 1
var is_overloaded = false
var blast_delay = 0.4
var blast_delay_save = blast_delay


#camera variables

var round = 0
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

@onready var slide_collider = $COLLISION_Sliding
@onready var default_collider = $COLLISION_Player


@onready var checkpoint: Vector3 = position

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

var on_menu = false

func _start_bounce():
	_bounce(slide_start_state)

func _bounce(slide_state):
	velocity = -slide_state
func _input(event):
	if(dead == true or on_menu == true or goofy_menu == true):
		return
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
	shockwave_delay = 0
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _tutorial_respawn():
	position = checkpoint
	
func _take_damage():
	$HUD/HUD_Static_Animator.play("static_flash")

func _reload_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	
func _menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _shoot():

	if($HEAD_Player/WeaponHolder/Revolver/Sketchfab_model/AnimationPlayer.is_playing()):
		return
	$HEAD_Player/WeaponHolder/Revolver/Sketchfab_model/AnimationPlayer.play("shoot")
	audio.pitch_scale = randf_range(0.95,1.1)
	audio.stream = gunshot_noise
	audio.play()
	camera._camera_shake()
	instance = bullet_trail.instantiate()
	instance.player_object = self
	if aim_ray.is_colliding():
		instance.init(bullet_spawn.global_position, aim_ray.get_collision_point())
		if( aim_ray.get_collider() is enemy or aim_ray.get_collider() is enemy_soul or aim_ray.get_collider() is enemy_ranged_robot or aim_ray.get_collider() is enemy_ranged_soul):
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
	if(slide_unqueued == true):
		if($HeadCheck.is_colliding() == false):
			is_sliding = false
			slide_unqueued = false
	if(on_menu == true):
		
		$HUD/ColorRect.visible = true
		get_tree().paused = true
	else:
		if(goofy_menu == false and dead == false):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$HUD/ColorRect.visible = false
		get_tree().paused = false
	if(dead == true or on_menu == true or goofy_menu == true):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
		
	if Input.is_action_just_pressed("overload"):
		if(void_energy_value >= 75):
			void_energy_value -= 75
			is_overloaded = true
	
	if(is_overloaded == true):
		damage = 2
		slide_force = 17
		speed = 14
		dash_force = 50
	else:
		damage = 1
		slide_force = 13
		speed = 8
		dash_force = 30
	
	blast_delay -= delta
	if(Input.is_action_pressed("blast")):
		if(blast_delay <= 0):
			is_charging_blast = true
			if($HEAD_Player/WeaponHolder/Revolver_glow.get_active_material(0).albedo_color.a < 0.6):
				if(void_energy_value > 5):
					void_energy_value -= round(70 * delta)
					charge_time += delta
					$HEAD_Player/WeaponHolder/Revolver_glow.get_active_material(0).albedo_color.a += delta * charge_time
	if(Input.is_action_just_released("blast") and is_charging_blast):
		if(charge_time > 0):
			var blast_object = blast_prefab.instantiate()
			if aim_ray.is_colliding():
			
				if(aim_ray.get_collision_point() != null):
				
					blast_object.blast_power = charge_time
					blast_object.scale_factor = charge_time - 0.5
					var collider = aim_ray.get_collision_point()
					blast_object.position = collider
					get_parent().add_child(blast_object)
			else:
			
				blast_object.scale_factor = charge_time - 0.5
				blast_object.blast_power = charge_time
				blast_object.position = aim_ray_end.global_position
				get_parent().add_child(blast_object)
		is_charging_blast = false
		blast_delay = blast_delay_save
		charge_time = 1
		if(void_energy_value <= 5):
			charge_time = 0
		$HEAD_Player/WeaponHolder/Revolver_glow.get_active_material(0).albedo_color.a = 0
	velocity.y += -gravity * delta
	input = Input.get_vector("left", "right", "forward", "back")
	_weapon_tilt(delta)
	_cam_tilt(delta)
	_weapon_sway(delta)
	_weapon_bob(velocity.length(), delta)
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	if(Input.is_action_just_pressed("left")):
		print("Holy Sea")
	if(shockwave_delay > 0):
		shockwave_delay -= delta
	if(Input.is_action_just_pressed("shockwave") and is_on_floor() and shockwave_delay <= 0):
		if(void_energy_value >= 50):
			void_energy_value -= 50
		else:
			return
		var shockwave_object = shockwave_prefab.instantiate()
		shockwave_object.global_position = global_position
		get_parent().add_child(shockwave_object)
		velocity.y = gravity
		shockwave_delay = shockwave_delay_save
	#movement code (DO NOT TOUCH)
	if(is_on_floor()):
		if(input != Vector2.ZERO and is_dashing == false and is_sliding == false):
			if($AUDIO_Walking.playing == false and step_delay <= 0):
				$AUDIO_Walking.pitch_scale = randf_range(0.95,1.15)
				$AUDIO_Walking.play()
				step_delay = step_delay_save
			elif(step_delay > 0):
				step_delay -= delta
			velocity.x = lerp(velocity.x, movement_dir.x * speed, acceleration)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, acceleration)
		elif(is_dashing == false and is_sliding == false):
			$AUDIO_Walking.stop()
			velocity.x = lerp(velocity.x, movement_dir.x * speed, deceleration)
			velocity.z = lerp(velocity.z, movement_dir.z * speed, deceleration)
	else:
		if(Input.is_action_just_pressed("slide")):
			velocity.y += -gravity
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
		default_collider.disabled = true
		slide_collider.disabled = false
		$HEAD_Player.position.y = lerp($HEAD_Player.position.y, -0.2, 0.1)
		slide_length -= delta
		velocity.x = slide_start_state.x
		velocity.z = slide_start_state.z
	
	if(is_sliding == false):
		default_collider.disabled = false
		slide_collider.disabled = true
		$HEAD_Player.position.y = lerp($HEAD_Player.position.y, 0.56, 0.1)
	
		
		
	
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	
	if Input.is_action_just_pressed("slide"):
		if(input != Vector2.ZERO):
			slide_start_state = transform.basis * Vector3(input.x, 0, input.y) * slide_force
		else:
			slide_start_state = transform.basis * Vector3(0, 0, -1) * slide_force
		if is_on_floor() and is_sliding == false:
			is_sliding = true
			slide_length = slide_length_save

	if Input.is_action_just_released("slide"):
		if($HeadCheck.is_colliding() == false):
			is_sliding = false
		else:
			slide_unqueued = true
		
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
	if(get_parent().get_parent().name == "tutorial"):
		$HUD/RichTextLabel.visible = false
	$HUD/RichTextLabel.text = str("Round:", round)
	
	if(void_energy_value > 250):
		void_energy_value = 250
	
	# Secret processes
	if(previousinputs == konamicode):
		goofy_menu = true
	if(goofy_menu == true):
		if(Input.mouse_mode != Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		goofy_menu_object.visible = true
	else:
		goofy_menu_object.visible = false
	# Hud processes
	if(is_overloaded):
		if($HUD/Overloadlines.modulate.a <= 0):
			$HUD/HUD_Animator.play("overloadappear")
		regen_time -= delta
		overload_time -= delta
	else:
		if($HUD/Overloadlines.modulate.a >= 1):
			$HUD/HUD_Animator.play("overloaddisappear")
	if(overload_time <= 0):
		is_overloaded = false
		overload_time = overload_time_base
	if(regen_time <= 0):
		nanobot_count += nano_regen_rate
		regen_time = regen_time_base
	void_energy_counter.text = str("Void Energy:", void_energy_value)
	nanobot_counter.text = str("Nanobots: ", nanobot_count)
	nanobot_slider.value = nanobot_count
	void_energy_slider.value = void_energy_value
	if(dead == true):
		$HUD/Static_Effect.modulate.a = 0.8
		$HUD/Death_Screen.visible = true
	
	# Value processes
	if(nanobot_count <= 0):
		_death()
	

	if Input.is_action_just_pressed("quick_exit"):
		on_menu = !on_menu

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
			var bob_freq: float = 0.008
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x + sin(Time.get_ticks_msec() * bob_freq / 2) * bob_amount, 10 * delta)
		else:
			weapon_holder.position.y = lerp(weapon_holder.position.y, def_weapon_holder_pos.y, 10 * delta)
			weapon_holder.position.x = lerp(weapon_holder.position.x, def_weapon_holder_pos.x, 10 * delta)


func _on_back_pressed():
	on_menu = false


func _on_quit_pressed():
	get_tree().quit()


func _on_hud_secret_hampter_pressed():
	$"../.."._summon_hampter(5)
	previousinputs = []
	goofy_menu = false
