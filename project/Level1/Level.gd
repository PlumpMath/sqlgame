extends "res://Base/Level.gd"

export var max_criminals = 10000
onready var primary_criminal_id = (randi() % max_criminals) + 1

func _ready():
    pass