package db;

class DatabaseResult<T> {
    public var database:IDatabase;
    public var table:ITable;
    public var data:T;

    public function new(database:IDatabase, table:ITable = null, data:T = null) {
        this.database = database;
        this.table = table;
        this.data = data;
    }
}