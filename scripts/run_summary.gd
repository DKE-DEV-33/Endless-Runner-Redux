extends Control

const RUN_STATS_FILE_TEMPLATE: String = "user://run_stats_%s.cfg"
const RELIC_UNLOCK_CHOICES: int = 3
const STARTING_UNLOCKED_RELICS: Array[String] = ["aegis_shard", "vitality_cell", "coin_lens"]
const RELIC_LIBRARY: Dictionary = {
	"aegis_shard": {"name": "Aegis Shard", "effect": "Gain a shield charge now.", "rarity": "common", "weight": 1.00},
	"vitality_cell": {"name": "Vitality Cell", "effect": "Restore 1 health immediately.", "rarity": "common", "weight": 1.00},
	"coin_lens": {"name": "Coin Lens", "effect": "+10% coin score value this run.", "rarity": "common", "weight": 0.95},
	"magnet_array": {"name": "Magnet Array", "effect": "+50 magnet pickup radius this run.", "rarity": "uncommon", "weight": 0.62},
	"chrono_spool": {"name": "Chrono Spool", "effect": "+1s chrono duration this run.", "rarity": "uncommon", "weight": 0.58},
	"firecore": {"name": "Firecore Prism", "effect": "+1.5s fireguard duration this run.", "rarity": "rare", "weight": 0.30},
}
const RELIC_IDS: Array[String] = ["aegis_shard", "vitality_cell", "coin_lens", "magnet_array", "chrono_spool", "firecore"]

@onready var center_box: VBoxContainer = $Card/Center
@onready var score_label: Label = $Card/Center/ScoreLabel
@onready var stats_summary_label: Label = $Card/Center/StatsSummaryLabel
@onready var breakdown_row: HBoxContainer = $Card/Center/BreakdownRow
@onready var stats_row: HBoxContainer = $Card/Center/StatsRow
@onready var distance_value_label: Label = $Card/Center/BreakdownRow/DistanceCard/VBox/Value
@onready var pickup_value_label: Label = $Card/Center/BreakdownRow/PickupCard/VBox/Value
@onready var risk_value_label: Label = $Card/Center/BreakdownRow/RiskCard/VBox/Value
@onready var coins_value_label: Label = $Card/Center/StatsRow/CoinsCard/VBox/Value
@onready var dodges_value_label: Label = $Card/Center/StatsRow/DodgesCard/VBox/Value
@onready var pace_value_label: Label = $Card/Center/StatsRow/PaceCard/VBox/Value
@onready var tier_value_label: Label = $Card/Center/StatsRow/TierCard/VBox/Value
@onready var best_label: Label = $Card/Center/BestLabel
@onready var credits_label: Label = $Card/Center/CreditsLabel
@onready var relics_label: Label = $Card/Center/RelicsLabel
@onready var play_again_button: Button = $Card/Center/PlayAgainButton
@onready var menu_button: Button = $Card/Center/MenuButton

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var unlock_header_label: Label
var unlock_status_label: Label
var unlock_choice_buttons: Array[Button] = []
var pending_unlock_choices: Array[String] = []

func _ready() -> void:
	rng.randomize()
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	# Keep the old card rows for future polish, but hide for now to prevent overlap at this card size.
	breakdown_row.visible = false
	stats_row.visible = false
	_setup_unlock_ui()
	_refresh_summary()
	_refresh_unlock_ui()

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
	var credits_earned: int = int(get_tree().get_meta("last_credits_earned", 0))
	var total_credits: int = int(get_tree().get_meta("total_credits", 0))
	var relics_text: String = String(get_tree().get_meta("last_relics", "None"))
	var rarity_text: String = String(get_tree().get_meta("last_relic_rarity", "C:0 U:0 R:0"))
	var synergies_text: String = String(get_tree().get_meta("last_synergies", "None"))

	score_label.text = "Run Score: %d" % last_score
	distance_value_label.text = str(distance_points)
	pickup_value_label.text = str(pickup_points)
	risk_value_label.text = str(risk_points)
	coins_value_label.text = str(coins_collected)
	dodges_value_label.text = str(hazards_dodged)
	pace_value_label.text = str(max_pace)
	tier_value_label.text = str(mission_tier)
	stats_summary_label.text = "Distance: %d   Pickups: %d   Risk: %d\nCoins: %d   Dodges: %d   Pace: %d   Directive: %d" % [distance_points, pickup_points, risk_points, coins_collected, hazards_dodged, max_pace, mission_tier]
	best_label.text = "Best Run: %d" % best_score
	credits_label.text = "Credits: +%d (Total %d)" % [credits_earned, total_credits]
	relics_label.text = "Relics (%s): %s\nSynergies: %s" % [rarity_text, relics_text, synergies_text]
	if is_new_best:
		best_label.text += " | New personal best"

