extends Node

signal state_updated
signal seeder_finished

onready var sql_tools = get_node("SQLTools")
onready var sql_seeder = get_node("SQLSeeder")
onready var states = get_node("States")
onready var UI = get_node("UI")

var state_history = Array()

func _ready():
    sql_tools.connect("sql_row_retrieved", self, "_check_row")

func _check_row(row, headings, clause):
    # Get current State
    var state_name = state_history[state_history.size() - 1]
    var state = states.get_node(state_name)
    if state.has_method("check_state_change"):
        state.check_state_change(row, headings, clause)
    if states.has_method("check_state_change"):
        states.check_state_change(row, headings, clause)

func _set_state(new_state, message):
    state_history.push_back(new_state)
    emit_signal("state_updated", message)

func _get_state():
    state_history.back()

func _is_state(state):
    return state == state_history.back()
    
func _table_show(name):
    sql_tools.describe_table(name)

func _table_add(name):
    var sql = UI.sql_editor.get_text()
    if sql.ends_with(name):
        pass
    elif sql == "":
        sql = "SELECT * FROM " + name
    elif sql.ends_with("\t") || sql.ends_with(" "):
        sql += name
    else:
        sql += " " + name
    UI.sql_editor.set_text(sql)

func _add_table(table_name):
    var item = UI.table_tree.create_item()
    item.add_button(0, load("res://Base/Images/view.png"))
    item.add_button(0, load("res://Base/Images/add.png"))
    item.set_text(0, table_name)
    item.set_selectable (0, false)