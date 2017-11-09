extends Control

onready var sql_node = get_parent().get_node("SQLTools")
onready var sql_editor = get_node("MarginContainer/VBoxMain/HBoxBottom/SQLEdit")
onready var sql_info = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/ScrollInfo/InfoText")
onready var item_list = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/ScrollTabular/ItemList")

func _ready():
    
    # Handle signals
    sql_node.connect("sql_start", self, "_start_statement")
    sql_node.connect("sql_error", self, "_show_sql_error")
    sql_node.connect("sql_headings_retrieved", self, "_insert_headings")
    sql_node.connect("sql_row_retrieved", self, "_insert_row")
    sql_node.connect("sql_complete", self, "_finish_statement")

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
    if (sql_node.get_clause(sql) in ["delete", "select", "insert", "update"]):
        sql_node.execute_select(sql)
    else:
        _show_sql_error('Not a valid or allowed SQL statement')

func _start_statement(sql, clause):
    if (clause == "select"):
        sql_info.get_parent().visible = false
    else:
        sql_info.get_parent().visible = true
    item_list.get_parent().visible = false

func _show_sql_error(error):
    sql_info.set_text("Error: " + error)
    sql_info.get_parent().visible = true

func _insert_headings(headings, clause):
    # Initiate list
    item_list.clear()
    item_list.max_columns = headings.size()
    item_list.fixed_column_width = (item_list.rect_size.x - 20) / headings.size() - 8;
    print(item_list.fixed_column_width)

    for heading in headings:
        item_list.add_item(String(heading))
    item_list.get_parent().visible = true

func _insert_row(row, headings, clause):
    for value in row:
        if value != null:
            item_list.add_item(String(value))
        else:
            item_list.add_item("")    

func _finish_statement(sql, clause):
    pass
