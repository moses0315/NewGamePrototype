extends Node2D
var enemy_strong = preload("res://enemy_strong.tscn")
var enemy = preload("res://enemy.tscn")
@onready var player = $Player
# Called when the node enters the scene tree for the first time.
var instance_x
func _ready():
	var instance
	var ran_num = (randi_range(1, 2))
	var ran_num_pos = (randi_range(1, 1))
	
	if ran_num_pos:
		instance_x = player.position.x+600
	else:
		instance_x = player.position.x-600
		
	if ran_num == 1:
		instance = enemy.instantiate()
	elif ran_num == 2:
		instance = enemy_strong.instantiate()

	instance.position = Vector2(instance_x, player.position.y)
	add_child(instance)
	
	
func _on_timer_timeout():
	var instance
	var ran_num = (randi_range(1, 2))
	var ran_num_pos = (randi_range(1, 1))
	
	if ran_num_pos:
		instance_x = player.position.x+600
	else:
		instance_x = player.position.x-600
		
	if ran_num == 1:
		instance = enemy.instantiate()
	elif ran_num == 2:
		instance = enemy_strong.instantiate()

	instance.position = Vector2(instance_x, player.position.y)
	add_child(instance)
