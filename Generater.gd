extends Node2D
var enemy = preload("res://enemy.tscn")
@onready var player = $Player
# Called when the node enters the scene tree for the first time.
var instance_x

func _on_timer_timeout():
	var rng = RandomNumberGenerator.new()
	if rng.seed >= 0:
		instance_x = player.position.x+600
	elif rng.seed < 0:
		instance_x = player.position.x-600

	var instance = enemy.instantiate()
	instance.position = Vector2(instance_x, player.position.y)
	add_child(instance)
