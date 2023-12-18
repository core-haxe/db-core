package db;

@:structInit
class TableSchema {
    @:optional public var name:String;
    @:optional public var columns:Array<ColumnDefinition> = [];
    @:optional public var data:Array<Record>;

    public function equals(other:TableSchema) {
        if (this.name != other.name) {
            return false;
        }

        if (this.columns.length != other.columns.length) {
            return false;
        }

        for (column in this.columns) {
            if (other.findColumn(column.name) == null) {
                return false;
            }
        }

        for (column in other.columns) {
            if (this.findColumn(column.name) == null) {
                return false;
            }
        }

        return true;
    }

    public function findColumn(name:String):ColumnDefinition {
        for (column in columns) {
            if (column.name == name) {
                return column;
            }
        }
        return null;
    }

    public function diff(other:TableSchema):TableSchemaDiff {
        var d = new TableSchemaDiff();

        for (column in this.columns) {
            if (other.findColumn(column.name) == null) {
                d.removedColumns.push(column);
            }
        }

        for (column in other.columns) {
            if (this.findColumn(column.name) == null) {
                d.addedColumns.push(column);
            }
        }

        return d;
    }

    public function clone():TableSchema {
        var c:TableSchema = {
            name: this.name,
            columns: []
        };
        c.name = this.name;
        for (col in this.columns) {
            c.columns.push(col.clone());
        }
        if (this.data != null) {
            c.data = this.data.copy();
        }
        return c;
    }

    public function debugString() {
        var sb = new StringBuf();
        sb.add(name);
        sb.add(":");
        sb.add("\n");
        for (column in columns) {
            sb.add("    ");
            sb.add(column.debugString());
            sb.add("\n");
        }
        return sb.toString();
    }
}