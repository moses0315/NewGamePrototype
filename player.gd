extends CharacterBody2D
const SPEED = 150
@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var healthbar = $Healthbar
var health = 100
var is_attacking = false

var pressed = []
var direction = "still"
var direction_num = 0
func _input(event):
	if event.as_text() in ["A", "S", "D"]:
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
	velocity.x = direction_num * SPEED
	move_and_slide()
	
func take_damage(damage):
	is_attacking = false
	$AnimatedSprite2D/AttackArea2D/CollisionShape2D.set_deferred("disabled", true)
	health -= damage
	if health <= 0:
		pass
		#self.queue_free()
	else:
		anim.play("hurt")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hurt":
		anim.play("idle")
	elif anim_name == "attack":
		is_attacking = false
		anim.play("idle")


func _on_attack_area_2d_body_entered(body):
	body.take_damage(10)



















































