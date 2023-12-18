package cases;

import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.ITest;
import Query.*;

class TestUpdate implements ITest {
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

    function testBasicUpdate(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("Ian", result.data.field("firstName"));
            Assert.equals("Harrigan", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.equals(111.222, result.data.field("hourlyRate"));

            var record = result.data;
            record.field("firstName", "IAN_MODIFIED");
            record.field("lastName", "HARRIGAN_MODIFIED");
            record.field("hourlyRate", 999.123);

            return result.table.update(query($personId = 1), record);
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("IAN_MODIFIED", result.data.field("firstName"));
            Assert.equals("HARRIGAN_MODIFIED", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.equals(999.123, result.data.field("hourlyRate"));

            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("IAN_MODIFIED", result.data.field("firstName"));
            Assert.equals("HARRIGAN_MODIFIED", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.equals(999.123, result.data.field("hourlyRate"));

        }).then(result -> {
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}