package cases;

import db.Record;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.ITest;

class TestAdd implements ITest {
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

    function testBasicAdd(async:Async) {
        db.table("Person").then(result -> {
            var record = new Record();
            record.field("lastName", "new last name");
            record.field("firstName", "new first name");
            record.field("iconId", 1);
            record.field("hourlyRate", 999.777);
            return result.table.add(record);
        }).then(result -> {
            Assert.equals(5, result.data.field("_insertedId"));
            Assert.equals(5, result.data.field("personId"));
            Assert.equals("new first name", result.data.field("firstName"));
            Assert.equals("new last name", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.equals(999.777, result.data.field("hourlyRate"));
            Assert.equals(1, result.itemsAffected);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicAddAll(async:Async) {
        db.table("Person").then(result -> {
            var record1 = new Record();
            record1.field("lastName", "new last name1");
            record1.field("firstName", "new first name1");
            record1.field("iconId", 1);
            record1.field("hourlyRate", 999.777);

            var record2 = new Record();
            record2.field("lastName", "new last name2");
            record2.field("firstName", "new first name2");
            record2.field("iconId", 2);
            record2.field("hourlyRate", 111.333);
            
            return result.table.addAll([record1, record2]);
        }).then(result -> {
            Assert.equals(2, result.itemsAffected);

            Assert.equals(5, result.data[0].field("_insertedId"));
            Assert.equals(5, result.data[0].field("personId"));
            Assert.equals("new first name1", result.data[0].field("firstName"));
            Assert.equals("new last name1", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(999.777, result.data[0].field("hourlyRate"));

            Assert.equals(6, result.data[1].field("_insertedId"));
            Assert.equals(6, result.data[1].field("personId"));
            Assert.equals("new first name2", result.data[1].field("firstName"));
            Assert.equals("new last name2", result.data[1].field("lastName"));
            Assert.equals(2, result.data[1].field("iconId"));
            Assert.equals(111.333, result.data[1].field("hourlyRate"));

            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}