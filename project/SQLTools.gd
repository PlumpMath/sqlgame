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
    sql_client.create_database()
    pass

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        # Destructor
        sql_client.close_database()

func execute_sql(sql, original_clause = null):
    
    var clause = get_clause(sql)

    emit_signal("sql_start", sql, clause, original_clause)

    var prepare_result = sql_client.prepare_statement(sql)
    if (prepare_result != null):
        emit_signal("sql_error", prepare_result)
        return

    var first_row = true
    var results
    var headings
    while (1):
        results = sql_client.get_row()
        if (results.size() == 0):
            break
        if (first_row):
            headings = sql_client.get_column_names()
            emit_signal("sql_headings_retrieved", headings, original_clause if original_clause else clause)
        emit_signal("sql_row_retrieved", results, headings, original_clause if original_clause else clause)
        first_row = false

    # If no rows returned - check for error
    if first_row:
        if typeof(results) == TYPE_STRING:
            emit_signal("sql_error", results)
            return
    
    var finalize_result = sql_client.finalize_statement()
    if (finalize_result != null):
        emit_signal("sql_error", finalize_result)

    emit_signal("sql_complete", sql, clause)

    if original_clause != null:
        if clause in ["delete", "update", "insert"]:
        # Translate to select statement
            var sql_select = translate_to_select(sql, clause)
            execute_sql(sql_select, clause)


func get_clause(sql):
    var clause
    if sql.strip_edges(" ;").left(11).to_lower() == "delete from":
        return "delete"
    if sql.strip_edges(" ;").left(6).to_lower() == "select":
        return "select"
    if sql.strip_edges(" ;").left(6).to_lower() == "update":
        return "update"
    if sql.strip_edges(" ;").left(11).to_lower() == "insert into":
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
