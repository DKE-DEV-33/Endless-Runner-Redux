extends Control

@onready var start_button: Button = $Card/Center/StartButton
@onready var quit_button: Button = $Card/Center/QuitButton
@onready var last_score_label: Label = $Card/Center/LastScoreLabel
@onready var best_score_label: Label = $Card/Center/BestScoreLabel
@onready var mode_button: Button = $Card/Center/ModeButton
@onready var daily_seed_label: Label = $Card/Center/DailySeedLabel

var run_mode: String = "standard"

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	mode_button.pressed.connect(_on_mode_pressed)
	run_mode = String(get_tree().get_meta("run_mode", "standard"))
	_refresh_mode_ui()
	_refresh_score_labels()

func _on_start_pressed() -> void:
	get_tree().set_meta("run_mode", run_mode)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

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
