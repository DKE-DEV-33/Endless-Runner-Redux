extends Control

@onready var start_button: Button = $Center/StartButton
@onready var quit_button: Button = $Center/QuitButton
@onready var last_score_label: Label = $Center/LastScoreLabel
@onready var best_score_label: Label = $Center/BestScoreLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_refresh_score_labels()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

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

func _load_best_score() -> int:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load("user://run_stats.cfg")
	if err != OK:
		return 0
	return int(config.get_value("scores", "best_score", 0))
