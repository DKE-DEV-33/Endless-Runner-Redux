extends Node2D
const BUILD_VERSION: String = "build-0.6.1"

const PLATFORM_THICKNESS: float = 24.0
const PLAYER_AHEAD_SPAWN: float = 1650.0
const DESPAWN_BEHIND: float = 500.0

const MIN_SEGMENT: float = 260.0
const MAX_SEGMENT: float = 520.0

const START_PLATFORM_X: float = -260.0
const START_PLATFORM_LENGTH: float = 1100.0
const START_LANE: int = 0
const BOOTSTRAP_RELEASE_OFFSET: float = 420.0
const RIFT_MIN_SECONDS: float = 16.0
const RIFT_MAX_SECONDS: float = 28.0
const RIFT_DURATION: float = 6.0
const MISSION_BONUS_BASE: int = 500

const LANE_Y: Array[float] = [448.0, 398.0, 352.0, 308.0]

@onready var player: CharacterBody2D = $Player
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var mission_label: Label = $CanvasLayer/MissionLabel
@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var version_label: Label = $CanvasLayer/VersionLabel

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var next_spawn_x: float = -120.0
var bootstrap_release_x: float = 0.0

var distance_score: int = 0
var bonus_score: int = 0
var health: int = 3
var mission_target: int = 40
var mission_progress: int = 0
var mission_tier: int = 1
var mission_completed: bool = false
var mission_complete_until: float = 0.0
var last_lane: int = START_LANE
var run_seconds: float = 0.0

var rift_active: bool = false
var rift_until: float = 0.0
var next_rift_at: float = 0.0

enum MissionType { COINS, SURVIVE_TIME, NO_HIT_DISTANCE }
var mission_type: int = MissionType.COINS
var mission_no_hit_start_x: float = 0.0

var platforms: Array[Node2D] = []
var coins: Array[Area2D] = []
var hazards: Array[Area2D] = []

func _ready() -> void:
	rng.randomize()
	player.global_position = Vector2(120.0, 408.0)
	player.velocity = Vector2.ZERO
	mission_no_hit_start_x = player.global_position.x
	_build_static_opening()
	_init_mission()
	next_rift_at = rng.randf_range(RIFT_MIN_SECONDS, RIFT_MAX_SECONDS)
	score_label.text = "Score: 0"
	health_label.text = "Health: %d" % health
	status_label.text = "Status: BOOTSTRAP"
	mission_label.text = _mission_text()
	info_label.text = "Space: Jump (tap/hold + double jump) | Left/Right: pace"
	version_label.text = "Version: %s" % BUILD_VERSION

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	run_seconds += delta
	_update_rift_state()

	distance_score = int(player.global_position.x / 12.0)
	score_label.text = "Score: %d" % (distance_score + bonus_score)

	if _bootstrap_active():
		status_label.text = "Status: BOOTSTRAP"
	else:
		if rift_active:
			status_label.text = "Status: RIFT SURGE"
		else:
			status_label.text = "Status: LIVE RUN"
		while next_spawn_x < player.global_position.x + PLAYER_AHEAD_SPAWN:
			_spawn_segment()

	_update_mission_progress()
	_tick_mission_chain()
	mission_label.text = _mission_text()

	_cleanup_old()

	if player.global_position.y > 900.0:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")

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

func _spawn_fixed_platform(start_x: float, lane: int, width: float, gap_after: float, add_coins: bool) -> float:
	var y: float = LANE_Y[lane]
	var platform: StaticBody2D = _create_platform(start_x, y, width)
	platforms.append(platform)
	add_child(platform)
	if add_coins:
		_place_coins(start_x, y, width, lane)
	return start_x + width + gap_after

func _spawn_segment() -> void:
	var segment_len: float = _pick_segment_length()
	var lane: int = _pick_reachable_lane(last_lane)
	var y: float = LANE_Y[lane]

	var platform: StaticBody2D = _create_platform(next_spawn_x, y, segment_len)
	platforms.append(platform)
	add_child(platform)

	_place_coins(next_spawn_x, y, segment_len, lane)
	_place_hazards(next_spawn_x, y, segment_len, lane)

	var gap: float = _safe_gap_for_transition(last_lane, lane)
	next_spawn_x += segment_len + gap
	last_lane = lane

func _pick_segment_length() -> float:
	# Slightly longer segments over time create a steadier rhythm while still increasing challenge.
	var tier_scale: float = clampf(float(mission_tier - 1) * 0.04, 0.0, 0.16)
	var min_len: float = MIN_SEGMENT + (MAX_SEGMENT - MIN_SEGMENT) * tier_scale
	return rng.randf_range(min_len, MAX_SEGMENT)

func _create_platform(x: float, y: float, width: float) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = Vector2(x + width * 0.5, y)

	var collision: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(width, PLATFORM_THICKNESS)
	collision.shape = rect_shape
	body.add_child(collision)

	var visual: Polygon2D = Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, PLATFORM_THICKNESS * 0.5),
		Vector2(-width * 0.5, PLATFORM_THICKNESS * 0.5)
	])
	visual.color = Color(0.36, 0.42, 0.52)
	body.add_child(visual)

	var top_strip: Polygon2D = Polygon2D.new()
	top_strip.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.2),
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.2)
	])
	top_strip.color = Color(0.68, 0.84, 0.98)
	body.add_child(top_strip)

	return body

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

func _create_hazard(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 14.0
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

func _on_coin_body_entered(body: Node, coin: Area2D) -> void:
	if body != player:
		return
	bonus_score += 25
	if mission_type == MissionType.COINS:
		mission_progress += 1
	coins.erase(coin)
	coin.queue_free()

func _on_hazard_body_entered(body: Node) -> void:
	if body != player:
		return
	health -= 1
	mission_no_hit_start_x = player.global_position.x
	health_label.text = "Health: %d" % health
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")

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

	for h: Area2D in hazards.duplicate():
		if h.global_position.x < limit:
			hazards.erase(h)
			h.queue_free()

func _pick_reachable_lane(previous_lane: int) -> int:
	var picked: int = rng.randi_range(maxi(0, previous_lane - 1), mini(LANE_Y.size() - 1, previous_lane + 1))
	return picked

func _safe_gap_for_transition(from_lane: int, to_lane: int) -> float:
	var tier_bonus: float = clampf(float(mission_tier - 1) * 2.0, 0.0, 18.0)
	if rift_active:
		tier_bonus += 8.0

	var delta: int = to_lane - from_lane
	if delta >= 1:
		return rng.randf_range(72.0 + (tier_bonus * 0.5), 108.0 + tier_bonus)
	if delta <= -1:
		return rng.randf_range(86.0 + (tier_bonus * 0.6), 138.0 + tier_bonus)
	return rng.randf_range(98.0 + (tier_bonus * 0.7), 152.0 + (tier_bonus * 1.2))

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
	info_label.text = "Mission %d live | Space: jump skills | Left/Right: pace" % mission_tier

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
		info_label.text = "Mission %d complete! +%d" % [mission_tier, reward]

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
