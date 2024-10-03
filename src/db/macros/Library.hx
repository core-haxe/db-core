package db.macros;

class Library {
    macro static function printInfo() {
        #if dbcore_as_externs
        Sys.println('db-core     > using db-core as externs (dbcore_as_externs)');
        #end
        #if (modular && !modular_host)
        Sys.println('db-core     > using db-core as externs (modular detected without modular-host)');
        #end
        return null;
    }
}