extends Control

const INTRO_MUSIC_PATH: String = "res://assets/audio/intro_music.mp3"
const RUN_STATS_FILE_TEMPLATE: String = "user://run_stats_%s.cfg"
const PROFILE_IDS: Array[String] = ["slot1", "slot2", "slot3"]
const STARTING_UNLOCKED_RELICS: Array[String] = ["aegis_shard", "vitality_cell", "coin_lens"]

@onready var main_menu_box: VBoxContainer = $Card/Center/MainMenuBox
@onready var load_panel: VBoxContainer = $Card/Center/LoadPanel
@onready var name_panel: VBoxContainer = $Card/Center/NamePanel

@onready var new_game_button: Button = $Card/Center/MainMenuBox/NewGameButton
@onready var load_game_button: Button = $Card/Center/MainMenuBox/LoadGameButton
@onready var quit_button: Button = $Card/Center/MainMenuBox/QuitButton

@onready var load_header_label: Label = $Card/Center/LoadPanel/LoadHeaderLabel
@onready var slot1_button: Button = $Card/Center/LoadPanel/SlotsBox/Slot1Button
@onready var slot2_button: Button = $Card/Center/LoadPanel/SlotsBox/Slot2Button
@onready var slot3_button: Button = $Card/Center/LoadPanel/SlotsBox/Slot3Button
@onready var load_hint_label: Label = $Card/Center/LoadPanel/LoadHintLabel
@onready var delete_mode_button: Button = $Card/Center/LoadPanel/LoadActions/DeleteModeButton
@onready var load_back_button: Button = $Card/Center/LoadPanel/LoadActions/MainMenuButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

@onready var name_header_label: Label = $Card/Center/NamePanel/NameHeaderLabel
@onready var target_slot_label: Label = $Card/Center/NamePanel/TargetSlotLabel
@onready var player_name_edit: LineEdit = $Card/Center/NamePanel/PlayerNameEdit
@onready var name_hint_label: Label = $Card/Center/NamePanel/NameHintLabel
@onready var create_button: Button = $Card/Center/NamePanel/NameActions/CreateButton
@onready var name_back_button: Button = $Card/Center/NamePanel/NameActions/BackButton

var intro_player: AudioStreamPlayer = AudioStreamPlayer.new()
var pending_slot: String = ""
var override_mode: bool = false
var delete_mode: bool = false
var selected_slot: String = ""
var pending_confirm_action: String = ""
var pending_confirm_slot: String = ""

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	slot1_button.pressed.connect(_on_slot_pressed.bind(PROFILE_IDS[0]))
	slot2_button.pressed.connect(_on_slot_pressed.bind(PROFILE_IDS[1]))
	slot3_button.pressed.connect(_on_slot_pressed.bind(PROFILE_IDS[2]))
	delete_mode_button.pressed.connect(_on_delete_mode_pressed)
	load_back_button.pressed.connect(_show_main_menu)
	create_button.pressed.connect(_on_create_pressed)
	name_back_button.pressed.connect(_on_name_back_pressed)
	confirm_dialog.confirmed.connect(_on_confirmed)
	player_name_edit.text_submitted.connect(func(_text: String) -> void: _on_create_pressed())
	_setup_intro_music()
	_show_main_menu()

func _on_new_game_pressed() -> void:
	var free_slot: String = _first_free_slot()
	if free_slot != "":
		_open_name_panel(free_slot, false)
		return
	_open_load_panel(true)
	load_hint_label.text = "No free slots. Choose a save file to overwrite."

func _on_load_game_pressed() -> void:
	_open_load_panel(false)
	load_hint_label.text = "Choose a save file to load."

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_slot_pressed(slot_id: String) -> void:
	selected_slot = slot_id
	_refresh_slot_buttons()
	if delete_mode:
		if not _slot_exists(slot_id):
			load_hint_label.text = "That slot is already empty."
			return
		_request_confirmation("delete", slot_id, "Delete %s?" % _slot_display_name(slot_id))
		return
	if override_mode:
		if not _slot_exists(slot_id):
			load_hint_label.text = "Select a used slot to overwrite."
			return
		_request_confirmation("overwrite", slot_id, "Overwrite %s?" % _slot_display_name(slot_id))
		return
	if not _slot_exists(slot_id):
		load_hint_label.text = "That slot is empty."
		return
	_load_slot(slot_id)

func _on_delete_mode_pressed() -> void:
	delete_mode = not delete_mode
	delete_mode_button.text = "Delete Mode: ON" if delete_mode else "Delete Save File"
	load_hint_label.text = "Choose a slot to delete." if delete_mode else "Choose a save file."

func _on_create_pressed() -> void:
	var player_name: String = player_name_edit.text.strip_edges()
	if player_name == "":
		name_hint_label.text = "Enter a player name to continue."
		return
	if pending_slot == "":
		name_hint_label.text = "No target slot selected."
		return
	_create_or_overwrite_slot(pending_slot, player_name)
	_load_slot(pending_slot)

func _on_name_back_pressed() -> void:
	if override_mode:
		_open_load_panel(true)
	else:
		_show_main_menu()

func _show_main_menu() -> void:
	main_menu_box.visible = true
	load_panel.visible = false
	name_panel.visible = false
	delete_mode = false
	override_mode = false
	pending_slot = ""
	selected_slot = ""

