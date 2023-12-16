package db.importer;

@:structInit
class DatabaseImportOptions {
    @:optional public var tableOptions:Array<TableImportOptions>;
    @:optional public var structureOnly:Bool;

    public function getTableOptions(tableName:String):TableImportOptions {
        if (tableOptions == null) {
            return null;
        }

        for (t in tableOptions) {
            if (t.name == tableName) {
                return t;
            }
        }
        return null;
    }
}