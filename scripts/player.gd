extends CharacterBody2D

const BASE_RUN_SPEED := 260.0
const MIN_RUN_SPEED := 170.0
const MAX_RUN_SPEED := 370.0
const SPEED_ADJUST_RATE := 520.0
const SPEED_RECOVER_RATE := 340.0
const GRAVITY := 1300.0
const JUMP_VELOCITY := -520.0
const EXTRA_JUMP_HOLD_FORCE := -900.0
const MAX_JUMP_HOLD := 0.12
const COYOTE_TIME := 0.09
const JUMP_BUFFER := 0.12
const MAX_AIR_JUMPS := 1
const JUMP_RELEASE_CUT := 0.48

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var jump_hold_timer := 0.0
var air_jumps_used := 0
var current_run_speed := BASE_RUN_SPEED

func _physics_process(delta: float) -> void:
	var speed_dir: float = Input.get_axis("ui_left", "ui_right")
	var target_run_speed: float = BASE_RUN_SPEED
	var adjust_rate: float = SPEED_RECOVER_RATE
	if speed_dir > 0.0:
		target_run_speed = MAX_RUN_SPEED
		adjust_rate = SPEED_ADJUST_RATE
	elif speed_dir < 0.0:
		target_run_speed = MIN_RUN_SPEED
		adjust_rate = SPEED_ADJUST_RATE
	current_run_speed = move_toward(current_run_speed, target_run_speed, adjust_rate * delta)

	velocity.x = current_run_speed
	velocity.y += GRAVITY * delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME
		air_jumps_used = 0
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0.0 and (coyote_timer > 0.0 or air_jumps_used < MAX_AIR_JUMPS):
		var used_ground_jump: bool = coyote_timer > 0.0
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump_hold_timer = MAX_JUMP_HOLD
		if not used_ground_jump:
			air_jumps_used += 1

	if Input.is_action_pressed("jump") and jump_hold_timer > 0.0 and velocity.y < 0.0:
		velocity.y += EXTRA_JUMP_HOLD_FORCE * delta
		jump_hold_timer -= delta
	else:
		jump_hold_timer = 0.0

	# Short tap cuts upward velocity; holding jump preserves lift.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_RELEASE_CUT

	move_and_slide()

func _draw() -> void:
	draw_rect(Rect2(-18, -26, 36, 52), Color(0.50, 0.95, 0.72), true)

func _process(_delta: float) -> void:
	queue_redraw()
