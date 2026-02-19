extends CharacterBody2D
class_name RunnerPlayer
signal jump_triggered(is_air_jump: bool)

const BASE_RUN_SPEED := 260.0
const MIN_RUN_SPEED := 170.0
const MAX_RUN_SPEED := 370.0
const SPEED_ADJUST_RATE := 520.0
const SPEED_RECOVER_RATE := 340.0
const PACE_LEVEL_STEP := 20.0
const MIN_PACE_LEVEL := 0
const MAX_PACE_LEVEL := 14
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
var pace_level := 0

func _physics_process(delta: float) -> void:
	var pace_bonus: float = float(pace_level) * PACE_LEVEL_STEP
	var section_base_speed: float = BASE_RUN_SPEED + pace_bonus
	var section_min_speed: float = MIN_RUN_SPEED + pace_bonus
	var section_max_speed: float = MAX_RUN_SPEED + pace_bonus

	var speed_dir: float = Input.get_axis("ui_left", "ui_right")
	var target_run_speed: float = section_base_speed
	var adjust_rate: float = SPEED_RECOVER_RATE
	if speed_dir > 0.0:
		target_run_speed = section_max_speed
		adjust_rate = SPEED_ADJUST_RATE
	elif speed_dir < 0.0:
		target_run_speed = section_min_speed
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
		emit_signal("jump_triggered", not used_ground_jump)

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

func add_pace_levels(level_delta: int) -> int:
	pace_level = clampi(pace_level + level_delta, MIN_PACE_LEVEL, MAX_PACE_LEVEL)
	return pace_level

func get_pace_level() -> int:
	return pace_level
