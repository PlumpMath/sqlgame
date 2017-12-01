extends "res://Base/State.gd"

func _ready():
    pass

func enter_state(from_state = null, message = null):
    level._set_message("[color=#999999][b]Primary Objective[/b]: Experiment with the lab rats but don't hurt the black one![/color]\n\nNice - you selected the rats. Did you notice their heads highlight when you SELECT them. Use that.\n\nNow try add a filter:\n[color=#1C9B1C]SELECT[/color] * FROM LabRats WHERE size > 0.5\n\nUse the up key to scroll through previous commands.")

func finish_statement(sql, table, clause, row_count, max_rows):
    if row_count != level.max_rats:
        level._set_state("OtherClauses")
    elif clause != "select":
        level._set_state("Proficient")
