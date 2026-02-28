extends Node2D
const BUILD_VERSION: String = "build-1.2.39"

const PLATFORM_THICKNESS: float = 24.0
const PLAYER_AHEAD_SPAWN: float = 1650.0
const DESPAWN_BEHIND: float = 500.0

const MIN_SEGMENT: float = 260.0
const MAX_SEGMENT: float = 520.0

const START_PLATFORM_X: float = -260.0
const START_PLATFORM_LENGTH: float = 1100.0
const START_LANE: int = 0
const BOOTSTRAP_RELEASE_OFFSET: float = 1080.0
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
const HAZARD_DODGE_Y_WINDOW: float = 180.0
const SETTINGS_FILE: String = "user://settings.cfg"
const WINDOW_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
const HEALTH_PICKUP_PITY_DANGER_ROUTES: int = 5
const BIG_COIN_VALUE: int = 10
const PLATFORM_LAYER_SOLID: int = 1
const PLATFORM_LAYER_ONE_WAY: int = 2
const INFO_NOTICE_DURATION: float = 3.0
const COMBO_TIMEOUT: float = 2.8
const COMBO_BONUS_STEP: int = 12
const COMBO_MAX: int = 15
const PARALLAX_BAND_HEIGHT: float = 120.0
const DROP_THROUGH_BASE_CHANCE: float = 0.20
const DROP_THROUGH_PITY_CHANCE: float = 0.28
const DROP_THROUGH_SUPPRESS_CHANCE: float = 0.08
const DROP_THROUGH_SUPPRESS_SEGMENTS: int = 2
const DROP_THROUGH_PITY_SEGMENTS: int = 6
const BRANCH_DROP_THROUGH_CHANCE_MID: float = 0.22
const BRANCH_DROP_THROUGH_CHANCE_TOP: float = 0.30
const HAZARD_SEGMENT_BASE_CHANCE: float = 0.67
const HAZARD_SEGMENT_COOLDOWN_CHANCE: float = 0.18
const HAZARD_SEGMENT_PITY_COUNT: int = 3
const LANE_GUIDE_LENGTH: float = 5600.0
const LANE_GUIDE_AHEAD: float = 1900.0
const LANE_GUIDE_BEHIND: float = 700.0
const PLATFORM_PANEL_GAP: float = 56.0
const PLATFORM_RIVET_GAP: float = 46.0
const ATMOS_STAR_COUNT: int = 90
const ATMOS_EMBER_COUNT: int = 54
const ATMOS_SPIRE_COUNT: int = 18
const ATMOS_SMOG_COUNT: int = 8
const BACKGROUND_ART_PATH: String = "res://assets/images/Background_image.png"
const ABILITY_PICKUP_BASE_CHANCE: float = 0.075
const ABILITY_COOLDOWN_SECONDS: float = 16.0
const SHIELD_HITS_GRANTED: int = 1
const CHRONO_DURATION: float = 5.5
const HEALTH_COLOR_SAFE: Color = Color(0.88, 1.0, 0.88)
const HEALTH_COLOR_WARN: Color = Color(1.0, 0.92, 0.52)
const HEALTH_COLOR_CRIT: Color = Color(1.0, 0.52, 0.52)

const LANE_Y: Array[float] = [468.0, 306.0, 144.0]
const HAZARD_EDGE_CLEARANCE: float = 84.0
const HAZARD_BRANCH_MIN_RATIO: float = 0.42
const HAZARD_BRANCH_MAX_RATIO: float = 0.66
const ECON_SECTION_DIFFICULTY_STEP: float = 0.0015
const HAZARD_CHASER_CHANCE: float = 0.22
const HAZARD_CHASER_MIN_SPEED: float = 185.0
const HAZARD_CHASER_MAX_SPEED: float = 275.0
const CHASER_MIN_PLATFORM_CLEARANCE_STEPS: float = 1.0
const FRACTIONAL_LANE_STEP: float = 28.0
const COIN_ARCH_CHANCE: float = 0.44
const COIN_ARCH_MIN_WIDTH: float = 260.0
const POWERUP_DEFAULT_FRACTION: float = 2.0
const BIG_COIN_APEX_FRACTION: float = 3.2
const BIOME_ARCH_BONUS: Array[float] = [0.0, 0.04, 0.20]
const BIOME_CHASER_BONUS: Array[float] = [-0.04, 0.18, 0.02]
const SECTION_COLORS: Array[Color] = [
	Color(0.03, 0.05, 0.08), # Forge dusk
	Color(0.05, 0.09, 0.15), # Reactor blue
	Color(0.12, 0.07, 0.09), # Ember haze
	Color(0.06, 0.10, 0.12), # Alloy storm
	Color(0.09, 0.06, 0.13), # Rift violet
]
const BIOMES: Array[Dictionary] = [
	{"name": "Foundry Rim", "hazard_mult": 0.95, "coin_bonus": 1},
	{"name": "Rift Span", "hazard_mult": 1.18, "coin_bonus": 0},
	{"name": "Ember Vault", "hazard_mult": 1.06, "coin_bonus": 2},
]
const GAMEPLAY_MUSIC_PATH: String = "res://assets/audio/gameplay_music.mp3"

@onready var player = $Player
@onready var world_background: ColorRect = $WorldBackground
@onready var atmosphere_decor: Node2D = $AtmosphereDecor
@onready var parallax_decor: Node2D = $ParallaxDecor
@onready var lane_guides_root: Node2D = $LaneGuides
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var mission_label: Label = $CanvasLayer/MissionLabel
@onready var info_label: Label = $CanvasLayer/InfoLabel
@onready var legend_label: Label = $CanvasLayer/LegendLabel
@onready var version_label: Label = $CanvasLayer/VersionLabel
@onready var pause_layer: CanvasLayer = $PauseLayer
@onready var pause_backdrop: ColorRect = $PauseLayer/PauseBackdrop
@onready var pause_panel: Panel = $PauseLayer/PausePanel
@onready var pause_status_label: Label = $PauseLayer/PausePanel/VBox/PauseStatusLabel
@onready var pause_window_size_button: Button = $PauseLayer/PausePanel/VBox/WindowSizeButton
@onready var pause_rules_button: Button = $PauseLayer/PausePanel/VBox/RulesButton
@onready var resume_button: Button = $PauseLayer/PausePanel/VBox/ResumeButton
@onready var restart_button: Button = $PauseLayer/PausePanel/VBox/RestartButton
@onready var menu_button: Button = $PauseLayer/PausePanel/VBox/MenuButton
@onready var pause_rules_overlay: ColorRect = $PauseLayer/PauseRulesOverlay
@onready var pause_rules_close_button: Button = $PauseLayer/PauseRulesOverlay/RulesPanel/VBox/CloseButton
@onready var master_slider: HSlider = $PauseLayer/PausePanel/VBox/MasterSlider
@onready var sfx_slider: HSlider = $PauseLayer/PausePanel/VBox/SfxSlider

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var next_spawn_x: float = -120.0
var bootstrap_release_x: float = 0.0

var distance_score: int = 0
var pickup_score: int = 0
var risk_score: int = 0
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
var current_biome_index: int = 0
var hazard_hit_cooldown: float = 0.0
var segments_since_hazard_spawn: int = HAZARD_SEGMENT_PITY_COUNT
var danger_routes_since_health: int = 0
var routes_since_speed_pickup: int = 0
var combo_count: int = 0
var combo_timeout_until: float = 0.0
var run_mode: String = "standard"
var run_seed: int = 0
var sfx_volume_db: float = -6.0
var window_size_index: int = 1
var info_notice: String = ""
var info_notice_until: float = 0.0
var run_end_requested: bool = false
var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var shield_hits: int = 0
var chrono_until: float = 0.0
var ability_cooldown_until: float = 0.0
var rift_event_type: int = 0
var rift_event_name: String = ""
var rift_event_target: int = 0
var rift_event_progress: int = 0
var rift_event_failed: bool = false
var rift_event_start_x: float = 0.0

var rift_active: bool = false
var rift_until: float = 0.0
var next_rift_at: float = 0.0

enum MissionType { COINS, SURVIVE_TIME, NO_HIT_DISTANCE }
enum PlatformType { SOLID, ONE_WAY_UP, DROP_THROUGH, GHOST }
enum AbilityType { SHIELD, CHRONO }
enum RiftEventType { NONE, COIN_SURGE, PHASE_LINE, EMBER_BREAKER }
enum EncounterPhase { PLATFORM_CHALLENGE, HAZARD_PRESSURE, RECOVERY_WINDOW, REWARD_BURST }
var mission_type: int = MissionType.COINS
var mission_no_hit_start_x: float = 0.0
var encounter_phase: int = EncounterPhase.PLATFORM_CHALLENGE
var encounter_segments_left: int = 0
var hazard_pressure_chaser_spawned: bool = false
var last_segment_spawned_chaser: bool = false
var hazards_dodged: int = 0
var max_pace_level: int = 0

var platforms: Array[Node2D] = []
var coins: Array[Area2D] = []
var big_coins: Array[Area2D] = []
var hazards: Array[Area2D] = []
var health_pickups: Array[Area2D] = []
var speed_pickups: Array[Area2D] = []
var ability_pickups: Array[Area2D] = []
var branch_chain_remaining: int = 0
var parallax_layers: Array[Dictionary] = []
var atmosphere_stars: Array[Dictionary] = []
var atmosphere_embers: Array[Dictionary] = []
var atmosphere_spires: Array[Dictionary] = []
var atmosphere_smog: Array[Dictionary] = []
var segments_since_drop_through: int = 0
var lane_guides: Array[Dictionary] = []

func _ready() -> void:
	_setup_run_mode_and_seed()
	_load_audio_settings()
	_load_display_settings()
	player.global_position = Vector2(120.0, 408.0)
	player.velocity = Vector2.ZERO
	player.jump_triggered.connect(_on_player_jump_triggered)
	mission_no_hit_start_x = player.global_position.x
	_build_static_opening()
	_build_atmosphere_decor()
	_build_lane_guides()
	_build_parallax_layers()
	_setup_biome_music()
	_init_mission()
	_init_encounter_director()
	_prewarm_post_bootstrap_route()
	next_rift_at = rng.randf_range(RIFT_MIN_SECONDS, RIFT_MAX_SECONDS)
	_apply_biome_for_section(0, false)
	_apply_section_theme(0)
	score_label.text = "Score: 0"
	_refresh_health_label()
	status_label.text = "Status: SKY-FORGE DOCK"
	mission_label.text = _mission_text()
	_refresh_info_label()
	_refresh_legend_text()
	_set_info_notice("Rule plates: up arrow=up-through | up+down=drop-through | diamond=ghost", 6.0)
	version_label.text = "Version: %s" % BUILD_VERSION
	_setup_pause_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_rules_overlay.visible:
			_hide_pause_rules()
			return
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
	_update_active_abilities()
	_update_atmosphere_decor()
	_update_parallax_layers()
	_update_lane_guides()
	_check_hazard_dodges()
	_update_combo_timeout()
	_update_rift_event_progress()
	_animate_runtime_visuals(delta)
	_ensure_music_playing()
	_refresh_info_label()

	distance_score = int(player.global_position.x / 12.0)
	_refresh_score_label()
	max_pace_level = maxi(max_pace_level, player.get_pace_level())

	if _bootstrap_active():
		status_label.text = "Status: SKY-FORGE DOCK"
	else:
		var biome_name: String = _current_biome().get("name", "Foundry Rim")
		if rift_active:
			status_label.text = "Status: RIFT STORM (%s) | Pace %d" % [biome_name, player.get_pace_level()]
		else:
			status_label.text = "Status: FORGE RUN (%s) | Pace %d" % [biome_name, player.get_pace_level()]
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
		_place_coins(start_x, y, width, lane, 1.0, false)
	return start_x + width + gap_after

