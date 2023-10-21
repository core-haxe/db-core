package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestPaging extends Test {
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

    function testBasicPaging(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.page(0, 2);
        }).then(result -> {
            Assert.equals(2, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));

            Assert.equals(2, result.data[1].field("personId"));
            Assert.equals("Bob", result.data[1].field("firstName"));
            Assert.equals("Barker", result.data[1].field("lastName"));
            Assert.equals(3, result.data[1].field("iconId"));

            return result.table.page(1, 2);
        }).then(result -> {
            Assert.equals(2, result.data.length);

            Assert.equals(3, result.data[0].field("personId"));
            Assert.equals("Tim", result.data[0].field("firstName"));
            Assert.equals("Mallot", result.data[0].field("lastName"));
            Assert.equals(2, result.data[0].field("iconId"));

            Assert.equals(4, result.data[1].field("personId"));
            Assert.equals("Jim", result.data[1].field("firstName"));
            Assert.equals("Parker", result.data[1].field("lastName"));
            Assert.equals(1, result.data[1].field("iconId"));

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicPagingNonEven(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            return result.table.page(0, 3);
        }).then(result -> {
            Assert.equals(3, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));

            Assert.equals(2, result.data[1].field("personId"));
            Assert.equals("Bob", result.data[1].field("firstName"));
            Assert.equals("Barker", result.data[1].field("lastName"));
            Assert.equals(3, result.data[1].field("iconId"));

            Assert.equals(3, result.data[2].field("personId"));
            Assert.equals("Tim", result.data[2].field("firstName"));
            Assert.equals("Mallot", result.data[2].field("lastName"));
            Assert.equals(2, result.data[2].field("iconId"));

            return result.table.page(1, 3);
        }).then(result -> {
            Assert.equals(1, result.data.length);

            Assert.equals(4, result.data[0].field("personId"));
            Assert.equals("Jim", result.data[0].field("firstName"));
            Assert.equals("Parker", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));

            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}