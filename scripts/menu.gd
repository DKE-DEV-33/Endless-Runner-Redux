extends Control
const INTRO_MUSIC_PATH: String = "res://assets/audio/intro_music.mp3"
const SETTINGS_FILE: String = "user://settings.cfg"
const WINDOW_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

@onready var start_button: Button = $Card/Center/StartButton
@onready var rules_button: Button = $Card/Center/RulesButton
@onready var quit_button: Button = $Card/Center/QuitButton
@onready var last_score_label: Label = $Card/Center/LastScoreLabel
@onready var best_score_label: Label = $Card/Center/BestScoreLabel
@onready var mode_button: Button = $Card/Center/ModeButton
@onready var ui_scale_button: Button = $Card/Center/UiScaleButton
@onready var daily_seed_label: Label = $Card/Center/DailySeedLabel
@onready var rules_overlay: ColorRect = $RulesOverlay
@onready var close_rules_button: Button = $RulesOverlay/RulesPanel/VBox/CloseRulesButton

var run_mode: String = "standard"
var intro_player: AudioStreamPlayer = AudioStreamPlayer.new()
var window_size_index: int = 1

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	rules_button.pressed.connect(_on_rules_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_rules_button.pressed.connect(_hide_rules_overlay)
	mode_button.pressed.connect(_on_mode_pressed)
	ui_scale_button.pressed.connect(_on_ui_scale_pressed)
	_setup_intro_music()
	_load_display_settings()
	run_mode = String(get_tree().get_meta("run_mode", "standard"))
	_refresh_mode_ui()
	_refresh_window_size_button()
	_refresh_score_labels()
	rules_overlay.visible = false

func _on_start_pressed() -> void:
	if intro_player.playing:
		intro_player.stop()
	get_tree().set_meta("run_mode", run_mode)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_rules_pressed() -> void:
	rules_overlay.visible = true

func _hide_rules_overlay() -> void:
	rules_overlay.visible = false

func _on_mode_pressed() -> void:
	run_mode = "daily" if run_mode == "standard" else "standard"
	_refresh_mode_ui()

func _on_ui_scale_pressed() -> void:
	window_size_index = (window_size_index + 1) % WINDOW_SIZES.size()
	_apply_window_size(window_size_index)
	_refresh_window_size_button()
	_save_display_settings()

func _refresh_score_labels() -> void:
	var best_score: int = _load_best_score()
	var has_last: bool = get_tree().has_meta("last_score")
	var last_score: int = int(get_tree().get_meta("last_score", 0))
	var is_new_best: bool = bool(get_tree().get_meta("is_new_best", false))

	if has_last:
		var suffix: String = " NEW BEST!" if is_new_best else ""
		last_score_label.text = "Last Run: %d%s" % [last_score, suffix]
	else:
		last_score_label.text = "Last Run: --"

	best_score_label.text = "Best Run: %d" % best_score

func _refresh_mode_ui() -> void:
	mode_button.text = "Mode: %s" % run_mode.capitalize()
	if run_mode == "daily":
		daily_seed_label.text = "Daily Seed: %s" % Time.get_date_string_from_system()
		daily_seed_label.visible = true
	else:
		daily_seed_label.visible = false

func _load_best_score() -> int:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load("user://run_stats.cfg")
	if err != OK:
		return 0
	return int(config.get_value("scores", "best_score", 0))

func _process(_delta: float) -> void:
	if intro_player.stream != null and not intro_player.playing:
		intro_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and rules_overlay.visible:
		_hide_rules_overlay()

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
	var centered: Vector2i = screen_rect.position + ((screen_rect.size - target) / 2)
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
