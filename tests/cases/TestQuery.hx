package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;

class TestQuery implements ITest {
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

    function testBasicQuery_VarColumn(async:Async) {
        var columnName = "personId";
        db.table("Person").then(result -> {
            return result.table.find(query(columnName = 1));
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

    function testBasicQuery_And_NoResults(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 && $personId = 2));
        }).then(result -> {
            Assert.equals(0, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_And_Results(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 && $firstName = "Ian" && $lastName = "Harrigan"));
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

    function testBasicQuery_Or_Results(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 || $personId = 2));
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
            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_AndOr_Results(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query(($personId = 1 || $personId = 2) && $firstName = "Ian" && $lastName = "Harrigan"));
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