func _spawn_segment() -> void:
	var segment_len: float = _pick_segment_length()
	var lane: int = _pick_reachable_lane(last_lane)
	var y: float = LANE_Y[lane]
	var coin_mult: float = 1.0
	var force_coin_arch: bool = false
	var hazard_mult: float = 1.0
	var force_hazard: bool = false
	var allow_chaser: bool = true
	var force_chaser: bool = false
	var branch_force: bool = false
	var branch_mult: float = 1.0
	var recovery_mode: bool = false
	var reward_mode: bool = false

	match encounter_phase:
		EncounterPhase.PLATFORM_CHALLENGE:
			hazard_mult = 0.82
			branch_force = rng.randf() < 0.65
			branch_mult = 1.45
		EncounterPhase.HAZARD_PRESSURE:
			hazard_mult = 1.55
			force_hazard = (segments_since_hazard_spawn >= 1) or (rng.randf() < 0.45)
			allow_chaser = true
			# Guarantee at least one chaser during each hazard-pressure phase.
			force_chaser = (not hazard_pressure_chaser_spawned) and (encounter_segments_left <= 1)
			branch_mult = 0.90
		EncounterPhase.RECOVERY_WINDOW:
			hazard_mult = 0.35
			allow_chaser = false
			recovery_mode = true
			branch_mult = 0.55
		EncounterPhase.REWARD_BURST:
			coin_mult = 1.35
			force_coin_arch = true
			hazard_mult = 0.52
			allow_chaser = false
			reward_mode = true
			branch_mult = 1.20

	var platform_type: int = _pick_platform_type_for_lane(lane)
	if platform_type == PlatformType.DROP_THROUGH:
		segments_since_drop_through = 0
	else:
		segments_since_drop_through += 1
	if platform_type == PlatformType.DROP_THROUGH:
		_ensure_lane_support(next_spawn_x, segment_len, lane)

	var platform: StaticBody2D = _create_platform(next_spawn_x, y, segment_len, platform_type)
	platforms.append(platform)
	add_child(platform)

	_place_coins(next_spawn_x, y, segment_len, lane, coin_mult, force_coin_arch)
	var hazards_spawned: bool = _place_hazards(next_spawn_x, y, segment_len, lane, hazard_mult, force_hazard, allow_chaser, force_chaser)
	if encounter_phase == EncounterPhase.HAZARD_PRESSURE and last_segment_spawned_chaser:
		hazard_pressure_chaser_spawned = true
	if hazards_spawned:
		segments_since_hazard_spawn = 0
	else:
		segments_since_hazard_spawn += 1
	routes_since_speed_pickup += 1
	if recovery_mode:
		_maybe_place_speed_pickup(next_spawn_x, y, segment_len, lane, 0.74)
		var recovery_health: bool = _maybe_place_health_pickup(next_spawn_x, y, segment_len, lane, 0.88)
		if not recovery_health:
			_maybe_place_health_pickup(next_spawn_x, y, segment_len, lane, 1.0)
	elif reward_mode:
		_maybe_place_ability_pickup(next_spawn_x, y, segment_len, lane)
		_maybe_place_speed_pickup(next_spawn_x, y, segment_len, lane, 0.12)
	else:
		var speed_spawned: bool = _maybe_place_speed_pickup(next_spawn_x, y, segment_len, lane)
		if not speed_spawned and routes_since_speed_pickup >= SPEED_PICKUP_PITY_SEGMENTS and player.get_pace_level() >= 4:
			_maybe_place_speed_pickup(next_spawn_x, y, segment_len, lane, 1.0)
		_maybe_place_ability_pickup(next_spawn_x, y, segment_len, lane)
	_spawn_branch_routes(next_spawn_x, segment_len, lane, branch_force, branch_mult)

	var gap: float = _safe_gap_for_transition(last_lane, lane)
	next_spawn_x += segment_len + gap
	last_lane = lane

	if not _bootstrap_active():
		encounter_segments_left -= 1
		if encounter_segments_left <= 0:
			_advance_encounter_phase()

func _init_encounter_director() -> void:
	encounter_phase = EncounterPhase.PLATFORM_CHALLENGE
	encounter_segments_left = _encounter_length_for(encounter_phase)
	hazard_pressure_chaser_spawned = false

func _encounter_length_for(phase: int) -> int:
	var tier_bonus: int = mini(2, int((mission_tier - 1) / 3))
	match phase:
		EncounterPhase.PLATFORM_CHALLENGE:
			return 2 + tier_bonus
		EncounterPhase.HAZARD_PRESSURE:
			return 2 + tier_bonus
		EncounterPhase.RECOVERY_WINDOW:
			return 1
		EncounterPhase.REWARD_BURST:
			return 1 + (1 if mission_tier >= 5 else 0)
	return 1

func _encounter_name(phase: int = encounter_phase) -> String:
	match phase:
		EncounterPhase.PLATFORM_CHALLENGE:
			return "Platform Challenge"
		EncounterPhase.HAZARD_PRESSURE:
			return "Hazard Pressure"
		EncounterPhase.RECOVERY_WINDOW:
			return "Recovery Window"
		EncounterPhase.REWARD_BURST:
			return "Reward Burst"
	return "Unknown"

func _advance_encounter_phase() -> void:
	encounter_phase = (encounter_phase + 1) % 4
	encounter_segments_left = _encounter_length_for(encounter_phase)
	if encounter_phase == EncounterPhase.HAZARD_PRESSURE:
		hazard_pressure_chaser_spawned = false
	_set_info_notice("Encounter: %s" % _encounter_name(encounter_phase), 2.2)

func _pick_segment_length() -> float:
	# Slightly longer segments over time create a steadier rhythm while still increasing challenge.
	var tier_scale: float = clampf(float(mission_tier - 1) * 0.04, 0.0, 0.16)
	var min_len: float = MIN_SEGMENT + (MAX_SEGMENT - MIN_SEGMENT) * tier_scale
	return rng.randf_range(min_len, MAX_SEGMENT)

func _pick_platform_type_for_lane(lane: int) -> int:
	if lane == 0:
		return PlatformType.SOLID
	var roll: float = rng.randf()
	var amber_chance: float = DROP_THROUGH_BASE_CHANCE
	if segments_since_drop_through <= DROP_THROUGH_SUPPRESS_SEGMENTS:
		amber_chance = DROP_THROUGH_SUPPRESS_CHANCE
	elif segments_since_drop_through >= DROP_THROUGH_PITY_SEGMENTS:
		amber_chance = DROP_THROUGH_PITY_CHANCE

	if roll < 0.62:
		return PlatformType.ONE_WAY_UP
	if roll < 0.62 + amber_chance:
		return PlatformType.DROP_THROUGH
	return PlatformType.SOLID

func _ensure_lane_support(x: float, width: float, lane: int) -> void:
	if lane <= 0:
		return
	var support_lane: int = lane - 1
	if _has_lane_covering_platform(support_lane, x, width):
		return

	var support_y: float = LANE_Y[support_lane]
	var support_type: int = PlatformType.SOLID if support_lane == 0 else PlatformType.ONE_WAY_UP
	var support_platform: StaticBody2D = _create_platform(x, support_y, width, support_type)
	platforms.append(support_platform)
	add_child(support_platform)

func _has_lane_covering_platform(lane: int, x: float, width: float) -> bool:
	var min_x: float = x + 12.0
	var max_x: float = x + width - 12.0
	for platform: Node2D in platforms:
		if not is_instance_valid(platform):
			continue
		var platform_lane: int = int(platform.get_meta("lane", -1))
		if platform_lane != lane:
			continue
		var platform_start: float = float(platform.get_meta("start_x", 0.0))
		var platform_width: float = float(platform.get_meta("width", 0.0))
		var platform_end: float = platform_start + platform_width
		if platform_start <= min_x and platform_end >= max_x:
			return true
	return false

func _create_platform(x: float, y: float, width: float, platform_type: int) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = Vector2(x + width * 0.5, y)
	var lane_idx: int = _lane_for_y(y)
	body.set_meta("lane", lane_idx)
	body.set_meta("start_x", x)
	body.set_meta("width", width)
	body.set_meta("platform_type", platform_type)

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
	var palette: Dictionary = _platform_palette(platform_type)
	var top_strip_color: Color = palette.get("trim", Color.WHITE)
	visual.color = palette.get("base", Color(0.36, 0.42, 0.52))
	body.add_child(visual)

	var top_strip: Polygon2D = Polygon2D.new()
	top_strip.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.5),
		Vector2(width * 0.5, -PLATFORM_THICKNESS * 0.2),
		Vector2(-width * 0.5, -PLATFORM_THICKNESS * 0.2)
	])
	top_strip.color = top_strip_color
	body.add_child(top_strip)

	if platform_type != PlatformType.GHOST:
		_add_platform_surface_details(body, width, visual.color, top_strip_color)

	if platform_type == PlatformType.ONE_WAY_UP:
		_add_platform_chevrons(body, width, true, false, Color(0.72, 0.97, 1.0))
		_add_platform_rule_markers(body, width, platform_type)
	elif platform_type == PlatformType.DROP_THROUGH:
		_add_platform_chevrons(body, width, true, true, Color(1.0, 0.92, 0.54))
		_add_platform_rule_markers(body, width, platform_type)
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
		_add_platform_rule_markers(body, width, platform_type)

	return body

func _platform_palette(platform_type: int) -> Dictionary:
	# Biome-driven material palette keeps each zone visually distinct.
	var solid_base: Color
	var solid_trim: Color
	var up_base: Color
	var up_trim: Color
	var drop_base: Color
	var drop_trim: Color
	var ghost_base: Color
	var ghost_trim: Color

	match current_biome_index:
		0: # Foundry Rim: steel + cyan optics
			solid_base = Color(0.37, 0.41, 0.47)
			solid_trim = Color(0.70, 0.82, 0.92)
			up_base = Color(0.18, 0.48, 0.63)
			up_trim = Color(0.56, 0.95, 1.0)
			drop_base = Color(0.60, 0.43, 0.20)
			drop_trim = Color(1.0, 0.86, 0.34)
			ghost_base = Color(0.38, 0.34, 0.57, 0.56)
			ghost_trim = Color(0.87, 0.75, 1.0, 0.68)
		1: # Rift Span: colder alloys + blue/plasma tones
			solid_base = Color(0.28, 0.36, 0.50)
			solid_trim = Color(0.60, 0.84, 1.0)
			up_base = Color(0.16, 0.41, 0.66)
			up_trim = Color(0.50, 0.90, 1.0)
			drop_base = Color(0.43, 0.36, 0.24)
			drop_trim = Color(0.96, 0.84, 0.46)
			ghost_base = Color(0.45, 0.33, 0.66, 0.58)
			ghost_trim = Color(0.92, 0.80, 1.0, 0.70)
		_: # Ember Vault: warmer iron + ember accents
			solid_base = Color(0.44, 0.36, 0.34)
			solid_trim = Color(0.90, 0.78, 0.60)
			up_base = Color(0.28, 0.50, 0.56)
			up_trim = Color(0.62, 0.94, 0.95)
			drop_base = Color(0.64, 0.38, 0.19)
			drop_trim = Color(1.0, 0.78, 0.33)
			ghost_base = Color(0.45, 0.30, 0.52, 0.58)
			ghost_trim = Color(0.94, 0.74, 0.94, 0.70)

	if platform_type == PlatformType.GHOST:
		return {"base": ghost_base, "trim": ghost_trim}
	if platform_type == PlatformType.DROP_THROUGH:
		return {"base": drop_base, "trim": drop_trim}
	if platform_type == PlatformType.ONE_WAY_UP:
		return {"base": up_base, "trim": up_trim}
	return {"base": solid_base, "trim": solid_trim}

