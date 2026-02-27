extends Control
const INTRO_MUSIC_PATH: String = "res://assets/audio/intro_music.mp3"

@onready var start_button: Button = $Card/Center/StartButton
@onready var rules_button: Button = $Card/Center/RulesButton
@onready var quit_button: Button = $Card/Center/QuitButton
@onready var last_score_label: Label = $Card/Center/LastScoreLabel
@onready var best_score_label: Label = $Card/Center/BestScoreLabel
@onready var mode_button: Button = $Card/Center/ModeButton
@onready var daily_seed_label: Label = $Card/Center/DailySeedLabel
@onready var rules_overlay: ColorRect = $RulesOverlay
@onready var close_rules_button: Button = $RulesOverlay/RulesPanel/VBox/CloseRulesButton

var run_mode: String = "standard"
var intro_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	rules_button.pressed.connect(_on_rules_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_rules_button.pressed.connect(_hide_rules_overlay)
	mode_button.pressed.connect(_on_mode_pressed)
	_setup_intro_music()
	run_mode = String(get_tree().get_meta("run_mode", "standard"))
	_refresh_mode_ui()
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
