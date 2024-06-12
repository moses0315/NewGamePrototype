extends CharacterBody2D

@export var is_sliding = false
@export var slide_speed : int = 0  # Initialize slide_speed as a float
@export var is_pushed = false
var a : int = 0

@onready var anim = $AnimationPlayer
@onready var healthbar = $HealthBar

enum States {IDLE, RUN, DASH, ATTACK, HURT, DEATH}
var current_state = States.IDLE

var is_invincible = false
var dash_ready = true

var pressed = []
var direction = "still"

var attack_type = ["attack_1", "attack_2", "attack_3"]
var attack_stat = 0

var speed = 150
var health = 100
var attack_power = 10

var pushed_direction = 0



func _ready():
	healthbar.max_value = health
	
func _physics_process(delta):
	healthbar.value = health
	match current_state:
		States.IDLE:
			if direction != "still":
				current_state = States.RUN
			elif Input.is_action_pressed("dash") and dash_ready:
				current_state = States.DASH
				is_invincible = true
				dash_ready = false
				$DashTimer.start()
				anim.play("dash")
			elif Input.is_action_pressed("attack"):
				current_state = States.ATTACK
				anim.play(attack_type[attack_stat])
				attack_stat += 1
				$AttackStatTimer.start()
				if attack_stat >= 3:
					attack_stat = 0
			velocity.x = 0
				
		States.RUN:
			if direction == "still":
				current_state = States.IDLE
				velocity.x = 0
				anim.play("idle")
			elif Input.is_action_pressed("dash") and dash_ready:
				current_state = States.DASH
				is_invincible = true
				dash_ready = false
				$DashTimer.start()
				anim.play("dash")
			elif Input.is_action_pressed("attack"):
				current_state = States.ATTACK
				anim.play(attack_type[attack_stat])
				attack_stat += 1
				$AttackStatTimer.start()
				if attack_stat >= 3:
					attack_stat = 0
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
				
		States.DASH:
			velocity.x = scale.y * 300
			
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
			if is_pushed:
				velocity.x = pushed_direction
			else :
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
		
func take_damage(damage, push_power, push_direction):
	if is_invincible:
		return
	health -= damage
	pushed_direction = push_direction * push_power
	if health <= 0:
		current_state = States.DEATH
		anim.play("death")
		await anim.animation_finished
		queue_free()
	else:
		current_state = States.HURT
		anim.play("hurt")


	
func _on_attack_area_body_entered(body):
	body.take_damage(attack_power, 90, scale.y)

func _on_attack_3_area_body_entered(body):
	body.take_damage(attack_power, 300, scale.y)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack_1" or\
	anim_name == "attack_2" or\
	anim_name == "attack_3":
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
	if anim_name == "hurt" or\
	anim_name == "dash":
		current_state = States.IDLE
		is_invincible = false
		anim.play("idle")

func _on_attack_stat_timer_timeout():
	attack_stat = 0

func _on_dash_timer_timeout():
	dash_ready = true
