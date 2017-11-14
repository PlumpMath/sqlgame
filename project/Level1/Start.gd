extends "res://Base/State.gd"

func _ready():
    pass

func check_state_change(row, headings, clause):
    if clause == "insert":
        level._set_state("Failure", "We don't need any more criminals to deal with.")
    if clause == "update":
        level._set_state("Failure", "What are you trying to do? Hide criminals?")
    if clause == "delete":
        for i in range(row.size()):
            if (headings[i] == "shirt_colour" && row[i] == "Royal red"):
                level._set_state("Victory", "Wohoo. You killed the criminal.")
                
        if !level._is_state("Victory"):
            level._set_state("Failure", "Oops. You killed the wrong criminal.")
