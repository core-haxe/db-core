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
            Assert.equals("new first name", result.data.field("firstName"));
            Assert.equals("new last name", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.equals(999.777, result.data.field("hourlyRate"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
    
}