func _add_platform_surface_details(body: StaticBody2D, width: float, base_color: Color, trim_color: Color) -> void:
	var panel_count: int = maxi(1, mini(10, int(width / PLATFORM_PANEL_GAP)))
	for i: int in panel_count:
		var t: float = float(i + 1) / float(panel_count + 1)
		var px: float = lerpf(-width * 0.5 + 18.0, width * 0.5 - 18.0, t)
		var panel: Polygon2D = Polygon2D.new()
		panel.polygon = PackedVector2Array([
			Vector2(px - 14.0, -6.0),
			Vector2(px + 14.0, -6.0),
			Vector2(px + 14.0, 5.5),
			Vector2(px - 14.0, 5.5)
		])
		panel.color = base_color.darkened(0.16)
		body.add_child(panel)

		var panel_glow: Polygon2D = Polygon2D.new()
		panel_glow.polygon = PackedVector2Array([
			Vector2(px - 11.0, -5.0),
			Vector2(px + 11.0, -5.0),
			Vector2(px + 11.0, -3.2),
			Vector2(px - 11.0, -3.2)
		])
		panel_glow.color = trim_color.lightened(0.12)
		body.add_child(panel_glow)

	var rivet_count: int = maxi(2, mini(14, int(width / PLATFORM_RIVET_GAP)))
	for i: int in rivet_count:
		var t: float = float(i + 1) / float(rivet_count + 1)
		var rx: float = lerpf(-width * 0.5 + 10.0, width * 0.5 - 10.0, t)
		var rivet: Polygon2D = Polygon2D.new()
		rivet.polygon = PackedVector2Array([
			Vector2(rx - 2.2, -9.2), Vector2(rx + 2.2, -9.2), Vector2(rx + 2.2, -5.8), Vector2(rx - 2.2, -5.8)
		])
		rivet.color = trim_color.lightened(0.06)
		body.add_child(rivet)

func _lane_for_y(y: float) -> int:
	var closest_idx: int = 0
	var closest_dist: float = absf(y - LANE_Y[0])
	for idx: int in range(1, LANE_Y.size()):
		var dist: float = absf(y - LANE_Y[idx])
		if dist < closest_dist:
			closest_dist = dist
			closest_idx = idx
	return closest_idx

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

func _add_platform_rule_markers(body: StaticBody2D, width: float, platform_type: int) -> void:
	var marker_count: int = 1 if width < 260.0 else 2
	for i: int in marker_count:
		var t: float = 0.18 if marker_count == 1 else (0.16 if i == 0 else 0.84)
		var mx: float = lerpf(-width * 0.5 + 20.0, width * 0.5 - 20.0, t)

		var plate: Polygon2D = Polygon2D.new()
		plate.polygon = PackedVector2Array([
			Vector2(mx - 10.0, -13.0), Vector2(mx + 10.0, -13.0), Vector2(mx + 10.0, 7.0), Vector2(mx - 10.0, 7.0)
		])
		if platform_type == PlatformType.ONE_WAY_UP:
			plate.color = Color(0.08, 0.22, 0.31, 0.85)
		elif platform_type == PlatformType.DROP_THROUGH:
			plate.color = Color(0.36, 0.24, 0.08, 0.85)
		else:
			plate.color = Color(0.24, 0.14, 0.35, 0.82)
		body.add_child(plate)

		if platform_type == PlatformType.ONE_WAY_UP:
			var up_glyph: Polygon2D = Polygon2D.new()
			up_glyph.polygon = PackedVector2Array([
				Vector2(mx - 5.0, -2.0), Vector2(mx, -9.0), Vector2(mx + 5.0, -2.0)
			])
			up_glyph.color = Color(0.72, 0.98, 1.0)
			body.add_child(up_glyph)
		elif platform_type == PlatformType.DROP_THROUGH:
			var up_glyph_dt: Polygon2D = Polygon2D.new()
			up_glyph_dt.polygon = PackedVector2Array([
				Vector2(mx - 5.0, -4.0), Vector2(mx, -10.0), Vector2(mx + 5.0, -4.0)
			])
			up_glyph_dt.color = Color(1.0, 0.95, 0.62)
			body.add_child(up_glyph_dt)

			var down_glyph_dt: Polygon2D = Polygon2D.new()
			down_glyph_dt.polygon = PackedVector2Array([
				Vector2(mx - 5.0, 0.0), Vector2(mx, 6.0), Vector2(mx + 5.0, 0.0)
			])
			down_glyph_dt.color = Color(1.0, 0.84, 0.44)
			body.add_child(down_glyph_dt)
		else:
			var ring: Polygon2D = Polygon2D.new()
			ring.polygon = PackedVector2Array([
				Vector2(mx - 6.0, -2.0), Vector2(mx, -8.0), Vector2(mx + 6.0, -2.0), Vector2(mx, 4.0)
			])
			ring.color = Color(0.96, 0.88, 1.0, 0.85)
			body.add_child(ring)

func _place_coins(x: float, y: float, width: float, lane: int, reward_mult: float = 1.0, force_arch: bool = false) -> void:
	var biome_bonus: int = int(_current_biome().get("coin_bonus", 0))
	var lane_bonus: int = 1 if lane > 0 else 0
	var pace_bonus: int = int(floor(float(player.get_pace_level()) / 3.0))
	var count: int = 3 + int(width / 200.0) + biome_bonus + lane_bonus + pace_bonus
	count = int(round(float(count) * clampf(reward_mult, 0.7, 1.8)))
	count = clampi(count, 3, 10)
	var base_coin_fraction: float = 1.0
	var coin_y: float = _fractional_y(y, base_coin_fraction)
	var arch_chance: float = COIN_ARCH_CHANCE
	arch_chance += BIOME_ARCH_BONUS[current_biome_index]
	if reward_mult > 1.0:
		arch_chance = minf(0.9, arch_chance + ((reward_mult - 1.0) * 0.35))
	var use_arch: bool = lane > 0 and width >= COIN_ARCH_MIN_WIDTH and (force_arch or (rng.randf() < arch_chance))

	for i: int in count:
		var t: float = float(i + 1) / float(count + 1)
		var coin_x: float = lerpf(x + 26.0, x + width - 26.0, t)
		if use_arch:
			var arc: float = 1.0 - pow((t * 2.0) - 1.0, 2.0)
			coin_y = _fractional_y(y, base_coin_fraction + (arc * 2.0))
		var coin: Area2D = _create_coin(Vector2(coin_x, coin_y))
		coins.append(coin)
		add_child(coin)
	if use_arch and width >= 300.0:
		var reward_roll: float = rng.randf()
		var reward_x: float = x + (width * 0.5)
		var big_coin_bias: float = 0.62 + (0.14 if current_biome_index == 2 else 0.0)
		if reward_roll < big_coin_bias:
			var big_coin_y: float = _fractional_y(y, BIG_COIN_APEX_FRACTION)
			var big_coin: Area2D = _create_big_coin(Vector2(reward_x, big_coin_y))
			big_coins.append(big_coin)
			add_child(big_coin)
		elif reward_roll < (0.78 if current_biome_index == 2 else 0.76):
			# Rarely put a strategic pickup at arch apex.
			var apex_pickup_y: float = _fractional_y(y, BIG_COIN_APEX_FRACTION)
			var ability_kind: int = AbilityType.SHIELD if rng.randf() < 0.5 else AbilityType.CHRONO
			var pickup: Area2D = _create_ability_pickup(Vector2(reward_x, apex_pickup_y), ability_kind)
			ability_pickups.append(pickup)
			add_child(pickup)

func _place_hazards(x: float, y: float, width: float, lane: int, encounter_mult: float = 1.0, force_spawn: bool = false, allow_chaser: bool = true, force_chaser: bool = false) -> bool:
	if lane > 2:
		return false
	last_segment_spawned_chaser = false
	var pace_level: int = player.get_pace_level()
	var hazard_mult: float = float(_current_biome().get("hazard_mult", 1.0))
	var skip_chance: float = clampf((0.42 / hazard_mult) - (float(pace_level) * 0.024), 0.04, 0.62)
	if width < 260.0 and rng.randf() < skip_chance:
		return false

	var pace_bonus: float = minf(0.20, float(pace_level) * 0.03)
	var segment_hazard_chance: float = clampf(((HAZARD_SEGMENT_BASE_CHANCE * hazard_mult) + pace_bonus) * encounter_mult, 0.12, 0.95)
	if segments_since_hazard_spawn <= 0:
		segment_hazard_chance = HAZARD_SEGMENT_COOLDOWN_CHANCE
	elif segments_since_hazard_spawn >= HAZARD_SEGMENT_PITY_COUNT:
		segment_hazard_chance = maxf(segment_hazard_chance, 0.92)
	if force_spawn:
		segment_hazard_chance = maxf(segment_hazard_chance, 0.96)
	if rng.randf() > segment_hazard_chance:
		return false

	var pattern_roll: float = rng.randf()
	if rift_active:
		pattern_roll += 0.18
	pattern_roll += (hazard_mult - 1.0) * 0.12
	if current_biome_index == 0:
		# Foundry Rim leans into static clusters.
		pattern_roll += 0.10

	if pattern_roll < 0.34:
		_spawn_hazard_single(x, y, width)
	elif pattern_roll < 0.72:
		_spawn_hazard_pair(x, y, width)
	else:
		_spawn_hazard_gate(x, y, width)

	var early_bonus: float = 0.10 if current_section <= 1 else 0.0
	var chaser_chance: float = HAZARD_CHASER_CHANCE + BIOME_CHASER_BONUS[current_biome_index] + early_bonus + minf(0.18, float(pace_level) * 0.022)
	if allow_chaser and ((force_chaser and width > 220.0) or (width > 300.0 and rng.randf() < chaser_chance)):
		_spawn_hazard_chaser(x, y, width)
		last_segment_spawned_chaser = true

	if rift_active and width > 320.0 and rng.randf() < 0.45:
		var spike_x: float = x + rng.randf_range(120.0, width - 90.0)
		_spawn_hazard_at(Vector2(spike_x, y - (PLATFORM_THICKNESS * 0.5) - 18.0))
	return true

