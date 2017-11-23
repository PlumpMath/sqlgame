extends Node

onready var level = get_parent()

func _ready():
    level.connect("state_updated", self, "_state_update")

func process_row(row, headings, clause):
    pass
    
func _state_update(message):
    if level._is_state("Victory"):
        level.UI.viewport_texture.modulate.r = 0.5
        level.UI.viewport_texture.modulate.g = 1.0
        level.UI.viewport_texture.modulate.b = 0.5
    if level._is_state("Failure"):
        level.UI.viewport_texture.modulate.r = 0.9
        level.UI.viewport_texture.modulate.g = 0.3
        level.UI.viewport_texture.modulate.b = 0.3