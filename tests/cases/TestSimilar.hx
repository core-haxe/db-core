package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;

class TestSimilar implements ITest {
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

    function testBasicSimilar(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($firstName =~ "ian"));
        }).then(result -> {
            Assert.equals("Ian", result.data.field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicSimilar_WildCard(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($firstName =~ "*a*"));
        }).then(result -> {
            Assert.equals("Ian", result.data.field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicSimilar_WildCardStart(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($firstName =~ "*b"));
        }).then(result -> {
            Assert.equals("Bob", result.data.field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicSimilar_WildCardEnd(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($firstName =~ "i*"));
        }).then(result -> {
            Assert.equals("Ian", result.data.field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
    
    function testBasicSimilar_WildCard_Multiple(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($firstName =~ "*i*"));
        }).then(result -> {
            Assert.equals(3, result.data.length);
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Tim", result.data[1].field("firstName"));
            Assert.equals("Jim", result.data[2].field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicSimilar_WildCard_Multiple_Or(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($firstName =~ "i*" || $firstName =~ "*b"));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Bob", result.data[1].field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicSimilar_WildCard_Multiple_Or_Nested(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query(($firstName =~ "i*" || $firstName =~ "*b") || $firstName = "Jim"));
        }).then(result -> {
            Assert.equals(3, result.data.length);
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Bob", result.data[1].field("firstName"));
            Assert.equals("Jim", result.data[2].field("firstName"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}