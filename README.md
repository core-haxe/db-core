<a href="https://github.com/core-haxe/db-core/actions/workflows/nodejs.yaml"><img src="https://github.com/core-haxe/db-core/actions/workflows/nodejs.yaml/badge.svg">
<a href="https://github.com/core-haxe/db-core/actions/workflows/hl.yaml"><img src="https://github.com/core-haxe/db-core/actions/workflows/hl.yaml/badge.svg">
<a href="https://github.com/core-haxe/db-core/actions/workflows/hxcpp.yaml"><img src="https://github.com/core-haxe/db-core/actions/workflows/hxcpp.yaml/badge.svg">
<a href="https://github.com/core-haxe/db-core/actions/workflows/neko.yaml"><img src="https://github.com/core-haxe/db-core/actions/workflows/neko.yaml/badge.svg">
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

# relationships example (one-to-one)

### 'Person' table:
| personId | firstName | lastName | iconId |
|----------|-----------|----------|--------|
| 1        | Bob       | Barker   | 2      |
| 2        | Ian       | Harrigan | 3      |

### 'Icon' table:
| iconId | path      |
|--------|-----------|
| 1      | icon1.png |
| 2      | icon2.png |
| 3      | icon3.png |

```haxe
db.defineTableRelationship("Person.iconId", "Icon.iconId");
db.connect().then(result -> {
    return result.database.table("Person");
}).then(result -> {
    return result.table.find(query($personId = 2));
}).then(result -> {
    printRecords(result.data);
    return null;
}, (error:DatabaseError) -> {
    // error
    return null;
});
```
### result:
| Person.personId | Person.firstName | Person.lastName | Person.iconId | Person.Icon.iconId | Person.Icon.path |
|-----------------|------------------|-----------------|---------------|--------------------|------------------|
| 2               | Ian              | Harrigan        | 3             | 3                  | icon3.png        |

# relationships example (one-to-many)

### 'Person' table:
| personId | firstName | lastName | iconId |
|----------|-----------|----------|--------|
| 1        | Bob       | Barker   | 2      |
| 2        | Ian       | Harrigan | 3      |

### 'Organization' table:
| organizationId | name     | iconId |
|----------------|----------|--------|
| 1              | haxeui   | 2      |
| 2              | acme org | 1      |
| 3              | inps     | 3      |

### 'Person_Organization' table:
| personId | organizationId |
|----------|----------------|
| 2        | 1              |
| 2        | 3              |
| 1        | 2              |

### 'Icon' table:
| iconId | path      |
|--------|-----------|
| 1      | icon1.png |
| 2      | icon2.png |
| 3      | icon3.png |

```haxe
db.defineTableRelationship("Person.personId", "Person_Organization.personId");
db.defineTableRelationship("Person.iconId", "Icon.iconId");
db.defineTableRelationship("Organization.organizationId", "Person_Organization.organizationId");
db.defineTableRelationship("Organization.iconId", "Icon.iconId");
db.connect().then(result -> {
    return result.database.table("Person");
}).then(result -> {
    return result.table.find(query($personId = 2));
}).then(result -> {
    printRecords(result.data);
    return null;
}, (error:DatabaseError) -> {
    // error
    return null;
});
```

### result:
| Person.personId | Person.firstName | Person.lastName | Person.iconId | Person.Icon.iconId | Person.Icon.path | Person.Person_Organization.personId | Person.Person_Organization.organizationId | Organization.organizationId | Organization.name | Organization.Icon.iconId | Organization.iconId | Organization.Icon.path |
|-----------------|------------------|-----------------|---------------|--------------------|------------------|-------------------------------------|-------------------------------------------|-----------------------------|-------------------|--------------------------|---------------------|------------------------|
| 2               | Ian              | Harrigan        | 3             | 3                  | icon3.png        | 2                                   | 1                                         | 1                           | haxeui            | 2                        | 2                   | icon2.png              |
| 2               | Ian              | Harrigan        | 3             | 3                  | icon3.png        | 2                                   | 3                                         | 3                           | inps              | 3                        | 3                   | icon3.png              |

# mysql

```haxe
var db:IDatabase = DatabaseFactory.instance.createDatabase(DatabaseFactory.MYSQL, {
    database: "somedb",
    host: "localhost",
    user: "someuser",
    pass: "somepassword"
});
```
_Note: must include [__db-mysql__](https://github.com/core-haxe/db-mysql) for plugin to be auto-registered_

# sqlite

```haxe
var db:IDatabase = DatabaseFactory.instance.createDatabase(DatabaseFactory.SQLITE, {
    filename: "somedb.db"
});
```
_Note: must include [__db-sqlite__](https://github.com/core-haxe/db-sqlite) for plugin to be auto-registered_
