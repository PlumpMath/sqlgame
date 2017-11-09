extends Node

onready var states = get_parent().get_children()
onready var level = get_parent().get_parent()

func _ready():
    pass

func check_state_change(row, headings, clause):
    if clause == "insert":
        level.state_history.push_back("Failure")
    if clause == "update":
        level.state_history.push_back("Failure")
    if clause == "delete":
        for i in range(row.size()):
            if (headings[i] == "owner" && row[i] == "Jill"):
                level.state_history.push_back("Victory")
                
        if (level.state_history[level.state_history.size() - 1] != "Victory"):
            level.state_history.push_back("Failure")
    # What to do on victory??
    if (level.state_history[level.state_history.size() - 1] == "Victory"):
        level.get_node("SceneVp/Spatial/MeshInstance").scale = Vector3(0.2,0.2,0.2)