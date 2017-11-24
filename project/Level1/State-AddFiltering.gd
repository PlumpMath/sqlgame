extends "res://Base/State.gd"

func _ready():
    pass

func enter_state(from_state = null, message = null):
    level._set_message("Nice - you selected the rats. Did you notice their heads highlight when you SELECT them. Use that.\n\nNow try add a filter:\n[color=#1C9B1C]SELECT[/color] * FROM LabRats WHERE size > 1\n\nUse the result from the previous query (below) as a guide on what to filter on")

func finish_statement(sql, clause, row_count, max_rows):
    if row_count != level.max_rats:
        level._set_state("OtherClauses")
    elif clause != "select":
        level._set_state("Proficient")
