extends "res://Base/State.gd"

func _ready():
    pass

var attempted

func enter_state(from_state = null, message = null):
    level._set_message("[color=#445544][b]Primary Objective[/b]: Experiment with (kill) the lab rats but don't hurt the black one![/color]\n\nPerfect - you selected just some of the rats. Now lets modify that DNA, try the following:\n\n[color=#1C9B1C]* UPDATE[/color] LabRats SET eye_colour = 'Red'\n    WHERE size > 0.5\n[color=#1C9B1C]* UPDATE[/color] LabRats SET adrenaline = 3\n    WHERE eye_color = 'Red'[color=#1C9B1C]\n* DELETE[/color] FROM LabRats WHERE nickname = '...'")

func finish_statement(sql, clause, row_count, max_rows):
    if clause in ['update', 'delete']:
        if attempted and clause != attempted:
            level._set_state("Proficient")
        attempted = clause
    