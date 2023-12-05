package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;

class TestCount implements ITest {
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

    function testBasicCount(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.count();
        }).then(result -> {
            Assert.equals(4, result.data);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicCountWhere(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.count(query($personId = 1 || $personId = 2));
        }).then(result -> {
            Assert.equals(2, result.data);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}