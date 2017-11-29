extends TextEdit

var sql_history = []
var sql_history_index = 0
var sql_modified_history = []

const keywords = [
    'ABORT',
    'ACTION',
    'ADD',
    'AFTER',
    'ALL',
    'ALTER',
    'ANALYZE',
    'AND',
    'AS',
    'ASC',
    'ATTACH',
    'AUTOINCREMENT',
    'BEFORE',
    'BEGIN',
    'BETWEEN',
    'BY',
    'CASCADE',
    'CASE',
    'CAST',
    'CHECK',
    'COLLATE',
    'COLUMN',
    'COMMIT',
    'CONFLICT',
    'CONSTRAINT',
    'CREATE',
    'CROSS',
    'CURRENT_DATE',
    'CURRENT_TIME',
    'CURRENT_TIMESTAMP',
    'DATABASE',
    'DEFAULT',
    'DEFERRABLE',
    'DEFERRED',
    'DELETE',
    'DESC',
    'DETACH',
    'DISTINCT',
    'DROP',
    'EACH',
    'ELSE',
    'END',
    'ESCAPE',
    'EXCEPT',
    'EXCLUSIVE',
    'EXISTS',
    'EXPLAIN',
    'FAIL',
    'FOR',
    'FOREIGN',
    'FROM',
    'FULL',
    'GLOB',
    'GROUP',
    'HAVING',
    'IF',
    'IGNORE',
    'IMMEDIATE',
    'IN',
    'INDEX',
    'INDEXED',
    'INITIALLY',
    'INNER',
    'INSERT',
    'INSTEAD',
    'INTERSECT',
    'INTO',
    'IS',
    'ISNULL',
    'JOIN',
    'KEY',
    'LEFT',
    'LIKE',
    'LIMIT',
    'MATCH',
    'NATURAL',
    'NO',
    'NOT',
    'NOTNULL',
    'NULL',
    'OF',
    'OFFSET',
    'ON',
    'OR',
    'ORDER',
    'OUTER',
    'PLAN',
    'PRAGMA',
    'PRIMARY',
    'QUERY',
    'RAISE',
    'RECURSIVE',
    'REFERENCES',
    'REGEXP',
    'REINDEX',
    'RELEASE',
    'RENAME',
    'REPLACE',
    'RESTRICT',
    'RIGHT',
    'ROLLBACK',
    'ROW',
    'SAVEPOINT',
    'SELECT',
    'SET',
    'TABLE',
    'TEMP',
    'TEMPORARY',
    'THEN',
    'TO',
    'TRANSACTION',
    'TRIGGER',
    'UNION',
    'UNIQUE',
    'UPDATE',
    'USING',
    'VACUUM',
    'VALUES',
    'VIEW',
    'VIRTUAL',
    'WHEN',
    'WHERE',
    'WITH',
    'WITHOUT'
]

func _ready():
    sql_modified_history.push_back("")

    for word in keywords:
        add_keyword_color(word, Color(0.11,0.61,0.11))
    for word in keywords:
        add_keyword_color(word.to_lower() , Color(0.11,0.61,0.11))

func _update_history():
    sql_modified_history[sql_history_index] = get_text()

func _create_new_history():
    # Update the last history entry with the current statement
    var last_sql = sql_modified_history[sql_history_index]
    sql_history.push_back(last_sql)
    sql_modified_history = sql_history.duplicate()

    # Insert a new history extry (for new current)
    sql_modified_history.push_back("")
    sql_history_index = sql_modified_history.size() - 1

    # Update the GUI
    text = sql_modified_history.back()
    grab_focus()

func _history_step_back():
    if sql_history_index > 0:
        sql_history_index -= 1
        text = sql_modified_history[sql_history_index]
        cursor_set_column(1000, true)
        cursor_set_line(1000, true)

func _history_step_forward():
    if sql_history_index < sql_modified_history.size() - 1:
        sql_history_index += 1
        text = sql_modified_history[sql_history_index]
        cursor_set_column(1000, true)
        cursor_set_line(1000, true)

#func _process(delta):
#    # Called every frame. Delta is time since last frame.
#    # Update game logic here.
#    pass
