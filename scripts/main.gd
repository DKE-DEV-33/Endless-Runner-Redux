extends Node2D

const PLATFORM_THICKNESS: float = 24.0
const PLAYER_AHEAD_SPAWN: float = 1650.0
const DESPAWN_BEHIND: float = 500.0

const MIN_SEGMENT: float = 230.0
const MAX_SEGMENT: float = 440.0

const START_PLATFORM_X: float = -260.0
const START_PLATFORM_LENGTH: float = 1100.0
const START_LANE: int = 0
const BOOTSTRAP_RELEASE_OFFSET: float = 420.0
const RIFT_MIN_SECONDS: float = 16.0
const RIFT_MAX_SECONDS: float = 28.0
const RIFT_DURATION: float = 6.0

const LANE_Y: Array[float] = [448.0, 398.0, 352.0, 308.0]

@onready var player: CharacterBody2D = $Player
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var mission_label: Label = $CanvasLayer/MissionLabel
@onready var info_label: Label = $CanvasLayer/InfoLabel

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var next_spawn_x: float = -120.0
var bootstrap_release_x: float = 0.0

var distance_score: int = 0
var bonus_score: int = 0
var health: int = 3
var mission_target: int = 40
var mission_progress: int = 0
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
	info_label.text = "BOOTSTRAP BUILD v2 | Space: Jump | Auto-run"

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
	var segment_len: float = rng.randf_range(MIN_SEGMENT, MAX_SEGMENT)
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
	if lane > 1:
		return
	var hazard_count: int = 1 if width < 340.0 else 2
	if rift_active:
		hazard_count += 1
	for i: int in hazard_count:
		var skip_chance: float = 0.45
		if rift_active:
			skip_chance = 0.22
		if rng.randf() < skip_chance:
			continue
		var hx: float = x + rng.randf_range(80.0, maxf(100.0, width - 80.0))
		var hy: float = y - (PLATFORM_THICKNESS * 0.5) - 12.0
		var hazard: Area2D = _create_hazard(Vector2(hx, hy))
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
	var delta: int = to_lane - from_lane
	if delta >= 1:
		return rng.randf_range(78.0, 118.0)
	if delta <= -1:
		return rng.randf_range(94.0, 150.0)
	return rng.randf_range(102.0, 142.0)

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
	mission_type = rng.randi_range(0, 2)
	mission_progress = 0
	match mission_type:
		MissionType.COINS:
			mission_target = 40
		MissionType.SURVIVE_TIME:
			mission_target = 75
		MissionType.NO_HIT_DISTANCE:
			mission_target = 2200

func _update_mission_progress() -> void:
	if mission_progress >= mission_target:
		return
	match mission_type:
		MissionType.COINS:
			pass
		MissionType.SURVIVE_TIME:
			mission_progress = mini(mission_target, int(run_seconds))
		MissionType.NO_HIT_DISTANCE:
			mission_progress = mini(mission_target, int(player.global_position.x - mission_no_hit_start_x))

	if mission_progress >= mission_target:
		# Mission completion bonus.
		bonus_score += 500
		info_label.text = "Mission complete! +500 | Space: Jump | Auto-run"

func _mission_text() -> String:
	var suffix: String = " (Complete)" if mission_progress >= mission_target else ""
	match mission_type:
		MissionType.COINS:
			return "Mission: Collect %d coins (%d/%d)%s" % [mission_target, mission_progress, mission_target, suffix]
		MissionType.SURVIVE_TIME:
			return "Mission: Survive %ds (%d/%d)%s" % [mission_target, mission_progress, mission_target, suffix]
		MissionType.NO_HIT_DISTANCE:
			return "Mission: No-hit %dpx (%d/%d)%s" % [mission_target, mission_progress, mission_target, suffix]
	return "Mission: --"
