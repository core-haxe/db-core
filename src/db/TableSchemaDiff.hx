package db;

class TableSchemaDiff {
    public var addedColumns:Array<ColumnDefinition> = [];
    public var removedColumns:Array<ColumnDefinition> = [];
    public var updatedColumns:Array<ColumnDefinition> = [];
    
    public function new() {
    }
}