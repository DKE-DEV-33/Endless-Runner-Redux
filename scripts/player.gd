extends CharacterBody2D

const RUN_SPEED := 260.0
const GRAVITY := 1300.0
const JUMP_VELOCITY := -520.0
const EXTRA_JUMP_HOLD_FORCE := -900.0
const MAX_JUMP_HOLD := 0.12
const COYOTE_TIME := 0.09
const JUMP_BUFFER := 0.12

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var jump_hold_timer := 0.0

func _physics_process(delta: float) -> void:
	velocity.x = RUN_SPEED
	velocity.y += GRAVITY * delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump_hold_timer = MAX_JUMP_HOLD

	if Input.is_action_pressed("jump") and jump_hold_timer > 0.0 and velocity.y < 0.0:
		velocity.y += EXTRA_JUMP_HOLD_FORCE * delta
		jump_hold_timer -= delta
	else:
		jump_hold_timer = 0.0

	move_and_slide()

func _draw() -> void:
	draw_rect(Rect2(-18, -26, 36, 52), Color(0.50, 0.95, 0.72), true)

func _process(_delta: float) -> void:
	queue_redraw()
