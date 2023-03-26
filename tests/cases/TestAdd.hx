package cases;

import db.Record;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import db.IDatabase;
import utest.Test;

class TestAdd extends Test {
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

    function testBasicAdd(async:Async) {
        db.table("Person").then(result -> {
            var record = new Record();
            record.field("lastName", "new last name");
            record.field("firstName", "new first name");
            record.field("iconId", 1);
            return result.table.add(record);
        }).then(result -> {
            Assert.equals(5, result.data.field("_insertedId"));
            Assert.equals("new first name", result.data.field("firstName"));
            Assert.equals("new last name", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
    
}