package cases;

import haxe.Json;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;
import db.exporter.JsonDatabaseExporter;

using StringTools;

class TestExport implements ITest {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        this.db = db;
    }

    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create(db).then(_ -> {
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
    
    function testExport_Json_All_String(async:Async) {
        var exporter = new JsonDatabaseExporter();
        exporter.exportToString(db).then(stringResult -> {
            Assert.notNull(stringResult);
            var json = Json.parse(stringResult);
            Assert.notNull(json.tables);
            Assert.equals(4, json.tables.length);

            // Icon table
            var jsonTable = findJsonTable("Icon", json.tables);
            Assert.notNull(jsonTable);
            Assert.equals("Icon".toLowerCase(), jsonTable.name.toLowerCase());
            assertJsonColumns(jsonTable.columns, [
                { name: "iconId", type: "Number", options: [] },
                { name: "path", type: "Text(50)", options: [] }
            ]);
            assertJsonData(jsonTable.data, [
                [1, "/somepath/icon1.png"],
                [2, "/somepath/icon2.png"],
                [3, "/somepath/icon3.png"]
            ]);

            // Organization table
            var jsonTable = findJsonTable("Organization", json.tables);
            Assert.notNull(jsonTable);
            Assert.equals("Organization".toLowerCase(), jsonTable.name.toLowerCase());
            assertJsonColumns(jsonTable.columns, [
                { name: "organizationId", type: "Number", options: [] },
                { name: "name", type: "Text(50)", options: [] },
                { name: "iconId", type: "Number", options: [] }
            ]);
            assertJsonData(jsonTable.data, [
                [1, "ACME Inc", 2],
                [2, "Haxe LLC", 1],
                [3, "PASX Ltd", 3]
            ]);

            // Person table
            var jsonTable = findJsonTable("Person", json.tables);
            Assert.notNull(jsonTable);
            Assert.equals("Person".toLowerCase(), jsonTable.name.toLowerCase());
            assertJsonColumns(jsonTable.columns, [
                { name: "personId", type: "Number", options: ["PrimaryKey", "AutoIncrement"] },
                { name: "lastName", type: "Text(50)", options: [] },
                { name: "firstName", type: "Text(50)", options: [] },
                { name: "iconId", type: "Number", options: [] },
                { name: "contractDocument", type: "Binary", options: [] },
                { name: "hourlyRate", type: "Decimal", options: [] },
            ]);
            assertJsonData(jsonTable.data, [
                [1, "Harrigan", "Ian", 1, "dGhpcyBpcyBpYW5zIGNvbnRyYWN0IGRvY3VtZW50", 111.222],
                [2, "Barker", "Bob", 3, null, 333.444],
                [3, "Mallot", "Tim", 2, null, 555.666],
                [4, "Parker", "Jim", 1, null, 777.888]
            ]);

            // Person_Organization table
            var jsonTable = findJsonTable("Person_Organization", json.tables);
            Assert.notNull(jsonTable);
            Assert.equals("Person_Organization".toLowerCase(), jsonTable.name.toLowerCase());
            assertJsonColumns(jsonTable.columns, [
                { name: "Person_personId", type: "Number", options: [] },
                { name: "Organization_organizationId", type: "Number", options: [] }
            ]);
            assertJsonData(jsonTable.data, [
                [1, 1],
                [2, 1],
                [3, 1],
                [2, 2],
                [4, 2],
                [1, 3],
                [4, 3]
            ]);

            async.done();
        }, error -> {
            Assert.fail(error);
            trace(error);
            async.done();
        });
    }

    function findJsonTable(tableName:String, tables:Array<Dynamic>):Dynamic {
        for (table in tables) {
            if (table.name.toLowerCase() == tableName.toLowerCase()) {
                return table;
            }
        }
        return null;
    }

    function assertJsonColumns(columns:Array<Dynamic>, expected:Array<Dynamic>) {
        Assert.equals(expected.length, columns.length);
        for (i in 0...columns.length) {
            var actualColumn = columns[i];
            var expectedColumn = expected[i];
            Assert.equals(expectedColumn.name, actualColumn.name);
            Assert.equals(expectedColumn.type, actualColumn.type);
            Assert.equals(expectedColumn.options.length, actualColumn.options.length);
            for (j in 0...expectedColumn.options.length) {
                var actualValue = actualColumn.options[j];
                var expectedValue = expectedColumn.options[j];
                Assert.equals(expectedValue, actualValue);
            }
        }
    }

    function assertJsonData(data:Array<Array<Any>>, expected:Array<Array<Any>>) {
        Assert.equals(expected.length, data.length);
        for (i in 0...data.length) {
            var actualData = data[i];
            var expectedData = data[i];
            Assert.equals(expectedData.length, actualData.length);
            for (j in 0...actualData.length) {
                var actualValue = actualData[j];
                var expectedValue = expectedData[j];
                Assert.equals(expectedValue, actualValue);
            }
        }
    }
    
}