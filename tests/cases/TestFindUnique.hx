package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestFindUnique extends Test {
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

    function testBasicFindUnique(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.findUnique("firstName");
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.findUnique("iconId");
        }).then(result -> {
            Assert.equals(3, result.data.length);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFindUniqueWhere(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.findUnique("firstName", query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);

            return result.table.findUnique("iconId", query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFindUniqueWhere_Alt1(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.findUnique("firstName", query($personId = 1 || $personId = 2));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            return result.table.findUnique("iconId", query($personId = 1 || $personId = 2));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFindUniqueWhere_Alt2(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.findUnique("firstName", query($personId = 1 || $personId = 4));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            return result.table.findUnique("iconId", query($personId = 1 || $personId = 4));
        }).then(result -> {
            Assert.equals(1, result.data.length);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}