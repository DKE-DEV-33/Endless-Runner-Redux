extends Control
const INTRO_MUSIC_PATH: String = "res://assets/audio/intro_music.mp3"
const SETTINGS_FILE: String = "user://settings.cfg"
const RUN_STATS_FILE_TEMPLATE: String = "user://run_stats_%s.cfg"
const WINDOW_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
const STARTING_UNLOCKED_RELICS: Array[String] = ["aegis_shard", "vitality_cell", "coin_lens"]
const PERK_MAX_LEVEL: int = 3
const PERK_COSTS: Dictionary = {
	"vitality": [400, 820, 1450],
	"coin_value": [460, 900, 1550],
	"fireguard": [430, 860, 1500],
}
const RELIC_LIBRARY: Dictionary = {
	"aegis_shard": {"name": "Aegis Shard", "effect": "Gain a shield charge now.", "rarity": "common"},
	"vitality_cell": {"name": "Vitality Cell", "effect": "Restore 1 health immediately.", "rarity": "common"},
	"coin_lens": {"name": "Coin Lens", "effect": "+10% coin score value this run.", "rarity": "common"},
	"magnet_array": {"name": "Magnet Array", "effect": "+50 magnet pickup radius this run.", "rarity": "uncommon"},
	"chrono_spool": {"name": "Chrono Spool", "effect": "+1s chrono duration this run.", "rarity": "uncommon"},
	"firecore": {"name": "Firecore Prism", "effect": "+1.5s fireguard duration this run.", "rarity": "rare"},
}
const RELIC_IDS: Array[String] = ["aegis_shard", "vitality_cell", "coin_lens", "magnet_array", "chrono_spool", "firecore"]

@onready var start_button: Button = $Card/Center/StartButton
@onready var rules_button: Button = $Card/Center/RulesButton
@onready var codex_button: Button = $Card/Center/CodexButton
@onready var quit_button: Button = $Card/Center/QuitButton
@onready var exit_button: Button = $Card/Center/ExitButton
@onready var last_score_label: Label = $Card/Center/LastScoreLabel
@onready var best_score_label: Label = $Card/Center/BestScoreLabel
@onready var summary_label: Label = $Card/Center/SummaryLabel
@onready var relic_history_label: Label = $Card/Center/RelicHistoryLabel
@onready var title_label: Label = $Card/Center/Title
@onready var mode_button: Button = $Card/Center/ModeButton
@onready var ui_scale_button: Button = $Card/Center/UiScaleButton
@onready var daily_seed_label: Label = $Card/Center/DailySeedLabel
@onready var credits_label: Label = $Card/Center/ArmoryCard/VBox/CreditsLabel
@onready var vitality_button: Button = $Card/Center/ArmoryCard/VBox/VitalityButton
@onready var coin_value_button: Button = $Card/Center/ArmoryCard/VBox/CoinValueButton
@onready var fireguard_button: Button = $Card/Center/ArmoryCard/VBox/FireguardButton
@onready var armory_hint_label: Label = $Card/Center/ArmoryCard/VBox/ArmoryHintLabel
@onready var rules_overlay: ColorRect = $RulesOverlay
@onready var close_rules_button: Button = $RulesOverlay/RulesPanel/VBox/CloseRulesButton
@onready var codex_overlay: ColorRect = $CodexOverlay
@onready var close_codex_button: Button = $CodexOverlay/CodexPanel/VBox/CloseCodexButton
@onready var codex_body_label: Label = $CodexOverlay/CodexPanel/VBox/Scroll/CodexBody

