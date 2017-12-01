extends "res://Base/State-Victory.gd"

export(NodePath) var next_scene = "res://Credits/Credits.tscn"

func _ready():
    pass

func enter_state(from_state, message):
    .enter_state(from_state, message)
    level._set_message("Well done.")
    
    yield(get_tree().create_timer(3), "timeout")
    get_node("/root/SceneSwitcher").cut_to_scene(next_scene)