package cases;

import cases.util.ExportData;
import haxe.io.Bytes;
import db.ColumnType;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;
import db.importer.JsonDatabaseImporter;
import cases.util.AssertionTools.*;

using StringTools;

class TestImport implements ITest {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        this.db = db;
    }

    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        // dont create the db with data or tables this time, since we'll be importing it
        DBCreator.create(db, false, false, false).then(_ -> {
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        db.disconnect().then(_ -> {
            DBCreator.cleanUp();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testImport_Json_All_String(async:Async) {
        var jsonString = ExportData.Persons;
        Assert.notNull(jsonString);
        Assert.isTrue(jsonString.length > 0);

        var importer = new JsonDatabaseImporter();
        importer.importFromString(db, jsonString).then(_ -> {
            return db.schema(true);
        }).then(result -> {
            var schema = result.data;
            assertTableSchema(schema.findTable("Icon"), "Icon", [
                {name: "iconId", type: ColumnType.Number, options: []},
                {name: "path", type: ColumnType.Text(50), options: []},
            ]);
            assertTableSchema(schema.findTable("Organization"), "Organization", [
                {name: "organizationId", type: ColumnType.Number, options: []},
                {name: "name", type: ColumnType.Text(50), options: []},
                {name: "iconId", type: ColumnType.Number, options: []},
            ]);
            assertTableSchema(schema.findTable("Person"), "Person", [
                {name: "personId", type: ColumnType.Number, options: [PrimaryKey, AutoIncrement]},
                {name: "lastName", type: ColumnType.Text(50), options: []},
                {name: "firstName", type: ColumnType.Text(50), options: []},
                {name: "iconId", type: ColumnType.Number, options: []},
                {name: "contractDocument", type: ColumnType.Binary, options: []},
                {name: "hourlyRate", type: ColumnType.Decimal, options: []},
            ]);
            assertTableSchema(schema.findTable("Person_Organization"), "Person_Organization", [
                {name: "Person_personId", type: ColumnType.Number, options: []},
                {name: "Organization_organizationId", type: ColumnType.Number, options: []},
            ]);

            // lets run some basic queries to verify import was alright
            return db.table("Icon");
        }).then(result -> {
            Assert.notNull(result.table);
            Assert.equals("Icon", result.table.name);
            return result.table.all();
        }).then(result -> {
            Assert.equals(3, result.data.length);
            assertRecordExists(["iconId" => 1, "path" => "/somepath/icon1.png"], result.data);
            assertRecordExists(["iconId" => 2, "path" => "/somepath/icon2.png"], result.data);
            assertRecordExists(["iconId" => 3, "path" => "/somepath/icon3.png"], result.data);
            return db.table("Organization");
        }).then(result -> {
            Assert.notNull(result.table);
            Assert.equals("Organization", result.table.name);
            return result.table.all();
        }).then(result -> {
            Assert.equals(3, result.data.length);
            assertRecordExists(["organizationId" => 1, "name" => "ACME Inc", "iconId" => 2], result.data);
            assertRecordExists(["organizationId" => 2, "name" => "Haxe LLC", "iconId" => 1], result.data);
            assertRecordExists(["organizationId" => 3, "name" => "PASX Ltd", "iconId" => 3], result.data);
            return db.table("Person");
        }).then(result -> {
            Assert.notNull(result.table);
            Assert.equals("Person", result.table.name);
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);
            assertRecordExists(["personId" => 1, "firstName" => "Ian", "lastName" => "Harrigan", "iconId" => 1, "contractDocument" => Bytes.ofString("this is ians contract document"), "hourlyRate" => 111.222], result.data);
            assertRecordExists(["personId" => 2, "firstName" => "Bob", "lastName" => "Barker", "iconId" => 3, "contractDocument" => null, "hourlyRate" => 333.444], result.data);
            assertRecordExists(["personId" => 3, "firstName" => "Tim", "lastName" => "Mallot", "iconId" => 2, "contractDocument" => null, "hourlyRate" => 555.666], result.data);
            assertRecordExists(["personId" => 4, "firstName" => "Jim", "lastName" => "Parker", "iconId" => 1, "contractDocument" => null, "hourlyRate" => 777.888], result.data);
            return db.table("Person_Organization");
        }).then(result -> {
            Assert.notNull(result.table);
            Assert.equals("Person_Organization", result.table.name);
            return result.table.all();
        }).then(result -> {
            Assert.equals(7, result.data.length);
            assertRecordExists(["Person_personId" => 1, "Organization_organizationId" => 1], result.data);
            assertRecordExists(["Person_personId" => 2, "Organization_organizationId" => 1], result.data);
            assertRecordExists(["Person_personId" => 3, "Organization_organizationId" => 1], result.data);
            assertRecordExists(["Person_personId" => 2, "Organization_organizationId" => 2], result.data);
            assertRecordExists(["Person_personId" => 4, "Organization_organizationId" => 2], result.data);
            assertRecordExists(["Person_personId" => 1, "Organization_organizationId" => 3], result.data);
            assertRecordExists(["Person_personId" => 4, "Organization_organizationId" => 3], result.data);
            async.done();
        }, error -> {
            Assert.fail(error);
            trace(error);
            async.done();
        });
    }
}