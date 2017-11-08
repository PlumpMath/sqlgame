/* register_types.cpp */

#include "register_types.h"
#include "class_db.h"
#include "sql_module.h"

void register_sql_module_types() {

        ClassDB::register_class<SqlModule>();
}

void unregister_sql_module_types() {
   //nothing to do here
}