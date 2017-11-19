/* sql_module.cpp */

#include "sql_module.h"
#include "external/sqlite3.h"

// SQLite extention functions
void sqlitePower(sqlite3_context *context, int argc, sqlite3_value **argv) {
    double num = sqlite3_value_double(argv[0]);
    double exp = sqlite3_value_double(argv[1]);
    double res = pow(num, exp);
    sqlite3_result_double(context, res);
}

SqlModule::SqlModule()
{
    preparedStatement = NULL;
    activeDb = NULL;
}


Variant SqlModule::openDatabase(String filename)
{
    int rc = sqlite3_open_v2(filename.ascii(), &activeDb, SQLITE_OPEN_READWRITE, NULL);

    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    int res = sqlite3_create_function(activeDb, "POW", 2, SQLITE_UTF8, NULL, &sqlitePower, NULL, NULL);

    return Variant();
}

Variant SqlModule::injectData(String sql, Array rows)
{
    int rc = sqlite3_prepare_v3(activeDb, sql.ascii(), -1, 0, &preparedStatement, NULL);
    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    for (int row = 0; row < rows.size(); ++row) {
        printf("NEXT ROW\n");

        if (rows[row].get_type() == Variant::ARRAY) {
            Array columns = rows[row];
            for (int col = 0; col < columns.size(); ++col) {
                rc = bindParameter(col + 1, columns[col]);
                if (rc != SQLITE_OK) {
                    return Variant(String("Error: ") + String(sqlite3_errmsg(activeDb)));
                }
            }
            Variant row_id = executeInsert();
            if (row_id.get_type() == Variant::STRING) {
                return row_id;
            }
            printf("INSERTD %d\n", (int)row_id);
            columns[0] = row_id;
        }
    }

    return finalizeStatement();
}

Variant SqlModule::injectDuplicates(String sql, Array column_data, int count)
{
    if (preparedStatement != NULL) {
        Variant(String("Previous statement not finalized."));
    }

    int rc = sqlite3_prepare_v3(activeDb, sql.ascii(), -1, 0, &preparedStatement, NULL);
    if (rc != SQLITE_OK) {
            return Variant(String("Error: ") + String(sqlite3_errmsg(activeDb)));
    }

    for (int col = 0; col < column_data.size(); ++col)
    {
        rc = bindParameter(col + 1, column_data[col]);
        if (rc != SQLITE_OK) {
            return Variant(String("Error: ") + String(sqlite3_errmsg(activeDb)));
        }
    }

    for (int row = 0; row < count; ++row) {
        rc = sqlite3_step(preparedStatement);

        if (rc != SQLITE_DONE) {
            return Variant(String("Error: ") + String(sqlite3_errmsg(activeDb)));
        }
    }

    return finalizeStatement();
}


Variant SqlModule::prepareStatement(String sql)
{
    int rc = sqlite3_prepare_v3(activeDb, sql.ascii(), -1, 0, &preparedStatement, NULL);

    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    return Variant();
}

Variant SqlModule::bindParameter(int position, Variant value)
{
    int rc;
    switch (value.get_type()) {
        case Variant::INT:
            printf("Bind INT %d\n", (int)value);
            sqlite3_bind_int(preparedStatement, position, (int)value);
            break;
        case Variant::STRING:
            printf("Bind String %s\n", ((String)value).ascii());
            sqlite3_bind_text(preparedStatement, position, ((String)value).ascii(), -1, NULL);
            break;
        case Variant::REAL:
            printf("Bind Double %f\n", (double)value);
            sqlite3_bind_double(preparedStatement, position, (double)value);
            break;
        default:
            printf("Bind NULL\n");
            sqlite3_bind_null(preparedStatement, position);
    }

    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    return Variant();
}

Array SqlModule::getColumnNames()
{
    int rc; // return code

    int count = sqlite3_data_count(preparedStatement);


    Array names;

    for (int iCol = 0; iCol < count; ++iCol) {

        Variant name = sqlite3_column_name(preparedStatement, iCol);

        names.push_back(name);
    }

    return names;
}

Variant SqlModule::executeInsert()
{
    executeGeneral();
    return Variant((int)sqlite3_last_insert_rowid(activeDb));
}

