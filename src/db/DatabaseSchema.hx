package db;

@:structInit
class DatabaseSchema {
    @:optional public var tables:Array<TableSchema> = [];

    public function findTable(name:String):TableSchema {
        for (t in tables) {
            if (t.name.toLowerCase() == name.toLowerCase()) {
                return t;
            }
        }
        return null;
    }

    public function setTableSchema(name:String, schema:TableSchema) {
        for (i in 0...tables.length) {
            if (tables[i].name == name) {
                tables[i] = schema;
                break;
            }
        }
    }
}