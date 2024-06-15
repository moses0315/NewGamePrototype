extends CharacterBody2D

@export var character_name : String
@export var speed: int
@export var health: int
@export var attack_power: int
@export var dash_speed: int
@export var pushing_power: int

@export var is_sliding = false
@export var slide_speed : int = 0 
@export var is_pushed = false

@onready var anim = $AnimationPlayer
@onready var healthbar = $Healthbar

enum States {IDLE, CHASE, ATTACK, HURT, DEATH}
var current_state = States.IDLE
var chase_target = null
var attack_target = null

var is_close = false
var is_hurt = false

var pushed_direction = 0

var a = 0

func _ready():
	# Initialize healthbar value
	healthbar.max_value = health
	healthbar.value = health
	
func _physics_process(delta):
	# Update healthbar value
	healthbar.value = health
	#$Label.text = str(healthbar.value, ' / ', current_state)
	if is_pushed:
		$Label.text = str(healthbar.value, ' / ', current_state, "SILiding")
	else:
		$Label.text = ""
	match current_state:
		States.IDLE:
			handle_idle_state()

		States.CHASE:
			handle_chase_state()

		States.ATTACK:
			handle_attack_state()

		States.HURT:
			handle_hurt_state()

		States.DEATH:
			handle_death_state()
	
	move_and_slide()


func handle_idle_state():
	# Handle idle state
	if chase_target:
		current_state = States.CHASE
	velocity.x = 0
		


func handle_chase_state():
	# Handle chase state
	if not chase_target:
		current_state = States.IDLE
		anim.play("idle")
	elif attack_target:
		attack()
	else:
		move_towards_target(chase_target, "run", speed)


func handle_attack_state():
	# Handle attack state
	if is_sliding:
		velocity.x = scale.y * slide_speed * (1 if is_close else -1)
	else:
		velocity.x = 0


func handle_hurt_state():
	# Handle hurt state
	velocity.x = pushed_direction if is_pushed else 0

func handle_death_state():
	# Handle death state
	velocity.x = 0
	return


func move_towards_target(target, animation, speed):
	# Move towards a target with specified animation and speed
	var direction = (target.position - position).normalized()
	scale.y = -1 if direction.x < 0 else 1
	set_rotation_degrees(-180 if direction.x < 0 else 0)
	healthbar.scale.x = -1 if direction.x < 0 else 1
	velocity.x = direction.x * speed
	anim.play(animation)


func attack():
	# Start attack state and animation
	current_state = States.ATTACK
	is_close = false
	anim.play("attack")
	move_towards_target(chase_target, "attack", 0)


func take_damage(damage: int, push_power: int, push_direction: int):
	# Handle taking damage and pushing the character
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
		#$HurtTimer.start()
		
	a += 1

func _on_hurt_timer_timeout():
	current_state = States.IDLE
	anim.play("idle")

func _on_player_detection_area_body_entered(body):
	chase_target = body


func _on_player_detection_area_body_exited(body):
	chase_target = null


func _on_attack_detection_area_body_entered(body):
	attack_target = body


func _on_attack_detection_area_body_exited(body):
	attack_target = null


func _on_attack_area_body_entered(body):
	body.take_damage(attack_power, pushing_power, scale.y)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack" or anim_name == "hurt":
		current_state = States.IDLE
		anim.play("idle")






