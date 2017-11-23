extends "res://Base/State.gd"


func _ready():
    pass

func enter_state(from_state, message):
    level.UI.viewport_texture.modulate.r = 0.9
    level.UI.viewport_texture.modulate.g = 0.3
    level.UI.viewport_texture.modulate.b = 0.3

    level.UI.execute_button.disabled = false
    level.UI.execute_button.theme = load("res://Base/Themes/DestructiveButton.tres")
    level.UI.execute_button.text = "RESTART"
