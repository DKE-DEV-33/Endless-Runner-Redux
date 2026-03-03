extends Control

@onready var score_label: Label = $Card/Center/ScoreLabel
@onready var distance_value_label: Label = $Card/Center/BreakdownRow/DistanceCard/VBox/Value
@onready var pickup_value_label: Label = $Card/Center/BreakdownRow/PickupCard/VBox/Value
@onready var risk_value_label: Label = $Card/Center/BreakdownRow/RiskCard/VBox/Value
@onready var coins_value_label: Label = $Card/Center/StatsRow/CoinsCard/VBox/Value
@onready var dodges_value_label: Label = $Card/Center/StatsRow/DodgesCard/VBox/Value
@onready var pace_value_label: Label = $Card/Center/StatsRow/PaceCard/VBox/Value
@onready var tier_value_label: Label = $Card/Center/StatsRow/TierCard/VBox/Value
@onready var best_label: Label = $Card/Center/BestLabel
@onready var play_again_button: Button = $Card/Center/PlayAgainButton
@onready var menu_button: Button = $Card/Center/MenuButton

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	_refresh_summary()

func _refresh_summary() -> void:
	var last_score: int = int(get_tree().get_meta("last_score", 0))
	var best_score: int = int(get_tree().get_meta("last_best_score", get_tree().get_meta("best_score", 0)))
	var is_new_best: bool = bool(get_tree().get_meta("is_new_best", false)) or bool(get_tree().get_meta("new_best", false))

	var distance_points: int = int(get_tree().get_meta("last_distance_points", 0))
	var pickup_points: int = int(get_tree().get_meta("last_pickup_points", 0))
	var risk_points: int = int(get_tree().get_meta("last_risk_points", 0))
	var coins_collected: int = int(get_tree().get_meta("last_coins_collected", 0))
	var hazards_dodged: int = int(get_tree().get_meta("last_hazards_dodged", 0))
	var max_pace: int = int(get_tree().get_meta("last_max_pace", 0))
	var mission_tier: int = int(get_tree().get_meta("last_mission_tier", 1))

	score_label.text = "Run Score: %d" % last_score
	distance_value_label.text = str(distance_points)
	pickup_value_label.text = str(pickup_points)
	risk_value_label.text = str(risk_points)
	coins_value_label.text = str(coins_collected)
	dodges_value_label.text = str(hazards_dodged)
	pace_value_label.text = str(max_pace)
	tier_value_label.text = str(mission_tier)
	best_label.text = "Best Run: %d" % best_score
	if is_new_best:
		best_label.text += " | New personal best"

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