Variant SqlModule::executeUpdate()
{
    return executeGeneral();
}

Variant SqlModule::executeDelete()
{
    return executeGeneral();
}

Variant SqlModule::executeGeneral()
{
    int rc; // return code

    rc = sqlite3_step(preparedStatement);

    if (rc == SQLITE_ERROR) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    if (rc == SQLITE_MISUSE) {
        return Variant("Oops - misuse of SQLite3 Library. Our error not yours.");
    }

    if (rc == SQLITE_ROW) {
        return Variant("Rows returned");
    }

    if (rc != SQLITE_DONE) {
        return Variant();
    }

    return Variant((int)sqlite3_changes(activeDb));
}

Variant SqlModule::getRow()
{
    int rc; // return code

    rc = sqlite3_step(preparedStatement);

    if (rc == SQLITE_DONE) {
        return Variant();
    }

    if (rc == SQLITE_ERROR) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    if (rc == SQLITE_MISUSE) {
        return Variant("Oops - misuse of SQLite3 Library. Our error not yours.");
    }

    if (rc != SQLITE_ROW) {
        return Variant(String("Oops - we got an unexpected result from the SQL client. Code (%s)").sprintf(Array{Variant(rc)}, NULL));
    }

    Array results;

    int count = sqlite3_data_count(preparedStatement);

    for (int iCol = 0; iCol < count; ++iCol) {

        int column_type = sqlite3_column_type(preparedStatement, iCol);

        Variant result;

        switch (column_type) {
        case (SQLITE_INTEGER):
            result = (uint64_t)sqlite3_column_int64(preparedStatement, iCol);
            results.push_back(result);
            break;
        case (SQLITE_FLOAT):
            result = sqlite3_column_double(preparedStatement, iCol);
            results.push_back(result);
            break;
        case (SQLITE_TEXT):
            result = String((char *)sqlite3_column_text(preparedStatement, iCol));
            results.push_back(result);
            break;
        case (SQLITE_BLOB):
            result = String((char *)sqlite3_column_blob(preparedStatement, iCol));
            results.push_back(result);
            break;
        case (SQLITE_NULL):
            results.push_back(Variant());
            break;
        }
    }

    return results;
}

Variant SqlModule::finalizeStatement()
{

    int rc; // return code

    rc = sqlite3_finalize(preparedStatement);

    if (rc != SQLITE_OK) {
        preparedStatement = NULL;
        return Variant(sqlite3_errmsg(activeDb));
    }

    preparedStatement = NULL;
    return Variant();
}

Variant SqlModule::closeDatabase()
{
    int rc; // return code

    rc = sqlite3_close_v2(activeDb);

    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }
    return Variant();
}

void SqlModule::_bind_methods() {

    ClassDB::bind_method(D_METHOD("open_database", "filename"), &SqlModule::openDatabase, DEFVAL(String(":memory:")));
    ClassDB::bind_method(D_METHOD("inject_data", "sql", "rows"), &SqlModule::injectData);
    ClassDB::bind_method(D_METHOD("inject_duplicates", "sql", "column_data", "count"), &SqlModule::injectDuplicates);
    ClassDB::bind_method(D_METHOD("prepare_statement", "statement"), &SqlModule::prepareStatement);
    ClassDB::bind_method(D_METHOD("bind_parameter", "value"), &SqlModule::bindParameter);
    ClassDB::bind_method(D_METHOD("get_column_names"), &SqlModule::getColumnNames);
    ClassDB::bind_method(D_METHOD("execute_insert"), &SqlModule::executeInsert);
    ClassDB::bind_method(D_METHOD("execute_update"), &SqlModule::executeUpdate);
    ClassDB::bind_method(D_METHOD("execute_delete"), &SqlModule::executeDelete);
    ClassDB::bind_method(D_METHOD("execute_general"), &SqlModule::executeGeneral);
    ClassDB::bind_method(D_METHOD("get_row"), &SqlModule::getRow);
    ClassDB::bind_method(D_METHOD("finalize_statement"), &SqlModule::finalizeStatement);
    ClassDB::bind_method(D_METHOD("close_database"), &SqlModule::closeDatabase);
}
