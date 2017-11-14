extends "res://Base/States.gd"

func _ready():
    level.connect("state_updated", self, "_state_update")
    level._set_state("Start", "We're looking for a criminal with a [color=#9B1C31]Royal red[/color] shirt. Find and DELETE him!")
    pass

func check_state_change(row, headings, clause):
    pass

func _state_update(message):
    if level._is_state("Victory"):
        level.get_node("SceneVp/Spatial/MeshInstance").scale = Vector3(0.2,0.2,0.2)
    if level._is_state("Failure"):
        level.UI.viewport_texture.modulate.r = 1
        level.UI.viewport_texture.modulate.g = 0.5
        level.UI.viewport_texture.modulate.b = 0.5