func _spawn_hazard_single(x: float, y: float, width: float) -> void:
	if rng.randf() < 0.12:
		return
	var hx: float = _hazard_x(x, width, rng.randf_range(0.40, 0.70))
	_spawn_hazard_at(Vector2(hx, y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _spawn_hazard_pair(x: float, y: float, width: float) -> void:
	if width < 290.0:
		_spawn_hazard_single(x, y, width)
		return
	var first_x: float = _hazard_x(x, width, rng.randf_range(0.30, 0.40))
	var second_x: float = _hazard_x(x, width, rng.randf_range(0.60, 0.74))
	if second_x - first_x < 72.0:
		second_x = minf(x + width - HAZARD_EDGE_CLEARANCE, first_x + 72.0)
	_spawn_hazard_at(Vector2(first_x, y - (PLATFORM_THICKNESS * 0.5) - 18.0))
	_spawn_hazard_at(Vector2(second_x, y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _spawn_hazard_gate(x: float, y: float, width: float) -> void:
	if width < 330.0:
		_spawn_hazard_pair(x, y, width)
		return
	var center: float = _hazard_x(x, width, rng.randf_range(0.55, 0.70))
	_spawn_hazard_at(Vector2(maxf(x + HAZARD_EDGE_CLEARANCE, center - 38.0), y - (PLATFORM_THICKNESS * 0.5) - 18.0))
	_spawn_hazard_at(Vector2(minf(x + width - HAZARD_EDGE_CLEARANCE, center + 38.0), y - (PLATFORM_THICKNESS * 0.5) - 18.0))

func _hazard_x(x: float, width: float, ratio: float) -> float:
	return x + clampf(width * ratio, HAZARD_EDGE_CLEARANCE, width - HAZARD_EDGE_CLEARANCE)

func _fractional_y(platform_y: float, steps_up: float) -> float:
	return platform_y - (FRACTIONAL_LANE_STEP * steps_up)

func _spawn_hazard_at(pos: Vector2) -> void:
	var hazard: Area2D = _create_hazard(pos)
	hazards.append(hazard)
	add_child(hazard)

func _spawn_hazard_chaser(x: float, y: float, width: float) -> void:
	var spawn_x: float = _hazard_x(x, width, 0.86)
	# Keep chasers at least one fractional lane above the nearest platform so crouch remains viable.
	var spawn_y: float = y - (PLATFORM_THICKNESS * 0.5) - (FRACTIONAL_LANE_STEP * CHASER_MIN_PLATFORM_CLEARANCE_STEPS) - 8.0
	var speed: float = rng.randf_range(HAZARD_CHASER_MIN_SPEED, HAZARD_CHASER_MAX_SPEED)
	var chaser: Area2D = _create_hazard_chaser(Vector2(spawn_x, spawn_y), speed)
	hazards.append(chaser)
	add_child(chaser)

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
	var hy: float = _fractional_y(y, POWERUP_DEFAULT_FRACTION)
	var pickup: Area2D = _create_health_pickup(Vector2(hx, hy))
	health_pickups.append(pickup)
	add_child(pickup)
	return true

func _spawn_branch_routes(x: float, width: float, base_lane: int, force_branches: bool = false, spawn_mult: float = 1.0) -> void:
	if width < 320.0:
		return
	var spawn_branches: bool = false
	if branch_chain_remaining > 0:
		spawn_branches = true
		branch_chain_remaining -= 1
	elif force_branches or rng.randf() < (BRANCH_CHAIN_CHANCE * spawn_mult):
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
	var branch_amber_chance: float = BRANCH_DROP_THROUGH_CHANCE_MID
	if target_lane >= 2:
		branch_amber_chance = BRANCH_DROP_THROUGH_CHANCE_TOP
	if segments_since_drop_through <= DROP_THROUGH_SUPPRESS_SEGMENTS:
		branch_amber_chance *= 0.55
	elif segments_since_drop_through >= DROP_THROUGH_PITY_SEGMENTS:
		branch_amber_chance = minf(0.40, branch_amber_chance + 0.12)
	if target_lane > 0 and type_roll < branch_amber_chance:
		platform_type = PlatformType.DROP_THROUGH
	elif type_roll > 0.95:
		platform_type = PlatformType.GHOST
	if platform_type == PlatformType.DROP_THROUGH:
		_ensure_lane_support(alt_x, alt_width, target_lane)

	var branch_platform: StaticBody2D = _create_platform(alt_x, target_y, alt_width, platform_type)
	platforms.append(branch_platform)
	add_child(branch_platform)

	_place_coins(alt_x, target_y, alt_width, target_lane, 1.0, false)

	danger_routes_since_health += 1
	_maybe_spawn_branch_hazard(alt_x, target_y, alt_width, lane_delta)

	var health_spawn_chance: float = _compute_health_spawn_chance()
	var health_spawned: bool = _maybe_place_health_pickup(alt_x, target_y, alt_width, target_lane, health_spawn_chance)
	if not health_spawned and health <= 3 and danger_routes_since_health >= HEALTH_PICKUP_PITY_DANGER_ROUTES:
		_maybe_place_health_pickup(alt_x, target_y, alt_width, target_lane, 1.0)

func _maybe_spawn_branch_hazard(x: float, y: float, width: float, lane_delta: int) -> bool:
	if width < 190.0:
		return false
	var spawn_chance: float = 0.50 + (0.06 * float(lane_delta - 1))
	if rift_active:
		spawn_chance += 0.08
	if rng.randf() > clampf(spawn_chance, 0.40, 0.72):
		return false
	var hx: float = _hazard_x(x, width, rng.randf_range(HAZARD_BRANCH_MIN_RATIO, HAZARD_BRANCH_MAX_RATIO))
	_spawn_hazard_at(Vector2(hx, y - (PLATFORM_THICKNESS * 0.5) - 18.0))
	return true

func _maybe_place_speed_pickup(x: float, y: float, width: float, lane: int, override_chance: float = -1.0) -> bool:
	if lane > 2:
		return false
	var pace_level: int = player.get_pace_level()
	var pace_bonus_chance: float = maxf(0.0, float(pace_level - 2)) * 0.006
	var section_penalty: float = minf(0.025, float(current_section) * ECON_SECTION_DIFFICULTY_STEP)
	var spawn_chance: float = SPEED_PICKUP_CHANCE + pace_bonus_chance - section_penalty
	if pace_level <= 2:
		spawn_chance *= 0.45
	spawn_chance = clampf(spawn_chance, 0.008, SPEED_PICKUP_MAX_CHANCE)
	if override_chance >= 0.0:
		spawn_chance = override_chance
	if rng.randf() > spawn_chance:
		return false
	var min_offset: float = minf(90.0, width * 0.32)
	var max_offset: float = maxf(min_offset + 8.0, width - 60.0)
	var sx: float = x + rng.randf_range(min_offset, max_offset)
	var sy: float = _fractional_y(y, POWERUP_DEFAULT_FRACTION)
	var pickup: Area2D = _create_speed_pickup(Vector2(sx, sy))
	speed_pickups.append(pickup)
	add_child(pickup)
	return true

func _maybe_place_ability_pickup(x: float, y: float, width: float, lane: int) -> bool:
	if lane > 2:
		return false
	if run_seconds < ability_cooldown_until:
		return false
	var chance: float = ABILITY_PICKUP_BASE_CHANCE
	if shield_hits > 0 or chrono_until > run_seconds:
		chance *= 0.35
	if rng.randf() > chance:
		return false
	var kind: int = AbilityType.SHIELD if rng.randf() < 0.55 else AbilityType.CHRONO
	var ax: float = x + rng.randf_range(width * 0.30, width * 0.75)
	var ay: float = _fractional_y(y, POWERUP_DEFAULT_FRACTION + 0.3)
	var pickup: Area2D = _create_ability_pickup(Vector2(ax, ay), kind)
	ability_pickups.append(pickup)
	add_child(pickup)
	return true

func _create_coin(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos
	area.set_meta("base_y", pos.y)

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 13.0
	shape.shape = circle
	area.add_child(shape)

	var sprite: Polygon2D = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-11, 0), Vector2(0, -11), Vector2(11, 0), Vector2(0, 11)
	])
	sprite.color = Color(1.0, 0.90, 0.28)
	sprite.set_meta("is_coin_core", true)
	area.add_child(sprite)

	var ring: Polygon2D = Polygon2D.new()
	ring.polygon = PackedVector2Array([
		Vector2(-14, 0), Vector2(0, -14), Vector2(14, 0), Vector2(0, 14)
	])
	ring.color = Color(1.0, 0.98, 0.64, 0.42)
	ring.set_meta("is_coin_ring", true)
	area.add_child(ring)

	var glint: Polygon2D = Polygon2D.new()
	glint.polygon = PackedVector2Array([
		Vector2(-1, -8), Vector2(2, -8), Vector2(1, -3), Vector2(-2, -3)
	])
	glint.color = Color(1.0, 1.0, 0.92, 0.86)
	glint.set_meta("is_coin_glint", true)
	area.add_child(glint)

	area.body_entered.connect(_on_coin_body_entered.bind(area))
	return area

func _create_big_coin(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos
	area.set_meta("base_y", pos.y)

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	area.add_child(shape)

	var sprite: Polygon2D = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-15, 0), Vector2(0, -15), Vector2(15, 0), Vector2(0, 15)
	])
	sprite.color = Color(1.0, 0.68, 0.10)
	sprite.set_meta("is_big_coin_core", true)
	area.add_child(sprite)

	var ring: Polygon2D = Polygon2D.new()
	ring.polygon = PackedVector2Array([
		Vector2(-20, 0), Vector2(0, -20), Vector2(20, 0), Vector2(0, 20)
	])
	ring.color = Color(1.0, 0.84, 0.45, 0.48)
	ring.set_meta("is_big_coin_ring", true)
	area.add_child(ring)

	var star: Polygon2D = Polygon2D.new()
	star.polygon = PackedVector2Array([
		Vector2(0, -8), Vector2(2, -2), Vector2(8, -2), Vector2(3, 1), Vector2(5, 7),
		Vector2(0, 3), Vector2(-5, 7), Vector2(-3, 1), Vector2(-8, -2), Vector2(-2, -2)
	])
	star.color = Color(1.0, 0.98, 0.84, 0.88)
	star.set_meta("is_big_coin_star", true)
	area.add_child(star)

	area.body_entered.connect(_on_big_coin_body_entered.bind(area))
	return area

