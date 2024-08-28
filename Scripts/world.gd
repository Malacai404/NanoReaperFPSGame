extends Node3D

var round = 0



var Hampter = preload("res://Prefabs/hamster.tscn")
var ENEMY_MELEE = preload("res://Prefabs/enemy_melee.tscn")
var ENEMY_MELEE_SOUL = preload("res://Prefabs/enemy_melee_soul.tscn")
var ENEMY_RANGED_ROBOT = preload("res://Prefabs/enemy_ranged_robot.tscn")
var ENEMY_RANGED_SOUL = preload("res://Prefabs/enemy_ranged_soul.tscn")

var spawn_points
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_points = $level/Spawn_Points.get_children()

func _summon_hampter(num: int):
	for i in range(num):
		var spawn = spawn_points.pick_random()
		var enemy_object = Hampter.instantiate()
		enemy_object.position = spawn.global_position
		enemy_object.player_path = $level/Player.get_path()
		$level.add_child(enemy_object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$level/Player.round = round
	var enemys_alive = false
	for i in $level.get_children():
		if "enemy" in i.name.to_lower():
			enemys_alive = true
	if(enemys_alive == false):
		round += 1
		for i in range(round):
			var spawn = spawn_points.pick_random()
			var enemy_select= randi_range(1,4)
			if(enemy_select == 1):
				var enemy_object = ENEMY_MELEE.instantiate()
				enemy_object.position = spawn.global_position
				enemy_object.player_path = $level/Player.get_path()
				$level.add_child(enemy_object)
			elif(enemy_select == 2):
				var enemy_object = ENEMY_MELEE_SOUL.instantiate()
				enemy_object.position = spawn.global_position
				enemy_object.player_path = $level/Player.get_path()
				$level.add_child(enemy_object)
			elif(enemy_select == 3):
				var enemy_object = ENEMY_RANGED_ROBOT.instantiate()
				enemy_object.position = spawn.global_position
				enemy_object.player_path = $level/Player.get_path()
				$level.add_child(enemy_object)
			elif(enemy_select == 4):
				var enemy_object = ENEMY_RANGED_SOUL.instantiate()
				enemy_object.position = spawn.global_position
				enemy_object.player_path = $level/Player.get_path()
				$level.add_child(enemy_object)
