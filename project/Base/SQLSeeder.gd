extends Node

onready var level = get_parent()
onready var sql_tools = get_parent().get_node("SQLTools")

func _seed():
    # Seed parameters
    sql_tools.execute_raw("ATTACH 'SeedData.db' as SeedDb")
    
    level.connect("seeder_finished", self, "_seeder_finished")

func _seeder_finished():
    sql_tools.execute_raw("DETACH SeedDb")

func _set_max_rows(max_rows):
    # Use the SeedDb.Counter as a base table for creating seed data
    # The Counter must be >= than the max number of seed rows required
    var seeder_counter = sql_tools.execute_select("SELECT COUNT(*) FROM SeedDb.Counter", false).front().front()
    if seeder_counter < max_rows:
        sql_tools.inject_duplicates("INSERT INTO SeedDb.Counter VALUES (NULL)", [], max_rows - seeder_counter)
