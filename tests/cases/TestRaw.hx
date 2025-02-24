package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;

class TestRaw implements ITest {
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

    function testBasicRawQuery(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(raw("SELECT * FROM Person WHERE personId = 1"));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicRawQuery_SubstTableName(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(raw("SELECT * FROM $table WHERE personId = 1"));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}