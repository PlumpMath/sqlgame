extends "res://Base/StateNode.gd"

func _ready():
    level.connect("state_updated", self, "_state_update")
    level.set_state("Start", "There is an animal out of place here.\nDestory it!")
    pass

func check_state_change(row, headings, clause):
    pass

func _state_update(message):
    if level.is_state("Victory"):
        level.get_node("SceneVp/Spatial/MeshInstance").scale = Vector3(0.2,0.2,0.2)