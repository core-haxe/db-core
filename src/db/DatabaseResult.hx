package db;

class DatabaseResult<T> {
    public var database:IDatabase;
    public var table:ITable;
    public var data:T;
    public var itemsAffected:Null<Int> = null;

    public function new(database:IDatabase, table:ITable = null, data:T = null, itemsAffected:Null<Int> = null) {
        this.database = database;
        this.table = table;
        this.data = data;
        this.itemsAffected = itemsAffected;
    }
}