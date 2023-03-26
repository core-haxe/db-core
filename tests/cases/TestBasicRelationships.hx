package cases;

import db.Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestBasicRelationships extends Test {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
        this.db = db;
    }

    function setupClass(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create(db, true).then(_ -> {
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
            Assert.equals(1, result.data.field("Person.personId"));
            Assert.equals("Ian", result.data.field("Person.firstName"));
            Assert.equals("Harrigan", result.data.field("Person.lastName"));
            Assert.equals(1, result.data.field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data.field("Person.Icon.path"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicAll(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            Assert.equals(1, result.data[0].field("Person.personId"));
            Assert.equals("Ian", result.data[0].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[0].field("Person.lastName"));
            Assert.equals(1, result.data[0].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[0].field("Person.Icon.path"));

            Assert.equals(3, result.data[2].field("Person.personId"));
            Assert.equals("Tim", result.data[2].field("Person.firstName"));
            Assert.equals("Mallot", result.data[2].field("Person.lastName"));
            Assert.equals(2, result.data[2].field("Person.iconId"));
            Assert.equals("/somepath/icon2.png", result.data[2].field("Person.Icon.path"));

            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}