extends Node

onready var level = get_parent().get_parent()

func _ready():
    pass

func enter_state(from_state, message):
    if message:
        level._set_message(message)
