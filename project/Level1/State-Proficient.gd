extends "res://Base/State.gd"

func enter_state(from_state = null, message = null):
    if from_state == "Start":
        level._set_message("Seems you have the hang of this already. I'll leave you to it but just remember.. don't hurt my pet!")
    else:
        level._set_message("Alright! Use those skills to start killing these rodents. Just don't hurt my pet!")

func _ready():
    # Called every time the node is added to the scene.
    # Initialization here
    pass

#func _process(delta):
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
