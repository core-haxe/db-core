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
            if (tables[i].name.toLowerCase() == name.toLowerCase()) {
                tables[i] = schema;
                break;
            }
        }
    }

    public function clone():DatabaseSchema {
        var c:DatabaseSchema = {
            tables: []
        };
        for (t in this.tables) {
            c.tables.push(t.clone());
        }
        return c;
    }

    public function debugString() {
        var sb = new StringBuf();
        for (table in tables) {
            sb.add(table.debugString());
        }
        return sb.toString();
    }
}