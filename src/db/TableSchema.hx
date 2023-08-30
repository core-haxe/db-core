package db;

@:structInit
class TableSchema {
    @:optional public var name:String;
    @:optional public var columns:Array<ColumnDefinition> = [];

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
}