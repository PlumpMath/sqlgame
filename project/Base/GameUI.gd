extends Control

onready var level_node = get_parent()
onready var sql_tools = get_parent().get_node("SQLTools")
onready var sql_editor = get_node("VBoxMain/HBoxBottom/SQLEdit")
onready var sql_info = get_node("VBoxMain/HBoxTop/DataColumn/ScrollInfo/InfoText")
onready var sql_errors = get_node("VBoxMain/HBoxTop/DataColumn/Errors/InfoText")
onready var item_list = get_node("VBoxMain/HBoxTop/DataColumn/ScrollTabular/ItemList")
onready var table_tree = get_node("VBoxMain/HBoxTop/DataColumn/Tree")
onready var tab_container = get_node("VBoxMain/HBoxTop/TabContainer")
onready var viewport_texture = tab_container.get_node("Scene")
onready var execute_button = get_node("VBoxMain/HBoxBottom/ExecuteButton")
onready var objectives = get_node("VBoxMain/HBoxTop/TabContainer/Objectives")
onready var dialog = objectives.get_node("DialogScroll/Dialog")
onready var popup = get_node("VBoxMain/HBoxTop/TabContainer/Scene/PopupPanel")


func _ready():
    # Handle signals
    sql_tools.connect("sql_start", self, "_start_statement")
    sql_tools.connect("sql_error", self, "_show_sql_error")
    sql_tools.connect("sql_headings_retrieved", self, "_insert_headings")
    sql_tools.connect("sql_row_retrieved", self, "_insert_row")
    sql_tools.connect("sql_complete", self, "_finish_statement")
    level_node.connect("message_updated", self, "_show_state_update")

    execute_button.disabled = true

    # Configure the viewport
    var viewport = get_parent().get_node("SceneVp")

    var window_size = OS.get_window_size()
    viewport.size.x = window_size.x
    viewport.size.y = window_size.y

    # Let two frames pass to make sure the screen was captured
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    viewport_texture.texture = viewport.get_texture()
    set_process(true)

func _on_ExecuteButton_pressed():
    # Show the scene
    if level_node._is_state("Failure"):
        level_node._set_state("Start")
        get_tree().reload_current_scene()
        return
    _execute_sql()

func _execute_sql():
    tab_container.set_current_tab(1)
    var sql = sql_editor.get_text()
    if (sql_tools.get_clause(sql) in ["delete", "select", "insert", "update"]):
        sql_tools.execute_select(sql)
        sql_editor._update_history()
        sql_editor._create_new_history()
    else:
        _show_sql_error('Not a valid or allowed SQL statement')

func _start_statement(sql, table, clause, max_rows):
    item_list.clear()

func _show_sql_error(error):
    sql_errors.set_text("Error: " + error)
    sql_info.get_parent().visible = false
    sql_errors.get_parent().visible = true
    yield(get_tree().create_timer(5), "timeout")
    sql_info.get_parent().visible = true
    sql_errors.get_parent().visible = false

func _insert_headings(table, headings, clause):
    var item_count = 0
    for heading in headings:
        if heading == "id" or heading.ends_with("_id"):
            continue
        item_list.add_item(String(heading))
        item_count += 1

    item_list.max_columns = item_count
    if item_count:
        item_list.fixed_column_width = (item_list.rect_size.x - 44) / item_count - 4;
    item_list.get_parent().visible = true

func _insert_row(row, table, headings, clause):
    var index = 0
    if headings[0] == "name" and row[0] == "id":
        return
    for value in row:
        if headings[index] == "id" or headings[index].ends_with("_id"):
            index += 1
            continue

        if value != null:
            item_list.add_item(String(value))
        else:
            item_list.add_item("")
        index += 1

func _finish_statement(sql, table, clause, row_count, max_rows):
    if row_count == max_rows:
        item_list.add_item("**Limited to")
        item_list.add_item(str(max_rows) + " rows")

func _show_state_update(message):
    sql_info.get_parent().visible = true
    sql_info.set_bbcode(message)

func _on_Tree_item_selected():
    pass

func _update_execute_button():
    # Check SQL clause
    if level_node._is_state("Failure"):
        return

    var clause = sql_tools.get_clause(sql_editor.get_text())
    if clause == "select":
        execute_button.disabled = false
        execute_button.theme = load("res://Base/Themes/SelectButton.tres")
        execute_button.text = "SELECT"
    elif clause == "delete":
        execute_button.disabled = false
        execute_button.theme = load("res://Base/Themes/DestructiveButton.tres")
        execute_button.text = "DELETE"
    elif clause == "update":
        execute_button.disabled = false
        execute_button.theme = load("res://Base/Themes/DestructiveButton.tres")
        execute_button.text = "UPDATE"
    elif clause == "insert":
        execute_button.disabled = false
        execute_button.theme = load("res://Base/Themes/DestructiveButton.tres")
        execute_button.text = "INSERT"
    else:
        execute_button.disabled = true
        execute_button.theme = load("res://Base/Themes/SelectButton.tres")
        execute_button.text = ""

func _on_SQLEdit_gui_input( ev ):
    sql_editor._update_history()
    if level_node._is_state("Failure"):
        return
    _update_execute_button()
    #if ev is InputEventKey and ev.get_scancode() == KEY_ENTER:
    #    if !ev.get_control():
    #        print ("Execute pressed")
    #        _on_ExecuteButton_pressed()

func _on_Out_meta_clicked( meta ):
    if meta == 'view_scene':
        tab_container.set_current_tab(1)

func _on_Tree_button_pressed( item, column, id ):
    if id == 0:
        level_node._table_show(item.get_text(column))
    elif id == 1:
        level_node._table_select(item.get_text(column))
        sql_editor._update_history()
        _update_execute_button()
    sql_editor.grab_focus()


func _on_TabContainer_tab_changed( tab ):
    if tab == 0:
        if !level_node.intro_started:
            level_node._run_intro()

func _on_UI_resized():
    var viewport = get_parent().get_node("SceneVp")
    var window_size = OS.get_window_size()
    viewport.size.x = window_size.x
    viewport.size.y = window_size.y
    var crt = get_parent().get_node("SceneVp/CRT Effect/CRT")
    if crt:
        crt.rect_size.x = viewport.size.x
        crt.rect_size.y = viewport.size.y
        crt.material.set_shader_param("screen_width", viewport.size.x)
        crt.material.set_shader_param("screen_height", viewport.size.y)