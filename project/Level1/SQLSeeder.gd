extends "res://Base/SQLSeeder.gd"

func _ready():

    _set_max_rows(level.max_rats)
    
    # Create Criminals table
    sql_tools.execute_raw("CREATE TABLE `LabRats` (" +
        "`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`nickname` TEXT NOT NULL," +
        "`colour` TEXT NOT NULL," +
        "`adrenaline` NUMERIC NOT NULL," +
        "`size` NUMERIC NOT NULL);")

    var result = sql_tools.execute_raw(
          "INSERT INTO LabRats"
        + "    SELECT"
        + "        NULL as id,"
        + "        first_name as nickname,"
        + "        colour,"
        + "        1 as adrenaline,"
        + "        1 as size"
        + "    FROM ("
        + "        SELECT"
        + "            fn.first_name,"
        + "            c.colour,"
        + "            ABS(Random() % fmax) AS random_fn,"
        + "            ABS(Random() % cmax) AS random_c"
        + "        FROM "
        + "            SeedDb.Counter,"
        + "            (SELECT MAX(id) AS fmax FROM SeedDb.FirstNames),"
        + "            (SELECT MAX(id) AS cmax FROM SeedDb.SimpleColours)"
        + "        LEFT JOIN SeedDb.FirstNames fn ON fn.id =  (random_fn * random_fn * random_fn / (fmax * fmax) + 1)"
        + "        LEFT JOIN SeedDb.SimpleColours c ON c.id = random_c + 1"
        + "        LIMIT " + str(level.max_rats)
        + "    );"
    )
    print(result)
    level.emit_signal("seeder_finished")