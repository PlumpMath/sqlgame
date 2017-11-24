extends "res://Base/State.gd"

func _ready():
    pass

func enter_state(from_state = null, message = null):
    level._set_message("Freely experiment with the lab rats but don't hurt my black one!\n\nTo begin with, type [color=#1C9B1C]SELECT[/color]:\n [code]SELECT * FROM LabRats[/code]\n(or click [img]res://Base/Images/add.png[/img])\n\nEach query will display results as data below.")

func finish_statement(sql, clause, row_count, max_rows):
    if clause == "select":
        if row_count == level.max_rats:
            level._set_state("AddFiltering")
    elif clause in ["update", "delete", "insert"]:
        level._set_state("Proficient")

func process_row(row, headings, clause):
    if clause == "select":
        pass
    if clause == "insert":
        pass
        #level._set_state("Failure", "We don't need any more criminals to deal with.")
    if clause == "update":
        pass
        #level._set_state("Failure", "What are you trying to do? Hide criminals?")
    if clause == "delete":
        pass
