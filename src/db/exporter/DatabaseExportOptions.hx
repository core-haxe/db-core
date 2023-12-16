package db.exporter;

@:structInit
class DatabaseExportOptions {
    @:optional public var tableNames:Array<String>;
    @:optional public var tableRegExp:String;
    @:optional public var tableOptions:Array<TableExportOptions>;
    @:optional public var structureOnly:Bool;

    public function getTableOptions(tableName:String):TableExportOptions {
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
