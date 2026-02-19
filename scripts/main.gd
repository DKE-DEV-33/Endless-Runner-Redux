extends Node2D
const BUILD_VERSION: String = "build-1.2.2"

const PLATFORM_THICKNESS: float = 24.0
const PLAYER_AHEAD_SPAWN: float = 1650.0
const DESPAWN_BEHIND: float = 500.0

const MIN_SEGMENT: float = 260.0
const MAX_SEGMENT: float = 520.0

const START_PLATFORM_X: float = -260.0
const START_PLATFORM_LENGTH: float = 1100.0
const START_LANE: int = 0
const BOOTSTRAP_RELEASE_OFFSET: float = 1400.0
const RIFT_MIN_SECONDS: float = 16.0
const RIFT_MAX_SECONDS: float = 28.0
const RIFT_DURATION: float = 6.0
const MISSION_BONUS_BASE: int = 500
const MAX_HEALTH: int = 5
const COINS_PER_BONUS_HEART: int = 100
const SECTION_LENGTH: float = 2300.0
const ALT_ROUTE_VERTICAL_GAP_MIN: float = 104.0
const ALT_ROUTE_EXTRA_LIFT: float = 88.0
const ALT_ROUTE_MIN_WIDTH: float = 220.0
const ALT_ROUTE_MAX_WIDTH: float = 340.0
const BRANCH_CHAIN_CHANCE: float = 0.12
const BRANCH_CHAIN_MAX: int = 1
const BRANCH_MIN_WIDTH: float = 150.0
const BRANCH_MAX_WIDTH: float = 280.0
const SPEED_PICKUP_CHANCE: float = 0.025
const SPEED_PICKUP_MAX_CHANCE: float = 0.085
const SPEED_PICKUP_PITY_SEGMENTS: int = 18
const HAZARD_HIT_COOLDOWN: float = 0.45
const SETTINGS_FILE: String = "user://settings.cfg"
const HEALTH_PICKUP_PITY_DANGER_ROUTES: int = 5
const BIG_COIN_VALUE: int = 10
const PLATFORM_LAYER_SOLID: int = 1
const PLATFORM_LAYER_ONE_WAY: int = 2
const INFO_NOTICE_DURATION: float = 3.0

const LANE_Y: Array[float] = [456.0, 314.0, 176.0]
const SECTION_COLORS: Array[Color] = [
	Color(0.03, 0.05, 0.09),
	Color(0.05, 0.08, 0.14),
	Color(0.08, 0.05, 0.12),
	Color(0.06, 0.10, 0.10),
	Color(0.09, 0.06, 0.08),
]

@onready var player = $Player
@onready var world_background: ColorRect = $WorldBackground
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var mission_label: Label = $CanvasLayer/MissionLabel
@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var version_label: Label = $CanvasLayer/VersionLabel
@onready var pause_layer: CanvasLayer = $PauseLayer
@onready var pause_backdrop: ColorRect = $PauseLayer/PauseBackdrop
@onready var pause_panel: Panel = $PauseLayer/PausePanel
@onready var pause_status_label: Label = $PauseLayer/PausePanel/VBox/PauseStatusLabel
@onready var resume_button: Button = $PauseLayer/PausePanel/VBox/ResumeButton
@onready var restart_button: Button = $PauseLayer/PausePanel/VBox/RestartButton
@onready var menu_button: Button = $PauseLayer/PausePanel/VBox/MenuButton
@onready var master_slider: HSlider = $PauseLayer/PausePanel/VBox/MasterSlider
@onready var sfx_slider: HSlider = $PauseLayer/PausePanel/VBox/SfxSlider

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var next_spawn_x: float = -120.0
var bootstrap_release_x: float = 0.0

var distance_score: int = 0
var bonus_score: int = 0
var health: int = 3
var total_coins_collected: int = 0
var next_bonus_heart_at: int = COINS_PER_BONUS_HEART
var mission_target: int = 40
var mission_progress: int = 0
var mission_tier: int = 1
var mission_completed: bool = false
var mission_complete_until: float = 0.0
var last_lane: int = START_LANE
var run_seconds: float = 0.0
var current_section: int = 0
var hazard_hit_cooldown: float = 0.0
var danger_routes_since_health: int = 0
var routes_since_speed_pickup: int = 0
var run_mode: String = "standard"
var run_seed: int = 0
var sfx_volume_db: float = -6.0
var info_notice: String = ""
var info_notice_until: float = 0.0

var rift_active: bool = false
var rift_until: float = 0.0
var next_rift_at: float = 0.0

enum MissionType { COINS, SURVIVE_TIME, NO_HIT_DISTANCE }
enum PlatformType { SOLID, ONE_WAY_UP, DROP_THROUGH, GHOST }
var mission_type: int = MissionType.COINS
var mission_no_hit_start_x: float = 0.0

