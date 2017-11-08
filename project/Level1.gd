extends Node

var sql_node
enum {VICTORY_UNKNOWN, VICTORY_FAILED, VICTORY_SUCCESS}
var victory_status

func _ready():
    victory_status = VICTORY_UNKNOWN
    sql_node = get_node("SQLTools")
    sql_node.connect("sql_row_retrieved", self, "_check_victory_row")
    
    # Level data
    sql_node.execute_sql("CREATE TABLE `animals` (" +
        "`id`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`species`   TEXT NOT NULL," +
        "`fullname`  TEXT NOT NULL," +
        "`owner` TEXT NOT NULL," +
        "`colour`    TEXT NOT NULL);")
    sql_node.execute_sql("INSERT INTO animals VALUES (1, 'Cat', 'Bob', 'Jill', 'Blue');")

func _check_victory_row(row, headings, clause):
    print(row)
    print(headings)
    print(clause)
    if victory_status != VICTORY_UNKNOWN:
        return

    if clause == "insert":
        victory_status = VICTORY_FAILED
    if clause == "update":
        victory_status = VICTORY_FAILED
    if clause == "delete":
        for i in range(row.size()):
            if (headings[i] == "owner" && row[i] == "Jill"):
                victory_status = VICTORY_SUCCESS
        if (victory_status != VICTORY_SUCCESS):
            victory_status = VICTORY_FAILED
    if victory_status == VICTORY_SUCCESS:
        get_node("SceneVp/Spatial/MeshInstance").scale(2,2,2)