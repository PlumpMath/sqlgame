extends "res://Base/Level.gd"

export var max_criminals = 10000
var primary_criminal_id = (randi() % max_criminals) + 1

func _ready():
    # Set tables
    _add_table("Criminals")

    _preview_scene(10)

func _start_objective_intro():
    print("Hide scene")
    UI.tab_container.set_current_tab(0)
    var agent1_icon = "res://Base/Images/agent1.svg"
    var handler_icon = "res://Base/Images/agent1.png"
    var dialog = [
        ["left", "Is that a capsicum?", agent1_icon, 1.3],
        ["right", "Yes. Why?", handler_icon, 1.3],
        ["left", "No reason.. just curious", agent1_icon, 1.3]
    ]
    yield(get_tree().create_timer(5), "timeout")
    emit_signal("end_objective_intro", dialog)