func _setup_unlock_ui() -> void:
	unlock_header_label = Label.new()
	unlock_header_label.text = "Archive Unlock Choice"
	unlock_header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unlock_header_label.add_theme_font_size_override("font_size", 20)
	unlock_header_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	center_box.add_child(unlock_header_label)
	center_box.move_child(unlock_header_label, center_box.get_children().find(play_again_button))

	unlock_status_label = Label.new()
	unlock_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unlock_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unlock_status_label.add_theme_font_size_override("font_size", 15)
	unlock_status_label.add_theme_color_override("font_color", Color(0.74, 0.86, 1.0))
	center_box.add_child(unlock_status_label)
	center_box.move_child(unlock_status_label, center_box.get_children().find(play_again_button))

	for i: int in range(RELIC_UNLOCK_CHOICES):
		var choice_button: Button = Button.new()
		choice_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice_button.focus_mode = Control.FOCUS_NONE
		choice_button.pressed.connect(_on_unlock_choice_pressed.bind(i))
		unlock_choice_buttons.append(choice_button)
		center_box.add_child(choice_button)
		center_box.move_child(choice_button, center_box.get_children().find(play_again_button))

func _refresh_unlock_ui() -> void:
	var unlocked: Array[String] = _load_unlocked_relics()
	var locked: Array[String] = []
	for relic_id: String in RELIC_IDS:
		if not unlocked.has(relic_id):
			locked.append(relic_id)
	if locked.is_empty():
		unlock_status_label.text = "All relic patterns unlocked for this save slot."
		for choice_button: Button in unlock_choice_buttons:
			choice_button.visible = false
		return

	pending_unlock_choices = _roll_weighted_unlock_choices(locked, mini(RELIC_UNLOCK_CHOICES, locked.size()))
	unlock_status_label.text = "Choose one permanent unlock for future runs."
	for idx: int in range(unlock_choice_buttons.size()):
		var choice_button: Button = unlock_choice_buttons[idx]
		if idx < pending_unlock_choices.size():
			var relic_id: String = pending_unlock_choices[idx]
			choice_button.text = _unlock_choice_text(relic_id)
			choice_button.visible = true
			choice_button.disabled = false
		else:
			choice_button.visible = false

func _on_unlock_choice_pressed(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= pending_unlock_choices.size():
		return
	var unlocked: Array[String] = _load_unlocked_relics()
	var relic_id: String = pending_unlock_choices[choice_index]
	if not unlocked.has(relic_id):
		unlocked.append(relic_id)
		_save_unlocked_relics(unlocked)
	unlock_status_label.text = "Unlocked: %s. This relic can now appear in run drafts." % _relic_display_name(relic_id)
	for choice_button: Button in unlock_choice_buttons:
		choice_button.disabled = true
		choice_button.visible = false
	get_tree().set_meta("last_meta_unlock", _relic_display_name(relic_id))

func _roll_weighted_unlock_choices(pool: Array[String], count: int) -> Array[String]:
	var source: Array[String] = []
	for relic_id: String in pool:
		source.append(relic_id)
	var result: Array[String] = []
	while result.size() < count and not source.is_empty():
		var picked_id: String = _pick_weighted_relic(source)
		if picked_id == "":
			break
		result.append(picked_id)
		source.erase(picked_id)
	return result

func _pick_weighted_relic(pool: Array[String]) -> String:
	if pool.is_empty():
		return ""
	var total_weight: float = 0.0
	for relic_id: String in pool:
		total_weight += _relic_weight(relic_id)
	if total_weight <= 0.0:
		return pool[rng.randi_range(0, pool.size() - 1)]
	var roll: float = rng.randf() * total_weight
	var cursor: float = 0.0
	for relic_id: String in pool:
		cursor += _relic_weight(relic_id)
		if roll <= cursor:
			return relic_id
	return pool[pool.size() - 1]

func _relic_weight(relic_id: String) -> float:
	if RELIC_LIBRARY.has(relic_id):
		return float(RELIC_LIBRARY[relic_id].get("weight", 1.0))
	return 1.0

func _unlock_choice_text(relic_id: String) -> String:
	var rarity: String = _relic_rarity(relic_id).capitalize()
	return "[%s] %s | %s" % [rarity, _relic_display_name(relic_id), _relic_effect_text(relic_id)]

func _relic_display_name(relic_id: String) -> String:
	if RELIC_LIBRARY.has(relic_id):
		return String(RELIC_LIBRARY[relic_id].get("name", relic_id))
	return relic_id

func _relic_effect_text(relic_id: String) -> String:
	if RELIC_LIBRARY.has(relic_id):
		return String(RELIC_LIBRARY[relic_id].get("effect", ""))
	return ""

func _relic_rarity(relic_id: String) -> String:
	if RELIC_LIBRARY.has(relic_id):
		return String(RELIC_LIBRARY[relic_id].get("rarity", "common"))
	return "common"

func _run_stats_file() -> String:
	var profile_id: String = String(get_tree().get_meta("profile_id", "slot1"))
	return RUN_STATS_FILE_TEMPLATE % profile_id

func _load_unlocked_relics() -> Array[String]:
	var config: ConfigFile = ConfigFile.new()
	if config.load(_run_stats_file()) != OK:
		return STARTING_UNLOCKED_RELICS.duplicate()
	return _sanitize_relic_unlocks(config.get_value("progression", "relic_unlocks", STARTING_UNLOCKED_RELICS))

func _save_unlocked_relics(unlocked: Array[String]) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(_run_stats_file())
	config.set_value("progression", "relic_unlocks", unlocked)
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

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
