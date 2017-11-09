extends Node

onready var sql_tools = get_node("SQLTools")
onready var sql_seeder = get_node("SQLSeeder")
onready var states = get_node("States")

onready var state_history = ["Start"]

enum {VICTORY_UNKNOWN, VICTORY_FAILED, VICTORY_SUCCESS}
var victory_status

func _ready():

    

    victory_status = VICTORY_UNKNOWN
    sql_tools.connect("sql_row_retrieved", self, "_check_row")


func _check_row(row, headings, clause):
    # Get current State
    var state_name = state_history[state_history.size() - 1]
    var state = states.get_node(state_name)
    if state.has_method("check_state_change"):
        state.check_state_change(row, headings, clause)
    if states.has_method("check_state_change"):
        states.check_state_change(row, headings, clause)
