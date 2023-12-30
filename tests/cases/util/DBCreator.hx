package cases.util;

import db.sqlite.SqliteDatabase;
import promises.PromiseUtils;
import haxe.io.Bytes;
import db.ColumnOptions;
import db.Record;
import db.IDatabase;
import sys.io.File;
import sys.FileSystem;
import promises.Promise;

class DBCreator {
    public static function create(db:IDatabase, defineRelationships:Bool = false, createDummyData:Bool = true, createTables:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if ((db is SqliteDatabase)) {
                File.saveContent("persons.db", "");
            }
            db.setProperty("autoReconnect", true);
            db.setProperty("replayQueriesOnReconnection", true);
            db.connect().then(_ -> {
                if ((db is SqliteDatabase)) {
                    return null;
                }
                return db.delete();
            }).then(_ -> {
                if ((db is SqliteDatabase)) {
                    return null;
                }
                return db.create();
            }).then(_ -> {
                if (createTables) {
                    return db.createTable("Person", [
                        {name: "personId", type: Number, options: [ColumnOptions.PrimaryKey, ColumnOptions.AutoIncrement]},
                        {name: "lastName", type: Text(50)},
                        {name: "firstName", type: Text(50)},
                        {name: "iconId", type: Number},
                        {name: "contractDocument", type: Binary},
                        {name: "hourlyRate", type: Decimal}
                    ]);
                }
                return null;
            }).then(_ -> {
                if (createTables) {
                    return db.createTable("Icon", [
                        {name: "iconId", type: Number},
                        {name: "path", type: Text(50)}
                    ]);
                }
                return null;
            }).then(_ -> {
                if (createTables) {
                    return db.createTable("Organization", [
                        {name: "organizationId", type: Number},
                        {name: "name", type: Text(50)},
                        {name: "iconId", type: Number}
                    ]);
                }
                return null;
            }).then(_ -> {
                if (createTables) {
                    return db.createTable("Person_Organization", [
                        {name: "Person_personId", type: Number},
                        {name: "Organization_organizationId", type: Number}
                    ]);
                } 
                return null;
            }).then(_ -> {
                if (defineRelationships) {
                    db.defineTableRelationship("Person.iconId", "Icon.iconId");
                    db.defineTableRelationship("Person.personId", "Person_Organization.Person_personId");
                    db.defineTableRelationship("Person_Organization.Organization_organizationId", "Organization.organizationId");
                } else {
                    db.clearTableRelationships();
                }
                if (createDummyData) {
                    addDummyData(db).then(_ -> {
                        resolve(true);
                    });
                } else {
                    resolve(true);
                }
            }, error -> {
                trace(haxe.Json.stringify(error));
                trace("error", error);
            });
        });
    }

    public static function addDummyData(db:IDatabase):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            db.table("Icon").then(result -> {
                return result.table.addAll([
                    Icon(1, '/somepath/icon1.png'),
                    Icon(2, '/somepath/icon2.png'),
                    Icon(3, '/somepath/icon3.png')
                ]);
            }).then(result -> {
                return db.table("Person");
            }).then(result -> {
                return result.table.addAll([
                    Person(1, 'Ian', 'Harrigan', 1, Bytes.ofString("this is ians contract document"), 111.222),
                    Person(2, 'Bob', 'Barker', 3, null, 333.444),
                    Person(3, 'Tim', 'Mallot', 2, null, 555.666),
                    Person(4, 'Jim', 'Parker', 1, null, 777.888)
                ]);
            }).then(result -> {
                return db.table("Organization");
            }).then(result -> {
                return result.table.addAll([
                    Organization(1, 'ACME Inc', 2),
                    Organization(2, 'Haxe LLC', 1),
                    Organization(3, 'PASX Ltd', 3)
                ]);
            }).then(result -> {
                return db.table("Person_Organization");
            }).then(result -> {
                return result.table.addAll([
                    Person_Organization(1, 1),
                    Person_Organization(2, 1),
                    Person_Organization(3, 1),
                    Person_Organization(2, 2),
                    Person_Organization(4, 2),
                    Person_Organization(1, 3),
                    Person_Organization(4, 3)
                ]);
            }).then(result -> {
                resolve(true);
            }, error -> {
                trace(haxe.Json.stringify(error));
                trace(error);
            });
        });
    }

    private static function Icon(iconId:Int, path:String):Record {
        var r = new Record();
        r.field("iconId", iconId);
        r.field("path", path);
        return r;
    }

    private static function Person(personId:Int, firstName:String, lastName:String, iconId:Int, contractDocument:Bytes, hourlyRate:Float):Record {
        var r = new Record();
        r.field("personId", personId);
        r.field("firstName", firstName);
        r.field("lastName", lastName);
        r.field("iconId", iconId);
        if (contractDocument != null) {
            r.field("contractDocument", contractDocument);
        }
        r.field("hourlyRate", hourlyRate);
        return r;
    }

    private static function Organization(organizationId:Int, name:String, iconId:Int):Record {
        var r = new Record();
        r.field("organizationId", organizationId);
        r.field("name", name);
        r.field("iconId", iconId);
        return r;
    }

    private static function Person_Organization(Person_personId:Int, Organization_organizationId:Int):Record {
        var r = new Record();
        r.field("Person_personId", Person_personId);
        r.field("Organization_organizationId", Organization_organizationId);
        return r;
    }

    public static function cleanUp() {
        try {
            if (FileSystem.exists("persons.db")) {
                FileSystem.deleteFile("persons.db");
            }
        } catch (e:Dynamic) {
            trace(e);
        }
    }
}