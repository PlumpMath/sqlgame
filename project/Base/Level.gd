extends Node

signal state_updated
signal seeder_finished
signal end_objective_intro
signal end_dialog

onready var sql_tools = get_node("SQLTools")
onready var sql_seeder = get_node("SQLSeeder")
onready var states = get_node("States")
onready var UI = get_node("UI")
onready var anim = UI.get_node("AnimationPlayer")
var objectives_shown = false

var state_history = Array()

func _ready():
    sql_tools.connect("sql_row_retrieved", self, "_check_row")

    connect("end_objective_intro", self, "_start_dialog")
    connect("end_dialog", self, "_start_level")

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
    
func _objective_comment_left(text, icon_path):
    var comment_scene = load("res://Base/LeftComment.tscn")
    var comment_node = comment_scene.instance()
    comment_node.get_node("Face").texture = load(icon_path)
    comment_node.get_node("Comment").text = text
    UI.dialog.add_child(comment_node)

func _objective_comment_right(text, icon_path):
    var comment_scene = load("res://Base/RightComment.tscn")
    var comment_node = comment_scene.instance()
    comment_node.get_node("Face").texture = load(icon_path)
    comment_node.get_node("Comment").text = text
    UI.dialog.add_child(comment_node)

func _preview_scene(period):
    anim.play("StartCutscene")
    # Without a delay the tab is not getting selected???
    yield(get_tree().create_timer(0.01), "timeout")
    UI.tab_container.set_current_tab(1)

func _start_dialog(dialog_array):
    for comment in dialog_array:
        var comment_scene
        if comment[0] == 'left':
            comment_scene = load("res://Base/LeftComment.tscn")
        else:
            comment_scene = load("res://Base/RightComment.tscn")

        var comment_node = comment_scene.instance()
        comment_node.get_node("Comment").text = comment[1]
        comment_node.get_node("Face").texture = load(comment[2])
        UI.dialog.add_child(comment_node)
        yield(get_tree().create_timer(comment[3]), "timeout")
    emit_signal("end_dialog")

func _start_level():
    anim.play("EndCutscene")
    UI.objectives.get_node('Out').visible = true

func _start_objective_intro():
    pass

func _show_objectives():
    if !objectives_shown:
        objectives_shown = true
        _start_objective_intro()
        