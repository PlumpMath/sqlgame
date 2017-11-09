extends Node

onready var sql_tools = get_parent().get_node("SQLTools")

func _ready():
    sql_tools.execute_raw("CREATE TABLE `animals` (" +
        "`id`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`species`   TEXT NOT NULL," +
        "`fullname`  TEXT NOT NULL," +
        "`owner` TEXT NOT NULL," +
        "`colour`    TEXT NOT NULL);")
    sql_tools.execute_raw("INSERT INTO animals VALUES (1, 'Cat', 'Bob', 'Jill', 'Blue');")