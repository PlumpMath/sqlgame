extends "res://Base/State-Victory.gd"


func _ready():
    pass

func enter_state(from_state, message):
    .enter_state(from_state, message)
    level._set_message("Well done. Now lets move on to the next phase - the human genome...")
