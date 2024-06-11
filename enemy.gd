extends CharacterBody2D

@export var character_name : String
@export var speed: int
@export var health: int
@export var attack_power: int

@export var is_sliding = false
@export var slide_speed : int = 0 

@onready var anim = $AnimationPlayer
@onready var healthbar = $HealthBar

enum States {IDLE, CHASE, ATTACK, HURT, DEATH}
var current_state = States.IDLE
var chase_target = null
var attack_target = null
var is_close = false


func _ready():
	healthbar.max_value = health
	
func _physics_process(delta):
	healthbar.value = health
	
	match current_state:
		States.IDLE:
			if chase_target:
				current_state = States.CHASE
			velocity.x = 0

		States.CHASE:
			if not chase_target:
				current_state = States.IDLE
				anim.play("idle")
			elif attack_target:
				attack()
			else:
				var direction = (chase_target.position-position).normalized()
				if direction.x < 0:
					scale.y = -1
					set_rotation_degrees(-180)
					healthbar.scale.x = -1
				elif direction.x >= 0:
					scale.y = 1
					set_rotation_degrees(0)
					healthbar.scale.x = 1
				velocity.x = direction.x * speed
				anim.play("run")
				

		States.ATTACK:
			if is_sliding:
				if is_close:
					velocity.x = -scale.y * slide_speed
				else:
					velocity.x = scale.y * slide_speed
			else:
				velocity.x = 0
			
		States.HURT:
			velocity.x = 0
			
		States.DEATH:
			velocity.x = 0
			return
	
	move_and_slide()

func attack():
	current_state = States.ATTACK
	is_close = false
	anim.play("attack")
	var direction = (chase_target.position-position).normalized()
	if direction.x < 0:
		scale.y = -1
		set_rotation_degrees(-180)
		healthbar.scale.x = -1
	elif direction.x >= 0:
		scale.y = 1
		set_rotation_degrees(0)
		healthbar.scale.x = 1

func take_damage(damage):
	health -= damage
	if health <= 0:
		current_state = States.DEATH
		anim.play("death")
		await anim.animation_finished
		queue_free()
	elif character_name == "slugger":
		pass
	else:
		
		current_state = States.HURT
		anim.play("hurt")

func _on_player_detection_area_body_entered(body):
	chase_target = body
	
func _on_player_detection_area_body_exited(body):
	chase_target = null
	
func _on_attack_detection_area_body_entered(body):
	attack_target = body

func _on_attack_detection_area_body_exited(body):
	attack_target = null
	
func _on_attack_area_body_entered(body):
	body.take_damage(attack_power)

func _on_close_distance_area_body_entered(body):
	is_close = true
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		current_state = States.IDLE
		anim.play("idle")
	if anim_name == "hurt":
		current_state = States.IDLE
		anim.play("idle")


		





