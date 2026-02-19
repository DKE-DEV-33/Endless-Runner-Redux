extends Node2D

const FLOOR_Y := 448.0
const PLATFORM_THICKNESS := 24.0
const PLAYER_AHEAD_SPAWN := 1700.0
const DESPAWN_BEHIND := 500.0

const MIN_SEGMENT := 220.0
const MAX_SEGMENT := 520.0
const GAP_MIN := 120.0
const GAP_MAX := 260.0

const LANE_Y: Array[float] = [448.0, 360.0, 290.0, 230.0]

@onready var player: CharacterBody2D = $Player
@onready var score_label: Label = $CanvasLayer/ScoreLabel

var rng := RandomNumberGenerator.new()
var next_spawn_x := -200.0
var score := 0

var platforms: Array[Node2D] = []
var coins: Array[Area2D] = []
var hazards: Array[Area2D] = []

func _ready() -> void:
	rng.randomize()
	for i in 8:
		_spawn_segment(true)

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	score = int(player.global_position.x / 12.0)
	score_label.text = "Score: %d" % score

	while next_spawn_x < player.global_position.x + PLAYER_AHEAD_SPAWN:
		_spawn_segment(false)

	_cleanup_old()

	if player.global_position.y > 900.0:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _spawn_segment(is_intro: bool) -> void:
	var segment_len: float = rng.randf_range(MIN_SEGMENT, MAX_SEGMENT)
	var lane: int = 0 if is_intro else _pick_lane()
	var y: float = LANE_Y[lane]

	var platform := _create_platform(next_spawn_x, y, segment_len)
	platforms.append(platform)
	add_child(platform)

	if not is_intro:
		_place_coins(next_spawn_x, y, segment_len, lane)
		_place_hazards(next_spawn_x, y, segment_len, lane)

	next_spawn_x += segment_len + rng.randf_range(GAP_MIN, GAP_MAX)

func _create_platform(x: float, y: float, width: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = Vector2(x + width * 0.5, y)

	var collision := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(width, PLATFORM_THICKNESS)
	collision.shape = rect_shape
	body.add_child(collision)

	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, PLATFORM_THICKNESS * 0.5),
		Vector2(-width * 0.5, PLATFORM_THICKNESS * 0.5)
	])
	visual.color = Color(0.36, 0.42, 0.52)
	body.add_child(visual)

	var top_strip := Polygon2D.new()
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
	var coin_y: float = y - 60.0
	if lane >= 2:
		coin_y = y - 46.0

	for i in count:
		var t: float = float(i + 1) / float(count + 1)
		var coin_x: float = lerpf(x + 26.0, x + width - 26.0, t)
		var coin := _create_coin(Vector2(coin_x, coin_y))
		coins.append(coin)
		add_child(coin)

func _place_hazards(x: float, y: float, width: float, lane: int) -> void:
	if lane > 1:
		return
	var hazard_count: int = 1 if width < 340.0 else 2
	for i in hazard_count:
		if rng.randf() < 0.40:
			continue
		var hx: float = x + rng.randf_range(80.0, maxf(100.0, width - 80.0))
		var hy: float = y - (PLATFORM_THICKNESS * 0.5) - 12.0
		var hazard := _create_hazard(Vector2(hx, hy))
		hazards.append(hazard)
		add_child(hazard)

func _create_coin(pos: Vector2) -> Area2D:
	var area := Area2D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 0

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	area.add_child(shape)

	var sprite := Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-10, 0), Vector2(0, -10), Vector2(10, 0), Vector2(0, 10)
	])
	sprite.color = Color(1.0, 0.88, 0.30)
	area.add_child(sprite)

	area.body_entered.connect(_on_coin_body_entered.bind(area))
	return area

func _create_hazard(pos: Vector2) -> Area2D:
	var area := Area2D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 0

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	area.add_child(shape)

	var sprite := Polygon2D.new()
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
	score += 25
	coins.erase(coin)
	coin.queue_free()

func _on_hazard_body_entered(body: Node) -> void:
	if body != player:
		return
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _cleanup_old() -> void:
	var limit := player.global_position.x - DESPAWN_BEHIND

	for p in platforms.duplicate():
		if p.global_position.x < limit - 500.0:
			platforms.erase(p)
			p.queue_free()

	for c in coins.duplicate():
		if c.global_position.x < limit:
			coins.erase(c)
			c.queue_free()

	for h in hazards.duplicate():
		if h.global_position.x < limit:
			hazards.erase(h)
			h.queue_free()

func _pick_lane() -> int:
	var roll := rng.randi_range(0, 99)
	if roll < 45:
		return 0
	if roll < 75:
		return 1
	if roll < 92:
		return 2
	return 3
