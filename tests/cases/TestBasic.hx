package cases;

import db.Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestBasic extends Test {
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
    
    function testBasicFindOne(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("Ian", result.data.field("firstName"));
            Assert.equals("Harrigan", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            async.done();
        });
    }

    function testBasicAll(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));

            Assert.equals(3, result.data[2].field("personId"));
            Assert.equals("Tim", result.data[2].field("firstName"));
            Assert.equals("Mallot", result.data[2].field("lastName"));
            Assert.equals(2, result.data[2].field("iconId"));

            async.done();
        });
    }

    function testBasicFind(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            async.done();
        });
    }

    function testBasicFindOr(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 || $personId = 4));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));

            Assert.equals(4, result.data[1].field("personId"));
            Assert.equals("Jim", result.data[1].field("firstName"));
            Assert.equals("Parker", result.data[1].field("lastName"));
            Assert.equals(1, result.data[1].field("iconId"));

            async.done();
        });
    }

    function testBasicFindAnd(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 && $firstName = "Ian"));
        }).then(result -> {
            Assert.equals(1, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));

            async.done();
        });
    }
}