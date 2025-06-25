extends CharacterBody2D

@export var gravity: float = 2000.0

@export var jump_power_1s: float = 600.0
@export var jump_power_2s: float = 700.0
@export var jump_power_3s: float = 850.0
@export var jump_power_4s: float = 1050.0

@export var horizontal_1s: float = 500.0
@export var horizontal_2s: float = 600.0
@export var horizontal_3s: float = 750.0
@export var horizontal_4s: float = 950.0

@onready var sfx_jump = $SFX/Jump
@onready var sfx_bounce = $SFX/Jump
@onready var sfx_fall = $SFX/Fall
@onready var sfx_finish = $SFX/Finish

var charging: bool = false
var jump_charge_time: float = 0.0
var jump_direction: float = 0.0
var just_jumped: bool = false

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Start charging
	if Input.is_action_just_pressed("jump") and is_on_floor():
		charging = true
		jump_charge_time = 0.0
		jump_direction = input_direction
		velocity.x = 0
		just_jumped = false

	# Charging in place
	if charging:
		jump_charge_time += delta
		velocity.x = 0

	# Release jump
	if Input.is_action_just_released("jump") and charging:
		charging = false

		var jump_power: float
		var horizontal_boost: float

		if jump_charge_time < 1.0:
			jump_power = 250.0
			horizontal_boost = 200.0
		elif jump_charge_time < 2.0:
			jump_power = jump_power_1s
			horizontal_boost = horizontal_1s
		elif jump_charge_time < 3.0:
			jump_power = jump_power_2s
			horizontal_boost = horizontal_2s
		elif jump_charge_time < 4.0:
			jump_power = jump_power_3s
			horizontal_boost = horizontal_3s
		else:
			jump_power = jump_power_4s
			horizontal_boost = horizontal_4s

		velocity.y = -jump_power
		velocity.x = jump_direction * horizontal_boost
		just_jumped = true

		if sfx_jump:
			sfx_jump.play()

	# Ground movement when not jumping
	if is_on_floor() and not charging and not just_jumped:
		velocity.x = input_direction * 150.0

	# In-air drag
	if not is_on_floor() and not charging and not just_jumped:
		velocity.x = lerp(velocity.x, 0.98 * velocity.x, delta * 1.5)

	# === MOVE AND DETECT COLLISIONS ===
	var previous_velocity = velocity
	move_and_slide()

	# WALL BOUNCE HANDLER (apply bounce BEFORE next frame)
	if not is_on_floor():
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			if abs(normal.x) > 0.9:
				velocity.x = -previous_velocity.x * 0.5
				velocity.y = previous_velocity.y * 0.9
				if sfx_bounce:
					sfx_bounce.play()
				break

	# Reset jump flag
	if is_on_floor():
		just_jumped = false

	# Flip sprite
	if input_direction != 0:
		$AnimatedSprite2D.flip_h = input_direction < 0

	# Animations
	update_animation(input_direction)

func update_animation(input_direction: float) -> void:
	if is_on_floor():
		if charging:
			$AnimatedSprite2D.play("hold_jump")
		elif abs(input_direction) > 0.1:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")

func play_fall_sound():
	if sfx_fall:
		sfx_fall.play()

func play_finish_sound():
	if sfx_finish:
		sfx_finish.play()
