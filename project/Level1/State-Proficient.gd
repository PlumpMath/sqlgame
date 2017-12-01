extends "res://Base/State.gd"

func enter_state(from_state = null, message = null):
    if from_state == "Start":
        level._set_message("[color=#999999][b]Primary Objective[/b]: Experiment with (kill) the lab rats but don't hurt the black one![/color]\n\nIt seems you have the hang of this already - you don't need my training. Just keep in mind: there's a plenty of ways to kill a rat, but no way to revive them - keep my black rat safe!")
    else:
        level._set_message("[color=#999999][b]Primary Objective[/b]: Experiment with (kill) the lab rats but don't hurt the black one![/color]\n\nSeems you have the hang of this. Just keep in mind: there's a plenty of ways to kill a rat, but no way to revive them - keep my black rat safe!")

func _ready():
    # Called every time the node is added to the scene.
    # Initialization here
    pass

#func _process(delta):
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
