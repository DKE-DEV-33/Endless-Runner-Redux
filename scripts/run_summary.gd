extends Control

@onready var score_label: Label = $Card/Center/ScoreLabel
@onready var breakdown_label: Label = $Card/Center/BreakdownLabel
@onready var stats_label: Label = $Card/Center/StatsLabel
@onready var best_label: Label = $Card/Center/BestLabel
@onready var play_again_button: Button = $Card/Center/PlayAgainButton
@onready var menu_button: Button = $Card/Center/MenuButton

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	_refresh_summary()

func _refresh_summary() -> void:
	var last_score: int = int(get_tree().get_meta("last_score", 0))
	var best_score: int = int(get_tree().get_meta("best_score", 0))
	var is_new_best: bool = bool(get_tree().get_meta("is_new_best", false))

	var distance_points: int = int(get_tree().get_meta("last_distance_points", 0))
	var pickup_points: int = int(get_tree().get_meta("last_pickup_points", 0))
	var risk_points: int = int(get_tree().get_meta("last_risk_points", 0))
	var coins_collected: int = int(get_tree().get_meta("last_coins_collected", 0))
	var hazards_dodged: int = int(get_tree().get_meta("last_hazards_dodged", 0))
	var max_pace: int = int(get_tree().get_meta("last_max_pace", 0))
	var mission_tier: int = int(get_tree().get_meta("last_mission_tier", 1))

	var best_suffix: String = " NEW BEST!" if is_new_best else ""
	score_label.text = "Score: %d%s" % [last_score, best_suffix]
	breakdown_label.text = "Distance %d | Pickup %d | Risk %d" % [distance_points, pickup_points, risk_points]
	stats_label.text = "Coins %d | Dodges %d | Max Pace %d | Directive Tier %d" % [coins_collected, hazards_dodged, max_pace, mission_tier]
	best_label.text = "Best: %d" % best_score

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
