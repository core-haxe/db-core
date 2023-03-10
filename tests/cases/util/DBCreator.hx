package cases.util;

import db.Record;
import db.IDatabase;
import sys.io.File;
import promises.Promise;

class DBCreator {
    public static function create(db:IDatabase, defineRelationships:Bool = false, createDummyData:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            File.saveContent("persons.db", "");
            db.connect().then(_ -> {
                return db.createTable("Person", [
                    {name: "personId", type: Number},
                    {name: "lastName", type: Text(50)},
                    {name: "firstName", type: Text(50)},
                    {name: "iconId", type: Number}
                ]);
            }).then(_ -> {
                return db.createTable("Icon", [
                    {name: "iconId", type: Number},
                    {name: "path", type: Text(50)}
                ]);
            }).then(_ -> {
                return db.createTable("Organization", [
                    {name: "organizationId", type: Number},
                    {name: "name", type: Text(50)},
                    {name: "iconId", type: Number}
                ]);
            }).then(_ -> {
                return db.createTable("Person_Organization", [
                    {name: "Person_personId", type: Number},
                    {name: "Organization_organizationId", type: Number}
                ]);
            }).then(_ -> {
                if (defineRelationships) {
                    db.defineTableRelationship("Person.iconId", "Icon.iconId");
                }
                if (createDummyData) {
                    addDummyData(db).then(_ -> {
                        resolve(true);
                    });
                } else {
                    resolve(true);
                }
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
                    Person(1, 'Ian', 'Harrigan', 1),
                    Person(2, 'Bob', 'Barker', 3),
                    Person(3, 'Tim', 'Mallot', 2),
                    Person(4, 'Jim', 'Parker', 1)
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

    private static function Person(personId:Int, firstName:String, lastName:String, iconId:Int):Record {
        var r = new Record();
        r.field("personId", personId);
        r.field("firstName", firstName);
        r.field("lastName", lastName);
        r.field("iconId", iconId);
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

    public static function delete() {
        //FileSystem.deleteFile("persons.db");
    }
}