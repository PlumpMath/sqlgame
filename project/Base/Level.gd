extends Node

signal message_updated
signal seeder_finished
signal end_objective_intro
signal end_dialog

onready var sql_tools = get_node("SQLTools")
onready var sql_seeder = get_node("SQLSeeder")
onready var states = get_node("States")
onready var UI = get_node("UI")
onready var anim = UI.get_node("AnimationPlayer")
onready var objectives_shown = false
onready var intro_started = false
onready var level_started = false

onready var state_history = Array()

onready var characters = {}
onready var dialog = []

func _ready():
    set_process(true)
    set_process_input(true)
    sql_seeder._seed()
    sql_tools.connect("sql_row_retrieved", self, "_check_row")
    sql_tools.connect("sql_headings_retrieved", self, "_check_headings")
    sql_tools.connect("sql_complete", self, "_finish_statement")

func scene_switcher_hide():
    get_node("UI").visible = false

func scene_switcher_show():
    get_node("UI").visible = true

func _input(ev):
    if ev is InputEventKey:
        if intro_started and !level_started: 
            if ev.get_scancode() == KEY_ESCAPE:
                print("Level Skip Start")
                _start_level()
        if ev.get_scancode() == KEY_E and ev.get_control():
            UI._execute_sql()

func _run_intro():
    intro_started = true
    _start_objective_intro()
    yield(self, "end_objective_intro")
    _start_dialog(characters, dialog)
    yield(self, "end_dialog")
    _start_level()

func _start_objective_intro():
    emit_signal("end_objective_intro")


func _check_headings(headings, clause):
    # Get current State
    var state_name = state_history.back()
    var state = states.get_node(state_name)
    if state.has_method("process_headings"):
        state.process_headings(headings, clause)
    if states.has_method("process_headings"):
        states.process_headings(headings, clause)

func _check_row(row, headings, clause):
    # Get current State
    var state_name = state_history.back()
    var state = states.get_node(state_name)
    if state.has_method("process_row"):
        state.process_row(row, headings, clause)
    if states.has_method("process_row"):
        states.process_row(row, headings, clause)

func _finish_statement(sql, clause, row_count, max_rows):
    # Get current State
    var state_name = state_history.back()
    var state = states.get_node(state_name)
    if state.has_method("finish_statement"):
        state.finish_statement(sql, clause, row_count, max_rows)
    if states.has_method("finish_statement"):
        states.finish_statement(sql, clause, row_count, max_rows)

func _set_state(new_state, message = null):
    if state_history.size() > 0 and state_history.back() == "Failure" and new_state != "Start":
        # No state change allowed..
        return
    var old_state
    if state_history.size() > 0:
        old_state = state_history.back()
    else:
        old_state = null

    var state = states.get_node(new_state)
    if state:
        state_history.push_back(new_state)
        state.enter_state(old_state, message)

func _get_state():
    state_history.back()

func _is_state(state):
    return state_history.size() and state == state_history.back()

func _set_message(message):
    if state_history.size() > 0 and state_history.back() == "Failure":
        # No message change allowed..
        return
    emit_signal("message_updated", message)

func _flash_popup(message):
    if state_history.size() > 0 and state_history.back() == "Failure":
        # No popup allowed..
        return
    UI.popup.get_node("Label").set_text(message)
    UI.popup.rect_size.x = 10 * message.length()
    UI.popup.popup()
    yield(get_tree().create_timer(4), "timeout")
    UI.popup.hide()
    
func _table_show(name):
    sql_tools.describe_table(name)

func _table_add(name):
    var sql = UI.sql_editor.get_text()
    if sql.ends_with(name):
        pass
    elif sql == "":
        UI.sql_editor.set_text("SELECT * FROM " + name)
    else:
        UI.sql_editor.insert_text_at_cursor(name)

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
    UI.objectives.get_node('Out').visible = true
    if !level_started:
        anim.play("EndCutscene")
        level_started = true
    yield(anim, "animation_finished")
    UI.sql_editor.grab_focus()
    _set_state("Start")

func _show_objectives():
    if !objectives_shown:
        objectives_shown = true
        _start_objective_intro()