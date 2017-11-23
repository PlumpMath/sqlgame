extends Node

onready var level = get_parent()

func _ready():
    level.connect("state_updated", self, "_state_update")

func process_row(row, headings, clause):
    pass