extends "res://Base/SQLSeeder.gd"

func _ready():
    pass

func _seed():
    ._seed()
    _set_max_rows(level.max_rats)

    # Create Criminals table
    sql_tools.execute_raw("CREATE TABLE `LabRats` (" +
        "`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`nickname` TEXT NOT NULL," +
        "`eye_color` TEXT NOT NULL," +
        "`adrenaline` NUMERIC NOT NULL," +
        "`size` NUMERIC NOT NULL);")

    var result = sql_tools.execute_raw(
          "INSERT INTO LabRats"
        + "    SELECT"
        + "        NULL as id,"
        + "        first_name as nickname,"
        + "        colour as eye_color,"
        + "        (Random() % 1000 + 3000) / 3000.0 as adrenaline,"
        + "        (Random() % 1000 + 3000) / 5000.0 as size"
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

    var headings = ['id', 'nickname', 'eye_color', 'adrenaline', 'size']
    var rows = sql_tools.execute_select("SELECT * FROM LabRats",  false)
    for row in rows:
        level.states.process_row(row, 'LabRats', headings, 'insert')
    level.emit_signal("seeder_finished")