var platforms: Array[Node2D] = []
var coins: Array[Area2D] = []
var big_coins: Array[Area2D] = []
var hazards: Array[Area2D] = []
var health_pickups: Array[Area2D] = []
var speed_pickups: Array[Area2D] = []
var branch_chain_remaining: int = 0

func _ready() -> void:
	_setup_run_mode_and_seed()
	_load_audio_settings()
	player.global_position = Vector2(120.0, 408.0)
	player.velocity = Vector2.ZERO
	player.jump_triggered.connect(_on_player_jump_triggered)
	mission_no_hit_start_x = player.global_position.x
	_build_static_opening()
	_init_mission()
	_prewarm_post_bootstrap_route()
	next_rift_at = rng.randf_range(RIFT_MIN_SECONDS, RIFT_MAX_SECONDS)
	_apply_section_theme(0)
	score_label.text = "Score: 0"
	health_label.text = "Health: %d" % health
	status_label.text = "Status: BOOTSTRAP"
	mission_label.text = _mission_text()
	_refresh_info_label()
	version_label.text = "Version: %s" % BUILD_VERSION
	_setup_pause_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_menu()
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			_toggle_pause_menu()

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	run_seconds += delta
	hazard_hit_cooldown = maxf(0.0, hazard_hit_cooldown - delta)
	if info_notice != "" and run_seconds >= info_notice_until:
		info_notice = ""
	_update_rift_state()
	_update_section_progression()
	_refresh_info_label()

	distance_score = int(player.global_position.x / 12.0)
	score_label.text = "Score: %d (x%.1f)" % [_current_score(), _speed_multiplier()]

	if _bootstrap_active():
		status_label.text = "Status: BOOTSTRAP"
	else:
		if rift_active:
			status_label.text = "Status: RIFT SURGE | Pace %d" % player.get_pace_level()
		else:
			status_label.text = "Status: LIVE RUN | Pace %d" % player.get_pace_level()
		while next_spawn_x < player.global_position.x + PLAYER_AHEAD_SPAWN:
			_spawn_segment()

	_update_mission_progress()
	_tick_mission_chain()
	mission_label.text = _mission_text()

	_cleanup_old()

	if player.global_position.y > 900.0:
		_end_run_and_return_to_menu()

func _build_static_opening() -> void:
	var x: float = START_PLATFORM_X
	x = _spawn_fixed_platform(x, START_LANE, START_PLATFORM_LENGTH, 32.0, false)
	x = _spawn_fixed_platform(x, 0, 380.0, 54.0, true)
	x = _spawn_fixed_platform(x, 1, 340.0, 80.0, true)
	x = _spawn_fixed_platform(x, 1, 320.0, 88.0, false)
	x = _spawn_fixed_platform(x, 2, 300.0, 84.0, true)
	x = _spawn_fixed_platform(x, 1, 330.0, 96.0, true)
	next_spawn_x = x
	bootstrap_release_x = x - BOOTSTRAP_RELEASE_OFFSET
	last_lane = 1

func _prewarm_post_bootstrap_route() -> void:
	# Seed future segments before bootstrap ends so first sector shift does not visibly pop.
	var preview_x: float = bootstrap_release_x
	while next_spawn_x < preview_x + PLAYER_AHEAD_SPAWN + 320.0:
		_spawn_segment()

func _spawn_fixed_platform(start_x: float, lane: int, width: float, gap_after: float, add_coins: bool) -> float:
	var y: float = LANE_Y[lane]
	var platform_type: int = PlatformType.SOLID if lane == 0 else PlatformType.ONE_WAY_UP
	var platform: StaticBody2D = _create_platform(start_x, y, width, platform_type)
	platforms.append(platform)
	add_child(platform)
	if add_coins:
		_place_coins(start_x, y, width, lane)
	return start_x + width + gap_after

func _spawn_segment() -> void:
	var segment_len: float = _pick_segment_length()
	var lane: int = _pick_reachable_lane(last_lane)
	var y: float = LANE_Y[lane]
	var platform_type: int = _pick_platform_type_for_lane(lane)

	var platform: StaticBody2D = _create_platform(next_spawn_x, y, segment_len, platform_type)
	platforms.append(platform)
	add_child(platform)

	_place_coins(next_spawn_x, y, segment_len, lane)
	_maybe_place_big_coin(next_spawn_x, y, segment_len, lane)
	_place_hazards(next_spawn_x, y, segment_len, lane)
	routes_since_speed_pickup += 1
	var speed_spawned: bool = _maybe_place_speed_pickup(next_spawn_x, y, segment_len, lane)
	if not speed_spawned and routes_since_speed_pickup >= SPEED_PICKUP_PITY_SEGMENTS and player.get_pace_level() >= 4:
		_maybe_place_speed_pickup(next_spawn_x, y, segment_len, lane, 1.0)
	_spawn_branch_routes(next_spawn_x, segment_len, lane)

	var gap: float = _safe_gap_for_transition(last_lane, lane)
	next_spawn_x += segment_len + gap
	last_lane = lane

