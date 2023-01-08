# db-core
pluggable database abstraction

# basic usage

```haxe
db.connect().then(result -> ´
    return result.database.createTable("Persons", [
        {name: "PersonID", type: Number, options: [PrimaryKey, NotNull, AutoIncrement]},
        {name: "FirstName", type: Text(50), options: [NotNull]},
        {name: "LastName", type: Text(50), options: [NotNull]}
    ]);
}).then(result -> {
    var record = new Record();
    record.field("FirstName", "Ian");
    record.field("LastName", "Harrigan");
    return result.table.add(record);
}).then(result -> {
    DebugUtils.printRecords([result.data]);
    return resut.table.all();
}).then(result -> {
    DebugUtils.printRecords(result.data);
    return result.table.findOne(query($FirstName = "Ian" && $LastName = "Harrigan")); // "find" will return an array of records instead
}).then(result -> {
    DebugUtils.printRecords([result.data]);
    record.field("FirstName", "Ian_New");
    record.field("LastName", "Harrigan_New");
    return result.table.update(query($PersonID = result.data.field("PersonID"))), record);
}).then(result -> {
    DebugUtils.printRecords([result.data]);
    return result.table.deleteAll(); // query param can also be used for subset
}, (error:DatabaseError) -> {
    db.disconnect();
    // error
});
```

# db creation (MySql)

```haxe
var db:IDatabase = DatabaseFactory.createDatabase(DatabaseFactory.MYSQL, {
    database: "somedb",
    host: "localhost",
    user: "someuser",
    pass: "somepassword"
});
```
_Note: must include [__db-mysql__](https://github.com/core-haxe/db-mysql) for plugin to be auto-registered_

# db creation (Sqlite)

```haxe
var db:IDatabase = DatabaseFactory.createDatabase(DatabaseFactory.SQLITE, {filename: "somedb.db"});
```
_Note: must include [__db-sqlite__](https://github.com/core-haxe/db-sqlite) for plugin to be auto-registered_
