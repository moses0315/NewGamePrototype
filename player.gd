extends CharacterBody2D

@export var is_sliding = false
@export var slide_speed : int = 0  # Initialize slide_speed as a float
var a : int = 0

@onready var anim = $AnimationPlayer
@onready var healthbar = $HealthBar

enum States {IDLE, RUN, ATTACK, HURT, DEATH}
var current_state = States.IDLE

var pressed = []
var direction = "still"

var speed = 150
var health = 300
var attack_power = 10



func _ready():
	healthbar.max_value = health
	
func _physics_process(delta):
	healthbar.value = health
	match current_state:
		States.IDLE:
			if direction != "still":
				current_state = States.RUN
			elif Input.is_action_pressed("skill"):
				current_state = States.ATTACK
				anim.play("attack_standing")
			elif Input.is_action_pressed("attack"):
				current_state = States.ATTACK
				anim.play("attack_sliding")
			velocity.x = 0
				
		States.RUN:
			if direction == "still":
				current_state = States.IDLE
				velocity.x = 0
				anim.play("idle")
			elif Input.is_action_pressed("skill"):
				current_state = States.ATTACK
				anim.play("attack_standing")
			elif Input.is_action_pressed("attack"):
				current_state = States.ATTACK
				anim.play("attack_sliding")
			else:
				if direction == "left":
					scale.y = -1
					set_rotation_degrees(-180)
					healthbar.scale.x = -1
					velocity.x = scale.y * speed
				elif direction == "right":
					scale.y = 1
					set_rotation_degrees(0)
					healthbar.scale.x = 1
					velocity.x = scale.y * speed
				elif direction == "back":
					velocity.x = -scale.y * speed
				elif direction == "still":
					velocity.x = 0
				anim.play("run")
		States.ATTACK:
			#a = lerp(a, int(0), delta * 15.0)  # Convert pushback_force to float
			#if is_sliding:
				#is_sliding = false
				#a = slide_speed
			if is_sliding:
				velocity.x = scale.y * slide_speed
			else:
				velocity.x = 0
			
		States.HURT:
			velocity.x = 0
			
		States.DEATH:
			velocity.x = 0
			return
	
	move_and_slide()
	
func _input(event):
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
		
func take_damage(damage):
	health -= damage
	if health <= 0:
		current_state = States.DEATH
		anim.play("death")
		await anim.animation_finished
		queue_free()
	else:	
		current_state = States.HURT
		anim.play("hurt")


	
func _on_attack_area_body_entered(body):
	body.take_damage(attack_power)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack_standing" or\
	anim_name == "attack_sliding":
		current_state = States.IDLE
		anim.play("idle")
		if direction == "left":
			scale.y = -1
			set_rotation_degrees(-180)
			healthbar.scale.x = -1
		elif direction == "right":
			scale.y = 1
			set_rotation_degrees(0)
			healthbar.scale.x = 1
	if anim_name == "hurt":
		current_state = States.IDLE
		anim.play("idle")


		