func _pick_segment_length() -> float:
	# Slightly longer segments over time create a steadier rhythm while still increasing challenge.
	var tier_scale: float = clampf(float(mission_tier - 1) * 0.04, 0.0, 0.16)
	var min_len: float = MIN_SEGMENT + (MAX_SEGMENT - MIN_SEGMENT) * tier_scale
	return rng.randf_range(min_len, MAX_SEGMENT)

func _pick_platform_type_for_lane(lane: int) -> int:
	if lane == 0:
		return PlatformType.SOLID
	var roll: float = rng.randf()
	if roll < 0.48:
		return PlatformType.ONE_WAY_UP
	if roll < 0.86:
		return PlatformType.DROP_THROUGH
	return PlatformType.SOLID

func _create_platform(x: float, y: float, width: float, platform_type: int) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = Vector2(x + width * 0.5, y)

	if platform_type != PlatformType.GHOST:
		var collision: CollisionShape2D = CollisionShape2D.new()
		var rect_shape: RectangleShape2D = RectangleShape2D.new()
		rect_shape.size = Vector2(width, PLATFORM_THICKNESS)
		collision.shape = rect_shape
		if platform_type == PlatformType.ONE_WAY_UP or platform_type == PlatformType.DROP_THROUGH:
			collision.one_way_collision = true
			collision.one_way_collision_margin = 8.0
			body.collision_layer = 1 << (PLATFORM_LAYER_ONE_WAY - 1)
		else:
			body.collision_layer = 1 << (PLATFORM_LAYER_SOLID - 1)
		body.add_child(collision)

	var visual: Polygon2D = Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, PLATFORM_THICKNESS * 0.5),
		Vector2(-width * 0.5, PLATFORM_THICKNESS * 0.5)
	])
	if platform_type == PlatformType.GHOST:
		visual.color = Color(0.38, 0.35, 0.58, 0.55)
	elif platform_type == PlatformType.DROP_THROUGH:
		visual.color = Color(0.64, 0.45, 0.19)
	elif platform_type == PlatformType.ONE_WAY_UP:
		visual.color = Color(0.20, 0.49, 0.66)
	else:
		visual.color = Color(0.36, 0.42, 0.52)
	body.add_child(visual)

	var top_strip: Polygon2D = Polygon2D.new()
	top_strip.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.2),
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.2)
	])
	if platform_type == PlatformType.GHOST:
		top_strip.color = Color(0.84, 0.72, 1.0, 0.65)
	elif platform_type == PlatformType.DROP_THROUGH:
		top_strip.color = Color(1.0, 0.84, 0.30)
	elif platform_type == PlatformType.ONE_WAY_UP:
		top_strip.color = Color(0.50, 0.94, 1.0)
	else:
		top_strip.color = Color(0.68, 0.84, 0.98)
	body.add_child(top_strip)

	if platform_type == PlatformType.ONE_WAY_UP:
		_add_platform_chevrons(body, width, true, false, Color(0.72, 0.97, 1.0))
	elif platform_type == PlatformType.DROP_THROUGH:
		_add_platform_chevrons(body, width, true, true, Color(1.0, 0.92, 0.54))
	elif platform_type == PlatformType.GHOST:
		_add_platform_chevrons(body, width, true, true, Color(0.94, 0.82, 1.0, 0.75))
		var ghost_core: Polygon2D = Polygon2D.new()
		ghost_core.polygon = PackedVector2Array([
			Vector2(-width * 0.5 + 8.0, 0),
			Vector2(width * 0.5 - 8.0, 0),
			Vector2(width * 0.5 - 8.0, 4.0),
			Vector2(-width * 0.5 + 8.0, 4.0)
		])
		ghost_core.color = Color(0.82, 0.66, 1.0, 0.45)
		body.add_child(ghost_core)

	return body

func _add_platform_chevrons(body: StaticBody2D, width: float, show_up: bool, show_down: bool, color: Color) -> void:
	var spacing: float = 30.0
	var count: int = maxi(2, mini(10, int(width / spacing)))
	for i: int in count:
		var t: float = float(i + 1) / float(count + 1)
		var cx: float = lerpf(-width * 0.5 + 10.0, width * 0.5 - 10.0, t)
		if show_up:
			var up_mark: Polygon2D = Polygon2D.new()
			up_mark.polygon = PackedVector2Array([
				Vector2(cx - 5.0, -6.0), Vector2(cx, -11.0), Vector2(cx + 5.0, -6.0)
			])
			up_mark.color = color
			body.add_child(up_mark)
		if show_down:
			var down_mark: Polygon2D = Polygon2D.new()
			down_mark.polygon = PackedVector2Array([
				Vector2(cx - 5.0, 7.0), Vector2(cx, 12.0), Vector2(cx + 5.0, 7.0)
			])
			down_mark.color = color
			body.add_child(down_mark)

