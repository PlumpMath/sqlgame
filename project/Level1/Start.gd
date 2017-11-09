extends "res://Base/StateNode.gd"

onready var states = get_parent().get_children()

func _ready():
    pass

func check_state_change(row, headings, clause):
    if clause == "insert":
        level.set_state("Failure", "No more animals - you failed.")
    if clause == "update":
        level.set_state("Failure", "Oh no, you shouldn't have updated that.")
    if clause == "delete":
        for i in range(row.size()):
            if (headings[i] == "owner" && row[i] == "Jill"):
                level.set_state("Victory", "Wohoo. You killed the critter.")
                
        if !level.is_state("Victory"):
            level.set_state("Failure", "Oops. You killed the wrong critter.")
