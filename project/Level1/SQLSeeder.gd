extends "res://Base/SQLSeeder.gd"

func _ready():

    _set_max_rows(level.max_criminals)
    
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
        + "        LIMIT " + str(level.max_criminals)
        + "    );"
    )
    # Remove anyone with Royal red
    sql_tools.execute_raw("UPDATE Criminals SET shirt_colour = 'Rose red' WHERE shirt_colour = 'Royal red'")

    # Give our primary criminal a Royal red shirt
    sql_tools.execute_raw("UPDATE Criminals SET shirt_colour = 'Royal red' WHERE id = " + str(level.primary_criminal_id))

    var root = get_parent().get_node("UI").table_tree.create_item()
    root.set_text(0,"Criminals")

    level.emit_signal("seeder_finished")