func _open_load_panel(require_override: bool) -> void:
	main_menu_box.visible = false
	load_panel.visible = true
	name_panel.visible = false
	override_mode = require_override
	delete_mode = false
	selected_slot = ""
	delete_mode_button.text = "Delete Save File"
	load_header_label.text = "Select Save To Overwrite" if require_override else "Load Game"
	_refresh_slot_buttons()

func _open_name_panel(slot_id: String, is_override: bool) -> void:
	main_menu_box.visible = false
	load_panel.visible = false
	name_panel.visible = true
	pending_slot = slot_id
	override_mode = is_override
	player_name_edit.text = ""
	player_name_edit.grab_focus()
	name_header_label.text = "Overwrite Save" if is_override else "Create New Save"
	target_slot_label.text = "Target: %s" % _slot_display_name(slot_id)
	name_hint_label.text = "This will replace existing data." if is_override else "Enter your player name."
	create_button.text = "Overwrite + Start" if is_override else "Create + Start"

func _refresh_slot_buttons() -> void:
	slot1_button.text = _slot_button_text(PROFILE_IDS[0])
	slot2_button.text = _slot_button_text(PROFILE_IDS[1])
	slot3_button.text = _slot_button_text(PROFILE_IDS[2])

func _slot_button_text(slot_id: String) -> String:
	var prefix: String = ">> " if selected_slot == slot_id else ""
	if not _slot_exists(slot_id):
		return "%s%s: Empty" % [prefix, _slot_display_name(slot_id)]
	var meta: Dictionary = _slot_meta(slot_id)
	var name: String = String(meta.get("name", "Player"))
	var best: int = int(meta.get("best", 0))
	var credits: int = int(meta.get("credits", 0))
	var last_played: String = String(meta.get("last_played", "Never"))
	return "%s%s: %s | Best %d | Credits %d | %s" % [prefix, _slot_display_name(slot_id), name, best, credits, last_played]

func _slot_display_name(slot_id: String) -> String:
	var idx: int = PROFILE_IDS.find(slot_id)
	var num: int = idx + 1 if idx >= 0 else 0
	return "Slot %d" % num

func _first_free_slot() -> String:
	for slot_id: String in PROFILE_IDS:
		if not _slot_exists(slot_id):
			return slot_id
	return ""

func _slot_exists(slot_id: String) -> bool:
	return FileAccess.file_exists(_run_stats_file(slot_id))

func _slot_player_name(slot_id: String) -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load(_run_stats_file(slot_id)) != OK:
		return "Unknown"
	return String(config.get_value("profile", "name", "Player"))

func _slot_meta(slot_id: String) -> Dictionary:
	var config: ConfigFile = ConfigFile.new()
	if config.load(_run_stats_file(slot_id)) != OK:
		return {}
	return {
		"name": String(config.get_value("profile", "name", "Player")),
		"best": int(config.get_value("scores", "best_score", 0)),
		"credits": int(config.get_value("progression", "credits", 0)),
		"last_played": String(config.get_value("profile", "last_played", "Never")),
	}

func _create_or_overwrite_slot(slot_id: String, player_name: String) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("profile", "name", player_name)
	config.set_value("profile", "last_played", Time.get_datetime_string_from_system(false, true))
	config.set_value("scores", "best_score", 0)
	config.set_value("progression", "credits", 0)
	config.set_value("progression", "perk_vitality", 0)
	config.set_value("progression", "perk_coin_value", 0)
	config.set_value("progression", "perk_fireguard", 0)
	config.set_value("progression", "relic_unlocks", STARTING_UNLOCKED_RELICS.duplicate())
	config.save(_run_stats_file(slot_id))

func _delete_slot(slot_id: String) -> void:
	if not _slot_exists(slot_id):
		load_hint_label.text = "That slot is already empty."
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(_run_stats_file(slot_id)))
	_refresh_slot_buttons()
	load_hint_label.text = "%s deleted." % _slot_display_name(slot_id)

func _request_confirmation(action: String, slot_id: String, message: String) -> void:
	pending_confirm_action = action
	pending_confirm_slot = slot_id
	confirm_dialog.dialog_text = message
	confirm_dialog.popup_centered()

func _on_confirmed() -> void:
	if pending_confirm_action == "overwrite":
		_open_name_panel(pending_confirm_slot, true)
	elif pending_confirm_action == "delete":
		_delete_slot(pending_confirm_slot)
	pending_confirm_action = ""
	pending_confirm_slot = ""

func _load_slot(slot_id: String) -> void:
	_clear_last_run_meta()
	get_tree().set_meta("profile_id", slot_id)
	if intro_player.playing:
		intro_player.stop()
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _run_stats_file(slot_id: String) -> String:
	return RUN_STATS_FILE_TEMPLATE % slot_id

func _clear_last_run_meta() -> void:
	var keys: Array[String] = [
		"last_score",
		"last_distance_points",
		"last_pickup_points",
		"last_risk_points",
		"last_hazards_dodged",
		"last_max_pace",
		"last_mission_tier",
		"last_coins_collected",
		"last_credits_earned",
		"last_relics",
		"last_relic_rarity",
		"last_synergies",
		"is_new_best",
		"new_best",
	]
	for key: String in keys:
		if get_tree().has_meta(key):
			get_tree().remove_meta(key)

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