var run_mode: String = "standard"
var intro_player: AudioStreamPlayer = AudioStreamPlayer.new()
var window_size_index: int = 1
var credits: int = 0
var perk_vitality_level: int = 0
var perk_coin_value_level: int = 0
var perk_fireguard_level: int = 0

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	rules_button.pressed.connect(_on_rules_pressed)
	codex_button.pressed.connect(_on_codex_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	close_rules_button.pressed.connect(_hide_rules_overlay)
	close_codex_button.pressed.connect(_hide_codex_overlay)
	mode_button.pressed.connect(_on_mode_pressed)
	ui_scale_button.pressed.connect(_on_ui_scale_pressed)
	vitality_button.pressed.connect(_on_vitality_pressed)
	coin_value_button.pressed.connect(_on_coin_value_pressed)
	fireguard_button.pressed.connect(_on_fireguard_pressed)
	_setup_intro_music()
	_load_display_settings()
	_refresh_title_for_profile()
	run_mode = String(get_tree().get_meta("run_mode", "standard"))
	_refresh_mode_ui()
	_refresh_window_size_button()
	_refresh_score_labels()
	_load_progression()
	_refresh_armory_ui()
	rules_overlay.visible = false
	codex_overlay.visible = false

func _on_start_pressed() -> void:
	if intro_player.playing:
		intro_player.stop()
	_touch_profile_last_played()
	get_tree().set_meta("run_mode", run_mode)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_pressed() -> void:
	_touch_profile_last_played()
	if intro_player.playing:
		intro_player.stop()
	get_tree().change_scene_to_file("res://scenes/Splash.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_rules_pressed() -> void:
	codex_overlay.visible = false
	rules_overlay.visible = true

func _hide_rules_overlay() -> void:
	rules_overlay.visible = false

func _on_codex_pressed() -> void:
	rules_overlay.visible = false
	_refresh_codex_ui()
	codex_overlay.visible = true

func _hide_codex_overlay() -> void:
	codex_overlay.visible = false

func _on_mode_pressed() -> void:
	run_mode = "daily" if run_mode == "standard" else "standard"
	_refresh_mode_ui()

func _on_ui_scale_pressed() -> void:
	window_size_index = (window_size_index + 1) % WINDOW_SIZES.size()
	_apply_window_size(window_size_index)
	_refresh_window_size_button()
	_save_display_settings()

func _on_vitality_pressed() -> void:
	_try_purchase_perk("vitality")

func _on_coin_value_pressed() -> void:
	_try_purchase_perk("coin_value")

func _on_fireguard_pressed() -> void:
	_try_purchase_perk("fireguard")

func _refresh_score_labels() -> void:
	var best_score: int = _load_best_score()
	var has_last: bool = get_tree().has_meta("last_score")
	var last_score: int = int(get_tree().get_meta("last_score", 0))
	var last_distance: int = int(get_tree().get_meta("last_distance_points", 0))
	var last_pickup: int = int(get_tree().get_meta("last_pickup_points", 0))
	var last_risk: int = int(get_tree().get_meta("last_risk_points", 0))
	var last_dodges: int = int(get_tree().get_meta("last_hazards_dodged", 0))
	var last_max_pace: int = int(get_tree().get_meta("last_max_pace", 0))
	var last_tier: int = int(get_tree().get_meta("last_mission_tier", 0))
	var last_coins: int = int(get_tree().get_meta("last_coins_collected", 0))
	var last_credits_earned: int = int(get_tree().get_meta("last_credits_earned", 0))
	var is_new_best: bool = bool(get_tree().get_meta("is_new_best", false)) or bool(get_tree().get_meta("new_best", false))
	var last_unlock: String = String(get_tree().get_meta("last_meta_unlock", ""))

	if has_last:
		var suffix: String = " NEW BEST!" if is_new_best else ""
		last_score_label.text = "Last Run: %d%s\nD: %d   P: %d   R: %d" % [last_score, suffix, last_distance, last_pickup, last_risk]
		summary_label.text = "Coins: %d   Dodges: %d\nPace: %d   Tier: %d   +%d Credits" % [last_coins, last_dodges, last_max_pace, last_tier, last_credits_earned]
		if last_unlock == "":
			relic_history_label.text = "Last Unlock: --"
		else:
			relic_history_label.text = "Last Unlock: %s" % last_unlock
	else:
		last_score_label.text = "Last Run: --"
		summary_label.text = "Run Summary: --"
		relic_history_label.text = "Last Unlock: --"

	best_score_label.text = "Best Run: %d" % best_score

func _refresh_mode_ui() -> void:
	mode_button.text = "Mode: %s" % run_mode.capitalize()
	if run_mode == "daily":
		daily_seed_label.text = "Daily Seed: %s" % Time.get_date_string_from_system()
		daily_seed_label.visible = true
	else:
		daily_seed_label.visible = false

func _load_best_score() -> int:
	var config: ConfigFile = _load_stats_config()
	return int(config.get_value("scores", "best_score", 0))

func _load_progression() -> void:
	var config: ConfigFile = _load_stats_config()
	credits = maxi(0, int(config.get_value("progression", "credits", 0)))
	perk_vitality_level = clampi(int(config.get_value("progression", "perk_vitality", 0)), 0, PERK_MAX_LEVEL)
	perk_coin_value_level = clampi(int(config.get_value("progression", "perk_coin_value", 0)), 0, PERK_MAX_LEVEL)
	perk_fireguard_level = clampi(int(config.get_value("progression", "perk_fireguard", 0)), 0, PERK_MAX_LEVEL)

func _save_progression() -> void:
	var config: ConfigFile = _load_stats_config()
	config.set_value("progression", "credits", credits)
	config.set_value("progression", "perk_vitality", perk_vitality_level)
	config.set_value("progression", "perk_coin_value", perk_coin_value_level)
	config.set_value("progression", "perk_fireguard", perk_fireguard_level)
	config.save(_run_stats_file())

func _load_stats_config() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	config.load(_run_stats_file())
	return config

func _run_stats_file() -> String:
	var profile_id: String = String(get_tree().get_meta("profile_id", "slot1"))
	return RUN_STATS_FILE_TEMPLATE % profile_id

func _refresh_title_for_profile() -> void:
	var config: ConfigFile = _load_stats_config()
	var player_name: String = String(config.get_value("profile", "name", "Pilot"))
	title_label.text = "SKY-FORGE RELAY | %s" % player_name

func _perk_level(key: String) -> int:
	match key:
		"vitality":
			return perk_vitality_level
		"coin_value":
			return perk_coin_value_level
		"fireguard":
			return perk_fireguard_level
	return 0

func _perk_cost(key: String, level: int) -> int:
	var costs: Array = PERK_COSTS.get(key, [])
	if level < 0 or level >= costs.size():
		return -1
	return int(costs[level])

func _set_perk_level(key: String, level: int) -> void:
	match key:
		"vitality":
			perk_vitality_level = level
		"coin_value":
			perk_coin_value_level = level
		"fireguard":
			perk_fireguard_level = level

func _perk_display_name(key: String) -> String:
	match key:
		"vitality":
			return "Vitality"
		"coin_value":
			return "Coin Value"
		"fireguard":
			return "Fireguard"
	return key

func _button_text_for_perk(key: String) -> String:
	var level: int = _perk_level(key)
	if level >= PERK_MAX_LEVEL:
		return "%s Lv %d/%d (MAX)" % [_perk_display_name(key), level, PERK_MAX_LEVEL]
	var cost: int = _perk_cost(key, level)
	return "%s Lv %d/%d - %dc" % [_perk_display_name(key), level, PERK_MAX_LEVEL, cost]

func _refresh_armory_ui() -> void:
	credits_label.text = "Credits: %d" % credits
	vitality_button.text = _button_text_for_perk("vitality")
	coin_value_button.text = _button_text_for_perk("coin_value")
	fireguard_button.text = _button_text_for_perk("fireguard")

	var vitality_level: int = _perk_level("vitality")
	var coin_level: int = _perk_level("coin_value")
	var fireguard_level: int = _perk_level("fireguard")
	var vitality_cost: int = _perk_cost("vitality", vitality_level)
	var coin_cost: int = _perk_cost("coin_value", coin_level)
	var fireguard_cost: int = _perk_cost("fireguard", fireguard_level)

	vitality_button.disabled = vitality_level >= PERK_MAX_LEVEL or (vitality_cost > 0 and credits < vitality_cost)
	coin_value_button.disabled = coin_level >= PERK_MAX_LEVEL or (coin_cost > 0 and credits < coin_cost)
	fireguard_button.disabled = fireguard_level >= PERK_MAX_LEVEL or (fireguard_cost > 0 and credits < fireguard_cost)
	armory_hint_label.text = "V:+%d HP  C:+%d%% coin score  F:+%ds fireguard" % [vitality_level, coin_level * 5, fireguard_level]

func _try_purchase_perk(key: String) -> void:
	var level: int = _perk_level(key)
	if level >= PERK_MAX_LEVEL:
		armory_hint_label.text = "%s already maxed." % _perk_display_name(key)
		return
	var cost: int = _perk_cost(key, level)
	if cost < 0:
		return
	if credits < cost:
		armory_hint_label.text = "Need %d more credits for %s." % [cost - credits, _perk_display_name(key)]
		return
	credits -= cost
	_set_perk_level(key, level + 1)
	_save_progression()
	_refresh_armory_ui()
	armory_hint_label.text = "%s upgraded to Lv %d." % [_perk_display_name(key), _perk_level(key)]

func _process(_delta: float) -> void:
	if intro_player.stream != null and not intro_player.playing:
		intro_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and rules_overlay.visible:
		_hide_rules_overlay()
	elif event.is_action_pressed("ui_cancel") and codex_overlay.visible:
		_hide_codex_overlay()

func _load_display_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load(SETTINGS_FILE)
	window_size_index = 1
	if err == OK:
		window_size_index = int(config.get_value("display", "window_size_index", 1))
	window_size_index = clampi(window_size_index, 0, WINDOW_SIZES.size() - 1)
	_apply_window_size(window_size_index)

func _save_display_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_FILE)
	config.set_value("display", "window_size_index", window_size_index)
	config.save(SETTINGS_FILE)

func _apply_window_size(size_index: int) -> void:
	var target: Vector2i = WINDOW_SIZES[size_index]
	var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect()
	target.x = mini(target.x, screen_rect.size.x)
	target.y = mini(target.y, screen_rect.size.y)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(target)
	get_window().size = target
	var delta: Vector2i = screen_rect.size - target
	var centered: Vector2i = screen_rect.position + Vector2i(int(round(float(delta.x) / 2.0)), int(round(float(delta.y) / 2.0)))
	DisplayServer.window_set_position(centered)

func _refresh_window_size_button() -> void:
	var sz: Vector2i = WINDOW_SIZES[window_size_index]
	ui_scale_button.text = "Window: %dx%d" % [sz.x, sz.y]

func _setup_intro_music() -> void:
	intro_player.name = "IntroMusic"
	intro_player.bus = "Master"
	intro_player.volume_db = -9.0
	add_child(intro_player)
	if not ResourceLoader.exists(INTRO_MUSIC_PATH):
		return
	var stream: AudioStream = load(INTRO_MUSIC_PATH)
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	intro_player.stream = stream
	intro_player.play()

func _touch_profile_last_played() -> void:
	var config: ConfigFile = _load_stats_config()
	config.set_value("profile", "last_played", Time.get_datetime_string_from_system(false, true))
	config.save(_run_stats_file())

func _sanitize_relic_unlocks(value: Variant) -> Array[String]:
	var unlocked: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			var relic_id: String = String(entry)
			if RELIC_IDS.has(relic_id) and not unlocked.has(relic_id):
				unlocked.append(relic_id)
	if unlocked.is_empty():
		return STARTING_UNLOCKED_RELICS.duplicate()
	return unlocked

func _relic_display_name(relic_id: String) -> String:
	if RELIC_LIBRARY.has(relic_id):
		return String(RELIC_LIBRARY[relic_id].get("name", relic_id))
	return relic_id

func _relic_effect_text(relic_id: String) -> String:
	if RELIC_LIBRARY.has(relic_id):
		return String(RELIC_LIBRARY[relic_id].get("effect", ""))
	return ""

func _relic_rarity_text(relic_id: String) -> String:
	if RELIC_LIBRARY.has(relic_id):
		return String(RELIC_LIBRARY[relic_id].get("rarity", "common")).capitalize()
	return "Common"

func _refresh_codex_ui() -> void:
	var config: ConfigFile = _load_stats_config()
	var unlocked: Array[String] = _sanitize_relic_unlocks(config.get_value("progression", "relic_unlocks", STARTING_UNLOCKED_RELICS))
	var locked: Array[String] = []
	for relic_id: String in RELIC_IDS:
		if not unlocked.has(relic_id):
			locked.append(relic_id)

	var lines: Array[String] = []
	lines.append("Unlocked %d/%d relics\n" % [unlocked.size(), RELIC_IDS.size()])
	lines.append("Unlocked:")
	for relic_id: String in unlocked:
		lines.append("- [%s] %s: %s" % [_relic_rarity_text(relic_id), _relic_display_name(relic_id), _relic_effect_text(relic_id)])
	lines.append("")
	lines.append("Locked:")
	if locked.is_empty():
		lines.append("- None. Archive complete.")
	else:
		for relic_id: String in locked:
			lines.append("- [%s] %s" % [_relic_rarity_text(relic_id), _relic_display_name(relic_id)])
	codex_body_label.text = "\n".join(lines)