func _place_coins(x: float, y: float, width: float, lane: int) -> void:
	var count: int = 4 + int(width / 180.0)
	var coin_y: float = y - 56.0
	if lane >= 2:
		coin_y = y - 46.0

	for i: int in count:
		var t: float = float(i + 1) / float(count + 1)
		var coin_x: float = lerpf(x + 26.0, x + width - 26.0, t)
		var coin: Area2D = _create_coin(Vector2(coin_x, coin_y))
		coins.append(coin)
		add_child(coin)

func _maybe_place_big_coin(x: float, y: float, width: float, lane: int, chance: float = 0.12) -> void:
	if lane == 0:
		return
	if width < 240.0:
		return
	if rng.randf() > chance:
		return
	var bx: float = x + rng.randf_range(width * 0.35, width * 0.72)
	var by: float = y - 72.0
	var big_coin: Area2D = _create_big_coin(Vector2(bx, by))
	big_coins.append(big_coin)
	add_child(big_coin)

func _place_hazards(x: float, y: float, width: float, lane: int) -> void:
	if lane > 2:
		return
	if width < 260.0 and rng.randf() < 0.5:
		return

	var pattern_roll: float = rng.randf()
	if rift_active:
		pattern_roll += 0.18

	if pattern_roll < 0.34:
		_spawn_hazard_single(x, y, width)
	elif pattern_roll < 0.72:
		_spawn_hazard_pair(x, y, width)
	else:
		_spawn_hazard_gate(x, y, width)

	if rift_active and width > 320.0 and rng.randf() < 0.45:
		var spike_x: float = x + rng.randf_range(120.0, width - 90.0)
		_spawn_hazard_at(Vector2(spike_x, y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _spawn_hazard_single(x: float, y: float, width: float) -> void:
	if rng.randf() < 0.35:
		return
	var hx: float = x + clampf(width * rng.randf_range(0.40, 0.70), 82.0, width - 82.0)
	_spawn_hazard_at(Vector2(hx, y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _spawn_hazard_pair(x: float, y: float, width: float) -> void:
	if width < 290.0:
		_spawn_hazard_single(x, y, width)
		return
	var first_x: float = x + clampf(width * rng.randf_range(0.28, 0.38), 80.0, width - 160.0)
	var second_x: float = x + clampf(width * rng.randf_range(0.62, 0.74), 160.0, width - 80.0)
	_spawn_hazard_at(Vector2(first_x, y - (PLATFORM_THICKNESS * 0.5) - 18.0))
	_spawn_hazard_at(Vector2(second_x, y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _spawn_hazard_gate(x: float, y: float, width: float) -> void:
	if width < 330.0:
		_spawn_hazard_pair(x, y, width)
		return
	var center: float = x + clampf(width * rng.randf_range(0.55, 0.72), 160.0, width - 160.0)
	_spawn_hazard_at(Vector2(center - 38.0, y - (PLATFORM_THICKNESS * 0.5) - 18.0))
	_spawn_hazard_at(Vector2(center + 38.0, y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _spawn_hazard_at(pos: Vector2) -> void:
	var hazard: Area2D = _create_hazard(pos)
	hazards.append(hazard)
	add_child(hazard)

func _maybe_place_health_pickup(x: float, y: float, width: float, lane: int, chance: float = 0.18) -> bool:
	if lane > 2:
		return false
	if rift_active:
		chance *= 0.8
	if rng.randf() > chance:
		return false
	var min_offset: float = minf(100.0, width * 0.35)
	var max_offset: float = maxf(min_offset + 8.0, width - 70.0)
	var hx: float = x + rng.randf_range(min_offset, max_offset)
	var hy: float = y - 72.0
	var pickup: Area2D = _create_health_pickup(Vector2(hx, hy))
	health_pickups.append(pickup)
	add_child(pickup)
	return true

func _spawn_branch_routes(x: float, width: float, base_lane: int) -> void:
	if width < 320.0:
		return
	var spawn_branches: bool = false
	if branch_chain_remaining > 0:
		spawn_branches = true
		branch_chain_remaining -= 1
	elif rng.randf() < BRANCH_CHAIN_CHANCE:
		spawn_branches = true
		branch_chain_remaining = rng.randi_range(0, BRANCH_CHAIN_MAX)

	if not spawn_branches:
		return

	var branch_lanes: Array[int] = [0, 1, 2]
	branch_lanes.erase(base_lane)
	if branch_lanes.is_empty():
		return

	# About half the time, intentionally skip one branch lane to create stronger divergence.
	if branch_lanes.size() > 1 and rng.randf() < 0.80:
		# Prefer the farthest lane to keep branch routes visually and mechanically distinct.
		var far_lane: int = branch_lanes[0]
		var far_delta: int = absi(far_lane - base_lane)
		for candidate_lane: int in branch_lanes:
			var candidate_delta: int = absi(candidate_lane - base_lane)
			if candidate_delta > far_delta:
				far_lane = candidate_lane
				far_delta = candidate_delta
		branch_lanes = [far_lane]

	for lane_idx: int in branch_lanes:
		_spawn_single_branch_platform(x, width, base_lane, lane_idx)

func _spawn_single_branch_platform(x: float, width: float, base_lane: int, target_lane: int) -> void:
	var lane_delta: int = absi(target_lane - base_lane)
	if lane_delta <= 0:
		return

	var alt_width: float = clampf(width * rng.randf_range(0.48, 0.72), BRANCH_MIN_WIDTH, BRANCH_MAX_WIDTH)
	var min_start: float = x + 96.0
	var max_start: float = x + width - alt_width - 64.0
	if max_start <= min_start:
		return

	var alt_x: float = rng.randf_range(min_start, max_start)
	var target_y: float = LANE_Y[target_lane]
	var type_roll: float = rng.randf()
	var platform_type: int = PlatformType.ONE_WAY_UP
	if type_roll < 0.52:
		platform_type = PlatformType.DROP_THROUGH
	elif type_roll > 0.95:
		platform_type = PlatformType.GHOST

	var branch_platform: StaticBody2D = _create_platform(alt_x, target_y, alt_width, platform_type)
	platforms.append(branch_platform)
	add_child(branch_platform)

	_place_coins(alt_x, target_y, alt_width, target_lane)
	_maybe_place_big_coin(alt_x, target_y, alt_width, target_lane, 0.30 + (0.08 * float(lane_delta - 1)))

	danger_routes_since_health += 1
	if rng.randf() < 0.60 + (0.08 * float(lane_delta - 1)):
		_spawn_hazard_single(alt_x, target_y, alt_width)

	var health_spawn_chance: float = _compute_health_spawn_chance()
	var health_spawned: bool = _maybe_place_health_pickup(alt_x, target_y, alt_width, target_lane, health_spawn_chance)
	if not health_spawned and health <= 3 and danger_routes_since_health >= HEALTH_PICKUP_PITY_DANGER_ROUTES:
		_maybe_place_health_pickup(alt_x, target_y, alt_width, target_lane, 1.0)

func _maybe_place_speed_pickup(x: float, y: float, width: float, lane: int, override_chance: float = -1.0) -> bool:
	if lane > 2:
		return false
	var pace_bonus_chance: float = float(player.get_pace_level()) * 0.006
	var spawn_chance: float = minf(SPEED_PICKUP_MAX_CHANCE, SPEED_PICKUP_CHANCE + pace_bonus_chance)
	if override_chance >= 0.0:
		spawn_chance = override_chance
	if rng.randf() > spawn_chance:
		return false
	var min_offset: float = minf(90.0, width * 0.32)
	var max_offset: float = maxf(min_offset + 8.0, width - 60.0)
	var sx: float = x + rng.randf_range(min_offset, max_offset)
	var sy: float = y - 66.0
	var pickup: Area2D = _create_speed_pickup(Vector2(sx, sy))
	speed_pickups.append(pickup)
	add_child(pickup)
	return true

func _create_coin(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	area.add_child(shape)

	var sprite: Polygon2D = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-10, 0), Vector2(0, -10), Vector2(10, 0), Vector2(0, 10)
	])
	sprite.color = Color(1.0, 0.88, 0.30)
	area.add_child(sprite)

	area.body_entered.connect(_on_coin_body_entered.bind(area))
	return area

func _create_big_coin(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 15.0
	shape.shape = circle
	area.add_child(shape)

	var sprite: Polygon2D = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-14, 0), Vector2(0, -14), Vector2(14, 0), Vector2(0, 14)
	])
	sprite.color = Color(1.0, 0.65, 0.12)
	area.add_child(sprite)

	area.body_entered.connect(_on_big_coin_body_entered.bind(area))
	return area

func _create_hazard(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	area.add_child(shape)

	var sprite: Polygon2D = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-12, 12), Vector2(0, -14), Vector2(12, 12)
	])
	sprite.color = Color(0.95, 0.35, 0.25)
	area.add_child(sprite)

	area.body_entered.connect(_on_hazard_body_entered)
	return area

func _create_speed_pickup(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	area.add_child(shape)

	var body_poly: Polygon2D = Polygon2D.new()
	body_poly.polygon = PackedVector2Array([
		Vector2(-10, 0), Vector2(-2, -10), Vector2(8, -10),
		Vector2(2, 0), Vector2(10, 0), Vector2(0, 12), Vector2(-8, 12)
	])
	body_poly.color = Color(0.34, 0.76, 1.0)
	area.add_child(body_poly)

	area.body_entered.connect(_on_speed_pickup_body_entered.bind(area))
	return area

func _create_health_pickup(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	area.add_child(shape)

	var core: Polygon2D = Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-10, -4), Vector2(-4, -4), Vector2(-4, -10), Vector2(4, -10),
		Vector2(4, -4), Vector2(10, -4), Vector2(10, 4), Vector2(4, 4),
		Vector2(4, 10), Vector2(-4, 10), Vector2(-4, 4), Vector2(-10, 4)
	])
	core.color = Color(0.40, 0.96, 0.50)
	area.add_child(core)

	area.body_entered.connect(_on_health_pickup_body_entered.bind(area))
	return area

func _on_coin_body_entered(body: Node, coin: Area2D) -> void:
	if body != player:
		return
	_play_sfx_tone(980.0, 0.045, -14.0)
	bonus_score += 25
	total_coins_collected += 1
	while total_coins_collected >= next_bonus_heart_at:
		_apply_health_delta(1)
		next_bonus_heart_at += COINS_PER_BONUS_HEART
		_set_info_notice("Coin milestone reached! +1 HP | Next at %d coins" % next_bonus_heart_at)
	if mission_type == MissionType.COINS:
		mission_progress += 1
	coins.erase(coin)
	coin.queue_free()

func _on_big_coin_body_entered(body: Node, big_coin: Area2D) -> void:
	if body != player:
		return
	_play_sfx_tone(1120.0, 0.08, -11.0)
	bonus_score += 25 * BIG_COIN_VALUE
	total_coins_collected += BIG_COIN_VALUE
	while total_coins_collected >= next_bonus_heart_at:
		_apply_health_delta(1)
		next_bonus_heart_at += COINS_PER_BONUS_HEART
		_set_info_notice("Coin milestone reached! +1 HP | Next at %d coins" % next_bonus_heart_at)
	if mission_type == MissionType.COINS:
		mission_progress += BIG_COIN_VALUE
	big_coins.erase(big_coin)
	big_coin.queue_free()

func _on_hazard_body_entered(body: Node) -> void:
	if body != player:
		return
	if hazard_hit_cooldown > 0.0:
		return
	hazard_hit_cooldown = HAZARD_HIT_COOLDOWN
	_play_sfx_tone(210.0, 0.14, -6.0)
	_apply_health_delta(-1)
	mission_no_hit_start_x = player.global_position.x
	if health <= 0:
		_end_run_and_return_to_menu()

func _on_health_pickup_body_entered(body: Node, pickup: Area2D) -> void:
	if body != player:
		return
	_play_sfx_tone(520.0, 0.15, -8.0)
	_apply_health_delta(1)
	danger_routes_since_health = 0
	health_pickups.erase(pickup)
	pickup.queue_free()

func _on_speed_pickup_body_entered(body: Node, pickup: Area2D) -> void:
	if body != player:
		return
	_play_sfx_tone(340.0, 0.18, -10.0)
	var slow_amount: int = 2 if rng.randf() < 0.35 else 1
	var pace_level: int = player.add_pace_levels(-slow_amount)
	_set_info_notice("Flux stabilizer collected: -%d pace (now %d)" % [slow_amount, pace_level])
	routes_since_speed_pickup = 0
	speed_pickups.erase(pickup)
	pickup.queue_free()

func _cleanup_old() -> void:
	var limit: float = player.global_position.x - DESPAWN_BEHIND

	for p: Node2D in platforms.duplicate():
		if p.global_position.x < limit - 500.0:
			platforms.erase(p)
			p.queue_free()

	for c: Area2D in coins.duplicate():
		if c.global_position.x < limit:
			coins.erase(c)
			c.queue_free()

	for bc: Area2D in big_coins.duplicate():
		if bc.global_position.x < limit:
			big_coins.erase(bc)
			bc.queue_free()

	for h: Area2D in hazards.duplicate():
		if h.global_position.x < limit:
			hazards.erase(h)
			h.queue_free()

	for hp: Area2D in health_pickups.duplicate():
		if hp.global_position.x < limit:
			health_pickups.erase(hp)
			hp.queue_free()

	for sp: Area2D in speed_pickups.duplicate():
		if sp.global_position.x < limit:
			speed_pickups.erase(sp)
			sp.queue_free()

func _pick_reachable_lane(previous_lane: int) -> int:
	var picked: int = rng.randi_range(maxi(0, previous_lane - 1), mini(LANE_Y.size() - 1, previous_lane + 1))
	return picked

func _safe_gap_for_transition(from_lane: int, to_lane: int) -> float:
	var tier_bonus: float = clampf(float(mission_tier - 1) * 2.0, 0.0, 18.0)
	if rift_active:
		tier_bonus += 8.0

	var delta: int = to_lane - from_lane
	if delta >= 1:
		return rng.randf_range(90.0 + (tier_bonus * 0.5), 128.0 + tier_bonus)
	if delta <= -1:
		return rng.randf_range(104.0 + (tier_bonus * 0.6), 160.0 + tier_bonus)
	return rng.randf_range(116.0 + (tier_bonus * 0.7), 174.0 + (tier_bonus * 1.2))

func _bootstrap_active() -> bool:
	return player.global_position.x < bootstrap_release_x

func _update_rift_state() -> void:
	if _bootstrap_active():
		return
	if rift_active:
		if run_seconds >= rift_until:
			rift_active = false
			next_rift_at = run_seconds + rng.randf_range(RIFT_MIN_SECONDS, RIFT_MAX_SECONDS)
		return

	if run_seconds >= next_rift_at:
		rift_active = true
		rift_until = run_seconds + RIFT_DURATION

func _update_section_progression() -> void:
	if _bootstrap_active():
		return
	var next_section: int = maxi(0, int(player.global_position.x / SECTION_LENGTH))
	if next_section <= current_section:
		return
	while current_section < next_section:
		current_section += 1
		_apply_section_theme(current_section)
		_increment_pace_level(1, "Sector shift")
		_play_sfx_tone(640.0, 0.12, -9.0)

func _apply_section_theme(section_index: int) -> void:
	if SECTION_COLORS.is_empty():
		return
	var color_index: int = section_index % SECTION_COLORS.size()
	world_background.color = SECTION_COLORS[color_index]

func _init_mission() -> void:
	mission_completed = false
	mission_complete_until = 0.0
	var next_type: int = rng.randi_range(0, 2)
	if mission_tier > 1 and next_type == mission_type:
		next_type = (next_type + 1 + rng.randi_range(0, 1)) % 3
	mission_type = next_type
	mission_progress = 0
	mission_no_hit_start_x = player.global_position.x
	match mission_type:
		MissionType.COINS:
			mission_target = mini(92, 28 + (mission_tier * 8))
		MissionType.SURVIVE_TIME:
			mission_target = mini(130, 35 + (mission_tier * 10))
		MissionType.NO_HIT_DISTANCE:
			mission_target = mini(5200, 900 + (mission_tier * 420))
	_set_info_notice("Mission %d live" % mission_tier, 2.4)

func _update_mission_progress() -> void:
	if mission_completed:
		return
	match mission_type:
		MissionType.COINS:
			pass
		MissionType.SURVIVE_TIME:
			mission_progress = mini(mission_target, int(run_seconds))
		MissionType.NO_HIT_DISTANCE:
			mission_progress = mini(mission_target, int(player.global_position.x - mission_no_hit_start_x))

	if mission_progress >= mission_target:
		mission_completed = true
		mission_complete_until = run_seconds + 2.0
		var reward: int = MISSION_BONUS_BASE + ((mission_tier - 1) * 75)
		bonus_score += reward
		_increment_pace_level(1, "Mission complete")
		_play_sfx_tone(760.0, 0.16, -8.0)
		_set_info_notice("Mission %d complete! +%d | Pace %d" % [mission_tier, reward, player.get_pace_level()])

func _tick_mission_chain() -> void:
	if not mission_completed:
		return
	if run_seconds < mission_complete_until:
		return
	mission_tier += 1
	_init_mission()

func _mission_text() -> String:
	var suffix: String = " (Complete)" if mission_progress >= mission_target else ""
	match mission_type:
		MissionType.COINS:
			return "Mission %d: Collect %d coins (%d/%d)%s" % [mission_tier, mission_target, mission_progress, mission_target, suffix]
		MissionType.SURVIVE_TIME:
			return "Mission %d: Survive %ds (%d/%d)%s" % [mission_tier, mission_target, mission_progress, mission_target, suffix]
		MissionType.NO_HIT_DISTANCE:
			return "Mission %d: No-hit %dpx (%d/%d)%s" % [mission_tier, mission_target, mission_progress, mission_target, suffix]
	return "Mission: --"

func _apply_health_delta(delta: int) -> void:
	health = clampi(health + delta, 0, MAX_HEALTH)
	health_label.text = "Health: %d" % health

func _increment_pace_level(amount: int, reason: String) -> void:
	var pace_level: int = player.add_pace_levels(amount)
	_set_info_notice("%s | Pace level: %d" % [reason, pace_level], 2.1)

func _compute_health_spawn_chance() -> float:
	var health_missing: int = MAX_HEALTH - health
	var pace_level: int = player.get_pace_level()
	var difficulty_penalty: float = minf(0.34, float(mission_tier - 1) * 0.018 + float(current_section) * 0.013)
	var pressure_bonus: float = float(health_missing) * 0.135
	var critical_bonus: float = 0.30 if health <= 1 else (0.14 if health == 2 else 0.0)
	var pace_bonus: float = float(pace_level) * 0.012
	var rift_penalty: float = 0.06 if rift_active else 0.0
	var chance: float = 0.09 + pressure_bonus + critical_bonus + pace_bonus - difficulty_penalty - rift_penalty

	# "Pity" protection: at critical health on repeated dangerous routes, force a spawn.
	if health <= 1 and danger_routes_since_health >= 2:
		return 1.0
	if health == 2 and danger_routes_since_health >= 4:
		return 0.95

	return clampf(chance, 0.04, 0.90)

func _base_info_text() -> String:
	return "Mode: %s | cyan=up-through | amber=drop-through | purple=ghost | Big coin: x10" % run_mode.capitalize()

func _refresh_info_label() -> void:
	var text: String = _base_info_text()
	if info_notice != "":
		text += " | " + info_notice
	info_label.text = text

func _set_info_notice(message: String, duration: float = INFO_NOTICE_DURATION) -> void:
	info_notice = message
	info_notice_until = run_seconds + duration
	_refresh_info_label()

func _current_score() -> int:
	return int(float(distance_score) * _speed_multiplier()) + bonus_score

func _speed_multiplier() -> float:
	return 1.0 + (float(player.get_pace_level()) * 0.1)

func _end_run_and_return_to_menu() -> void:
	var run_score: int = _current_score()
	var best_score: int = _load_best_score()
	var is_new_best: bool = run_score > best_score
	if is_new_best:
		best_score = run_score
		_save_best_score(best_score)

	get_tree().set_meta("last_score", run_score)
	get_tree().set_meta("best_score", best_score)
	get_tree().set_meta("is_new_best", is_new_best)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _load_best_score() -> int:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load("user://run_stats.cfg")
	if err != OK:
		return 0
	return int(config.get_value("scores", "best_score", 0))

func _save_best_score(score: int) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("scores", "best_score", score)
	config.save("user://run_stats.cfg")

func _setup_run_mode_and_seed() -> void:
	run_mode = String(get_tree().get_meta("run_mode", "standard"))
	if run_mode == "daily":
		var daily_key: String = Time.get_date_string_from_system()
		run_seed = abs(daily_key.hash())
		rng.seed = run_seed
	else:
		rng.randomize()
		run_seed = rng.randi()

func _setup_pause_ui() -> void:
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_backdrop.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_backdrop.visible = false
	pause_panel.visible = false

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	master_slider.value_changed.connect(_on_master_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	master_slider.value = AudioServer.get_bus_volume_db(0)
	sfx_slider.value = sfx_volume_db

func _toggle_pause_menu() -> void:
	var opening: bool = not pause_panel.visible
	pause_backdrop.visible = opening
	pause_panel.visible = opening
	get_tree().paused = opening
	if opening:
		pause_status_label.text = "Paused | Score: %d | Pace %d" % [_current_score(), player.get_pace_level()]

func _on_resume_pressed() -> void:
	pause_backdrop.visible = false
	pause_panel.visible = false
	get_tree().paused = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().paused = false
	_end_run_and_return_to_menu()

func _on_master_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	_save_audio_settings()

func _on_sfx_slider_changed(value: float) -> void:
	sfx_volume_db = value
	_save_audio_settings()

func _load_audio_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load(SETTINGS_FILE)
	if err != OK:
		AudioServer.set_bus_volume_db(0, -4.0)
		sfx_volume_db = -6.0
		return
	AudioServer.set_bus_volume_db(0, float(config.get_value("audio", "master_db", -4.0)))
	sfx_volume_db = float(config.get_value("audio", "sfx_db", -6.0))

func _save_audio_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "master_db", AudioServer.get_bus_volume_db(0))
	config.set_value("audio", "sfx_db", sfx_volume_db)
	config.save(SETTINGS_FILE)

func _on_player_jump_triggered(is_air_jump: bool) -> void:
	if is_air_jump:
		_play_sfx_tone(520.0, 0.08, -12.0)
	else:
		_play_sfx_tone(440.0, 0.07, -12.0)

func _play_sfx_tone(frequency: float, duration: float, level_db: float) -> void:
	var stream: AudioStreamWAV = _create_tone_stream(frequency, duration)
	var player_node: AudioStreamPlayer = AudioStreamPlayer.new()
	player_node.stream = stream
	player_node.bus = "Master"
	player_node.volume_db = level_db + sfx_volume_db
	add_child(player_node)
	player_node.finished.connect(player_node.queue_free)
	player_node.play()

func _create_tone_stream(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = maxi(1, int(sample_rate * duration))
	var data: PackedByteArray = PackedByteArray()
	data.resize(total_samples * 2)

	for i: int in total_samples:
		var t: float = float(i) / float(sample_rate)
		var env: float = 1.0 - (float(i) / float(total_samples))
		var sample: float = sin(TAU * frequency * t) * env * 0.42
		var s: int = int(clampi(int(sample * 32767.0), -32768, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF

	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav
