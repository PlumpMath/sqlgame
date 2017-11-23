extends "res://Base/State.gd"


func _ready():
    pass

func enter_state(from_state, message):
    level.UI.viewport_texture.modulate.r = 0.5
    level.UI.viewport_texture.modulate.g = 1.0
    level.UI.viewport_texture.modulate.b = 0.5