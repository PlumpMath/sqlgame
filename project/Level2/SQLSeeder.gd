extends "res://Base/SQLSeeder.gd"

func _ready():
    pass

func _seed():
    ._seed()
    _set_max_rows(level.max_passports)

    sql_tools.execute_raw("CREATE TABLE `PlaneParts` (" +
        "`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`part_name` TEXT NOT NULL);")

    sql_tools.execute_raw("INSERT INTO `PlaneParts` VALUES "
        + "    (1, 'Left Engine'),"
        + "    (2, 'Right Engine'),"
        + "    (3, 'Left Wing'),"
        + "    (4, 'Right Wing'),"
        + "    (5, 'Left Flaps'),"
        + "    (6, 'Right Flaps'),"
        + "    (7, 'Rudder'),"
        + "    (8, 'Elevators'),"
        + "    (9, 'Cockpit')")

    for i in range(level.max_seats):
        sql_tools.execute_raw("INSERT INTO `PlaneParts` VALUES (" + str(i + 10) + ", 'Seat" + str(i + 1) + "')")

    sql_tools.execute_raw("CREATE TABLE `Passports` (" +
        "`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`name` TEXT NOT NULL," +
        "`dob` TEXT NOT NULL," +
        "`occupation` TEXT NOT NULL," +
        "`issued` TEXT NOT NULL)")

    var result = sql_tools.execute_raw(
          "INSERT INTO Passports"
        + "    SELECT"
        + "        NULL as id,"
        + "        first_name || ' ' || last_name as name,"
        + "        datetime(strftime('%s', '1945-01-01 00:00:00') + (ABS(Random() % 1734700000)), 'unixepoch') as dob,"
        + "        occupation as occupation,"
        + "        datetime(strftime('%s', '2007-01-01 00:00:00') + (ABS(Random() % 315400000)), 'unixepoch') as issued"
        + "    FROM ("
        + "        SELECT"
        + "            fn.first_name,"
        + "            ln.last_name,"
        + "            o.occupation,"
        + "            ABS(Random() % fmax) AS random_fn,"
        + "            ABS(Random() % lmax) AS random_ln,"
        + "            ABS(Random() % cmax) AS random_o"
        + "        FROM "
        + "            SeedDb.Counter,"
        + "            (SELECT MAX(id) AS fmax FROM SeedDb.FirstNames),"
        + "            (SELECT MAX(id) AS lmax FROM SeedDb.LastNames),"
        + "            (SELECT MAX(id) AS cmax FROM SeedDb.Occupations)"
        + "        LEFT JOIN SeedDb.FirstNames fn ON fn.id =  (random_fn * random_fn * random_fn / (fmax * fmax) + 1)"
        + "        LEFT JOIN SeedDb.LastNames ln ON ln.id =  (random_ln * random_ln * random_ln / (lmax * lmax) + 1)"
        + "        LEFT JOIN SeedDb.Occupations o ON o.id = random_o + 1"
        + "        LIMIT " + str(level.max_passports)
        + "    );"
    )

    sql_tools.execute_raw("CREATE TABLE `Tickets` (" +
        "`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
        "`seat` TEXT NOT NULL," +
        "`person_name` TEXT NOT NULL," +
        "`dob` TEXT NOT NULL);")

    var tickets = []
    var primary_issued = "datetime(strftime('%s', '2007-01-01 00:00:00') + (" + str(randi() % 315400000) + "), 'unixepoch')"

    for passport_id in level.primary_passport_ids:
        var passport = sql_tools.execute_select("SELECT * FROM Passports WHERE id = " + str(passport_id), false)[0]
        tickets.push_back({
            "name": passport[1],
            "dob": passport[2],
            "order": randi()
        })
        sql_tools.execute_raw("UPDATE Passports SET issued = " + primary_issued + " WHERE id = " + str(passport_id))

    # Add others
    var other_passport_ids = []
    for index in range(level.max_seats - level.max_scientists):
        var id
        while (1):
            id = randi() % level.max_passports + 1
            if !(id in level.primary_passport_ids) and !(id in other_passport_ids):
                other_passport_ids.push_back(id)
                break

        var passport = sql_tools.execute_select("SELECT * FROM Passports WHERE id = " + str(id), false)[0]
        tickets.push_back({
            "name": passport[1],
            "dob": passport[2],
            "order": randi()
        })

    tickets.sort_custom(self, "_sort_tickets")
    # Add tickets
    var seat = 1
    for ticket in tickets:
        sql_tools.execute_raw("INSERT INTO `Tickets` (seat, person_name, dob) VALUES ('Seat" + str(seat) + "', '" + ticket["name"] + "', '" + ticket["dob"] + "')")
        seat += 1
    level.emit_signal("seeder_finished")

    # Get the primary place parts
    var primary_tickets = sql_tools.execute_select("SELECT * FROM Tickets WHERE person_name in (SELECT name FROM Passports WHERE issued = (SELECT issued FROM Passports GROUP BY issued HAVING count(issued) = 10 LIMIT 1))", false)
    for ticket in primary_tickets:
        level.primary_plane_part_names.push_back(ticket[1])

func _sort_tickets(ticket1, ticket2):
    return ticket1["order"] < ticket2["order"]