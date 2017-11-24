extends "res://Base/State.gd"

func _ready():
    pass

var attempted

func enter_state(from_state = null, message = null):
    level._set_message("Perfect - you selected just some of the rats. Now lets get a bit more interactive, try each of the following:\n\n[color=#1C9B1C]DELETE[/color] FROM LabRats WHERE name = '?'\n[color=#1C9B1C]UPDATE[/color] LabRats SET eye_color = 'Yellow'\n    WHERE size > 1\n[color=#1C9B1C]UPDATE[/color] LabRats SET adrenaline = 3\n    WHERE eye_color = 'Yellow'")

func finish_statement(sql, clause, row_count, max_rows):
    if clause in ['update', 'delete']:
        if attempted and clause != attempted:
            level._set_state("Proficient")
        attempted = clause
    if clause != 'select':
        level._set_state("Proficient")
    