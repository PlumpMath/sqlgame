/* patchwork.h */
#ifndef SQLMODULE_H
#define SQLMODULE_H

#include "reference.h"

#include "core/array.h"
#include "external/sqlite3.h"

class SqlModule : public Reference {
    GDCLASS(SqlModule, Reference);

    sqlite3 *activeDb;
    sqlite3_stmt *preparedStatement;

protected:


    static void _bind_methods();

public:

    SqlModule();
    Variant openDatabase(String filename);
    Variant injectData(String sql, Array rows);
    Variant injectDuplicates(String sql, Array column_data, int count);

    Variant prepareStatement(String statement);
    Variant bindParameter(int position, Variant value);
    Variant executeInsert();
    Variant executeUpdate();
    Variant executeDelete();
    Variant executeGeneral();
    Variant getRow();
    Array getColumnNames();
    Variant finalizeStatement();
    Variant closeDatabase();
};

#endif
