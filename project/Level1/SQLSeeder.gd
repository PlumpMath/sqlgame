extends Node

onready var sql_tools = get_parent().get_node("SQLTools")

func _ready():
    sql_tools.connect("sql_seed_row_retrieved", self, "_seed_row");

    sql_tools.execute_raw("CREATE TABLE `Animals` (" +
        "`id`    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`species`   TEXT NOT NULL," +
        "`fullname`  TEXT NOT NULL," +
        "`owner` TEXT NOT NULL," +
        "`colour`    TEXT NOT NULL);")
    #sql_tools.execute_raw("INSERT INTO animals VALUES (1, 'Dog', 'Jack', 'Peter', 'Black');")
    #sql_tools.execute_raw("INSERT INTO animals VALUES (2, 'Cat', 'Cathrine', 'Jill', 'Blue');")
    #sql_tools.execute_raw("INSERT INTO animals VALUES (3, 'Mouse', 'Micky', 'Sam', 'Grey');")
    #sql_tools.execute_raw("INSERT INTO animals VALUES (4, 'Ant', 'Adam', 'Tom', 'Black');")
    #sql_tools.execute_raw("INSERT INTO animals VALUES (5, 'Nat', 'Nathan', 'John', 'White');")

    var root = get_parent().get_node("UI").table_tree.create_item()
    root.set_text(0,"Animals")

    sql_tools.select_seed_data("/srv/game/sqlgame/project/Animals.db", "SELECT * FROM Animals", "Animals")

func _seed_row(row, headings, table):
    var value_list = ""
    for value in row:
        if typeof(value) == TYPE_INT:
            value_list += str(value) + ","
        else: 
            value_list += "'" + str(value) + "',"
    value_list = value_list.left(value_list.length()-1)

    sql_tools.execute_raw("INSERT INTO Animals VALUES (" + value_list + ");")