extends Control

@onready var logo: Label = $Center/Logo

func _ready() -> void:
	logo.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(logo, "modulate:a", 1.0, 0.7)
	t.tween_interval(1.0)
	t.tween_property(logo, "modulate:a", 0.0, 0.5)
	t.finished.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	)
