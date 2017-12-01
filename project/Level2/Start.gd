extends "res://Base/State.gd"

func _ready():
    pass

func enter_state(from_state = null, message = null):
    level._set_message("[color=#999999][b]Primary Objective[/b]: Remove the 10 scientists from the plane.[/color]\n\n88 seats and 10 scientists - how will you ever find that GROUP, HAVING so little to go off?")

func finish_statement(sql, table, clause, row_count, max_rows):
    if clause == "select":
        if row_count == level.max_passports:
            pass
            #level._set_state("AddFiltering")
    elif clause in ["update", "delete", "insert"]:
        pass
        #level._set_state("Proficient")

func process_row(row, table, headings, clause):
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
