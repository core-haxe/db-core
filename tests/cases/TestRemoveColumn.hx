package cases;

import db.ColumnType;
import db.DatabaseSchema;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.ITest;

class TestRemoveColumn implements ITest {
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

    function testBasicRemoveColumn(async:Async) {
        db.schema().then(result -> {
            Assert.notNull(result);

            var schema:DatabaseSchema = result.data;
            Assert.notNull(schema);
            Assert.notNull(schema.tables);
            Assert.equals(4, schema.tables.length);

            var personTable = schema.findTable("Person");
            Assert.notNull(personTable);
            Assert.equals(6, personTable.columns.length);
            Assert.equals("personId", personTable.findColumn("personId").name);
            Assert.equals("lastName", personTable.findColumn("lastName").name);
            Assert.equals("firstName", personTable.findColumn("firstName").name);
            Assert.equals("iconId", personTable.findColumn("iconId").name);
            Assert.equals("contractDocument", personTable.findColumn("contractDocument").name);
            Assert.equals("hourlyRate", personTable.findColumn("hourlyRate").name);

            var iconTable = schema.findTable("Icon");
            Assert.notNull(iconTable);
            Assert.equals(2, iconTable.columns.length);
            Assert.equals("iconId", iconTable.findColumn("iconId").name);
            Assert.equals("path", iconTable.findColumn("path").name);

            var organizationTable = schema.findTable("Organization");
            Assert.notNull(organizationTable);
            Assert.equals(3, organizationTable.columns.length);
            Assert.equals("organizationId", organizationTable.findColumn("organizationId").name);
            Assert.equals("name", organizationTable.findColumn("name").name);
            Assert.equals("iconId", organizationTable.findColumn("iconId").name);

            var personOrganizationTable = schema.findTable("Person_Organization");
            Assert.notNull(personOrganizationTable);
            Assert.equals(2, personOrganizationTable.columns.length);
            Assert.equals("Person_personId", personOrganizationTable.findColumn("Person_personId").name);
            Assert.equals("Organization_organizationId", personOrganizationTable.findColumn("Organization_organizationId").name);

            return db.table("Person");
        }).then(result -> {
            return result.table.removeColumn({
                name: "contractDocument",
                type: ColumnType.Binary
            });
        }).then(result -> {
            return db.schema();
        }).then(result -> {
            Assert.notNull(result);

            var schema:DatabaseSchema = result.data;
            Assert.notNull(schema);
            Assert.notNull(schema.tables);
            Assert.equals(4, schema.tables.length);

            var personTable = schema.findTable("Person");
            Assert.notNull(personTable);
            Assert.equals(5, personTable.columns.length);
            Assert.equals("personId", personTable.findColumn("personId").name);
            Assert.equals("lastName", personTable.findColumn("lastName").name);
            Assert.equals("firstName", personTable.findColumn("firstName").name);
            Assert.equals("iconId", personTable.findColumn("iconId").name);
            Assert.equals("hourlyRate", personTable.findColumn("hourlyRate").name);

            async.done();
        }, error -> {
            trace(haxe.Json.stringify(error));
            trace("error", error);
        });
    }
}