func _create_hazard(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 11.0
	shape.shape = circle
	area.add_child(shape)

	var base: Polygon2D = Polygon2D.new()
	base.polygon = PackedVector2Array([
		Vector2(-20, 13), Vector2(20, 13), Vector2(14, 22), Vector2(-14, 22)
	])
	base.color = Color(0.22, 0.17, 0.16)
	area.add_child(base)

	var danger_ring: Polygon2D = Polygon2D.new()
	danger_ring.polygon = PackedVector2Array([
		Vector2(-22, 12), Vector2(0, -29), Vector2(22, 12), Vector2(15, 22), Vector2(-15, 22)
	])
	danger_ring.color = Color(1.0, 0.36, 0.20, 0.22)
	area.add_child(danger_ring)

	var flame_outer: Polygon2D = Polygon2D.new()
	flame_outer.polygon = PackedVector2Array([
		Vector2(-17, 16), Vector2(-6, -4), Vector2(0, -27), Vector2(7, -4), Vector2(17, 16)
	])
	flame_outer.color = Color(0.96, 0.35, 0.22)
	flame_outer.set_meta("is_flame_outer", true)
	area.add_child(flame_outer)

	var flame_inner: Polygon2D = Polygon2D.new()
	flame_inner.polygon = PackedVector2Array([
		Vector2(-9, 14), Vector2(-2, 1), Vector2(0, -15), Vector2(4, 1), Vector2(9, 14)
	])
	flame_inner.color = Color(1.0, 0.80, 0.34)
	flame_inner.set_meta("is_flame_inner", true)
	area.add_child(flame_inner)

	area.body_entered.connect(_on_hazard_body_entered)
	return area

func _create_hazard_chaser(pos: Vector2, speed: float) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos
	area.set_meta("hazard_kind", "chaser")
	area.set_meta("move_speed", speed)
	area.set_meta("base_y", pos.y)
	area.set_meta("phase", rng.randf_range(0.0, TAU))

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	area.add_child(shape)

	var core: Polygon2D = Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-19, 0), Vector2(-8, -14), Vector2(8, -14), Vector2(19, 0), Vector2(8, 14), Vector2(-8, 14)
	])
	core.color = Color(0.92, 0.34, 0.20, 0.96)
	core.set_meta("is_chaser_core", true)
	area.add_child(core)

	var eye: Polygon2D = Polygon2D.new()
	eye.polygon = PackedVector2Array([
		Vector2(-8, -3), Vector2(8, -3), Vector2(8, 3), Vector2(-8, 3)
	])
	eye.color = Color(1.0, 0.90, 0.40, 0.96)
	eye.set_meta("is_chaser_eye", true)
	area.add_child(eye)

	var trail: Polygon2D = Polygon2D.new()
	trail.polygon = PackedVector2Array([
		Vector2(17, -10), Vector2(32, -5), Vector2(32, 5), Vector2(17, 10)
	])
	trail.color = Color(1.0, 0.46, 0.22, 0.40)
	trail.set_meta("is_chaser_trail", true)
	area.add_child(trail)

	area.body_entered.connect(_on_hazard_body_entered)
	return area

func _create_speed_pickup(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 15.0
	shape.shape = circle
	area.add_child(shape)

	var ring: Polygon2D = Polygon2D.new()
	ring.polygon = PackedVector2Array([
		Vector2(-15, 0), Vector2(0, -15), Vector2(15, 0), Vector2(0, 15)
	])
	ring.color = Color(0.28, 0.78, 1.0, 0.88)
	area.add_child(ring)

	var core: Polygon2D = Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-11, 0), Vector2(0, -11), Vector2(11, 0), Vector2(0, 11)
	])
	core.color = Color(0.08, 0.34, 0.52, 0.96)
	core.set_meta("is_speed_core", true)
	area.add_child(core)

	var minus: Polygon2D = Polygon2D.new()
	minus.polygon = PackedVector2Array([
		Vector2(-7, -2), Vector2(7, -2), Vector2(7, 2), Vector2(-7, 2)
	])
	minus.color = Color(0.86, 0.98, 1.0)
	minus.set_meta("is_speed_minus", true)
	area.add_child(minus)

	area.body_entered.connect(_on_speed_pickup_body_entered.bind(area))
	return area

func _create_ability_pickup(pos: Vector2, ability_kind: int) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos
	area.set_meta("ability_kind", ability_kind)

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	area.add_child(shape)

	var ring: Polygon2D = Polygon2D.new()
	ring.polygon = PackedVector2Array([
		Vector2(-15, 0), Vector2(0, -15), Vector2(15, 0), Vector2(0, 15)
	])
	if ability_kind == AbilityType.SHIELD:
		ring.color = Color(0.54, 0.93, 1.0, 0.82)
	else:
		ring.color = Color(1.0, 0.86, 0.42, 0.84)
	area.add_child(ring)

	var core: Polygon2D = Polygon2D.new()
	if ability_kind == AbilityType.SHIELD:
		core.polygon = PackedVector2Array([
			Vector2(-6, -3), Vector2(0, -10), Vector2(6, -3), Vector2(4, 7), Vector2(-4, 7)
		])
		core.color = Color(0.84, 0.98, 1.0)
	else:
		# Hourglass silhouette is clearer than a tiny lightning bolt.
		core.polygon = PackedVector2Array([
			Vector2(-6, -9), Vector2(6, -9), Vector2(2, -3), Vector2(-2, -3),
			Vector2(-2, 3), Vector2(2, 3), Vector2(6, 9), Vector2(-6, 9)
		])
		core.color = Color(1.0, 0.95, 0.74)
	area.add_child(core)

	area.body_entered.connect(_on_ability_pickup_body_entered.bind(area))
	return area

func _create_health_pickup(pos: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.position = pos

	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 15.0
	shape.shape = circle
	area.add_child(shape)

	var core: Polygon2D = Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-12, -5), Vector2(-5, -5), Vector2(-5, -12), Vector2(5, -12),
		Vector2(5, -5), Vector2(12, -5), Vector2(12, 5), Vector2(5, 5),
		Vector2(5, 12), Vector2(-5, 12), Vector2(-5, 5), Vector2(-12, 5)
	])
	core.color = Color(0.40, 0.96, 0.50)
	area.add_child(core)

	var ring: Polygon2D = Polygon2D.new()
	ring.polygon = PackedVector2Array([
		Vector2(-16, 0), Vector2(0, -16), Vector2(16, 0), Vector2(0, 16)
	])
	ring.color = Color(0.70, 1.0, 0.76, 0.42)
	area.add_child(ring)

	area.body_entered.connect(_on_health_pickup_body_entered.bind(area))
	return area

func _on_coin_body_entered(body: Node, coin: Area2D) -> void:
	if body != player:
		return
	_play_sfx_tone(980.0, 0.045, -14.0)
	pickup_score += 25
	_register_combo(1, "", false)
	total_coins_collected += 1
	while total_coins_collected >= next_bonus_heart_at:
		_apply_health_delta(1)
		next_bonus_heart_at += COINS_PER_BONUS_HEART
		_set_info_notice("Coin milestone reached! +1 HP | Next at %d coins" % next_bonus_heart_at)
	if mission_type == MissionType.COINS:
		mission_progress += 1
	if rift_active and rift_event_type == RiftEventType.COIN_SURGE:
		rift_event_progress += 1
	coins.erase(coin)
	coin.queue_free()

func _on_big_coin_body_entered(body: Node, big_coin: Area2D) -> void:
	if body != player:
		return
	_play_sfx_tone(1120.0, 0.08, -11.0)
	pickup_score += 25 * BIG_COIN_VALUE
	_register_combo(2, "Big relic x10", false)
	total_coins_collected += BIG_COIN_VALUE
	while total_coins_collected >= next_bonus_heart_at:
		_apply_health_delta(1)
		next_bonus_heart_at += COINS_PER_BONUS_HEART
		_set_info_notice("Coin milestone reached! +1 HP | Next at %d coins" % next_bonus_heart_at)
	if mission_type == MissionType.COINS:
		mission_progress += BIG_COIN_VALUE
	if rift_active and rift_event_type == RiftEventType.COIN_SURGE:
		rift_event_progress += BIG_COIN_VALUE
	big_coins.erase(big_coin)
	big_coin.queue_free()

func _on_hazard_body_entered(body: Node) -> void:
	if body != player:
		return
	if hazard_hit_cooldown > 0.0:
		return
	hazard_hit_cooldown = HAZARD_HIT_COOLDOWN
	if shield_hits > 0:
		shield_hits -= 1
		_play_sfx_tone(520.0, 0.12, -6.0)
		_set_info_notice("Aegis absorbed impact", 2.0)
		return
	_play_sfx_tone(210.0, 0.14, -6.0)
	_apply_health_delta(-1)
	_break_combo("Impact taken")
	mission_no_hit_start_x = player.global_position.x
	if rift_active and rift_event_type == RiftEventType.PHASE_LINE:
		rift_event_failed = true
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

func _on_ability_pickup_body_entered(body: Node, pickup: Area2D) -> void:
	if body != player:
		return
	var kind: int = int(pickup.get_meta("ability_kind", AbilityType.SHIELD))
	if kind == AbilityType.SHIELD:
		shield_hits = SHIELD_HITS_GRANTED
		_set_info_notice("Aegis acquired: next hit blocked", 2.8)
		_play_sfx_tone(420.0, 0.16, -8.0)
	else:
		chrono_until = run_seconds + CHRONO_DURATION
		Engine.time_scale = 0.84
		_set_info_notice("Chrono surge: time dilated", 2.8)
		_play_sfx_tone(300.0, 0.18, -8.0)
	ability_cooldown_until = run_seconds + ABILITY_COOLDOWN_SECONDS
	_register_combo(1, "Ability chain", false)
	ability_pickups.erase(pickup)
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

	for ap: Area2D in ability_pickups.duplicate():
		if ap.global_position.x < limit:
			ability_pickups.erase(ap)
			ap.queue_free()

func _animate_runtime_visuals(delta: float) -> void:
	var phase: float = run_seconds * 5.8

	for coin: Area2D in coins:
		if not is_instance_valid(coin):
			continue
		coin.rotation = sin(phase + coin.global_position.x * 0.013) * 0.18
		var coin_base_y: float = float(coin.get_meta("base_y", coin.position.y))
		coin.position.y = coin_base_y + (sin((phase * 1.6) + coin.global_position.x * 0.011) * 4.0)

	for big_coin: Area2D in big_coins:
		if not is_instance_valid(big_coin):
			continue
		big_coin.rotation = sin((phase * 0.9) + big_coin.global_position.x * 0.008) * 0.22
		var big_base_y: float = float(big_coin.get_meta("base_y", big_coin.position.y))
		big_coin.position.y = big_base_y + (sin((phase * 1.2) + big_coin.global_position.x * 0.009) * 5.0)
		big_coin.scale = Vector2.ONE * (1.0 + (sin(phase + big_coin.global_position.x * 0.006) * 0.04))

	for hazard: Area2D in hazards:
		if not is_instance_valid(hazard):
			continue
		if String(hazard.get_meta("hazard_kind", "")) == "chaser":
			var move_speed: float = float(hazard.get_meta("move_speed", HAZARD_CHASER_MIN_SPEED))
			var h_phase: float = float(hazard.get_meta("phase", 0.0))
			var h_base_y: float = float(hazard.get_meta("base_y", hazard.position.y))
			hazard.position.x -= move_speed * delta
			hazard.position.y = h_base_y + (sin((run_seconds * 3.8) + h_phase) * 8.0)
		var flicker: float = 1.0 + (sin((phase * 1.8) + hazard.global_position.x * 0.02) * 0.08)
		for node: Node in hazard.get_children():
			if node is Polygon2D:
				var poly: Polygon2D = node
				if bool(poly.get_meta("is_flame_outer", false)):
					poly.scale = Vector2(flicker, 1.0 + (flicker - 1.0) * 1.7)
				elif bool(poly.get_meta("is_flame_inner", false)):
					poly.scale = Vector2(flicker * 0.95, 1.0 + (flicker - 1.0) * 2.0)
				elif bool(poly.get_meta("is_chaser_core", false)):
					poly.rotation = sin((phase * 1.2) + hazard.global_position.x * 0.01) * 0.08
				elif bool(poly.get_meta("is_chaser_eye", false)):
					poly.scale = Vector2(1.0 + (flicker - 1.0) * 1.8, 1.0)
				elif bool(poly.get_meta("is_chaser_trail", false)):
					poly.scale = Vector2(1.0 + (flicker - 1.0) * 2.4, 1.0)

	for pickup: Area2D in speed_pickups:
		if not is_instance_valid(pickup):
			continue
		pickup.rotation = sin((phase * 0.9) + pickup.global_position.x * 0.008) * 0.10
		pickup.scale = Vector2.ONE * (1.0 + (sin((phase * 1.4) + pickup.global_position.x * 0.01) * 0.05))

	for pickup: Area2D in health_pickups:
		if not is_instance_valid(pickup):
			continue
		pickup.rotation = sin((phase * 0.7) + pickup.global_position.x * 0.007) * 0.08
		pickup.scale = Vector2.ONE * (1.0 + (sin((phase * 1.1) + pickup.global_position.x * 0.012) * 0.05))

	for pickup: Area2D in ability_pickups:
		if not is_instance_valid(pickup):
			continue
		pickup.rotation = sin((phase * 0.8) + pickup.global_position.x * 0.009) * 0.14
		pickup.scale = Vector2.ONE * (1.0 + (sin((phase * 1.3) + pickup.global_position.x * 0.008) * 0.04))

