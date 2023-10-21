package cases;

import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.Test;
import Query.*;

class TestDeleteAll extends Test {
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
            Assert.equals(0, result.data.fieldNames.length);
            Assert.equals(null, result.data.field("personId"));
            Assert.equals(null, result.data.field("firstName"));
            Assert.equals(null, result.data.field("lastName"));
            Assert.equals(null, result.data.field("iconId"));
            return result.table.all();
        }).then(result -> {
            Assert.equals(3, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}