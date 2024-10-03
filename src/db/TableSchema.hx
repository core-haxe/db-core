package db;

#if (!macro && (dbcore_as_externs || (modular && !modular_host)))

@:structInit
extern class TableSchema {
    @:optional public var name:String;
    @:optional public var columns:Array<ColumnDefinition>;
    @:optional public var data:RecordSet;
    public function clone():TableSchema;
    public function debugString():String;
}

#else

@:keep @:expose
@:structInit
class TableSchema {
    @:optional public var name:String;
    @:optional public var columns:Array<ColumnDefinition> = [];
    @:optional public var data:RecordSet;

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

    public function findPrimaryKeyColumns():Array<ColumnDefinition> {
        var primaryKeyColumns = [];
        for (column in columns) {
            if (column.options != null && column.options.contains(PrimaryKey)) {
                primaryKeyColumns.push(column);
            }
        }
        return primaryKeyColumns;
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

#end