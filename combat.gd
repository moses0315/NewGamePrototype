extends Node2D

var enemy_fast = preload("res://enemy_fast.tscn")
var enemy_strong = preload("res://enemy_strong.tscn")

func _on_timer_timeout():
	var randon_name = (randi_range(1, 10))
	var random_position = (randi_range(1, 10))
	if randon_name%2 == 0:
		randon_name = enemy_fast
	else:
		randon_name = enemy_strong
	genarate_enemy(randon_name, Vector2(1000, 367))

	randon_name = (randi_range(1, 10))
	random_position = (randi_range(1, 10))
	if randon_name%2 == 0:
		randon_name = enemy_fast
	else:
		randon_name = enemy_strong
	genarate_enemy(randon_name, Vector2(0, 367))
	


func genarate_enemy(enemy_name, enemy_position):
	var instance = enemy_name.instantiate()
	instance.position = enemy_position
	add_child(instance)