func _refresh_score_label() -> void:
	var combo_mult: float = 1.0 + (float(combo_count) * 0.08)
	score_label.text = "Score: %d | D:%d P:%d R:%d | Pace x%.1f | Combo x%.2f | Coins %d" % [_current_score(), _distance_points(), pickup_score, risk_score, _speed_multiplier(), combo_mult, total_coins_collected]

func _register_combo(step: int, reason: String = "", show_notice: bool = false) -> void:
	if step <= 0:
		return
	combo_count = mini(COMBO_MAX, combo_count + step)
	combo_timeout_until = run_seconds + COMBO_TIMEOUT
	risk_score += COMBO_BONUS_STEP * combo_count * step
	if show_notice and reason != "":
		_set_info_notice("%s | Combo x%.2f" % [reason, 1.0 + (float(combo_count) * 0.08)], 1.8)

func _update_combo_timeout() -> void:
	if combo_count <= 0:
		return
	if run_seconds >= combo_timeout_until:
		_break_combo("Combo cooled")

func _break_combo(reason: String = "") -> void:
	if combo_count <= 0:
		return
	combo_count = 0
	combo_timeout_until = 0.0
	if reason != "":
		_set_info_notice(reason, 1.5)

func _check_hazard_dodges() -> void:
	for hazard: Area2D in hazards:
		if not is_instance_valid(hazard):
			continue
		if bool(hazard.get_meta("dodge_scored", false)):
			continue
		if hazard.global_position.x > player.global_position.x - 18.0:
			continue
		if absf(hazard.global_position.y - player.global_position.y) > HAZARD_DODGE_Y_WINDOW:
			continue
		hazard.set_meta("dodge_scored", true)
		hazards_dodged += 1
		_register_combo(1, "Clean dodge", false)
		if rift_active and rift_event_type == RiftEventType.EMBER_BREAKER:
			rift_event_progress += 1

func _update_active_abilities() -> void:
	if chrono_until > 0.0 and run_seconds >= chrono_until:
		chrono_until = 0.0
		Engine.time_scale = 1.0
		_set_info_notice("Chrono normalized", 1.6)

	if shield_hits > 0:
		player.modulate = Color(0.76, 0.96, 1.0, 1.0)
	elif chrono_until > run_seconds:
		player.modulate = Color(1.0, 0.92, 0.70, 1.0)
	else:
		player.modulate = Color(1, 1, 1, 1)

func _start_rift_event() -> void:
	rift_event_progress = 0
	rift_event_failed = false
	rift_event_start_x = player.global_position.x
	match current_biome_index:
		0:
			rift_event_type = RiftEventType.COIN_SURGE
			rift_event_name = "Relic Surge"
			rift_event_target = 12
		1:
			rift_event_type = RiftEventType.PHASE_LINE
			rift_event_name = "Phase Line"
			rift_event_target = 620 + (mission_tier * 35)
		_:
			rift_event_type = RiftEventType.EMBER_BREAKER
			rift_event_name = "Ember Breaker"
			rift_event_target = 3
	_set_info_notice("%s live" % rift_event_name, 2.2)

func _update_rift_event_progress() -> void:
	if not rift_active:
		return
	if rift_event_type == RiftEventType.PHASE_LINE and not rift_event_failed:
		rift_event_progress = maxi(rift_event_progress, int(player.global_position.x - rift_event_start_x))

func _resolve_rift_event() -> void:
	if rift_event_type == RiftEventType.NONE:
		return
	var success: bool = (not rift_event_failed) and rift_event_progress >= rift_event_target
	if success:
		var reward: int = 360 + (mission_tier * 45)
		risk_score += reward
		_register_combo(2, "", false)
		_set_info_notice("%s complete! +%d" % [rift_event_name, reward], 2.6)
	else:
		_set_info_notice("%s failed" % rift_event_name, 1.8)
	rift_event_type = RiftEventType.NONE
	rift_event_name = ""
	rift_event_target = 0
	rift_event_progress = 0
	rift_event_failed = false

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
			_resolve_rift_event()
			next_rift_at = run_seconds + rng.randf_range(RIFT_MIN_SECONDS, RIFT_MAX_SECONDS)
		return

	if run_seconds >= next_rift_at:
		rift_active = true
		rift_until = run_seconds + RIFT_DURATION
		_start_rift_event()

func _update_section_progression() -> void:
	if _bootstrap_active():
		return
	var next_section: int = maxi(0, int(player.global_position.x / SECTION_LENGTH))
	if next_section <= current_section:
		return
	while current_section < next_section:
		current_section += 1
		_apply_biome_for_section(current_section)
		_apply_section_theme(current_section)
		_increment_pace_level(1, "Sector shift")
		_play_sfx_tone(640.0, 0.12, -9.0)

func _apply_biome_for_section(section_index: int, announce: bool = true) -> void:
	if BIOMES.is_empty():
		current_biome_index = 0
		return
	var next_idx: int = section_index % BIOMES.size()
	var changed: bool = next_idx != current_biome_index
	current_biome_index = next_idx
	_update_biome_music()
	if changed and announce:
		_set_info_notice("Entering %s" % _current_biome().get("name", "Sky-Forge"), 3.0)

func _current_biome() -> Dictionary:
	if BIOMES.is_empty():
		return {"name": "Sky-Forge", "hazard_mult": 1.0, "coin_bonus": 0}
	return BIOMES[current_biome_index]

func _setup_biome_music() -> void:
	music_player.name = "BiomeMusic"
	music_player.bus = "Master"
	music_player.volume_db = -10.0
	add_child(music_player)
	_update_biome_music()

func _update_biome_music() -> void:
	var path: String = GAMEPLAY_MUSIC_PATH
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

func _ensure_music_playing() -> void:
	if music_player.stream == null:
		return
	if get_tree().paused:
		return
	if not music_player.playing:
		music_player.play()

func _apply_section_theme(section_index: int) -> void:
	if SECTION_COLORS.is_empty():
		return
	var color_index: int = section_index % SECTION_COLORS.size()
	world_background.color = SECTION_COLORS[color_index]
	_tint_atmosphere_decor(SECTION_COLORS[color_index])
	_tint_parallax_layers(SECTION_COLORS[color_index])
	_tint_lane_guides(SECTION_COLORS[color_index])

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
	_set_info_notice("Directive %d live" % mission_tier, 2.4)

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
		risk_score += reward
		_increment_pace_level(1, "Directive complete")
		_play_sfx_tone(760.0, 0.16, -8.0)
		_set_info_notice("Directive %d complete! +%d | Pace %d" % [mission_tier, reward, player.get_pace_level()])

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
			return "Directive %d: Recover %d relic shards (%d/%d)%s" % [mission_tier, mission_target, mission_progress, mission_target, suffix]
		MissionType.SURVIVE_TIME:
			return "Directive %d: Endure the forge for %ds (%d/%d)%s" % [mission_tier, mission_target, mission_progress, mission_target, suffix]
		MissionType.NO_HIT_DISTANCE:
			return "Directive %d: Hold clean line for %dpx (%d/%d)%s" % [mission_tier, mission_target, mission_progress, mission_target, suffix]
	return "Directive: --"

func _apply_health_delta(delta: int) -> void:
	health = clampi(health + delta, 0, MAX_HEALTH)
	_refresh_health_label()

func _refresh_health_label() -> void:
	health_label.text = "Health: %d" % health
	if health <= 1:
		health_label.modulate = HEALTH_COLOR_CRIT
	elif health == 2:
		health_label.modulate = HEALTH_COLOR_WARN
	else:
		health_label.modulate = HEALTH_COLOR_SAFE

func _increment_pace_level(amount: int, reason: String) -> void:
	var pace_level: int = player.add_pace_levels(amount)
	_set_info_notice("%s | Pace level: %d" % [reason, pace_level], 2.1)

func _compute_health_spawn_chance() -> float:
	var health_missing: int = MAX_HEALTH - health
	var pace_level: int = player.get_pace_level()
	var difficulty_penalty: float = minf(0.36, float(mission_tier - 1) * 0.020 + float(current_section) * 0.014)
	var pressure_bonus: float = float(health_missing) * 0.135
	var critical_bonus: float = 0.30 if health <= 1 else (0.14 if health == 2 else 0.0)
	var pace_bonus: float = float(pace_level) * 0.010
	var coins_to_next_heart: int = maxi(0, next_bonus_heart_at - total_coins_collected)
	var economy_pressure_bonus: float = 0.05 if (health <= 2 and coins_to_next_heart > 65) else 0.0
	var rift_penalty: float = 0.06 if rift_active else 0.0
	var chance: float = 0.09 + pressure_bonus + critical_bonus + pace_bonus + economy_pressure_bonus - difficulty_penalty - rift_penalty

	# "Pity" protection: at critical health on repeated dangerous routes, force a spawn.
	if health <= 1 and danger_routes_since_health >= 2:
		return 1.0
	if health == 2 and danger_routes_since_health >= 4:
		return 0.95

	return clampf(chance, 0.04, 0.85)

func _base_info_text() -> String:
	var text: String = "Mode: %s | Biome: %s | Encounter: %s | Esc: pause/settings/rules | Big coin x10" % [run_mode.capitalize(), _current_biome().get("name", "Sky-Forge"), _encounter_name()]
	if rift_active and rift_event_type != RiftEventType.NONE:
		text += " | Event: %s %d/%d" % [rift_event_name, rift_event_progress, rift_event_target]
	return text

func _refresh_info_label() -> void:
	var text: String = _base_info_text()
	if info_notice != "":
		text += " | " + info_notice
	info_label.text = text

func _refresh_legend_text() -> void:
	var lines: Array[String] = [
		"Rules",
		"Cyan plate: jump up through.",
		"Amber plate: up/down through (Down+Jump).",
		"Violet plate: no collision (ghost).",
		"Hold Down: crouch to dodge low lines.",
		"",
		"Pickups",
		"Teal ring [-]: reduce pace by 1-2.",
		"Green plus: restore 1 health.",
		"Blue sigil: shield next hit.",
		"Gold sigil: chrono slow-time.",
	]
	var legend_text: String = "\n".join(lines)
	legend_label.text = legend_text

func _set_info_notice(message: String, duration: float = INFO_NOTICE_DURATION) -> void:
	info_notice = message
	info_notice_until = run_seconds + duration
	_refresh_info_label()

