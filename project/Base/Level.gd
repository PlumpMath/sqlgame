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
var level_started = false

var state_history = Array()

var characters = {}
var dialog = []

func _ready():
    set_process(true)
    set_process_input(true)
    sql_seeder._seed()
    sql_tools.connect("sql_row_retrieved", self, "_check_row")

func _input(ev):
    if ev is InputEventKey and (ev.get_scancode() == KEY_SPACE or ev.get_scancode() == KEY_ESCAPE):
        if !level_started:
            print("Level Skip Start")
            _start_level()


func _run_intro():
    _start_objective_intro()
    yield(self, "end_objective_intro")
    _start_dialog(characters, dialog)
    yield(self, "end_dialog")
    _start_level()

func _start_objective_intro():
    emit_signal("end_objective_intro")

func _check_row(row, headings, clause):
    # Get current State
    var state_name = state_history[state_history.size() - 1]
    var state = states.get_node(state_name)
    if state.has_method("process_row"):
        state.process_row(row, headings, clause)
    if states.has_method("process_row"):
        states.process_row(row, headings, clause)

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

func _preview_scene():
    anim.play("StartCutscene")
    # Without a delay the tab is not getting selected???
    yield(get_tree().create_timer(0.01), "timeout")
    UI.tab_container.set_current_tab(1)

func _start_dialog(characters, dialog_array):
    var last_character = ''
    for comment in dialog_array:

        var animate_seconds = comment[1].length() / 20

        var comment_scene
        if characters[comment[0]][0] == 'left':
            comment_scene = load("res://Base/LeftComment.tscn")
        else:
            comment_scene = load("res://Base/RightComment.tscn")

        var comment_node = comment_scene.instance()
        comment_node.get_node("Comment").text = comment[1]
        # For the moment display duplicate icons
        # if comment[0] == last_character:
        comment_node.get_node("Avatar/Face").texture = load(characters[comment[0]][1])
        comment_node.get_node("Avatar/Label").text = comment[0]

        if level_started:
            animate_seconds = 0
        comment_node.get_node("AnimationPlayer").play("RevealComment", -1, 1/(animate_seconds + 0.001))

        UI.dialog.add_child(comment_node)
        yield(get_tree().create_timer(0.01), "timeout")

        last_character = comment[0]
        # AUTO SCROLL:
        var current_scroll = UI.objectives.get_node("DialogScroll").get_v_scroll()
        # Determine max scroll
        UI.objectives.get_node("DialogScroll").set_v_scroll(100000)
        if !level_started:
            var max_scroll = UI.objectives.get_node("DialogScroll").get_v_scroll()
            UI.objectives.get_node("DialogScroll").set_v_scroll(current_scroll)
            # Poors man's animate (cannot use animation for v_scroll)
            while current_scroll < max_scroll:
                current_scroll += 2
                UI.objectives.get_node("DialogScroll").set_v_scroll(current_scroll)
                yield(get_tree().create_timer(0.0005), "timeout")
    
            yield(get_tree().create_timer(animate_seconds + comment[2]), "timeout")
    emit_signal("end_dialog")

func _start_level():
    anim.play("EndCutscene")
    UI.objectives.get_node('Out').visible = true
    level_started = true

func _show_objectives():
    if !objectives_shown:
        objectives_shown = true
        _start_objective_intro()
        