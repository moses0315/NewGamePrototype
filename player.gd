extends CharacterBody2D
var SPEED = 150
@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var healthbar = $Healthbar
var health = 100
var is_attacking = false
@export var color : Color = Color(1, 1, 1)
var pressed = []
var direction = "still"
var direction_num = 0
func _ready():
	Engine.time_scale = 0.7
	$AnimatedSprite2D.modulate = color
	print(color)
func _input(event):
	#if event.as_text() in ["A", "S", "D"]:
		if event.is_action_pressed("right"):
			pressed.append("right")
		elif event.is_action_pressed("left"):
			pressed.append("left")
		elif event.is_action_pressed("back"):
			pressed.append("back")

		if event.is_action_released("right"):
			pressed.erase("right")
		elif event.is_action_released("left"):
			pressed.erase("left")
		elif event.is_action_released("back"):
			pressed.erase("back")

		if len(pressed) > 0:
			direction = pressed[-1]
		else:
			direction = "still"

			
func _physics_process(delta):

	healthbar.value = health
	if Input.is_action_pressed("attack") and not is_attacking:
		anim.play("attack")
		is_attacking = true

	if direction == "left":
		sprite.scale.x = -1
		direction_num = -1
	elif direction == "right":
		sprite.scale.x = 1	
		direction_num = 1
	elif direction == "back":
		if sprite.scale.x == -1:
			direction_num = 1
		elif sprite.scale.x == 1:
			direction_num = -1		
	elif direction == "still":
		direction_num = 0
	#set_linear_velocity(Vector2(direction_num*SPEED,0))
	velocity.x = direction_num * SPEED
	#position += Vector2(direction_num*SPEED, 0)*delta
	move_and_slide()

	
func take_damage(damage):
	is_attacking = false
	$AnimatedSprite2D/AttackArea2D/CollisionShape2D.set_deferred("disabled", true)
	health -= damage
	if health <= 0:
		pass
		#self.queue_free()
	else:
		pass
		$AnimatedSprite2D.modulate = Color(200,200,200)
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate = color
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hurt":
		anim.play("idle")
	elif anim_name == "attack" or anim_name == "attack_fast":
		is_attacking = false
		anim.play("idle")


func _on_attack_area_2d_body_entered(body):
	body.take_damage(20)