func _current_score() -> int:
	return _distance_points() + pickup_score + risk_score

func _distance_points() -> int:
	return int(float(distance_score) * _speed_multiplier())

func _speed_multiplier() -> float:
	return 1.0 + (float(player.get_pace_level()) * 0.1)

func _end_run_and_return_to_menu() -> void:
	if run_end_requested:
		return
	run_end_requested = true
	if Engine.is_in_physics_frame():
		call_deferred("_finish_end_run")
		return
	_finish_end_run()

func _finish_end_run() -> void:
	Engine.time_scale = 1.0
	var run_score: int = _current_score()
	var best_score: int = _load_best_score()
	var is_new_best: bool = run_score > best_score
	if is_new_best:
		best_score = run_score
		_save_best_score(best_score)

	get_tree().set_meta("last_score", run_score)
	get_tree().set_meta("last_distance_points", _distance_points())
	get_tree().set_meta("last_pickup_points", pickup_score)
	get_tree().set_meta("last_risk_points", risk_score)
	get_tree().set_meta("last_hazards_dodged", hazards_dodged)
	get_tree().set_meta("last_max_pace", max_pace_level)
	get_tree().set_meta("last_mission_tier", mission_tier)
	get_tree().set_meta("last_coins_collected", total_coins_collected)
	get_tree().set_meta("best_score", best_score)
	get_tree().set_meta("is_new_best", is_new_best)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/RunSummary.tscn")

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
	pause_rules_overlay.visible = false

	pause_window_size_button.pressed.connect(_on_pause_window_size_pressed)
	pause_rules_button.pressed.connect(_on_pause_rules_pressed)
	pause_rules_close_button.pressed.connect(_hide_pause_rules)
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	master_slider.value_changed.connect(_on_master_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	master_slider.value = AudioServer.get_bus_volume_db(0)
	sfx_slider.value = sfx_volume_db
	_refresh_window_size_button()

func _toggle_pause_menu() -> void:
	var opening: bool = not pause_panel.visible
	if not opening:
		_hide_pause_rules()
	pause_backdrop.visible = opening
	pause_panel.visible = opening
	get_tree().paused = opening
	if opening:
		pause_status_label.text = "Paused | Score %d | D:%d P:%d R:%d | Pace %d" % [_current_score(), _distance_points(), pickup_score, risk_score, player.get_pace_level()]
		_refresh_window_size_button()

func _on_resume_pressed() -> void:
	_hide_pause_rules()
	pause_backdrop.visible = false
	pause_panel.visible = false
	get_tree().paused = false

func _on_restart_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	_end_run_and_return_to_menu()

func _on_pause_window_size_pressed() -> void:
	window_size_index = (window_size_index + 1) % WINDOW_SIZES.size()
	_apply_window_size(window_size_index)
	_refresh_window_size_button()
	_save_display_settings()

func _refresh_window_size_button() -> void:
	var sz: Vector2i = WINDOW_SIZES[window_size_index]
	pause_window_size_button.text = "Window: %dx%d" % [sz.x, sz.y]

func _on_pause_rules_pressed() -> void:
	pause_rules_overlay.visible = true

func _hide_pause_rules() -> void:
	pause_rules_overlay.visible = false

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

func _load_display_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_FILE) != OK:
		window_size_index = 1
		_apply_window_size(window_size_index)
		return
	window_size_index = int(config.get_value("display", "window_size_index", 1))
	window_size_index = clampi(window_size_index, 0, WINDOW_SIZES.size() - 1)
	_apply_window_size(window_size_index)

func _apply_window_size(size_index: int) -> void:
	var target: Vector2i = WINDOW_SIZES[size_index]
	var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect()
	target.x = mini(target.x, screen_rect.size.x)
	target.y = mini(target.y, screen_rect.size.y)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(target)
	get_window().size = target
	var centered: Vector2i = screen_rect.position + ((screen_rect.size - target) / 2)
	DisplayServer.window_set_position(centered)

func _save_display_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_FILE)
	config.set_value("display", "window_size_index", window_size_index)
	config.save(SETTINGS_FILE)

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

func _build_atmosphere_decor() -> void:
	atmosphere_stars.clear()
	atmosphere_embers.clear()
	atmosphere_spires.clear()
	atmosphere_smog.clear()
	for child: Node in atmosphere_decor.get_children():
		child.queue_free()

	if ResourceLoader.exists(BACKGROUND_ART_PATH):
		var bg_tex: Texture2D = load(BACKGROUND_ART_PATH)
		if bg_tex != null:
			var bg: Sprite2D = Sprite2D.new()
			bg.texture = bg_tex
			bg.centered = true
			bg.modulate = Color(0.86, 0.92, 0.98, 0.58)
			var vp: Vector2 = get_viewport_rect().size
			var sx: float = (vp.x / maxf(1.0, float(bg_tex.get_width()))) * 1.35
			var sy: float = (vp.y / maxf(1.0, float(bg_tex.get_height()))) * 1.35
			var scale_fill: float = maxf(sx, sy)
			bg.scale = Vector2(scale_fill, scale_fill)
			bg.position = player.global_position + Vector2(160.0, -120.0)
			bg.set_meta("screen_locked", true)
			atmosphere_decor.add_child(bg)
			atmosphere_spires.append({"node": bg, "is_texture": true})

	for i: int in ATMOS_SPIRE_COUNT:
		var spire: Polygon2D = Polygon2D.new()
		var width: float = rng.randf_range(180.0, 520.0)
		var height: float = rng.randf_range(140.0, 360.0)
		spire.polygon = PackedVector2Array([
			Vector2(-width * 0.5, 0.0), Vector2(width * 0.5, 0.0), Vector2(width * 0.18, -height), Vector2(-width * 0.22, -height * 0.78)
		])
		spire.color = Color(0.08, 0.12, 0.19, 0.42)
		var px: float = rng.randf_range(-2400.0, 20000.0)
		var py: float = rng.randf_range(500.0, 680.0)
		spire.position = Vector2(px, py)
		spire.set_meta("base_x", px)
		spire.set_meta("base_y", py)
		spire.set_meta("parallax", rng.randf_range(0.10, 0.18))
		atmosphere_decor.add_child(spire)
		atmosphere_spires.append({"node": spire})

	for i: int in ATMOS_SMOG_COUNT:
		var smog: Polygon2D = Polygon2D.new()
		var w: float = rng.randf_range(1200.0, 2600.0)
		var h: float = rng.randf_range(160.0, 320.0)
		smog.polygon = PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.3), Vector2(w * 0.5, -h * 0.45), Vector2(w * 0.5, h * 0.55), Vector2(-w * 0.5, h * 0.4)
		])
		smog.color = Color(0.32, 0.38, 0.46, 0.11)
		var sx: float = rng.randf_range(-2600.0, 21000.0)
		var sy: float = rng.randf_range(20.0, 420.0)
		smog.position = Vector2(sx, sy)
		smog.set_meta("base_x", sx)
		smog.set_meta("base_y", sy)
		smog.set_meta("parallax", rng.randf_range(0.08, 0.18))
		smog.set_meta("drift", rng.randf_range(0.4, 1.0))
		atmosphere_decor.add_child(smog)
		atmosphere_smog.append({"node": smog})

	for i: int in ATMOS_STAR_COUNT:
		var star: Polygon2D = Polygon2D.new()
		var size: float = rng.randf_range(1.2, 3.6)
		star.polygon = PackedVector2Array([
			Vector2(-size, -size), Vector2(size, -size), Vector2(size, size), Vector2(-size, size)
		])
		star.color = Color(0.78, 0.91, 1.0, rng.randf_range(0.24, 0.72))
		var sx: float = rng.randf_range(-2600.0, 21000.0)
		var sy: float = rng.randf_range(-520.0, 260.0)
		star.position = Vector2(sx, sy)
		star.set_meta("base_x", sx)
		star.set_meta("base_y", sy)
		star.set_meta("parallax", rng.randf_range(0.05, 0.16))
		star.set_meta("twinkle", rng.randf_range(0.8, 2.2))
		atmosphere_decor.add_child(star)
		atmosphere_stars.append({"node": star})

	for i: int in ATMOS_EMBER_COUNT:
		var ember: Polygon2D = Polygon2D.new()
		var size: float = rng.randf_range(2.0, 6.0)
		ember.polygon = PackedVector2Array([
			Vector2(-size, 0.0), Vector2(0.0, -size), Vector2(size, 0.0), Vector2(0.0, size)
		])
		ember.color = Color(1.0, 0.56, 0.25, rng.randf_range(0.24, 0.58))
		var ex: float = rng.randf_range(-2200.0, 20000.0)
		var ey: float = rng.randf_range(120.0, 640.0)
		ember.position = Vector2(ex, ey)
		ember.set_meta("base_x", ex)
		ember.set_meta("base_y", ey)
		ember.set_meta("parallax", rng.randf_range(0.12, 0.32))
		ember.set_meta("drift", rng.randf_range(0.6, 1.6))
		atmosphere_decor.add_child(ember)
		atmosphere_embers.append({"node": ember})

func _update_atmosphere_decor() -> void:
	var px: float = player.global_position.x
	for entry: Dictionary in atmosphere_spires:
		var node: Node2D = entry["node"]
		if not is_instance_valid(node):
			continue
		if bool(node.get_meta("screen_locked", false)):
			node.position = player.global_position + Vector2(160.0, -120.0)
			continue
		var bx: float = float(node.get_meta("base_x", node.position.x))
		var by: float = float(node.get_meta("base_y", node.position.y))
		var parallax: float = float(node.get_meta("parallax", 0.12))
		node.position.x = bx + (px * parallax)
		node.position.y = by

	for entry: Dictionary in atmosphere_smog:
		var smog: Polygon2D = entry["node"]
		if not is_instance_valid(smog):
			continue
		var bx: float = float(smog.get_meta("base_x", smog.position.x))
		var by: float = float(smog.get_meta("base_y", smog.position.y))
		var parallax: float = float(smog.get_meta("parallax", 0.12))
		var drift: float = float(smog.get_meta("drift", 0.7))
		smog.position.x = bx + (px * parallax) + (sin(run_seconds * drift + bx * 0.0008) * 12.0)
		smog.position.y = by + (sin(run_seconds * drift * 0.6 + by * 0.008) * 7.0)

	for entry: Dictionary in atmosphere_stars:
		var star: Polygon2D = entry["node"]
		if not is_instance_valid(star):
			continue
		var bx: float = float(star.get_meta("base_x", star.position.x))
		var by: float = float(star.get_meta("base_y", star.position.y))
		var parallax: float = float(star.get_meta("parallax", 0.1))
		var twinkle: float = float(star.get_meta("twinkle", 1.2))
		star.position.x = bx + (px * parallax)
		star.position.y = by + (sin((run_seconds * twinkle) + bx * 0.0015) * 2.0)
		star.color.a = clampf(0.14 + (0.28 * (0.5 + 0.5 * sin(run_seconds * (1.1 + twinkle)))), 0.09, 0.46)

	for entry: Dictionary in atmosphere_embers:
		var ember: Polygon2D = entry["node"]
		if not is_instance_valid(ember):
			continue
		var bx: float = float(ember.get_meta("base_x", ember.position.x))
		var by: float = float(ember.get_meta("base_y", ember.position.y))
		var parallax: float = float(ember.get_meta("parallax", 0.2))
		var drift: float = float(ember.get_meta("drift", 1.0))
		ember.position.x = bx + (px * parallax) + (sin(run_seconds * 0.8 * drift + bx * 0.002) * 9.0)
		ember.position.y = by + (sin(run_seconds * 1.4 * drift + bx * 0.001) * 6.0)
		ember.rotation = sin(run_seconds * 1.2 * drift + by * 0.01) * 0.45

