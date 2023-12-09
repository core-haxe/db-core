package cases;

import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.ITest;
import Query.*;

class TestDeleteAll implements ITest {
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

    function testBasicDelete(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("Ian", result.data.field("firstName"));
            Assert.equals("Harrigan", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            return result.table.deleteAll(query($personId = 1));
        }).then(result -> {
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.isNull(result.data);
            return result.table.all();
        }).then(result -> {
            Assert.equals(3, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}