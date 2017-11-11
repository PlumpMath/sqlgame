extends Node

onready var sql_tools = get_parent().get_node("SQLTools")
onready var level = get_parent()

export var max_criminals = 10000
onready var primary_criminal_id = (randi() % max_criminals) + 1

func _ready():
    # Seed parameters
    sql_tools.execute_raw("ATTACH 'SeedData.db' as SeedDb")

    # User the SeedDb.Counter as a base table for creating seed data
    # The Counter must be >= than the max number of seed rows required
    var seeder_counter = sql_tools.execute_select("SELECT COUNT(*) FROM SeedDb.Counter", false).front().front()
    if seeder_counter < max_criminals:
        sql_tools.inject_duplicates("INSERT INTO SeedDb.Counter VALUES (NULL)", [], max_criminals - seeder_counter)

    # Create Criminals table
    sql_tools.execute_raw("CREATE TABLE `Criminals` (" +
        "`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`first_name` TEXT NOT NULL," +
        "`last_name` TEXT NOT NULL," +
        "`shirt_colour` TEXT NOT NULL);")

    # Primary seeding query
    var result = sql_tools.execute_raw(
          "INSERT INTO Criminals"
        + "    SELECT"
        + "        NULL as id,"
        + "        first_name,"
        + "        last_name,"
        + "        colour as shirt_colour"
        + "    FROM ("
        + "        SELECT"
        + "            fn.first_name,"
        + "            ln.last_name,"
        + "            c.colour,"
        + "            ABS(Random() % fmax) AS random_fn,"
        + "            ABS(Random() % lmax) AS random_ln,"
        + "            ABS(Random() % cmax) AS random_c"
        + "        FROM "
        + "            SeedDb.Counter,"
        + "            (SELECT MAX(id) AS fmax FROM SeedDb.FirstNames),"
        + "            (SELECT MAX(id) AS lmax FROM SeedDb.LastNames),"
        + "            (SELECT MAX(id) AS cmax FROM SeedDb.Colours)"
        + "        LEFT JOIN SeedDb.FirstNames fn ON fn.id =  (random_fn * random_fn * random_fn / (fmax * fmax) + 1)"
        + "        LEFT JOIN SeedDb.LastNames ln ON ln.id = (random_ln * random_ln * random_ln / (lmax * lmax) + 1)"
        + "        LEFT JOIN SeedDb.Colours c ON c.id = random_c + 1"
        + "        LIMIT " + str(max_criminals)
        + "    );"
    )
    # Remove anyone with Royal red
    sql_tools.execute_raw("UPDATE Criminals SET shirt_colour = 'Rose red' WHERE shirt_colour = 'Royal red'")

    # Give our primary criminal a Royal red shirt
    sql_tools.execute_raw("UPDATE Criminals SET shirt_colour = 'Royal red' WHERE id = " + str(primary_criminal_id))

    sql_tools.execute_raw("detach SeedDb")

    var root = get_parent().get_node("UI").table_tree.create_item()
    root.set_text(0,"Criminals")