func _tint_atmosphere_decor(section_color: Color) -> void:
	for entry: Dictionary in atmosphere_spires:
		var node: Node2D = entry["node"]
		if not is_instance_valid(node):
			continue
		if node is Polygon2D:
			var spire: Polygon2D = node
			spire.color = Color(
				clampf(0.04 + section_color.r * 0.30, 0.0, 1.0),
				clampf(0.07 + section_color.g * 0.34, 0.0, 1.0),
				clampf(0.12 + section_color.b * 0.38, 0.0, 1.0),
				0.42
			)
		elif node is Sprite2D:
			var bg_sprite: Sprite2D = node
			bg_sprite.modulate = Color(
				clampf(0.74 + section_color.r * 0.26, 0.0, 1.0),
				clampf(0.78 + section_color.g * 0.22, 0.0, 1.0),
				clampf(0.82 + section_color.b * 0.28, 0.0, 1.0),
				0.50
			)

	var ember_tint: Color = Color(1.0, 0.58, 0.25, 0.42)
	if current_biome_index == 1:
		ember_tint = Color(0.58, 0.79, 1.0, 0.44)
	elif current_biome_index == 2:
		ember_tint = Color(1.0, 0.44, 0.22, 0.48)
	for entry: Dictionary in atmosphere_embers:
		var ember: Polygon2D = entry["node"]
		if is_instance_valid(ember):
			ember.color = ember_tint

	var fog_tint: Color = Color(0.28, 0.34, 0.44, 0.10)
	if current_biome_index == 1:
		fog_tint = Color(0.22, 0.33, 0.52, 0.12)
	elif current_biome_index == 2:
		fog_tint = Color(0.42, 0.28, 0.24, 0.12)
	for entry: Dictionary in atmosphere_smog:
		var smog: Polygon2D = entry["node"]
		if is_instance_valid(smog):
			smog.color = fog_tint

func _build_lane_guides() -> void:
	lane_guides.clear()
	for child: Node in lane_guides_root.get_children():
		child.queue_free()

	for lane_idx: int in range(LANE_Y.size()):
		var lane_node: Node2D = Node2D.new()
		lane_guides_root.add_child(lane_node)

		var guide_band: Polygon2D = Polygon2D.new()
		guide_band.polygon = PackedVector2Array([
			Vector2(-LANE_GUIDE_LENGTH * 0.5, -12.0),
			Vector2(LANE_GUIDE_LENGTH * 0.5, -12.0),
			Vector2(LANE_GUIDE_LENGTH * 0.5, 12.0),
			Vector2(-LANE_GUIDE_LENGTH * 0.5, 12.0),
		])
		guide_band.color = _lane_guide_color(lane_idx)
		lane_node.add_child(guide_band)

		var edge_line: Polygon2D = Polygon2D.new()
		edge_line.polygon = PackedVector2Array([
			Vector2(-LANE_GUIDE_LENGTH * 0.5, -10.0),
			Vector2(LANE_GUIDE_LENGTH * 0.5, -10.0),
			Vector2(LANE_GUIDE_LENGTH * 0.5, -7.0),
			Vector2(-LANE_GUIDE_LENGTH * 0.5, -7.0),
		])
		edge_line.color = _lane_guide_color(lane_idx).lightened(0.25)
		lane_node.add_child(edge_line)

		lane_guides.append({"node": lane_node, "lane": lane_idx})

func _lane_guide_color(lane_idx: int) -> Color:
	match lane_idx:
		0:
			return Color(0.28, 0.34, 0.42, 0.28)
		1:
			return Color(0.17, 0.47, 0.62, 0.24)
		2:
			return Color(0.40, 0.28, 0.56, 0.24)
	return Color(0.32, 0.36, 0.44, 0.24)

func _update_lane_guides() -> void:
	if lane_guides.is_empty():
		return
	var anchor_x: float = player.global_position.x + ((LANE_GUIDE_AHEAD - LANE_GUIDE_BEHIND) * 0.5)
	for lane_info: Dictionary in lane_guides:
		var lane_node: Node2D = lane_info["node"]
		var lane_idx: int = int(lane_info["lane"])
		lane_node.position = Vector2(anchor_x, LANE_Y[lane_idx] + 8.0)

func _tint_lane_guides(section_color: Color) -> void:
	if lane_guides.is_empty():
		return
	for lane_info: Dictionary in lane_guides:
		var lane_node: Node2D = lane_info["node"]
		var lane_idx: int = int(lane_info["lane"])
		var base: Color = _lane_guide_color(lane_idx)
		var mixed: Color = Color(
			clampf((base.r * 0.62) + (section_color.r * 0.38), 0.0, 1.0),
			clampf((base.g * 0.62) + (section_color.g * 0.38), 0.0, 1.0),
			clampf((base.b * 0.62) + (section_color.b * 0.38), 0.0, 1.0),
			base.a
		)
		var highlight: Color = mixed.lightened(0.20)
		if lane_node.get_child_count() > 0 and lane_node.get_child(0) is Polygon2D:
			(lane_node.get_child(0) as Polygon2D).color = mixed
		if lane_node.get_child_count() > 1 and lane_node.get_child(1) is Polygon2D:
			(lane_node.get_child(1) as Polygon2D).color = highlight

func _build_parallax_layers() -> void:
	parallax_layers.clear()
	for child: Node in parallax_decor.get_children():
		child.queue_free()

	var layer_defs: Array[Dictionary] = [
		{"name": "FarGlow", "factor": 0.18, "base_y": 290.0, "alpha": 0.20, "jitter": 22.0, "height_min": 36.0, "height_max": 86.0, "step": 220.0, "sway": 8.0},
		{"name": "MidRuins", "factor": 0.34, "base_y": 364.0, "alpha": 0.30, "jitter": 32.0, "height_min": 52.0, "height_max": 132.0, "step": 180.0, "sway": 13.0},
		{"name": "NearSteel", "factor": 0.52, "base_y": 436.0, "alpha": 0.42, "jitter": 20.0, "height_min": 44.0, "height_max": 96.0, "step": 200.0, "sway": 18.0},
	]

	for def: Dictionary in layer_defs:
		var layer_root: Node2D = Node2D.new()
		layer_root.name = String(def["name"])
		parallax_decor.add_child(layer_root)
		_populate_parallax_layer(layer_root, def)
		parallax_layers.append({"node": layer_root, "factor": float(def["factor"]), "sway": float(def["sway"])})

	_tint_parallax_layers(world_background.color)

func _populate_parallax_layer(layer_root: Node2D, def: Dictionary) -> void:
	var base_y: float = float(def["base_y"])
	var alpha: float = float(def["alpha"])
	var jitter: float = float(def["jitter"])
	var height_min: float = float(def["height_min"])
	var height_max: float = float(def["height_max"])
	var step: float = float(def["step"])
	var start_x: float = -2600.0
	var end_x: float = 18000.0
	var x: float = start_x
	var idx: int = 0
	while x < end_x:
		var width: float = rng.randf_range(step * 0.65, step * 1.14)
		var height: float = rng.randf_range(height_min, height_max)
		var col: Color = Color(
			0.24 + rng.randf_range(-0.05, 0.08),
			0.43 + rng.randf_range(-0.05, 0.12),
			0.62 + rng.randf_range(-0.06, 0.12),
			alpha
		)

		var slab: Polygon2D = Polygon2D.new()
		slab.polygon = PackedVector2Array([
			Vector2(-width * 0.5, 0.0),
			Vector2(width * 0.5, 0.0),
			Vector2(width * 0.5, -height),
			Vector2(-width * 0.5, -height)
		])
		slab.position = Vector2(x + width * 0.5, base_y + rng.randf_range(-jitter, jitter))
		slab.color = col
		slab.set_meta("base_x", slab.position.x)
		slab.set_meta("base_y", slab.position.y)
		layer_root.add_child(slab)

		if idx % 2 == 0:
			var cap: Polygon2D = Polygon2D.new()
			cap.polygon = PackedVector2Array([
				Vector2(-width * 0.42, -height),
				Vector2(width * 0.42, -height),
				Vector2(width * 0.42, -height - PARALLAX_BAND_HEIGHT * 0.10),
				Vector2(-width * 0.42, -height - PARALLAX_BAND_HEIGHT * 0.10)
			])
			cap.position = slab.position
			cap.color = col.lightened(0.22)
			cap.set_meta("base_x", cap.position.x)
			cap.set_meta("base_y", cap.position.y)
			layer_root.add_child(cap)

		x += step + rng.randf_range(-24.0, 34.0)
		idx += 1

func _update_parallax_layers() -> void:
	if parallax_layers.is_empty():
		return
	var px: float = player.global_position.x
	for layer_info: Dictionary in parallax_layers:
		var layer: Node2D = layer_info["node"]
		var factor: float = float(layer_info["factor"])
		var sway: float = float(layer_info["sway"])
		layer.position.x = px * factor
		var sway_phase: float = run_seconds * 0.45
		for piece: Node in layer.get_children():
			if piece is Polygon2D:
				var poly: Polygon2D = piece
				var base_y: float = float(poly.get_meta("base_y", poly.position.y))
				var base_x: float = float(poly.get_meta("base_x", poly.position.x))
				var wave: float = sin((base_x * 0.0022) + sway_phase) * sway
				poly.position.y = base_y + wave

func _tint_parallax_layers(base_color: Color) -> void:
	if parallax_layers.is_empty():
		return
	var biome_tint: Color = Color(0.56, 0.68, 0.82)
	var biome_mix: float = 0.46
	if current_biome_index == 1:
		biome_tint = Color(0.48, 0.72, 1.0)
		biome_mix = 0.54
	elif current_biome_index == 2:
		biome_tint = Color(0.90, 0.56, 0.30)
		biome_mix = 0.50
	for layer_info: Dictionary in parallax_layers:
		var layer: Node2D = layer_info["node"]
		var factor: float = float(layer_info["factor"])
		var tint: Color = base_color.lightened(0.34 + (factor * 0.16))
		tint.a = 1.0
		for piece: Node in layer.get_children():
			if piece is Polygon2D:
				var poly: Polygon2D = piece
				var original: Color = poly.color
				var mixed: Color = Color(
					clampf((original.r * (1.0 - biome_mix)) + (tint.r * biome_mix), 0.0, 1.0),
					clampf((original.g * (1.0 - biome_mix)) + (tint.g * biome_mix), 0.0, 1.0),
					clampf((original.b * (1.0 - biome_mix)) + (tint.b * biome_mix), 0.0, 1.0),
					original.a
				)
				poly.color = Color(
					clampf((mixed.r * 0.65) + (biome_tint.r * 0.35), 0.0, 1.0),
					clampf((mixed.g * 0.65) + (biome_tint.g * 0.35), 0.0, 1.0),
					clampf((mixed.b * 0.65) + (biome_tint.b * 0.35), 0.0, 1.0),
					original.a
				)
