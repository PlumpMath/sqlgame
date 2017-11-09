extends Node

var sql_client

signal sql_start
signal sql_error
signal sql_headings_retrieved
signal sql_row_retrieved
signal sql_complete

func _ready():
    # Initiate the client - connect to the database
    sql_client = SqlModule.new()
    sql_client.open_database()
    pass

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        # Destructor
        sql_client.close_database()

# Returns an error or the number of effected rows
func execute_raw(sql):
    var prepare_result = sql_client.prepare_statement(sql)
    if (prepare_result != null):
        return prepare_result
    return sql_client.execute_general()

func execute_raw_insert(sql):
    var prepare_result = sql_client.prepare_statement(sql)
    if (prepare_result != null):
        return prepare_result
    return sql_client.execute_insert()

# Translates the statement to an SELECT and 'signals' the results
func execute_select(sql):    
    var clause = get_clause(sql)

    # Translate SQL to a select statement
    var new_sql
    if clause in ["update", "delete"]:
        new_sql = translate_to_select(sql, clause)
    elif clause == "insert":
        var result = execute_raw_insert(sql)
        if (typeof(result) == TYPE_STRING):
            emit_signal("sql_error", result)
            return
        var table = get_table_name(sql, clause)
        new_sql = "SELECT * FROM " + table + " WHERE id = " + str(result)
    else:
        new_sql = sql

    emit_signal("sql_start", sql, clause)

    var prepare_result = sql_client.prepare_statement(new_sql)
    if (prepare_result != null):
        emit_signal("sql_error", prepare_result)
        return

    var first_row = true
    var results
    var headings
    while (1):
        results = sql_client.get_row()
        if typeof(results) == TYPE_STRING:
            emit_signal("sql_error", results)
            break
        if typeof(results) == TYPE_INT:
            emit_signal("sql_error", results)
            break
        if typeof(results) != TYPE_ARRAY || results.size() == 0:
            break
        if (first_row):
            headings = sql_client.get_column_names()
            emit_signal("sql_headings_retrieved", headings, clause)
        emit_signal("sql_row_retrieved", results, headings, clause)
        first_row = false
    
    var finalize_result = sql_client.finalize_statement()
    if (finalize_result != null):
        emit_signal("sql_error", finalize_result)

    emit_signal("sql_complete", sql, clause)


func get_clause(sql):
    var clause
    if sql.strip_edges(" ;").left(6).to_lower() == "delete":
        return "delete"
    if sql.strip_edges(" ;").left(6).to_lower() == "select":
        return "select"
    if sql.strip_edges(" ;").left(6).to_lower() == "update":
        return "update"
    if sql.strip_edges(" ;").left(6).to_lower() == "insert":
        return "insert"
    return "unknown";

func translate_to_select(sql, clause):
    if (clause == "delete"):
        return sql.replacen("DELETE FROM", "SELECT * FROM")
    if (clause == "update"):
        var select_sql = sql.replacen("UPDATE ", "SELECT * FROM ")
        var set_location = sql.findn(" SET ")
        var part1 = sql.left(set_location)
        var where_location = sql.findn(" WHERE ")
        var part2 = sql.right(where_location)
        return part1 + part2

func get_table_name(sql, clause):
    var lead
    if clause == "insert":
        lead = "INSERT INTO"
    elif clause == "update":
        lead = "UPDATE"
    elif clause == "delete":
        lead = "DELETE FROM"
    else:
        lead = " FROM "

    var start = sql.findn(lead) + 11
    var remaining = sql.right(start).strip_edges(" ")
    var end = 0
    while remaining.substr(end, 1) != " ":
        end += 1
    return remaining.left(end)