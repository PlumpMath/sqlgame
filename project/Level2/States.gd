extends "res://Base/States.gd"

onready var living_scientists = level.max_scientists

func _ready():
    pass

func start_statement(sql, table, clause, max_rows):
    pass

func process_row(row, table, headings, clause):
    if level._is_state("Failure"):
        return

    var id = row[0]

    if clause == 'select':
        pass

    if clause == 'insert':
        if table == 'PlaneParts':
            level.airliner._eject_part('Body')
            yield(get_tree().create_timer(5), "timeout")
            level._flash_popup("The manuafactering wrapper doesn't seem to like inserts...")
            level._set_state("Failure")

    if clause == 'delete' or clause == 'update':
        if table == 'PlaneParts':
            level.airliner._eject_part(row[1])
            if row[1] in level.airliner.critical_parts:
                yield(get_tree().create_timer(5), "timeout")
                level._flash_popup("It seemed like a good idea at the time.")
                level._set_state("Failure")
            elif row[0] <= 10:
                level._flash_popup("Guess that part wasn't needed. Continue on.")
            elif row[1] in level.primary_plane_part_names:
                living_scientists -= 1
                yield(get_tree().create_timer(5), "timeout")
                level._flash_popup("Bye bye")
            else:
                yield(get_tree().create_timer(5), "timeout")
                level._flash_popup("Oops, he wasn't one of them")
                level._set_state("Failure")

func finish_statement(sql, table, clause, row_count, max_rows):
    if table == 'PlaneParts' and clause == 'delete':
        if living_scientists == 0:
            yield(get_tree().create_timer(5), "timeout")
            level._set_state("Victory")
