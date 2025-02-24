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

    function testBasicRawQuery_VarQuery(async:Async) {
        db.table("Person").then(result -> {
            var query = "SELECT * FROM Person WHERE personId = 1";
            return result.table.find(raw(query));
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

    function testBasicRawQuery_Join(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(raw("
                SELECT * FROM Person
                INNER JOIN Icon ON Person.iconId = Icon.IconId  
                WHERE personId = 1 or personId = 3;            
            "));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals("/somepath/icon1.png", result.data[0].field("path"));

            Assert.equals(3, result.data[1].field("personId"));
            Assert.equals("Tim", result.data[1].field("firstName"));
            Assert.equals("Mallot", result.data[1].field("lastName"));
            Assert.equals(2, result.data[1].field("iconId"));
            Assert.equals(555.666, result.data[1].field("hourlyRate"));
            Assert.equals(2, result.data[1].field("iconId"));
            Assert.equals("/somepath/icon2.png", result.data[1].field("path"));
            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}