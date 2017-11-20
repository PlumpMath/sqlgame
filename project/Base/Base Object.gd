extends Spatial

var _id = 1
var _original_albedo_color

func _ready():
    _original_albedo_color = get_node("Base Mesh").get_surface_material(0).albedo_color

func set_id(id):
    _id = id

func on_select():
    var material = get_node("Base Mesh").get_surface_material(0)
    material.albedo_color = Color(1.0, 1.0, 0.0, 1.0)

func on_deselect():
    var material = get_node("Base Mesh").get_surface_material(0)
    material.albedo_color = _original_albedo_color

func on_update():
    print('updated')
    
func on_delete():
    print('deleted')

func _on_SQLTools_sql_row_retrieved(results, headings, clause):
    var id_index = headings.find('id')
    if (id_index != -1):
        var got_id = results[id_index]
        
        if (got_id == _id):
            if (clause == 'select'):
                on_select()
            elif (clause == 'update'):
                on_update()
            elif (clause == 'delete'):
                on_delete()

func _on_SQLTools_sql_start(sql, clause, max_rows):
	on_deselect()
