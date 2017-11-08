extends Control

var sql_client

func _ready():

    # Configure the viewport
    var viewport = get_node("SceneVp")
    var viewport_texture = get_node("MarginContainer/VBoxMain/HBoxTop/MainSceneTexture")    

    viewport.size.x = viewport_texture.rect_size.x
    viewport.size.y = viewport_texture.rect_size.y

    # Let two frames pass to make sure the screen was captured
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    viewport_texture.texture = viewport.get_texture()  
    set_process(true)

    sql_client = SqlModule.new()
    sql_client.create_database()

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        sql_client.close_database()

func _on_ExecuteButton_pressed():
    var sql_editor = get_node("MarginContainer/VBoxMain/HBoxBottom/SQLEdit")
    var item_list_panel = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/ScrollTabular")
    var item_list = item_list_panel.get_child(0)
    var sql_info_panel = get_node("MarginContainer/VBoxMain/HBoxTop/DataColumn/ScrollInfo")
    var sql_info = sql_info_panel.get_child(0)

    sql_info.set_text("Executing: " + sql_editor.get_text())
    sql_info_panel.visible = true
    item_list_panel.visible = false

    var result

    result = sql_client.prepare_statement(sql_editor.get_text())
    if (result != null):
        sql_info.set_text("Error: " + result)
        return

    var first = true
    while (1):
        result = sql_client.get_row()
        if (result.size() == 0):
            break

        if (first):
            var headings = sql_client.get_column_names()
            item_list_panel.visible = true
            item_list.max_columns = headings.size()
            item_list.fixed_column_width = (item_list.rect_size.x - 20) / headings.size() - 8;
            print(item_list.fixed_column_width)

            item_list.clear()
            for heading in headings:
                item_list.add_item(String(heading))
        for value in result:
            if value != null:
                item_list.add_item(String(value))
            else:
                item_list.add_item("")
                
        first = false

    var a = Array()

    if first:
        if typeof(result) == TYPE_STRING:
            sql_info.set_text("Error: " + result)
        else:
            sql_info.set_text(sql_info.get_text() + "\nDone")
    else:
        sql_info_panel.visible = false
                        
    result = sql_client.finalize_statement()
    if (result != null):
        sql_info.set_text("Error finalizing: " + result)
        sql_info_panel.visible = true
    sql_editor.set_text("")