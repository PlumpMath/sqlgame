extends "res://Base/Level.gd"

export var max_criminals = 10000
var primary_criminal_id = (randi() % max_criminals) + 1

func _ready():
    var player = UI.get_node("AnimationPlayer")
    yield(get_tree().create_timer(5.0), "timeout")
    player.play("StartCutscene")
    yield(get_tree().create_timer(5.0), "timeout")
    player.queue("EndCutscene")