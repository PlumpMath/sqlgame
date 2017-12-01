extends "res://Base/States.gd"

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
        pass

    if clause == 'delete':
        if table == 'PlaneParts':
            level.airliner._eject_part(row[1])
            if !(row[1] in level.primary_plane_part_names):
                yield(get_tree().create_timer(5), "timeout")
                level._set_state("Failure")
            elif (row[1] in level.airliner.critical_parts):
                yield(get_tree().create_timer(5), "timeout")
                level._flash_popup("It seemed like a good idea at the time.")
                level._set_state("Failure")
            else:
                level._flash_popup("Guess the that wasn't needed. Continue on.")

    if clause == 'update':
        pass

func finish_statement(sql, table, clause, row_count, max_rows):
    if table == 'PlaneParts' and clause == 'delete':
        if row_count != level.max_scientists:
            yield(get_tree().create_timer(5), "timeout")
            level._set_state("Failure")
        else:
            yield(get_tree().create_timer(5), "timeout")
            level._set_state("Victory")
