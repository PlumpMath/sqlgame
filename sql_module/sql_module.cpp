/* sql_module.cpp */

#include "sql_module.h"
#include "external/sqlite3.h"

SqlModule::SqlModule()
{
}


Variant SqlModule::openDatabase(String filename)
{
    int rc = sqlite3_open_v2(filename.ascii(), &activeDb, SQLITE_OPEN_READWRITE, NULL);

    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    return Variant();
}

Variant SqlModule::prepareStatement(String statement)
{
    int rc; // return code

    rc = sqlite3_prepare_v3(activeDb, statement.ascii(), -1, 0, &preparedStatement, NULL);

    // rc = sqlite3_prepare16_v3(activeDb, statement.c_str(), -1, 0, &preparedStatement, NULL);

    if (rc != SQLITE_OK) {
        return Variant(sqlite3_errmsg(activeDb));
    }

    return Variant();
}

Variant SqlModule::bindParameter(Variant value)
{
    int rc;

    // rc = sqlite3_bind_*(preparedStatement, -1, 0, &preparedStatement, NULL);

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
        return Variant(sqlite3_errmsg(activeDb));
    }

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
