extends Control

onready var level_node = get_parent()
onready var sql_tools = get_parent().get_node("SQLTools")
onready var sql_editor = get_node("MarginContainer/VBoxMain/HBoxBottom/SQLEdit")
onready var sql_info = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/ScrollInfo/InfoText")
onready var item_list = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/ScrollTabular/ItemList")
onready var table_tree = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/Tree")

func _ready():
    
    # Handle signals
    sql_tools.connect("sql_start", self, "_start_statement")
    sql_tools.connect("sql_error", self, "_show_sql_error")
    sql_tools.connect("sql_headings_retrieved", self, "_insert_headings")
    sql_tools.connect("sql_row_retrieved", self, "_insert_row")
    sql_tools.connect("sql_complete", self, "_finish_statement")
    level_node.connect("state_updated", self, "_show_state_update")

    # Configure the viewport
    var viewport = get_parent().get_node("SceneVp")
    var viewport_texture = get_node("MarginContainer/VBoxMain/HBoxTop/MainSceneTexture")    

    viewport.size.x = viewport_texture.rect_size.x
    viewport.size.y = viewport_texture.rect_size.y

    # Let two frames pass to make sure the screen was captured
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    viewport_texture.texture = viewport.get_texture()  
    set_process(true)

func _on_ExecuteButton_pressed():
    var sql = sql_editor.get_text()
    if (sql_tools.get_clause(sql) in ["unknown", "delete", "select", "insert", "update"]):
        sql_tools.execute_select(sql)
    else:
        _show_sql_error('Not a valid or allowed SQL statement')

func _start_statement(sql, clause):
    sql_info.get_parent().visible = true
    item_list.get_parent().visible = false

func _show_sql_error(error):
    sql_info.set_text("Error: " + error)
    sql_info.get_parent().visible = true

func _insert_headings(headings, clause):
    # Initiate list
    item_list.clear()
    #print(item_list.fixed_column_width)

    var item_count = 0
    for heading in headings:
        if heading != "id" && !heading.ends_with("_id"):
            item_list.add_item(String(heading))
            item_count += 1
    item_list.max_columns = item_count
    if item_count:
        item_list.fixed_column_width = (item_list.rect_size.x - 20) / item_count - 8;
    item_list.get_parent().visible = true

func _insert_row(row, headings, clause):
    var index = 0
    for value in row:
        if headings[index] != "id" && !headings[index].ends_with("_id"):
            if value != null:
                item_list.add_item(String(value))
            else:
                item_list.add_item("")
        index += 1

func _finish_statement(sql, clause):
    pass

func _show_state_update(message):
    sql_info.get_parent().visible = true
    sql_info.set_text(message)

func _on_Tree_item_selected():
    sql_tools.describe_table("Criminals")
