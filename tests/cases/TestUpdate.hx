package cases;

import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.Test;
import Query.*;

class TestUpdate extends Test {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
        this.db = db;
    }

    function setupClass(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create(db).then(_ -> {
            async.done();
        });
    }

    function teardownClass(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        async.done();
    }

    function testBasicUpdate(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("Ian", result.data.field("firstName"));
            Assert.equals("Harrigan", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));

            var record = result.data;
            record.field("firstName", "IAN_MODIFIED");
            record.field("lastName", "HARRIGAN_MODIFIED");

            return result.table.update(query($personId = 1), record);
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("IAN_MODIFIED", result.data.field("firstName"));
            Assert.equals("HARRIGAN_MODIFIED", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));

            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("IAN_MODIFIED", result.data.field("firstName"));
            Assert.equals("HARRIGAN_MODIFIED", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));

        }).then(result -> {
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}