extends "res://Base/Level.gd"

export var max_criminals = 10000
var primary_criminal_id = (randi() % max_criminals) + 1

func _ready():
    # Set tables
    _add_table("Criminals")

    _preview_scene()

func _start_objective_intro():
    print("Hide scene")
    UI.tab_container.set_current_tab(0)

    var characters = {
        'Agent1' : "res://Base/Images/agent1.svg",
        'Handler' : "res://Base/Images/agent1.png"
    }
    var dialog = [
        ["left", "Is that a capsicum?", 'Agent1', 1.6],
        ["right", "Yes. Why?", 'Handler', 1.6],
        ["left", "No reason.. just curious", 'Agent1', 1.6]
    ]
    yield(get_tree().create_timer(2), "timeout")
    emit_signal("end_objective_intro", characters, dialog)