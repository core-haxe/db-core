package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestQuery extends Test {
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

    function testBasicQuery(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryVar(async:Async) {
        var thePersonId = 1;
        db.table("Person").then(result -> {
            return result.table.find(query($personId = thePersonId));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_In(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId in [1]));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_InVar(async:Async) {
        var array = [1];
        db.table("Person").then(result -> {
            return result.table.find(query($personId in array));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}